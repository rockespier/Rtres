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
public sealed class PaymentsController(RtresDbContext db, IPayPalClient payPal, PayPalCheckoutService checkoutService, INotificationSender notifications) : ControllerBase
{
    private IActionResult? ClientScope(Guid? requested, out Guid clientId)
    {
        clientId = Guid.Empty;
        if (User.IsInRole(nameof(UserRole.SuperAdmin))) { if (requested is not Guid value) return BadRequest(new { message = "clientId es obligatorio para SuperAdmin." }); clientId = value; return null; }
        return Guid.TryParse(User.FindFirstValue("client_id"), out clientId) ? null : Forbid();
    }

    [Authorize, HttpGet("catalog/products")]
    public async Task<IActionResult> Catalog(CancellationToken ct) => Ok(await db.Products.Where(x => x.IsActive).OrderBy(x => x.Name).Select(x => new { id = x.Id, type = x.Type, name = x.Name, billingCycle = x.BillingCycle, basePrice = x.BasePrice, currency = x.Currency, description = x.Description, isActive = x.IsActive }).ToListAsync(ct));

    [Authorize(Roles = "Cliente,Admin"), HttpPost("subscriptions")]
    public async Task<IActionResult> Subscribe(SubscribeRequest request, CancellationToken ct)
    {
        var scope = ClientScope(null, out var clientId); if (scope is not null) return scope;
        var product = await db.Products.SingleOrDefaultAsync(x => x.Id == request.ProductId && x.IsActive, ct);
        if (product is null || !await db.Projects.AnyAsync(x => x.Id == request.ProjectId && x.ClientId == clientId, ct)) return NotFound();
        if (request.BillingCycle != product.BillingCycle) return BadRequest(new { message = "El ciclo debe coincidir con el producto seleccionado." });
        var item = new ClientProduct { ClientId = clientId, ProjectId = request.ProjectId, ProductId = product.Id, Product = product, BillingCycle = request.BillingCycle, Status = ClientProductStatus.Pendiente, Price = product.BasePrice };
        db.ClientProducts.Add(item);
        try { var checkout = await checkoutService.StartAsync(item, product, ct); await db.SaveChangesAsync(ct); return Ok(new { clientProductId = item.Id, approvalUrl = checkout.ApprovalUrl }); } catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
    }

    [Authorize(Roles = "Cliente,Admin"), HttpPost("client-products/{id:guid}/renew")]
    public async Task<IActionResult> Renew(Guid id, Guid? clientId, CancellationToken ct)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct);
        if (item?.Product is null) return NotFound();
        if (item.IsManualBilling || item.BillingCycle is not (BillingCycle.Anual or BillingCycle.Unico) || item.Status is not (ClientProductStatus.PorVencer or ClientProductStatus.Vencido)) return BadRequest(new { message = "Este producto no se puede renovar en línea." });
        try { var checkout = await checkoutService.StartAsync(item, item.Product, ct); await db.SaveChangesAsync(ct); return Ok(new { approvalUrl = checkout.ApprovalUrl }); } catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
    }

    [Authorize(Roles = "Cliente,Admin"), HttpPost("client-products/{id:guid}/cancel")]
    public async Task<IActionResult> Cancel(Guid id, Guid? clientId, CancellationToken ct)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct);
        if (item is null) return NotFound();
        if (item.IsManualBilling || item.Status != ClientProductStatus.Activo || item.BillingCycle != BillingCycle.Mensual || string.IsNullOrWhiteSpace(item.PayPalSubscriptionId)) return BadRequest(new { message = "Este producto no tiene una suscripción cancelable." });
        await payPal.CancelSubscriptionAsync(item.PayPalSubscriptionId, "Cancelada por el cliente desde el portal Rtres.", ct); item.Status = ClientProductStatus.Cancelado; await db.SaveChangesAsync(ct); return Ok();
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
        var resourceId = Find(resource, "id"); var orderId = Nested(resource, "supplementary_data", "related_ids", "order_id") ?? resourceId; var customId = Find(resource, "custom_id") ?? Find(root, "custom_id") ?? PurchaseUnit(resource, "custom_id");
        ClientProduct? item = Guid.TryParse(customId, out var customGuid) ? await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == customGuid, ct) : null;
        item ??= !string.IsNullOrWhiteSpace(orderId) ? await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.PayPalSubscriptionId == resourceId || x.PayPalOrderId == orderId, ct) : null;
        if (item is null) return Ok();
        if (eventType is "BILLING.SUBSCRIPTION.ACTIVATED" or "BILLING.SUBSCRIPTION.CANCELLED") { item.Status = eventType.EndsWith("ACTIVATED") ? ClientProductStatus.Activo : ClientProductStatus.Cancelado; item.PayPalSubscriptionId ??= resourceId; }
        if (eventType is "PAYMENT.CAPTURE.COMPLETED" or "CHECKOUT.ORDER.APPROVED") { item.PayPalOrderId ??= orderId; item.Status = ClientProductStatus.Activo; item.RenewsAt = (item.RenewsAt ?? DateTime.UtcNow).AddYears(1); }
        Notification? notification = null;
        if (eventType is "PAYMENT.SALE.COMPLETED" or "PAYMENT.CAPTURE.COMPLETED")
        {
            var (amount, currency) = Amount(resource); var transactionId = orderId ?? item.PayPalSubscriptionId ?? item.PayPalOrderId ?? item.Id.ToString();
            if (amount is decimal value && !await db.PaymentTransactions.AnyAsync(x => x.PayPalOrderIdOrSubscriptionId == transactionId, ct))
            {
                var transaction = new PaymentTransaction { ClientProductId = item.Id, PayPalOrderIdOrSubscriptionId = transactionId, Amount = value, Currency = currency ?? item.Product?.Currency ?? "USD", Status = "COMPLETED" };
                transaction.InternalCode = $"RT-INT-{1 + await db.PaymentTransactions.CountAsync(ct):000000}";
                transaction.AmountPen = value * await db.RateToPenAsync(transaction.Currency, DateOnly.FromDateTime(transaction.CreatedAt), ct);
                db.PaymentTransactions.Add(transaction);
                notification = new Notification(NotificationType.PaymentReceived, new() { ["product"] = item.Product?.Name ?? "", ["amount"] = value.ToString(CultureInfo.InvariantCulture), ["currency"] = transaction.Currency }, $"payment:{transactionId}");
            }
        }
        if (eventType is "PAYMENT.CAPTURE.DENIED" or "PAYMENT.SALE.DENIED" or "BILLING.SUBSCRIPTION.PAYMENT.FAILED")
            notification = new Notification(NotificationType.PaymentFailed, new() { ["product"] = item.Product?.Name ?? "" }, $"payment-failed:{Find(root, "id") ?? resourceId}");
        await db.SaveChangesAsync(ct);
        if (notification is not null && await db.Clients.FindAsync([item.ClientId], ct) is Client client) await notifications.SendAsync(client, notification, ct);
        return Ok();
    }

    private static string? Find(JsonElement value, string property) => value.TryGetProperty(property, out var item) && item.ValueKind == JsonValueKind.String ? item.GetString() : null;
    private static string? Nested(JsonElement value, params string[] path) { foreach (var property in path) { if (!value.TryGetProperty(property, out value)) return null; } return value.ValueKind == JsonValueKind.String ? value.GetString() : null; }
    private static string? PurchaseUnit(JsonElement resource, string property) => resource.TryGetProperty("purchase_units", out var units) && units.ValueKind == JsonValueKind.Array && units.GetArrayLength() > 0 ? Find(units[0], property) : null;
    private static (decimal? amount, string? currency) Amount(JsonElement resource)
    {
        foreach (var name in new[] { "amount", "gross_amount" }) if (resource.TryGetProperty(name, out var value) && value.TryGetProperty("value", out var amount) && decimal.TryParse(amount.GetString(), System.Globalization.NumberStyles.Number, System.Globalization.CultureInfo.InvariantCulture, out var parsed)) return (parsed, Find(value, "currency_code") ?? Find(value, "currency"));
        if (resource.TryGetProperty("purchase_units", out var units) && units.ValueKind == JsonValueKind.Array && units.GetArrayLength() > 0) return Amount(units[0]);
        return (null, null);
    }
}

public sealed record SubscribeRequest(Guid ProductId, Guid ProjectId, BillingCycle BillingCycle);
