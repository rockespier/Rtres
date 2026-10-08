using System.Globalization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Jobs;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>
/// Cronograma de vencimientos de SUNAT (declaración mensual IGV-Renta): la tabla anual por último dígito del RUC, la fecha
/// que le toca a Rtres y la marca de periodo presentado. SUNAT publica el cronograma de cada año en diciembre: se carga aquí.
/// </summary>
[ApiController, Authorize(Roles = "SuperAdmin"), Route("api/admin/tax-calendar")]
public sealed class TaxCalendarController(RtresDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult> Get(int? year, CancellationToken ct) => Ok(await GetAsync(year, DateTime.UtcNow, ct));

    internal async Task<TaxCalendarDto> GetAsync(int? year, DateTime utcNow, CancellationToken ct)
    {
        var settings = await db.TaxSettings.FirstOrDefaultAsync(ct) ?? new TaxSettings();
        var today = TaxDueReminderJob.LimaToday(utcNow);
        var selected = year ?? today.Year;
        var years = await db.TaxDueDates.Select(x => x.Period.Year).Distinct().OrderBy(x => x).ToListAsync(ct);
        var rows = await db.TaxDueDates.Where(x => x.Period.Year == selected).OrderBy(x => x.Period).ToListAsync(ct);
        // Próximo vencimiento sin presentar (de cualquier año) y periodos vencidos sin marcar como presentados.
        var pending = (await db.TaxDueDates.Where(x => x.FiledAt == null).OrderBy(x => x.Period).ToListAsync(ct))
            .Select(x => (Row: x, Due: x.DueFor(settings.Ruc, settings.IsGoodTaxpayer))).Where(x => x.Due is not null).ToList();
        var next = pending.FirstOrDefault(x => x.Due >= today && x.Row.Period <= today);
        var overdue = pending.Where(x => x.Due < today).Select(x => Month(x.Row.Period)).ToList();
        return new TaxCalendarDto(settings.Ruc, settings.IsGoodTaxpayer, today, selected, years,
            rows.Select(x => ToDto(x, settings)).ToList(),
            next.Row is null ? null : ToDto(next.Row, settings), overdue,
            // El cronograma del año siguiente se necesita desde el periodo diciembre (vence en enero).
            MissingNextYear: today.Month == 12 && !years.Contains(today.Year + 1));
    }

    /// <summary>Crea o corrige la fila de un periodo (yyyy-MM) con las fechas que publicó SUNAT.</summary>
    [HttpPut("{period}")]
    public async Task<ActionResult> Upsert(string period, TaxDueDateRequest request, CancellationToken ct)
    {
        if (!DateOnly.TryParseExact(period + "-01", "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var start)) return BadRequest(new { message = "El periodo debe tener el formato AAAA-MM." });
        DateOnly[] dates = [request.Digit0, request.Digit1, request.Digit2And3, request.Digit4And5, request.Digit6And7, request.Digit8And9, request.GoodTaxpayer];
        // La declaración de un mes se presenta el mes siguiente (o, a lo sumo, el subsiguiente).
        if (dates.Any(d => d < start.AddMonths(1) || d >= start.AddMonths(3))) return BadRequest(new { message = $"Las fechas de vencimiento de {Month(start)} deben caer en los dos meses siguientes al periodo." });
        if (dates.Any(d => d.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday)) return BadRequest(new { message = "Hay una fecha en sábado o domingo: SUNAT solo fija vencimientos en días hábiles." });
        var row = await db.TaxDueDates.SingleOrDefaultAsync(x => x.Period == start, ct);
        if (row is null) { row = new TaxDueDate { Period = start }; db.TaxDueDates.Add(row); }
        (row.Digit0, row.Digit1, row.Digit2And3, row.Digit4And5, row.Digit6And7, row.Digit8And9, row.GoodTaxpayer) = (request.Digit0, request.Digit1, request.Digit2And3, request.Digit4And5, request.Digit6And7, request.Digit8And9, request.GoodTaxpayer);
        await db.SaveChangesAsync(ct);
        return Ok(ToDto(row, await db.TaxSettings.FirstOrDefaultAsync(ct) ?? new TaxSettings()));
    }

    [HttpPost("{id:guid}/filed")]
    public async Task<ActionResult> MarkFiled(Guid id, CancellationToken ct) => await SetFiledAsync(id, DateTime.UtcNow, ct);

    [HttpDelete("{id:guid}/filed")]
    public async Task<ActionResult> UnmarkFiled(Guid id, CancellationToken ct) => await SetFiledAsync(id, null, ct);

    /// <summary>Marca como presentados todos los periodos ya vencidos (para ponerse al día al empezar a usar el calendario).</summary>
    [HttpPost("filed-overdue")]
    public async Task<ActionResult> MarkOverdueFiled(CancellationToken ct)
    {
        var settings = await db.TaxSettings.FirstOrDefaultAsync(ct) ?? new TaxSettings();
        var today = TaxDueReminderJob.LimaToday(DateTime.UtcNow);
        var overdue = (await db.TaxDueDates.Where(x => x.FiledAt == null && x.Period < today).ToListAsync(ct)).Where(x => x.DueFor(settings.Ruc, settings.IsGoodTaxpayer) < today).ToList();
        foreach (var row in overdue) row.FiledAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return Ok(new { marked = overdue.Count });
    }

    private async Task<ActionResult> SetFiledAsync(Guid id, DateTime? filedAt, CancellationToken ct)
    {
        var row = await db.TaxDueDates.FindAsync([id], ct); if (row is null) return NotFound();
        row.FiledAt = filedAt; await db.SaveChangesAsync(ct);
        return Ok(ToDto(row, await db.TaxSettings.FirstOrDefaultAsync(ct) ?? new TaxSettings()));
    }

    private static string Month(DateOnly period) => period.ToString("MMMM yyyy", CultureInfo.GetCultureInfo("es-PE")).ToLowerInvariant();

    private static TaxDueDateDto ToDto(TaxDueDate x, TaxSettings settings) => new(x.Id, x.Period.ToString("yyyy-MM", CultureInfo.InvariantCulture),
        x.Digit0, x.Digit1, x.Digit2And3, x.Digit4And5, x.Digit6And7, x.Digit8And9, x.GoodTaxpayer, x.DueFor(settings.Ruc, settings.IsGoodTaxpayer), x.FiledAt);
}

public sealed record TaxDueDateRequest(DateOnly Digit0, DateOnly Digit1, DateOnly Digit2And3, DateOnly Digit4And5, DateOnly Digit6And7, DateOnly Digit8And9, DateOnly GoodTaxpayer);
public sealed record TaxDueDateDto(Guid Id, string Period, DateOnly Digit0, DateOnly Digit1, DateOnly Digit2And3, DateOnly Digit4And5, DateOnly Digit6And7, DateOnly Digit8And9, DateOnly GoodTaxpayer, DateOnly? DueDate, DateTime? FiledAt);
public sealed record TaxCalendarDto(string? Ruc, bool IsGoodTaxpayer, DateOnly Today, int Year, List<int> Years, List<TaxDueDateDto> Rows, TaxDueDateDto? Next, List<string> Overdue, bool MissingNextYear);
