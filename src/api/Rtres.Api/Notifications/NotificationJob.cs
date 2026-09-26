using Hangfire;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Notifications;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Notifications;

/// <summary>
/// Envía un aviso por email en segundo plano (así un SMTP lento no frena los webhooks) y lo registra en
/// <see cref="NotificationLog"/>. Un aviso con <see cref="Notification.DedupeKey"/> ya enviado con éxito no se repite.
/// </summary>
public sealed class NotificationJob(RtresDbContext db, IEmailSender email, IConfiguration configuration, ILogger<NotificationJob> logger)
{
    [AutomaticRetry(Attempts = 3)]
    public async Task SendAsync(Guid clientId, Notification notification, CancellationToken cancellationToken)
    {
        if (notification.DedupeKey is not null && await AlreadySentAsync(db, notification.DedupeKey, cancellationToken)) return;
        var client = await db.Clients.SingleOrDefaultAsync(x => x.Id == clientId, cancellationToken);
        if (client is null || !client.IsActive || string.IsNullOrWhiteSpace(client.Email))
        {
            logger.LogInformation("Aviso {Type} omitido: cliente {ClientId} inexistente, inactivo o sin email", notification.Type, clientId);
            return;
        }

        var (subject, html, text) = EmailTemplates.Render(notification, client.PreferredLanguage, configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net");
        var log = new NotificationLog { ClientId = client.Id, Type = notification.Type.ToString(), Channel = "email", Recipient = client.Email, DedupeKey = notification.DedupeKey };
        db.NotificationLogs.Add(log);
        try
        {
            await email.SendAsync(new EmailMessage(client.Email, subject, html, text), cancellationToken);
            log.Success = true;
        }
        catch (Exception ex)
        {
            log.Error = ex.Message.Length > 1000 ? ex.Message[..1000] : ex.Message;
            await db.SaveChangesAsync(cancellationToken);
            throw; // Hangfire reintenta
        }
        await db.SaveChangesAsync(cancellationToken);
    }

    public static Task<bool> AlreadySentAsync(RtresDbContext db, string dedupeKey, CancellationToken cancellationToken) =>
        db.NotificationLogs.AnyAsync(x => x.DedupeKey == dedupeKey && x.Success, cancellationToken);
}

public sealed class QueuedNotificationSender(IBackgroundJobClient jobs) : INotificationSender
{
    public Task SendAsync(Client client, Notification notification, CancellationToken cancellationToken = default)
    {
        jobs.Enqueue<NotificationJob>(j => j.SendAsync(client.Id, notification, CancellationToken.None));
        return Task.CompletedTask;
    }
}
