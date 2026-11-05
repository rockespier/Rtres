using Microsoft.EntityFrameworkCore;
using Rtres.Domain;

namespace Rtres.Infrastructure.Persistence;

/// <summary>Snapshot del tipo de cambio a usar en una fecha dada — nunca se recalcula después (un mes cerrado no cambia de valor).</summary>
public static class ExchangeRateQueries
{
    /// <summary>Siguiente código interno de cobro. Sale del mayor existente y no del conteo: un extorno borra cobros y el conteo repetiría códigos.</summary>
    public static async Task<string> NextInternalCodeAsync(this RtresDbContext db, CancellationToken ct)
    {
        const string prefix = "RT-INT-";
        var last = await db.PaymentTransactions.Where(x => x.InternalCode != null && x.InternalCode.StartsWith(prefix)).MaxAsync(x => x.InternalCode, ct);
        return $"{prefix}{1 + (int.TryParse(last?[prefix.Length..], out var number) ? number : 0):000000}";
    }

    public static async Task<decimal> RateToPenAsync(this RtresDbContext db, string currency, DateOnly date, CancellationToken ct)
    {
        if (currency == "PEN") return 1m;
        var rates = await db.ExchangeRates.Where(x => x.CurrencyCode == currency).ToListAsync(ct);
        if (rates.Count == 0) return 1m; // sin tipo de cambio aún sincronizado: se corrige a partir de la próxima venta una vez que ExchangeRateSyncJob tenga historial
        return rates.OrderBy(x => Math.Abs(x.Date.DayNumber - date.DayNumber)).First().RateToPen;
    }
}
