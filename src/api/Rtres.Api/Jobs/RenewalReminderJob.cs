using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

public sealed class RenewalReminderJob(RtresDbContext db, INotificationSender notifications)
{
    public async Task SendAsync(CancellationToken cancellationToken)
    {
        var limit = DateTime.UtcNow.AddDays(14);
        var due = await db.ClientProducts.Where(x => x.Status == ClientProductStatus.Activo && x.RenewsAt <= limit)
            .Join(db.Clients, product => product.ClientId, client => client.Id, (product, client) => new { product, client }).ToListAsync(cancellationToken);
        foreach (var item in due) { await notifications.SendAsync(item.client, "renewal-reminder", item.product, cancellationToken); db.NotificationLogs.Add(new NotificationLog { ClientId = item.client.Id, Type = "renewal-reminder", Channel = "email", Success = true }); }
        await db.SaveChangesAsync(cancellationToken);
    }
}
