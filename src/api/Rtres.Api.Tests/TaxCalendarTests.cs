using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Jobs;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class TaxCalendarTests
{
    [Fact]
    public void Seeded_2026_schedule_falls_on_business_days_after_each_period()
    {
        var rows = TaxDueDateSeed.Rows2026;
        Assert.Equal(12, rows.Length);
        foreach (var row in rows)
        {
            DateOnly[] dates = [row.Digit0, row.Digit1, row.Digit2And3, row.Digit4And5, row.Digit6And7, row.Digit8And9, row.GoodTaxpayer];
            Assert.All(dates, d => Assert.True(d.DayOfWeek is not (DayOfWeek.Saturday or DayOfWeek.Sunday), $"{row.Period:yyyy-MM}: {d} cae en fin de semana"));
            Assert.All(dates, d => Assert.Equal(row.Period.AddMonths(1).Month, d.Month));
            Assert.Equal(dates.Order(), dates); // el orden de las columnas es el orden de los vencimientos
        }
    }

    [Theory]
    [InlineData("20612345670", false, "2026-10-16")]
    [InlineData("20612345671", false, "2026-10-19")]
    [InlineData("10456789013", false, "2026-10-20")]
    [InlineData("20612345674", false, "2026-10-21")]
    [InlineData("20612345677", false, "2026-10-22")]
    [InlineData("20612345679", false, "2026-10-23")]
    [InlineData("20612345679", true, "2026-10-26")]
    [InlineData(null, true, "2026-10-26")]
    public void Due_date_follows_last_digit_of_the_ruc(string? ruc, bool goodTaxpayer, string expected)
    {
        var september = TaxDueDateSeed.Rows2026[8];
        Assert.Equal(DateOnly.Parse(expected), september.DueFor(ruc, goodTaxpayer));
    }

    [Fact]
    public void Without_ruc_there_is_no_due_date() => Assert.Null(TaxDueDateSeed.Rows2026[0].DueFor(null, false));

    [Fact]
    public async Task Reminder_is_sent_once_per_threshold_and_not_after_filing()
    {
        using var db = Db("20612345670"); // dígito 0: setiembre vence el viernes 16-10-2026
        var email = new FakeEmail();
        var job = Job(db, email);

        await job.SendAsync(Lima(2026, 10, 8), CancellationToken.None); // faltan 8 días: todavía no
        Assert.Empty(email.Sent);
        await job.SendAsync(Lima(2026, 10, 9), CancellationToken.None); // 7 días
        await job.SendAsync(Lima(2026, 10, 10), CancellationToken.None); // 6 días: mismo umbral, no repite
        Assert.Single(email.Sent);
        Assert.Contains("setiembre 2026", email.Sent[0].Subject);
        Assert.Equal("equipo@rtres.net", email.Sent[0].To);
        var bell = Assert.Single(await db.PortalNotifications.ToListAsync());
        Assert.True(bell.ForStaff);
        Assert.Equal(nameof(NotificationType.TaxDueReminder), bell.Type);

        await job.SendAsync(Lima(2026, 10, 15), CancellationToken.None); // 1 día
        Assert.Equal(2, email.Sent.Count);
        Assert.Contains("mañana", email.Sent[1].Subject);

        (await db.TaxDueDates.SingleAsync(x => x.Period == new DateOnly(2026, 9, 1))).FiledAt = DateTime.UtcNow;
        await db.SaveChangesAsync();
        await job.SendAsync(Lima(2026, 10, 16), CancellationToken.None); // vence hoy, pero ya se presentó
        Assert.Equal(2, email.Sent.Count);
    }

    [Fact]
    public async Task Failed_email_is_retried_without_duplicating_the_bell()
    {
        using var db = Db("20612345670");
        await Assert.ThrowsAsync<InvalidOperationException>(() => Job(db, new FakeEmail { Fail = true }).SendAsync(Lima(2026, 10, 16), CancellationToken.None));
        var email = new FakeEmail();
        await Job(db, email).SendAsync(Lima(2026, 10, 16), CancellationToken.None);
        Assert.Contains("hoy", Assert.Single(email.Sent).Subject);
        Assert.Single(await db.PortalNotifications.ToListAsync());
    }

    [Fact]
    public async Task No_reminders_without_ruc()
    {
        using var db = Db(null);
        var email = new FakeEmail();
        await Job(db, email).SendAsync(Lima(2026, 10, 16), CancellationToken.None);
        Assert.Empty(email.Sent);
    }

    [Fact]
    public async Task Calendar_shows_next_due_date_and_overdue_periods()
    {
        using var db = Db("20612345674"); // dígito 4: setiembre vence el 21-10-2026
        var calendar = new TaxCalendarController(db);
        var dto = await calendar.GetAsync(null, Lima(2026, 10, 7), CancellationToken.None);
        Assert.Equal(2026, dto.Year);
        Assert.Equal(12, dto.Rows.Count);
        Assert.Equal("2026-09", dto.Next!.Period);
        Assert.Equal(new DateOnly(2026, 10, 21), dto.Next.DueDate);
        Assert.Equal(8, dto.Overdue.Count); // enero–agosto sin marcar

        (await db.TaxDueDates.SingleAsync(x => x.Period == new DateOnly(2026, 9, 1))).FiledAt = DateTime.UtcNow;
        await db.SaveChangesAsync();
        dto = await calendar.GetAsync(null, Lima(2026, 10, 7), CancellationToken.None);
        Assert.Equal("2026-10", dto.Next!.Period); // octubre ya empezó: vence en noviembre

        Assert.True((await calendar.GetAsync(null, Lima(2026, 12, 2), CancellationToken.None)).MissingNextYear);
    }

    [Fact]
    public async Task Upsert_rejects_weekends_and_dates_outside_the_window()
    {
        using var db = Db("20612345670");
        var calendar = new TaxCalendarController(db);
        var ok = new TaxDueDateRequest(new(2027, 2, 15), new(2027, 2, 16), new(2027, 2, 17), new(2027, 2, 18), new(2027, 2, 19), new(2027, 2, 22), new(2027, 2, 23));
        Assert.IsType<OkObjectResult>(await calendar.Upsert("2027-01", ok, CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await calendar.Upsert("2027-01", ok with { Digit0 = new(2027, 2, 13) }, CancellationToken.None)); // sábado
        Assert.IsType<BadRequestObjectResult>(await calendar.Upsert("2027-01", ok with { Digit0 = new(2027, 1, 15) }, CancellationToken.None)); // dentro del periodo
        Assert.IsType<BadRequestObjectResult>(await calendar.Upsert("2027-13", ok, CancellationToken.None));
        Assert.IsType<OkObjectResult>(await calendar.Upsert("2027-01", ok with { Digit0 = new(2027, 2, 12) }, CancellationToken.None)); // corrige la fila
        Assert.Equal(new DateOnly(2027, 2, 12), (await db.TaxDueDates.SingleAsync(x => x.Period == new DateOnly(2027, 1, 1))).Digit0);
    }

    private static DateTime Lima(int year, int month, int day) => new(year, month, day, 13, 30, 0, DateTimeKind.Utc); // 8:30 en Lima

    private static TaxDueReminderJob Job(RtresDbContext db, FakeEmail email) => new(db, email,
        new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Notifications:StaffEmail"] = "equipo@rtres.net" }).Build(), NullLogger<TaxDueReminderJob>.Instance);

    private static RtresDbContext Db(string? ruc)
    {
        var db = TestData.Db(out _); // EnsureCreated siembra el cronograma 2026 (HasData)
        db.TaxSettings.Add(new TaxSettings { Ruc = ruc }); db.SaveChanges();
        return db;
    }
}
