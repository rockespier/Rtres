using Microsoft.AspNetCore.Http;
using Rtres.Domain;

namespace Rtres.Api.Services;

public sealed class PayPalCheckoutService(IPayPalClient payPal, IConfiguration configuration)
{
    /// <summary>
    /// Inicia el pago en PayPal: orden (Único/Anual) o suscripción (Mensual). <paramref name="request"/> es la petición
    /// del portal: PayPal vuelve al mismo origen desde el que se pagó (localhost en desarrollo), siempre que sea uno de
    /// los orígenes permitidos; si no, a <c>Frontend:PortalUrl</c>.
    /// </summary>
    public async Task<PayPalCheckout> StartAsync(ClientProduct item, Product product, HttpRequest? request, CancellationToken ct)
    {
        var baseUrl = PortalBaseUrl(request, configuration);
        var returnUrl = $"{baseUrl}/billing/return?clientProductId={item.Id}";
        var cancelUrl = $"{baseUrl}/dashboard";
        var price = item.Price ?? product.BasePrice ?? throw new InvalidOperationException("El producto no tiene precio.");
        if (price <= 0) throw new InvalidOperationException("Un producto con precio 0 no se puede cobrar por PayPal; asígnalo en modo Manual.");
        if (item.BillingCycle == BillingCycle.Mensual)
        {
            item.PayPalPlanId = await MonthlyPlanAsync(product, price, ct);
            var subscription = await payPal.CreateSubscriptionAsync(item.PayPalPlanId, item.Id.ToString(), returnUrl, cancelUrl, ct);
            item.PayPalSubscriptionId = subscription.Id;
            return subscription;
        }
        var order = await payPal.CreateOrderAsync(price, product.Currency, item.Id.ToString(), returnUrl, cancelUrl, ct);
        item.PayPalOrderId = order.Id;
        return order;
    }

    /// <summary>
    /// Plan mensual de PayPal para el precio a cobrar. El del precio base se crea una vez y se guarda en el producto
    /// (se recrea si el precio base cambia); un precio especial para un cliente usa un plan propio.
    /// </summary>
    private async Task<string> MonthlyPlanAsync(Product product, decimal price, CancellationToken ct)
    {
        if (price != product.BasePrice) return await payPal.CreateMonthlyPlanAsync(product.Name, price, product.Currency, ct);
        if (product.PayPalPlanId is null || product.PayPalPlanPrice != price)
        {
            product.PayPalPlanId = await payPal.CreateMonthlyPlanAsync(product.Name, price, product.Currency, ct);
            product.PayPalPlanPrice = price;
        }
        return product.PayPalPlanId;
    }

    public static string[] AllowedOrigins(IConfiguration configuration) =>
        [configuration["Frontend:PublicUrl"] ?? "https://rtres.net", configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net", "http://localhost:4200", "http://localhost:4201"];

    /// <summary>URL del portal desde el que se hizo la petición (si es un origen permitido), o <c>Frontend:PortalUrl</c>.</summary>
    public static string PortalBaseUrl(HttpRequest? request, IConfiguration configuration)
    {
        var origin = request?.Headers.Origin.ToString().TrimEnd('/');
        if (!string.IsNullOrEmpty(origin) && AllowedOrigins(configuration).Any(x => string.Equals(x.TrimEnd('/'), origin, StringComparison.OrdinalIgnoreCase))) return origin;
        return (configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net").TrimEnd('/');
    }
}
