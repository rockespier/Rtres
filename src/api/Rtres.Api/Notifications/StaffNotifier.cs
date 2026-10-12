using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Notifications;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Notifications;

/// <summary>
/// Aviso interno sin cliente (ClientId vacío): entra en la campana de SuperAdmin y se envía por email al equipo
/// (<c>Notifications:StaffEmail</c>, o <c>Smtp:From</c>). Lo usan los recordatorios de SUNAT y los contactos de la web.
/// Si el email falla, el log queda sin éxito y se relanza para que Hangfire reintente; la clave evita duplicar la campana.
/// </summary>
public sealed class StaffNotifier(RtresDbContext db, IEmailSender email, IConfiguration configuration, ILogger<StaffNotifier> logger)
{
    [Hangfire.AutomaticRetry(Attempts = 3)]
    public async Task SendAsync(Notification notification, CancellationToken cancellationToken)
    {
        if (notification.DedupeKey is not null && await NotificationJob.AlreadySentAsync(db, notification.DedupeKey, cancellationToken)) return;
        if (!await db.PortalNotifications.AnyAsync(x => x.DedupeKey == notification.DedupeKey, cancellationToken))
            db.PortalNotifications.Add(new PortalNotification { ClientId = Guid.Empty, Type = notification.Type.ToString(), ForStaff = true, DedupeKey = notification.DedupeKey, DataJson = JsonSerializer.Serialize(notification.Data) });
        var staffEmail = configuration["Notifications:StaffEmail"] is { Length: > 0 } configured ? configured : configuration["Smtp:From"];
        if (string.IsNullOrWhiteSpace(staffEmail)) { logger.LogWarning("Aviso interno {Type} sin email: falta Notifications:StaffEmail", notification.Type); await db.SaveChangesAsync(cancellationToken); return; }
        var (subject, html, text) = EmailTemplates.Render(notification, "es", configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net");
        var log = new NotificationLog { ClientId = Guid.Empty, Type = notification.Type.ToString(), Channel = "email", Recipient = staffEmail, DedupeKey = notification.DedupeKey };
        db.NotificationLogs.Add(log);
        try
        {
            await email.SendAsync(new EmailMessage(staffEmail, subject, html, text), cancellationToken);
            log.Success = true;
        }
        catch (Exception ex)
        {
            log.Error = ex.Message.Length > 1000 ? ex.Message[..1000] : ex.Message;
            await db.SaveChangesAsync(cancellationToken);
            throw;
        }
        await db.SaveChangesAsync(cancellationToken);
    }
}
