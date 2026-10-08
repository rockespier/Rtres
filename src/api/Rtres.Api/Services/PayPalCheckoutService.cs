using Microsoft.AspNetCore.Http;
using Rtres.Domain;

namespace Rtres.Api.Services;

public sealed class PayPalCheckoutService(IPayPalClient payPal, IConfiguration configuration)
{
    /// <summary>
    /// Inicia el pago en PayPal: orden (Único/Anual) o suscripción (Mensual, Bimestral, Trimestral, Semestral). <paramref name="request"/> es la petición
    /// del portal: PayPal vuelve al mismo origen desde el que se pagó (localhost en desarrollo), siempre que sea uno de
    /// los orígenes permitidos; si no, a <c>Frontend:PortalUrl</c>.
    /// </summary>
    /// <param name="igvRate">IGV a sumar (de <c>IgvRateForAsync</c>): el catálogo y los descuentos son sin IGV.</param>
    /// <param name="years">Años pagados por adelantado (solo Anual): una sola orden por el total.</param>
    public async Task<PayPalCheckout> StartAsync(ClientProduct item, Product product, HttpRequest? request, CancellationToken ct, decimal igvRate = 0m, int years = 1)
    {
        if (item.ValidateYears(years) is string yearsError) throw new InvalidOperationException(yearsError);
        var baseUrl = PortalBaseUrl(request, configuration);
        var returnUrl = $"{baseUrl}/billing/return?clientProductId={item.Id}";
        var cancelUrl = $"{baseUrl}/dashboard";
        var listPrice = ClientProductPricing.WithIgv(item.ListPrice(product) ?? throw new InvalidOperationException("El producto no tiene precio."), igvRate);
        var price = item.NextChargeTotal(igvRate, product)!.Value;
        if (price <= 0) throw new InvalidOperationException("Un producto con precio 0 no se puede cobrar por PayPal; asígnalo en modo Manual.");
        if (item.BillingCycle.SubscriptionMonths() is int months)
        {
            // Descuento sin usar: solo el primer periodo va rebajado, luego se cobra el precio de lista.
            item.PayPalPlanId = price != listPrice ? await payPal.CreatePlanAsync(product.Name, listPrice, product.Currency, months, price, ct) : await PlanAsync(product, item.BillingCycle, listPrice, ct);
            var subscription = await payPal.CreateSubscriptionAsync(item.PayPalPlanId, item.Id.ToString(), returnUrl, cancelUrl, ct);
            item.PayPalSubscriptionId = subscription.Id;
            return subscription;
        }
        var order = await payPal.CreateOrderAsync(item.ChargeTotal(igvRate, years, product)!.Value, product.Currency, item.Id.ToString(), returnUrl, cancelUrl, ct);
        item.PayPalOrderId = order.Id;
        item.PayPalOrderYears = years; // al capturar la orden (retorno o webhook) se extienden estos años
        return order;
    }

    /// <summary>
    /// Plan de PayPal para el precio y ciclo a cobrar. El del precio base y ciclo del catálogo se crea una vez y se guarda
    /// en el producto (se recrea si el precio base cambia); otro precio u otro ciclo usan un plan propio.
    /// </summary>
    private async Task<string> PlanAsync(Product product, BillingCycle cycle, decimal price, CancellationToken ct)
    {
        var months = cycle.SubscriptionMonths()!.Value;
        if (price != product.BasePrice || cycle != product.BillingCycle) return await payPal.CreatePlanAsync(product.Name, price, product.Currency, months, cancellationToken: ct);
        if (product.PayPalPlanId is null || product.PayPalPlanPrice != price)
        {
            product.PayPalPlanId = await payPal.CreatePlanAsync(product.Name, price, product.Currency, months, cancellationToken: ct);
            product.PayPalPlanPrice = price;
        }
        return product.PayPalPlanId;
    }

    public static string[] AllowedOrigins(IConfiguration configuration) =>
        [configuration["Frontend:PublicUrl"] ?? "https://rtres.net", configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net", "http://localhost:4200", "http://localhost:4201", "http://localhost:4000"];

    /// <summary>URL del portal desde el que se hizo la petición (si es un origen permitido), o <c>Frontend:PortalUrl</c>.</summary>
    public static string PortalBaseUrl(HttpRequest? request, IConfiguration configuration)
    {
        var origin = request?.Headers.Origin.ToString().TrimEnd('/');
        if (!string.IsNullOrEmpty(origin) && AllowedOrigins(configuration).Any(x => string.Equals(x.TrimEnd('/'), origin, StringComparison.OrdinalIgnoreCase))) return origin;
        return (configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net").TrimEnd('/');
    }
}
