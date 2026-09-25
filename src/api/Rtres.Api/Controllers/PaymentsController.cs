using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

[ApiController, Route("api/payments")]
public sealed class PaymentsController(RtresDbContext db, IPayPalClient payPal) : ControllerBase
{
    [Authorize, HttpPost("checkout")]
    public async Task<ActionResult> Checkout(CheckoutRequest request, CancellationToken ct)
    {
        var clientId = Guid.Parse(User.FindFirstValue("client_id")!);
        var item = await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == request.ClientProductId && x.ClientId == clientId, ct);
        if (item?.Product is null) return NotFound();
        var checkout = item.Product.BillingCycle != BillingCycle.Unico
            ? await payPal.CreateSubscriptionAsync(item.PayPalPlanId ?? throw new InvalidOperationException("PayPal plan missing"), request.ReturnUrl, request.CancelUrl, ct)
            : await payPal.CreateOrderAsync(item.Price ?? item.Product.BasePrice ?? 0, request.ReturnUrl, request.CancelUrl, ct);
        return Ok(checkout);
    }

    [HttpPost("webhooks/paypal")]
    public async Task<ActionResult> PayPalWebhook(CancellationToken ct)
    {
        using var reader = new StreamReader(Request.Body); var payload = await reader.ReadToEndAsync(ct);
        var headers = Request.Headers.ToDictionary(x => x.Key.ToLowerInvariant(), x => x.Value.ToString());
        if (!await payPal.VerifyWebhookAsync(payload, headers, ct)) return Unauthorized();
        using var json = JsonDocument.Parse(payload);
        var eventType = json.RootElement.TryGetProperty("event_type", out var eventProperty) ? eventProperty.GetString() : null;
        var subscriptionId = json.RootElement.TryGetProperty("resource", out var resource) && resource.TryGetProperty("id", out var id) ? id.GetString() : null;
        if (!string.IsNullOrWhiteSpace(subscriptionId))
        {
            var product = await db.ClientProducts.SingleOrDefaultAsync(x => x.PayPalSubscriptionId == subscriptionId, ct);
            if (product is not null)
            {
                product.Status = eventType switch { "BILLING.SUBSCRIPTION.ACTIVATED" => ClientProductStatus.Activo, "BILLING.SUBSCRIPTION.CANCELLED" => ClientProductStatus.Cancelado, _ => product.Status };
                if (eventType == "PAYMENT.SALE.COMPLETED") db.PaymentTransactions.Add(new PaymentTransaction { ClientProductId = product.Id, PayPalOrderIdOrSubscriptionId = subscriptionId, Amount = 0, Currency = "USD", Status = "COMPLETED" });
                await db.SaveChangesAsync(ct);
            }
        }
        return Ok();
    }
}
