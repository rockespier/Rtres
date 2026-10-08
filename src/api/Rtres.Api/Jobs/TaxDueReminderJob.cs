using System.Globalization;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Notifications;
using Rtres.Domain;
using Rtres.Infrastructure.Notifications;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Job diario: avisa a Rtres (<c>Notifications:StaffEmail</c> y la campana de SuperAdmin) a 7, 3 y 1 día y el mismo día del
/// vencimiento de la declaración mensual, según el último dígito del RUC configurado. No avisa los periodos ya marcados como
/// presentados. Cada umbral se envía una sola vez por periodo, aunque el job corra varias veces o se salte un día.
/// </summary>
public sealed class TaxDueReminderJob(RtresDbContext db, IEmailSender email, IConfiguration configuration, ILogger<TaxDueReminderJob> logger)
{
    public static readonly int[] ThresholdDays = [7, 3, 1, 0];

    public async Task SendAsync(CancellationToken cancellationToken) => await SendAsync(DateTime.UtcNow, cancellationToken);

    public async Task SendAsync(DateTime utcNow, CancellationToken cancellationToken)
    {
        var settings = await db.TaxSettings.FirstOrDefaultAsync(cancellationToken);
        if (settings is null || (settings.Ruc is null && !settings.IsGoodTaxpayer)) { logger.LogInformation("Recordatorio SUNAT omitido: falta el RUC en Configuración tributaria"); return; }
        var today = LimaToday(utcNow);
        // Un periodo vence el mes siguiente: basta mirar los dos últimos periodos.
        var from = new DateOnly(today.Year, today.Month, 1).AddMonths(-2);
        var rows = await db.TaxDueDates.Where(x => x.FiledAt == null && x.Period >= from && x.Period <= today).ToListAsync(cancellationToken);
        foreach (var row in rows)
        {
            if (row.DueFor(settings.Ruc, settings.IsGoodTaxpayer) is not DateOnly due) continue;
            var days = due.DayNumber - today.DayNumber;
            if (days < 0 || days > ThresholdDays.Max()) continue;
            var threshold = ThresholdDays.Where(t => days <= t).Min();
            var key = $"tax-due:{row.Period:yyyyMM}:{due:yyyyMMdd}:{threshold}";
            if (await NotificationJob.AlreadySentAsync(db, key, cancellationToken)) continue;
            var data = new Dictionary<string, string>
            {
                ["period"] = row.Period.ToString("yyyy-MM", CultureInfo.InvariantCulture),
                ["dueDate"] = due.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                ["days"] = days.ToString(CultureInfo.InvariantCulture),
            };
            await SendAsync(new Notification(NotificationType.TaxDueReminder, data, key), cancellationToken);
        }
    }

    /// <summary>Fecha de hoy en Lima (UTC−5, sin horario de verano): los vencimientos de SUNAT son fechas locales.</summary>
    public static DateOnly LimaToday(DateTime utcNow) => DateOnly.FromDateTime(utcNow.AddHours(-5));

    /// <summary>
    /// Aviso interno sin cliente (ClientId vacío): la campana lo muestra a SuperAdmin y el email va al equipo. Si el email
    /// falla, el log queda sin éxito y Hangfire reintenta el job; la clave evita duplicar la entrada de la campana.
    /// </summary>
    private async Task SendAsync(Notification notification, CancellationToken cancellationToken)
    {
        if (!await db.PortalNotifications.AnyAsync(x => x.DedupeKey == notification.DedupeKey, cancellationToken))
            db.PortalNotifications.Add(new PortalNotification { ClientId = Guid.Empty, Type = notification.Type.ToString(), ForStaff = true, DedupeKey = notification.DedupeKey, DataJson = JsonSerializer.Serialize(notification.Data) });
        var staffEmail = configuration["Notifications:StaffEmail"] is { Length: > 0 } configured ? configured : configuration["Smtp:From"];
        if (string.IsNullOrWhiteSpace(staffEmail)) { logger.LogWarning("Recordatorio SUNAT sin email: falta Notifications:StaffEmail"); await db.SaveChangesAsync(cancellationToken); return; }
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
            throw; // Hangfire reintenta
        }
        await db.SaveChangesAsync(cancellationToken);
    }
}
