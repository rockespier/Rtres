using System.Globalization;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

[ApiController, Route("api")]
public sealed class PaymentsController(RtresDbContext db, IPayPalClient payPal, PayPalCheckoutService checkoutService, PayPalPaymentService payments, INotificationSender notifications, IConfiguration configuration, ILogger<PaymentsController> logger) : ControllerBase
{
    /// <summary>Días antes del vencimiento en que se puede pagar la renovación (igual que el primer recordatorio por email).</summary>
    public const int RenewalWindowDays = 30;

    private IActionResult? ClientScope(Guid? requested, out Guid clientId)
    {
        clientId = Guid.Empty;
        if (User.IsInRole(nameof(UserRole.SuperAdmin))) { if (requested is not Guid value) return BadRequest(new { message = "clientId es obligatorio para SuperAdmin." }); clientId = value; return null; }
        return Guid.TryParse(User.FindFirstValue("client_id"), out clientId) ? null : Forbid();
    }

    [Authorize, HttpGet("catalog/products")]
    public async Task<IActionResult> Catalog(CancellationToken ct)
    {
        // Precios sin IGV; igvRate indica si a este cliente se le suma (Perú + Factura) para mostrar "+ IGV".
        var client = Guid.TryParse(User.FindFirstValue("client_id"), out var clientId) ? await db.Clients.SingleOrDefaultAsync(x => x.Id == clientId, ct) : null;
        var igvRate = await db.IgvRateAsync(ct);
        var products = await db.Products.Where(x => x.IsActive).OrderBy(x => x.Name).ToListAsync(ct);
        return Ok(products.Select(x => new { id = x.Id, type = x.Type, name = x.Name, billingCycle = x.BillingCycle, basePrice = x.BasePrice, currency = x.Currency, description = x.Description, category = x.Category, tags = x.Tags, allowsTickets = x.AllowsTickets, isActive = x.IsActive, igvRate = client is null ? 0m : ClientProductPricing.IgvRateFor(client, x, igvRate) }));
    }

    [Authorize(Roles = "Cliente,Admin"), HttpPost("subscriptions")]
    public async Task<IActionResult> Subscribe(SubscribeRequest request, CancellationToken ct)
    {
        var scope = ClientScope(null, out var clientId); if (scope is not null) return scope;
        var product = await db.Products.SingleOrDefaultAsync(x => x.Id == request.ProductId && x.IsActive, ct);
        if (product is null || !await db.Projects.AnyAsync(x => x.Id == request.ProjectId && x.ClientId == clientId, ct)) return NotFound();
        if (request.BillingCycle != product.BillingCycle) return BadRequest(new { message = "El ciclo debe coincidir con el producto seleccionado." });
        if (request.PaymentMethod is not (PaymentMethods.PayPal or PaymentMethods.Transferencia)) return BadRequest(new { message = "Método de pago inválido." });
        var transfer = request.PaymentMethod == PaymentMethods.Transferencia;
        var item = new ClientProduct { ClientId = clientId, ProjectId = request.ProjectId, ProductId = product.Id, Product = product, BillingCycle = request.BillingCycle, Status = ClientProductStatus.Pendiente, Price = product.BasePrice, IsManualBilling = transfer };
        if (item.ValidateYears(request.Years) is string yearsError) return BadRequest(new { message = yearsError });
        db.ClientProducts.Add(item);
        var igvRate = await db.IgvRateForAsync(clientId, product, ct);
        // Transferencia: queda Pendiente hasta que Rtres registre el pago (Detalle del cliente → Registrar pago).
        if (transfer)
        {
            await db.SaveChangesAsync(ct);
            await NotifyTransferRequestAsync(item, product, igvRate, request.Years, ct);
            return Ok(new { clientProductId = item.Id, approvalUrl = (string?)null, bankTransfer = BankTransferInfo(configuration, item, igvRate, request.Years) });
        }
        try { var checkout = await checkoutService.StartAsync(item, product, Request, ct, igvRate, request.Years); await db.SaveChangesAsync(ct); return Ok(new { clientProductId = item.Id, approvalUrl = checkout.ApprovalUrl }); } catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
    }

    /// <summary>Datos para pagar por transferencia (cuentas de <c>BankTransfer:Instructions</c>) y el monto a transferir por <paramref name="years"/> años.</summary>
    [Authorize, HttpGet("client-products/{id:guid}/bank-transfer")]
    public async Task<IActionResult> BankTransfer(Guid id, Guid? clientId, CancellationToken ct, int years = 1)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct);
        if (item?.Product is null) return NotFound();
        if (item.ValidateYears(years) is string yearsError) return BadRequest(new { message = yearsError });
        return Ok(BankTransferInfo(configuration, item, await db.IgvRateForAsync(owner, item.Product, ct), years));
    }

    /// <summary>
    /// Avisa a Rtres (<c>Notifications:StaffEmail</c>, o el remitente <c>Smtp:From</c> si no está) que hay un pedido por
    /// transferencia esperando el pago. Va por la cola como el resto de avisos: un SMTP caído no frena el pedido.
    /// </summary>
    private async Task NotifyTransferRequestAsync(ClientProduct item, Product product, decimal igvRate, int years, CancellationToken ct)
    {
        var staffEmail = configuration["Notifications:StaffEmail"] is { Length: > 0 } configured ? configured : configuration["Smtp:From"];
        if (string.IsNullOrWhiteSpace(staffEmail)) { logger.LogWarning("Pedido por transferencia {ClientProductId} sin aviso: falta Notifications:StaffEmail", item.Id); return; }
        var client = await db.Clients.SingleAsync(x => x.Id == item.ClientId, ct);
        var project = await db.Projects.Where(x => x.Id == item.ProjectId).Select(x => x.Name).SingleAsync(ct);
        var data = new Dictionary<string, string> { ["clientId"] = client.Id.ToString(), ["company"] = client.CompanyName, ["product"] = years > 1 ? $"{product.Name} ({years} años)" : product.Name, ["project"] = project, ["currency"] = product.Currency };
        if (item.ChargeTotal(igvRate, years) is decimal amount) data["amount"] = amount.ToString(CultureInfo.InvariantCulture);
        await notifications.SendAsync(client, new Notification(NotificationType.TransferRequested, data, $"transfer-request:{item.Id}", staffEmail), ct);
    }

    internal static object BankTransferInfo(IConfiguration configuration, ClientProduct item, decimal igvRate, int years = 1) => new
    {
        instructions = configuration["BankTransfer:Instructions"] ?? "",
        amount = item.ChargeTotal(igvRate, years),
        years,
        currency = item.Product?.Currency ?? "USD",
        includesIgv = igvRate > 0,
    };

    [Authorize(Roles = "Cliente,Admin"), HttpPost("client-products/{id:guid}/renew")]
    public async Task<IActionResult> Renew(Guid id, Guid? clientId, CancellationToken ct, int years = 1)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct);
        if (item?.Product is null) return NotFound();
        // Renovar (Anual por vencer o vencido; el pago único no se renueva) o reintentar un pago que quedó a medias (Pendiente, cualquier ciclo).
        var renewable = item.BillingCycle == BillingCycle.Anual && (item.Status is ClientProductStatus.PorVencer or ClientProductStatus.Vencido || item.RenewsAt <= DateTime.UtcNow.AddDays(RenewalWindowDays));
        if (item.IsManualBilling || !(renewable || item.Status == ClientProductStatus.Pendiente)) return BadRequest(new { message = "Este producto no se puede renovar en línea." });
        try { var checkout = await checkoutService.StartAsync(item, item.Product, Request, ct, await db.IgvRateForAsync(owner, item.Product, ct), years); await db.SaveChangesAsync(ct); return Ok(new { approvalUrl = checkout.ApprovalUrl }); } catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
    }

    [Authorize(Roles = "Cliente,Admin"), HttpPost("client-products/{id:guid}/cancel")]
    public async Task<IActionResult> Cancel(Guid id, Guid? clientId, CancellationToken ct)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct);
        if (item is null) return NotFound();
        if (item.IsManualBilling || item.Status != ClientProductStatus.Activo || !item.BillingCycle.IsSubscription() || string.IsNullOrWhiteSpace(item.PayPalSubscriptionId)) return BadRequest(new { message = "Este producto no tiene una suscripción cancelable." });
        await payPal.CancelSubscriptionAsync(item.PayPalSubscriptionId, "Cancelada por el cliente desde el portal Rtres.", ct); item.Status = ClientProductStatus.Cancelado; await db.SaveChangesAsync(ct); return Ok();
    }

    /// <summary>La llama la pantalla de retorno de PayPal: captura el cobro sin esperar al webhook (idempotente con él).</summary>
    [Authorize(Roles = "Cliente,Admin"), HttpPost("client-products/{id:guid}/capture")]
    public async Task<IActionResult> Capture(Guid id, Guid? clientId, CancellationToken ct)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct);
        if (item is null) return NotFound();
        try { await payments.ConfirmAsync(item, ct); }
        catch (HttpRequestException ex) { logger.LogWarning(ex, "Captura de {ClientProductId} fallida; queda a la espera del webhook", id); }
        return Ok(new { status = item.Status.ToString() });
    }

    [Authorize(Roles = "Cliente,Admin"), HttpGet("client-products/{id:guid}")]
    public async Task<IActionResult> ClientProduct(Guid id, Guid? clientId, CancellationToken ct)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.Include(x => x.Product).Include(x => x.Project).SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct); return item is null ? NotFound() : Ok(item);
    }

    [HttpPost("payments/webhooks/paypal")]
    public async Task<IActionResult> Webhook(CancellationToken ct)
    {
        using var reader = new StreamReader(Request.Body); var payload = await reader.ReadToEndAsync(ct); var headers = Request.Headers.ToDictionary(x => x.Key.ToLowerInvariant(), x => x.Value.ToString());
        if (!await payPal.VerifyWebhookAsync(payload, headers, ct)) return Unauthorized();
        using var json = JsonDocument.Parse(payload); var root = json.RootElement; var eventType = Find(root, "event_type"); if (!root.TryGetProperty("resource", out var resource)) return Ok();
        var resourceId = Find(resource, "id"); var orderId = Nested(resource, "supplementary_data", "related_ids", "order_id") ?? resourceId; var customId = Find(resource, "custom_id") ?? Find(resource, "custom") ?? Find(root, "custom_id") ?? PurchaseUnit(resource, "custom_id");
        // En los cobros de una suscripción, el recurso es la venta y la suscripción viene en billing_agreement_id.
        var subscriptionId = Find(resource, "billing_agreement_id") ?? resourceId;
        ClientProduct? item = Guid.TryParse(customId, out var customGuid) ? await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == customGuid, ct) : null;
        item ??= !string.IsNullOrWhiteSpace(orderId) ? await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.PayPalSubscriptionId == subscriptionId || x.PayPalOrderId == orderId, ct) : null;
        if (item is null) return Ok();
        if (eventType is "BILLING.SUBSCRIPTION.ACTIVATED" or "BILLING.SUBSCRIPTION.CANCELLED") { item.Status = eventType.EndsWith("ACTIVATED") ? ClientProductStatus.Activo : ClientProductStatus.Cancelado; item.PayPalSubscriptionId ??= resourceId; }
        // Aprobar no es cobrar: con la orden aprobada se captura aquí (idempotente con la captura de la pantalla de retorno).
        if (eventType is "CHECKOUT.ORDER.APPROVED") { item.PayPalOrderId ??= orderId; await db.SaveChangesAsync(ct); await payments.CaptureAsync(item, ct); }
        // Cobro confirmado: el pago se aplica una sola vez por orden (o por venta, en suscripciones).
        if (eventType is "PAYMENT.CAPTURE.COMPLETED" or "PAYMENT.SALE.COMPLETED" && Amount(resource) is (decimal amount, var currency) && orderId is not null)
            await payments.ApplyPaymentAsync(item, orderId, amount, currency, ct);
        Notification? failure = null;
        if (eventType is "PAYMENT.CAPTURE.DENIED" or "PAYMENT.SALE.DENIED" or "BILLING.SUBSCRIPTION.PAYMENT.FAILED")
            failure = new Notification(NotificationType.PaymentFailed, new() { ["product"] = item.Product?.Name ?? "" }, $"payment-failed:{Find(root, "id") ?? resourceId}");
        await db.SaveChangesAsync(ct);
        if (failure is not null && await db.Clients.FindAsync([item.ClientId], ct) is Client client) await notifications.SendAsync(client, failure, ct);
        return Ok();
    }

    private static string? Find(JsonElement value, string property) => value.TryGetProperty(property, out var item) && item.ValueKind == JsonValueKind.String ? item.GetString() : null;
    private static string? Nested(JsonElement value, params string[] path) { foreach (var property in path) { if (!value.TryGetProperty(property, out value)) return null; } return value.ValueKind == JsonValueKind.String ? value.GetString() : null; }
    private static string? PurchaseUnit(JsonElement resource, string property) => resource.TryGetProperty("purchase_units", out var units) && units.ValueKind == JsonValueKind.Array && units.GetArrayLength() > 0 ? Find(units[0], property) : null;
    private static (decimal? amount, string? currency) Amount(JsonElement resource)
    {
        // Órdenes/capturas: amount.value + currency_code. Ventas de suscripción (PAYMENT.SALE.*): amount.total + currency.
        foreach (var name in new[] { "amount", "gross_amount" }) if (resource.TryGetProperty(name, out var value) && (value.TryGetProperty("value", out var amount) || value.TryGetProperty("total", out amount)) && decimal.TryParse(amount.GetString(), System.Globalization.NumberStyles.Number, System.Globalization.CultureInfo.InvariantCulture, out var parsed)) return (parsed, Find(value, "currency_code") ?? Find(value, "currency"));
        if (resource.TryGetProperty("purchase_units", out var units) && units.ValueKind == JsonValueKind.Array && units.GetArrayLength() > 0) return Amount(units[0]);
        return (null, null);
    }
}

public sealed record SubscribeRequest(Guid ProductId, Guid ProjectId, BillingCycle BillingCycle, string PaymentMethod = PaymentMethods.PayPal, int Years = 1);
