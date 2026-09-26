using Rtres.Domain;

namespace Rtres.Api.Services;

public sealed class PayPalCheckoutService(IPayPalClient payPal, IConfiguration configuration)
{
    public async Task<PayPalCheckout> StartAsync(ClientProduct item, Product product, CancellationToken ct)
    {
        var baseUrl = configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net";
        var returnUrl = $"{baseUrl.TrimEnd('/')}/billing/return?clientProductId={item.Id}";
        var cancelUrl = $"{baseUrl.TrimEnd('/')}/catalog";
        if (item.BillingCycle == BillingCycle.Mensual)
        {
            if (string.IsNullOrWhiteSpace(item.PayPalPlanId)) throw new InvalidOperationException("El producto no tiene PayPalPlanId para una suscripción mensual.");
            var checkout = await payPal.CreateSubscriptionAsync(item.PayPalPlanId, item.Id.ToString(), returnUrl, cancelUrl, ct);
            item.PayPalSubscriptionId = checkout.Id;
            return checkout;
        }
        var amount = item.Price ?? product.BasePrice ?? throw new InvalidOperationException("El producto no tiene precio.");
        var checkoutOrder = await payPal.CreateOrderAsync(amount, product.Currency, item.Id.ToString(), returnUrl, cancelUrl, ct);
        item.PayPalOrderId = checkoutOrder.Id;
        return checkoutOrder;
    }
}
