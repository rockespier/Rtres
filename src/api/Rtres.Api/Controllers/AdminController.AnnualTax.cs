using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;

namespace Rtres.Api.Controllers;

/// <summary>
/// Renta anual del Régimen MYPE Tributario y Formulario 1662. Respuestas del contador en
/// Documentacion/Confirmacion_de_mi_contador.md; decisiones en PLAN-contabilidad-sunat.md.
/// </summary>
public sealed partial class AdminController
{
    // ---- Parámetros por año ----

    [HttpGet("annual-tax-settings")]
    public async Task<ActionResult> AnnualTaxSettings(CancellationToken ct) => Ok(await db.AnnualTaxSettings.OrderByDescending(x => x.Year).ToListAsync(ct));

    [HttpPut("annual-tax-settings/{year:int}")]
    public async Task<ActionResult> SaveAnnualTaxSettings(int year, AnnualTaxSettingsRequest request, CancellationToken ct)
    {
        if (year is < 2000 or > 2100) return BadRequest(new { message = "Año inválido." });
        if (request.Uit <= 0) return BadRequest(new { message = "Indica el valor de la UIT del año." });
        if (request.ThresholdUits <= 0 || request.LowRate is < 0 or > 1 || request.HighRate is < 0 or > 1) return BadRequest(new { message = "Las tasas van entre 0 y 1 (ej. 0.10 para 10 %) y el límite del primer tramo debe ser mayor a 0." });
        var row = await db.AnnualTaxSettings.SingleOrDefaultAsync(x => x.Year == year, ct);
        if (row is null) { row = new AnnualTaxSettings { Year = year }; db.AnnualTaxSettings.Add(row); }
        (row.Uit, row.ThresholdUits, row.LowRate, row.HighRate) = (request.Uit, request.ThresholdUits, request.LowRate, request.HighRate);
        await db.SaveChangesAsync(ct);
        return Ok(row);
    }

    // ---- Renta anual ----

    /// <summary>
    /// Estimación de la Renta anual de la MYPE: ventas sin IGV (facturas y cobros sin comprobante) − gastos deducibles =
    /// renta neta; impuesto por tramos; menos los pagos a cuenta (los registrados al presentar cada mes o, si faltan, el
    /// estimado). Los recibos por honorarios son del titular como persona natural: se informan aparte. Para el año en
    /// curso agrega una proyección al cierre con el promedio de los meses ya cerrados.
    /// </summary>
    [HttpGet("reports/annual-renta")]
    public async Task<ActionResult> AnnualRentaReport(int year, CancellationToken ct) => await AnnualRentaAsync(year, DateTime.UtcNow, ct);

    internal async Task<ActionResult> AnnualRentaAsync(int year, DateTime utcNow, CancellationToken ct)
    {
        var annual = await db.AnnualTaxSettings.SingleOrDefaultAsync(x => x.Year == year, ct);
        if (annual is null) return NotFound(new { message = $"Configura la UIT de {year} en Configuración → Renta anual." });
        var settings = await TaxSettingsRow(ct);
        var (from, to) = (new DateOnly(year, 1, 1), new DateOnly(year, 12, 31));
        var sales = await SalesAsync(from, to, ct);
        var expenses = await db.Expenses.Include(x => x.Category).Where(x => x.Date >= from && x.Date <= to).ToListAsync(ct);
        var filed = await db.TaxDueDates.Where(x => x.Period >= from && x.Period <= to).ToDictionaryAsync(x => x.Period.Month, ct);
        var today = DateOnly.FromDateTime(utcNow.AddHours(-5));
        // Meses que ya cuentan: todo el año si ya pasó; si es el año en curso, hasta el mes actual (incluido).
        var lastMonth = year < today.Year ? 12 : year == today.Year ? today.Month : 0;

        var months = Enumerable.Range(1, 12).Select(m =>
        {
            var start = new DateOnly(year, m, 1); var end = start.AddMonths(1).AddDays(-1);
            var ventas = sales.Where(x => x.Mype && x.Date >= start && x.Date <= end).Sum(x => x.BasePen);
            var gastos = expenses.Where(x => x.Date >= start && x.Date <= end && IsDeductible(x)).Sum(x => x.AmountPen);
            var paid = filed.TryGetValue(m, out var row) ? row.RentaPaid : null;
            var pago = m > lastMonth ? 0m : paid ?? Math.Round(ventas * settings.RentaRate, 2);
            return new AnnualMonth(start.ToString("yyyy-MM"), Math.Round(ventas, 2), Math.Round(gastos, 2), pago, m <= lastMonth && paid is null);
        }).ToList();

        var ventasMype = months.Sum(x => x.VentasPen); var deducibles = months.Sum(x => x.GastosPen);
        var noDeducibles = expenses.Where(x => !IsDeductible(x) && x.Category?.IsIncomeTax != true).GroupBy(x => x.Description.Trim()).Select(g => new { descripcion = g.Key, monto = Math.Round(g.Sum(x => x.AmountPen), 2) }).OrderByDescending(x => x.monto).ToList();
        var renta = ventasMype - deducibles;
        var impuesto = MypeIncomeTax.Compute(renta, annual);
        var pagos = months.Sum(x => x.PagoACuentaPen);

        // Proyección: promedio de los meses cerrados (sin el mes en curso) × 12, solo para el año en curso.
        object? proyeccion = null;
        if (year == today.Year && today.Month < 12 && today.Month > 1)
        {
            var closed = months.Take(today.Month - 1).ToList();
            var ventasP = closed.Average(x => x.VentasPen) * 12; var gastosP = closed.Average(x => x.GastosPen) * 12;
            var impuestoP = MypeIncomeTax.Compute(ventasP - gastosP, annual);
            var pagosP = Math.Round(ventasP * settings.RentaRate, 2);
            proyeccion = new { mesesBase = closed.Count, ventasPen = Math.Round(ventasP, 2), gastosDeduciblesPen = Math.Round(gastosP, 2), rentaNetaPen = Math.Round(ventasP - gastosP, 2), impuesto = impuestoP, pagosACuentaPen = pagosP, saldoPen = Math.Round(impuestoP.Total - pagosP, 2) };
        }

        var natural = sales.Where(x => x.PersonaNatural).ToList();
        return Ok(new
        {
            year, uit = annual.Uit, tasas = new { annual.ThresholdUits, annual.LowRate, annual.HighRate, pagoACuenta = settings.RentaRate },
            ventasMypePen = Math.Round(ventasMype, 2), gastosDeduciblesPen = Math.Round(deducibles, 2), noDeducibles, noDeduciblesPen = noDeducibles.Sum(x => x.monto),
            rentaNetaPen = Math.Round(renta, 2), impuesto, pagosACuentaPen = Math.Round(pagos, 2), pagosEstimados = months.Count(x => x.Estimado),
            saldoPen = Math.Round(impuesto.Total - pagos, 2), meses = months, proyeccion,
            personaNatural = new { ingresosPen = Math.Round(natural.Sum(x => x.BasePen), 2), retencionesPen = Math.Round(natural.Sum(x => x.RetentionPen), 2) },
            disclaimer = TaxDisclaimer,
        });
    }

    /// <summary>Deducible en la Renta: ni pago de Renta, ni categoría no deducible, ni gasto marcado como no deducible.</summary>
    private static bool IsDeductible(Expense x) => x.Category?.IsIncomeTax != true && x.Category?.IsDeductible != false && !x.IsNonDeductible;

    private sealed record AnnualMonth(string Mes, decimal VentasPen, decimal GastosPen, decimal PagoACuentaPen, bool Estimado);

    // ---- Formulario 1662 ----

    /// <summary>Pagos a proveedores no domiciliados del mes (cada uno es un 1662 aparte: tributo 1041, periodo = mes del pago).</summary>
    [HttpGet("form-1662")]
    public async Task<ActionResult> Form1662List(int year, int month, CancellationToken ct)
    {
        var settings = await TaxSettingsRow(ct);
        var rows = await db.Expenses.Where(x => x.IsNonDomiciledService && x.Date.Year == year && x.Date.Month == month).OrderBy(x => x.Date).ToListAsync(ct);
        var items = rows.Select(x => new { id = x.Id, date = x.Date, description = x.Description, supplier = x.ForeignSupplierName, country = x.ForeignSupplierCountry, amount = x.Amount, currency = x.Currency, exchangeRate = x.Amount == 0 ? 0 : Math.Round(x.AmountPen / x.Amount, 3), basePen = Math.Round(x.AmountPen, 2), igvPen = Form1662.Igv(x, settings.IgvRate), paidAt = x.Form1662PaidAt, number = x.Form1662Number }).ToList();
        return Ok(new { periodo = $"{month:00}/{year}", tributo = "1041", igvRate = settings.IgvRate, usedAsCredit = settings.Use1662AsCredit, totalIgvPen = items.Sum(x => x.igvPen), pendientes = items.Count(x => x.paidAt is null), items });
    }

    [HttpPost("expenses/{id:guid}/form-1662")]
    public async Task<ActionResult> MarkForm1662Paid(Guid id, Form1662PaymentRequest request, CancellationToken ct)
    {
        var expense = await db.Expenses.FindAsync([id], ct); if (expense is null) return NotFound();
        if (!expense.IsNonDomiciledService) return BadRequest(new { message = "Este gasto no está marcado como servicio de un proveedor no domiciliado." });
        if (request.PaidAt < expense.Date) return BadRequest(new { message = "El 1662 se paga después del pago al proveedor." });
        (expense.Form1662PaidAt, expense.Form1662Number) = (request.PaidAt, EmptyToNull(request.Number));
        await db.SaveChangesAsync(ct); return NoContent();
    }

    [HttpDelete("expenses/{id:guid}/form-1662")]
    public async Task<ActionResult> UnmarkForm1662Paid(Guid id, CancellationToken ct)
    {
        var expense = await db.Expenses.FindAsync([id], ct); if (expense is null) return NotFound();
        (expense.Form1662PaidAt, expense.Form1662Number) = (null, null);
        await db.SaveChangesAsync(ct); return NoContent();
    }
}

public sealed record AnnualTaxSettingsRequest(decimal Uit, decimal ThresholdUits = 15m, decimal LowRate = 0.10m, decimal HighRate = 0.295m);
public sealed record Form1662PaymentRequest(DateOnly PaidAt, string? Number);
