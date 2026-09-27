using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Job diario: sincroniza el tipo de cambio USD/PEN (SUNAT) y EUR/PEN (BCRP) del día. Si una fuente falla
/// (fin de semana, feriado, error de red), reutiliza el último <c>ExchangeRate</c> ya guardado para esa moneda
/// — nunca deja una <c>PaymentTransaction</c> sin <c>AmountPen</c> por falta de tipo de cambio.
/// </summary>
public sealed class ExchangeRateSyncJob(RtresDbContext db, IExchangeRateClient client, ILogger<ExchangeRateSyncJob> logger)
{
    public async Task SyncAsync(CancellationToken cancellationToken)
    {
        await SyncCurrencyAsync("USD", client.GetUsdAsync, cancellationToken);
        await SyncCurrencyAsync("EUR", client.GetEurAsync, cancellationToken);
        await db.SaveChangesAsync(cancellationToken);
    }

    private async Task SyncCurrencyAsync(string currency, Func<CancellationToken, Task<ExchangeRateQuote?>> fetch, CancellationToken cancellationToken)
    {
        ExchangeRateQuote? quote = null;
        try { quote = await fetch(cancellationToken); }
        catch (Exception ex) { logger.LogWarning(ex, "No se pudo obtener el tipo de cambio de {Currency}", currency); }

        if (quote is null)
        {
            var last = await db.ExchangeRates.Where(x => x.CurrencyCode == currency).OrderByDescending(x => x.Date).FirstOrDefaultAsync(cancellationToken);
            if (last is null) { logger.LogWarning("Sin tipo de cambio previo de {Currency}; no hay fallback posible", currency); return; }
            quote = new ExchangeRateQuote(DateOnly.FromDateTime(DateTime.UtcNow), last.RateToPen, $"fallback:{last.Source}");
        }

        if (await db.ExchangeRates.AnyAsync(x => x.Date == quote.Date && x.CurrencyCode == currency, cancellationToken)) return;
        db.ExchangeRates.Add(new ExchangeRate { Date = quote.Date, CurrencyCode = currency, RateToPen = quote.RateToPen, Source = quote.Source });
    }
}
