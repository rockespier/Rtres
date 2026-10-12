namespace Rtres.Domain;

/// <summary>Impuesto a la Renta anual del Régimen MYPE Tributario, por tramos de la renta neta imponible.</summary>
public sealed record MypeIncomeTax(decimal Limit, decimal LowBase, decimal LowTax, decimal HighBase, decimal HighTax)
{
    public decimal Total => LowTax + HighTax;

    /// <summary>
    /// Tramo 1: la renta neta hasta <see cref="AnnualTaxSettings.ThresholdUits"/> UIT paga <see cref="AnnualTaxSettings.LowRate"/>;
    /// tramo 2: solo el exceso paga <see cref="AnnualTaxSettings.HighRate"/>. Sin utilidad (o con pérdida) no hay impuesto.
    /// </summary>
    public static MypeIncomeTax Compute(decimal netIncome, AnnualTaxSettings settings)
    {
        var limit = settings.ThresholdUits * settings.Uit;
        var taxable = Math.Max(netIncome, 0m);
        var low = Math.Min(taxable, limit); var high = Math.Max(taxable - limit, 0m);
        return new MypeIncomeTax(limit, low, Math.Round(low * settings.LowRate, 2), high, Math.Round(high * settings.HighRate, 2));
    }
}

public static class Form1662
{
    /// <summary>
    /// IGV por utilización de servicios de no domiciliados: la tasa del IGV sobre el monto en soles. El monto en soles del
    /// gasto ya usa el tipo de cambio venta de SUNAT de la fecha del pago (el más cercano si ese día no hay).
    /// </summary>
    public static decimal Igv(Expense expense, decimal igvRate) => Math.Round(expense.AmountPen * igvRate, 2);
}
