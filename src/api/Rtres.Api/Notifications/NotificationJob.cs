using System.Text.Json;
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
        await AddToInboxAsync(clientId, notification, cancellationToken);
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

    /// <summary>Bandeja de la campana: una entrada por aviso aunque el email falle y se reintente (la clave lo evita).</summary>
    private async Task AddToInboxAsync(Guid clientId, Notification notification, CancellationToken cancellationToken)
    {
        if (notification.Type == NotificationType.AccountAccess) return; // lleva la contraseña temporal: solo por email
        if (notification.DedupeKey is not null && await db.PortalNotifications.AnyAsync(x => x.DedupeKey == notification.DedupeKey, cancellationToken)) return;
        if (!await db.Clients.AnyAsync(x => x.Id == clientId, cancellationToken)) return;
        db.PortalNotifications.Add(new PortalNotification
        {
            ClientId = clientId, Type = notification.Type.ToString(), DedupeKey = notification.DedupeKey,
            ForStaff = notification.Type is NotificationType.TicketCreated or NotificationType.TransferRequested or NotificationType.TransferReported,
            DataJson = JsonSerializer.Serialize(notification.Data.Where(x => x.Key != "portalUrl").ToDictionary()),
        });
        await db.SaveChangesAsync(cancellationToken);
    }

    public static Task<bool> AlreadySentAsync(RtresDbContext db, string dedupeKey, CancellationToken cancellationToken) =>
        db.NotificationLogs.AnyAsync(x => x.DedupeKey == dedupeKey && x.Success, cancellationToken);
}

public sealed class QueuedNotificationSender(IBackgroundJobClient jobs) : INotificationSender
{
    public Task SendAsync(Client client, Notification notification, CancellationToken cancellationToken = default)
    {
        // Sin clave propia se le asigna una: así un reintento del job no duplica el email ni la entrada de la campana.
        var keyed = notification.DedupeKey is null ? notification with { DedupeKey = $"auto:{Guid.NewGuid():N}" } : notification;
        jobs.Enqueue<NotificationJob>(j => j.SendAsync(client.Id, keyed, CancellationToken.None));
        return Task.CompletedTask;
    }
}
