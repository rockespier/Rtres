using Hangfire;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Concilia cada hora las suscripciones de PayPal con el portal: registra los cobros que no llegaron por webhook
/// (el primer cobro se procesa minutos después de activar la suscripción; en local el webhook no llega nunca; en
/// producción un webhook puede perderse), actualiza el próximo cobro y marca las suscripciones canceladas en PayPal.
/// Cada cobro se aplica una sola vez, así que es seguro que coincida con el webhook.
/// </summary>
public sealed class PayPalReconciliationJob(RtresDbContext db, PayPalPaymentService payments, ILogger<PayPalReconciliationJob> logger)
{
    [AutomaticRetry(Attempts = 0)] // corre cada hora: no hace falta reintentar
    public async Task ReconcileAsync(CancellationToken ct)
    {
        var items = await db.ClientProducts.Include(x => x.Product)
            .Where(x => x.PayPalSubscriptionId != null && !x.IsManualBilling && x.Status != ClientProductStatus.Cancelado)
            .ToListAsync(ct);
        foreach (var item in items)
        {
            try { await payments.SyncSubscriptionAsync(item, ct); }
            catch (Exception ex) when (ex is HttpRequestException or InvalidOperationException)
            {
                logger.LogWarning(ex, "No se pudo conciliar la suscripción {SubscriptionId} del producto {ClientProductId}", item.PayPalSubscriptionId, item.Id);
            }
        }
    }
}
