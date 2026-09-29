namespace Rtres.Domain;

/// <summary>
/// Precio de un producto de cliente. El precio de lista es el del catálogo (así se estandariza); un cliente con un
/// precio menor lleva un descuento de monto fijo que cubre un solo periodo: al renovar se cobra el precio del catálogo.
/// <see cref="ClientProduct.DiscountEndsAt"/> en null = el descuento aún no se usó (se aplica al próximo cobro);
/// con fecha = cubre el periodo pagado que termina en esa fecha, y el próximo cobro ya es la renovación sin descuento.
/// </summary>
public static class ClientProductPricing
{
    /// <summary>Periodo sin fecha de fin (pago único sin vencimiento o manual sin fecha): el descuento no expira por tiempo.</summary>
    public static readonly DateTime NoEnd = new(9999, 12, 31, 0, 0, 0, DateTimeKind.Utc);

    /// <summary>Precio del catálogo; el precio propio del cliente solo cuenta si el producto no tiene precio de catálogo.</summary>
    public static decimal? ListPrice(this ClientProduct item, Product? product = null) => (product ?? item.Product)?.BasePrice ?? item.Price;

    public static bool DiscountPendingUse(this ClientProduct item) => item.Discount > 0 && item.DiscountEndsAt is null;

    /// <summary>Lo que se cobrará en el próximo pago: con descuento solo si todavía no se usó; si no, precio de lista.</summary>
    public static decimal? NextChargePrice(this ClientProduct item, Product? product = null) =>
        item.ListPrice(product) is decimal list ? list - (item.DiscountPendingUse() ? item.Discount!.Value : 0m) : null;

    /// <summary>
    /// IGV que se suma al cobro. Los precios del catálogo y los descuentos son sin IGV: solo se agrega cuando el producto
    /// emite Factura y el cliente requiere comprobante (Perú). Exterior (exportación de servicios) y Recibo por honorarios: 0.
    /// </summary>
    public static decimal IgvRateFor(Client client, Product product, decimal igvRate) =>
        client.RequiresTaxDocument && product.TaxDocumentType == TaxDocumentType.Factura ? igvRate : 0m;

    public static decimal WithIgv(decimal net, decimal igvRate) => Math.Round(net * (1 + igvRate), 2);

    /// <summary>Monto a cobrar en el próximo pago, con IGV si corresponde (<paramref name="igvRate"/> de <see cref="IgvRateFor"/>).</summary>
    public static decimal? NextChargeTotal(this ClientProduct item, decimal igvRate, Product? product = null) =>
        item.NextChargePrice(product) is decimal net ? WithIgv(net, igvRate) : null;

    public const int MaxPrepaidYears = 5;

    /// <summary>
    /// Monto a cobrar por <paramref name="years"/> años de un producto anual pagados de una vez: el descuento (si aún no
    /// se usó) solo rebaja el primer año, los siguientes van a precio de catálogo; el IGV se aplica al total.
    /// </summary>
    public static decimal? ChargeTotal(this ClientProduct item, decimal igvRate, int years, Product? product = null) =>
        item.NextChargePrice(product) is decimal first && item.ListPrice(product) is decimal list ? WithIgv(first + (years - 1) * list, igvRate) : null;

    /// <summary>Error si no se pueden pagar <paramref name="years"/> años de una vez (solo productos anuales, hasta <see cref="MaxPrepaidYears"/>).</summary>
    public static string? ValidateYears(this ClientProduct item, int years) =>
        years < 1 || years > MaxPrepaidYears ? $"Se pueden pagar de 1 a {MaxPrepaidYears} años."
        : years > 1 && item.BillingCycle != BillingCycle.Anual ? "Solo los productos anuales se pueden pagar por varios años." : null;

    /// <summary>Precio vigente del periodo actual (lo que muestra el portal).</summary>
    public static decimal? CurrentPrice(this ClientProduct item, DateTime now, Product? product = null) =>
        item.ListPrice(product) is decimal list ? list - (item.Discount > 0 && (item.DiscountEndsAt is null || now < item.DiscountEndsAt) ? item.Discount!.Value : 0m) : null;

    /// <summary>
    /// Fija (o quita, con null/0) el descuento. Si el producto ya tiene un periodo pagado (no está Pendiente), el
    /// descuento cubre ese periodo y termina con él; si está Pendiente, se aplica al primer cobro. Devuelve el error de validación.
    /// </summary>
    public static string? SetDiscount(this ClientProduct item, decimal? discount, Product? product = null)
    {
        if (discount is null or 0) { item.Discount = null; item.DiscountEndsAt = null; return null; }
        if (item.ListPrice(product) is not decimal list) return "El producto no tiene precio: no se le puede aplicar un descuento.";
        if (discount < 0 || discount > list) return $"El descuento debe estar entre 0 y el precio del catálogo ({list:0.00}).";
        item.Discount = Math.Round(discount.Value, 2);
        item.DiscountEndsAt = item.Status == ClientProductStatus.Pendiente ? null : item.PeriodEnd() ?? NoEnd;
        return null;
    }

    /// <summary>
    /// Tras aplicar un pago (con la vigencia ya extendida): si el descuento estaba pendiente, ese pago lo usó y cubre el
    /// periodo recién pagado; si ya se había usado, este pago es la renovación a precio de lista y el descuento se quita.
    /// </summary>
    public static void OnPaymentApplied(this ClientProduct item)
    {
        if (!(item.Discount > 0)) return;
        if (item.DiscountEndsAt is null) item.DiscountEndsAt = item.PeriodEnd() ?? NoEnd;
        else { item.Discount = null; item.DiscountEndsAt = null; }
    }

    /// <summary>Si el descuento cubría un periodo sin fecha y ahora se le pone una, termina con esa fecha.</summary>
    public static void OnDatesChanged(this ClientProduct item)
    {
        if (item.DiscountEndsAt == NoEnd && item.PeriodEnd() is DateTime end) item.DiscountEndsAt = end;
    }

    private static DateTime? PeriodEnd(this ClientProduct item) => item.BillingCycle == BillingCycle.Mensual ? item.NextChargeAt : item.RenewsAt;
}
