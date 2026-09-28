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
    /// <returns>Si el email se envió (false si se omitió: ya enviado, cliente inactivo o sin email).</returns>
    public async Task<bool> SendAsync(Guid clientId, Notification notification, CancellationToken cancellationToken)
    {
        if (notification.DedupeKey is not null && await AlreadySentAsync(db, notification.DedupeKey, cancellationToken)) return false;
        var client = await db.Clients.SingleOrDefaultAsync(x => x.Id == clientId, cancellationToken);
        if (client is null || !client.IsActive || string.IsNullOrWhiteSpace(client.Email))
        {
            logger.LogInformation("Aviso {Type} omitido: cliente {ClientId} inexistente, inactivo o sin email", notification.Type, clientId);
            return false;
        }

        var portalUrl = notification.Data.TryGetValue("portalUrl", out var url) ? url : configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net";
        var (subject, html, text) = EmailTemplates.Render(notification, client.PreferredLanguage, portalUrl);
        var recipient = notification.To ?? client.Email;
        var log = new NotificationLog { ClientId = client.Id, Type = notification.Type.ToString(), Channel = "email", Recipient = recipient, DedupeKey = notification.DedupeKey };
        db.NotificationLogs.Add(log);
        try
        {
            await email.SendAsync(new EmailMessage(recipient, subject, html, text), cancellationToken);
            log.Success = true;
        }
        catch (Exception ex)
        {
            log.Error = ex.Message.Length > 1000 ? ex.Message[..1000] : ex.Message;
            await db.SaveChangesAsync(cancellationToken);
            throw; // Hangfire reintenta
        }
        await db.SaveChangesAsync(cancellationToken);
        return true;
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
