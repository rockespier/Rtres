using Microsoft.EntityFrameworkCore;
using Rtres.Domain;

namespace Rtres.Infrastructure.Persistence;

/// <summary>Snapshot del tipo de cambio a usar en una fecha dada — nunca se recalcula después (un mes cerrado no cambia de valor).</summary>
public static class ExchangeRateQueries
{
    public static async Task<decimal> RateToPenAsync(this RtresDbContext db, string currency, DateOnly date, CancellationToken ct)
    {
        if (currency == "PEN") return 1m;
        var rates = await db.ExchangeRates.Where(x => x.CurrencyCode == currency).ToListAsync(ct);
        if (rates.Count == 0) return 1m; // sin tipo de cambio aún sincronizado: se corrige a partir de la próxima venta una vez que ExchangeRateSyncJob tenga historial
        return rates.OrderBy(x => Math.Abs(x.Date.DayNumber - date.DayNumber)).First().RateToPen;
    }
}
