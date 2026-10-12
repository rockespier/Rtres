using System.Globalization;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Notifications;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Job diario: avisa a Rtres (<c>Notifications:StaffEmail</c> y la campana de SuperAdmin) a 7, 3 y 1 día y el mismo día del
/// vencimiento de la declaración mensual, según el último dígito del RUC configurado. No avisa los periodos ya marcados como
/// presentados. Cada umbral se envía una sola vez por periodo, aunque el job corra varias veces o se salte un día.
/// </summary>
public sealed class TaxDueReminderJob(RtresDbContext db, StaffNotifier staff, ILogger<TaxDueReminderJob> logger)
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
            await staff.SendAsync(new Notification(NotificationType.TaxDueReminder, data, key), cancellationToken);
        }
    }

    /// <summary>Fecha de hoy en Lima (UTC−5, sin horario de verano): los vencimientos de SUNAT son fechas locales.</summary>
    public static DateOnly LimaToday(DateTime utcNow) => DateOnly.FromDateTime(utcNow.AddHours(-5));
}
