using System.Globalization;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Notifications;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Job diario: avisa a 30, 7 y 1 día del vencimiento (<c>RenewsAt</c>) y marca el producto como PorVencer; cuando la
/// fecha ya pasó sin renovarse, lo marca Vencido. Cada umbral se envía una sola vez por fecha de vencimiento, aunque el
/// job corra varias veces o se salte un día.
/// </summary>
public sealed class RenewalReminderJob(RtresDbContext db, INotificationSender notifications)
{
    public static readonly int[] ThresholdDays = [30, 7, 1];

    public async Task SendAsync(CancellationToken cancellationToken) => await SendAsync(DateTime.UtcNow, cancellationToken);

    public async Task SendAsync(DateTime now, CancellationToken cancellationToken)
    {
        var today = now.Date;
        var limit = today.AddDays(ThresholdDays.Max() + 1);
        var expired = await db.ClientProducts
            .Where(x => (x.Status == ClientProductStatus.Activo || x.Status == ClientProductStatus.PorVencer) && x.RenewsAt != null && x.RenewsAt < today)
            .ToListAsync(cancellationToken);
        foreach (var item in expired) item.Status = ClientProductStatus.Vencido;
        var due = await db.ClientProducts.Include(x => x.Product)
            .Where(x => (x.Status == ClientProductStatus.Activo || x.Status == ClientProductStatus.PorVencer) && x.RenewsAt != null && x.RenewsAt >= today && x.RenewsAt < limit)
            .Join(db.Clients.Where(c => c.IsActive), product => product.ClientId, client => client.Id, (product, client) => new { product, client })
            .ToListAsync(cancellationToken);

        foreach (var (item, client) in due.Select(x => (x.product, x.client)))
        {
            var renewsAt = item.RenewsAt!.Value;
            var days = (renewsAt.Date - today).Days;
            var threshold = ThresholdDays.Where(t => days <= t).Min();
            item.Status = ClientProductStatus.PorVencer;
            var key = $"renewal:{item.Id}:{renewsAt:yyyyMMdd}:{threshold}";
            if (await NotificationJob.AlreadySentAsync(db, key, cancellationToken)) continue;
            var data = new Dictionary<string, string>
            {
                ["product"] = item.Product?.Name ?? "",
                ["renewsAt"] = renewsAt.ToString("O", CultureInfo.InvariantCulture),
                ["days"] = days.ToString(CultureInfo.InvariantCulture),
                ["autoRenew"] = item.PayPalSubscriptionId is null ? "false" : "true",
            };
            if (!string.IsNullOrWhiteSpace(item.DomainName)) data["domain"] = item.DomainName;
            if ((item.Price ?? item.Product?.BasePrice) is decimal price)
            {
                data["amount"] = price.ToString(CultureInfo.InvariantCulture);
                data["currency"] = item.Product?.Currency ?? "USD";
            }
            await notifications.SendAsync(client, new Notification(NotificationType.RenewalReminder, data, key), cancellationToken);
        }
        await db.SaveChangesAsync(cancellationToken);
    }

    /// <summary>
    /// Estado que corresponde a un vencimiento, con el mismo criterio que el job (vencido si la fecha ya pasó, por vencer
    /// dentro de los 30 días). Solo toca productos vigentes: Pendiente y Cancelado, o sin <c>RenewsAt</c>, no cambian.
    /// </summary>
    public static ClientProductStatus StatusFor(ClientProductStatus current, DateTime? renewsAt, DateTime now)
    {
        if (current is not (ClientProductStatus.Activo or ClientProductStatus.PorVencer or ClientProductStatus.Vencido) || renewsAt is not DateTime date) return current;
        var today = now.Date;
        return date < today ? ClientProductStatus.Vencido : date < today.AddDays(ThresholdDays.Max() + 1) ? ClientProductStatus.PorVencer : ClientProductStatus.Activo;
    }
}
