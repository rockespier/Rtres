using Hangfire;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Programa los pagos de los gastos recurrentes: crea los que caen en los próximos <see cref="DaysAhead"/> días para que
/// aparezcan como "Por pagar". Una serie es "mismo concepto, categoría y moneda" (igual que al finalizarla) y sigue hasta
/// que se finaliza. Solo programa hacia adelante: los pagos que faltan en el pasado no se inventan (se registran a mano).
/// </summary>
public sealed class RecurringExpenseJob(RtresDbContext db, ILogger<RecurringExpenseJob> logger)
{
    public const int DaysAhead = 30;

    [AutomaticRetry(Attempts = 3), DisableConcurrentExecution(timeoutInSeconds: 300)]
    public async Task GenerateAsync(CancellationToken cancellationToken) => await GenerateAsync(DateOnly.FromDateTime(DateTime.UtcNow.AddHours(-5)), cancellationToken);

    /// <param name="today">Fecha de Lima; parámetro para poder probarlo.</param>
    public async Task<int> GenerateAsync(DateOnly today, CancellationToken cancellationToken)
    {
        var recurring = await db.Expenses.Where(x => x.Recurring && x.RecurrenceCycle != null && x.RecurrenceCycle != BillingCycle.Unico).ToListAsync(cancellationToken);
        var until = today.AddDays(DaysAhead);
        var created = 0;
        foreach (var series in recurring.GroupBy(x => (Description: x.Description.Trim().ToLowerInvariant(), x.CategoryId, x.Currency)))
        {
            // Una serie finalizada no se programa más, aunque alguna fila vieja no tenga la marca.
            if (series.Any(x => x.RecurrenceEndsAt is not null)) continue;
            var last = series.MaxBy(x => x.Date)!;
            var months = last.RecurrenceCycle!.Value.Months();
            // El día del mes sale del primer pago: así un gasto del 31 no se corre al 28 para siempre tras pasar por febrero.
            var anchor = series.Min(x => x.Date);
            var step = 1;
            for (var next = anchor.AddMonths(months); next <= until; next = anchor.AddMonths(months * ++step))
            {
                if (next <= last.Date || next < today) continue;
                db.Expenses.Add(new Expense
                {
                    Description = last.Description, CategoryId = last.CategoryId, Type = last.Type, Amount = last.Amount, Currency = last.Currency,
                    Date = next, Recurring = true, RecurrenceCycle = last.RecurrenceCycle,
                    // Tipo de cambio más cercano disponible: para una fecha futura es una estimación.
                    AmountPen = last.Amount * await db.RateToPenAsync(last.Currency, next, cancellationToken),
                });
                created++;
                logger.LogInformation("Gasto recurrente «{Description}» programado para {Date}", last.Description, next);
            }
        }
        await db.SaveChangesAsync(cancellationToken);
        return created;
    }
}
