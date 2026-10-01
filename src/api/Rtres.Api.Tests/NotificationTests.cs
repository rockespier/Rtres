using System.Security.Claims;
using System.Text;
using Hangfire.Common;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Jobs;
using Rtres.Api.Notifications;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Notifications;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class EmailTemplatesTests
{
    public static TheoryData<NotificationType, string> AllTypesAndLanguages()
    {
        var data = new TheoryData<NotificationType, string>();
        foreach (var type in Enum.GetValues<NotificationType>())
            foreach (var lang in EmailTemplates.Languages) data.Add(type, lang);
        return data;
    }

    [Theory, MemberData(nameof(AllTypesAndLanguages))]
    public void Every_type_renders_in_every_language(NotificationType type, string lang)
    {
        var (subject, html, text) = EmailTemplates.Render(Sample(type), lang, "https://portal.rtres.net/");
        Assert.False(string.IsNullOrWhiteSpace(subject));
        Assert.DoesNotContain("{0}", subject + text);
        Assert.Contains("https://portal.rtres.net/", html);
        Assert.DoesNotContain("portal.rtres.net//", text);
    }

    [Fact]
    public void Renders_localized_values_and_encodes_html()
    {
        var reply = Sample(NotificationType.TicketReply);
        reply.Data["body"] = "<script>alert(1)</script>";
        var (_, html, _) = EmailTemplates.Render(reply, "es", "https://portal.rtres.net");
        Assert.DoesNotContain("<script>", html);
        Assert.Contains("&lt;script&gt;", html);
        Assert.Contains("/tickets/t-1", html);

        Assert.Equal("Ticket RT-108: En progreso", EmailTemplates.Render(Sample(NotificationType.TicketStatusChanged), "es", "x").Subject);
        Assert.Equal("Ticket RT-108: In corso", EmailTemplates.Render(Sample(NotificationType.TicketStatusChanged), "it", "x").Subject);
        Assert.Equal("Ticket RT-108: En progreso", EmailTemplates.Render(Sample(NotificationType.TicketStatusChanged), "fr", "x").Subject); // idioma desconocido → es

        var (subject, _, text) = EmailTemplates.Render(Sample(NotificationType.RenewalReminder), "en", "x");
        Assert.Equal("Hosting (cabalgatasandinas.com) expires in 7 days", subject);
        Assert.Contains("October 14, 2026", text);
        Assert.Contains("USD 120.00", text);
        Assert.Contains("14 de octubre de 2026", EmailTemplates.Render(Sample(NotificationType.RenewalReminder), "es", "x").Text);
        Assert.Contains("14 ottobre 2026", EmailTemplates.Render(Sample(NotificationType.RenewalReminder), "it", "x").Text);
    }

    internal static Notification Sample(NotificationType type) => new(type, type switch
    {
        NotificationType.RenewalReminder => new() { ["product"] = "Hosting", ["domain"] = "cabalgatasandinas.com", ["renewsAt"] = "2026-10-14T00:00:00.0000000Z", ["days"] = "7", ["autoRenew"] = "false", ["amount"] = "120", ["currency"] = "USD" },
        NotificationType.TicketStatusChanged => new() { ["ticketId"] = "t-1", ["code"] = "RT-108", ["title"] = "Botón", ["status"] = "EnProgreso" },
        NotificationType.TicketReply => new() { ["ticketId"] = "t-1", ["code"] = "RT-108", ["title"] = "Botón", ["author"] = "dev", ["body"] = "Listo" },
        NotificationType.PaymentReceived => new() { ["product"] = "Hosting", ["amount"] = "120", ["currency"] = "USD" },
        NotificationType.AccountAccess => new() { ["name"] = "Ana", ["company"] = "Andes Tours", ["email"] = "ana@andes.pe", ["password"] = "Xk3pQ9" },
        NotificationType.TransferRequested => new() { ["clientId"] = "c-1", ["company"] = "Andes Tours", ["product"] = "Hosting anual", ["project"] = "Web", ["amount"] = "120", ["currency"] = "USD" },
        _ => new() { ["product"] = "Hosting" },
    });
}

public class NotificationJobTests
{
    [Fact]
    public async Task Sends_logs_and_deduplicates()
    {
        using var db = TestData.Db(out var seed);
        var email = new FakeEmail();
        var job = Job(db, email);
        var notification = EmailTemplatesTests.Sample(NotificationType.PaymentReceived) with { DedupeKey = "payment:abc" };

        await job.SendAsync(seed.Client.Id, notification, CancellationToken.None);
        await job.SendAsync(seed.Client.Id, notification, CancellationToken.None);

        var message = Assert.Single(email.Sent);
        Assert.Equal("c@example.com", message.To);
        var log = await db.NotificationLogs.SingleAsync();
        Assert.True(log.Success); Assert.Equal("PaymentReceived", log.Type); Assert.Equal("payment:abc", log.DedupeKey); Assert.Equal("c@example.com", log.Recipient);
    }

    [Fact]
    public async Task Bell_inbox_keeps_one_entry_per_notice_and_counts_unread_per_user()
    {
        using var db = TestData.Db(out var seed);
        var job = Job(db, new FakeEmail());
        var reply = EmailTemplatesTests.Sample(NotificationType.TicketReply) with { DedupeKey = "reply:1" };
        await job.SendAsync(seed.Client.Id, reply, CancellationToken.None);
        await job.SendAsync(seed.Client.Id, reply, CancellationToken.None); // reintento: no duplica
        await job.SendAsync(seed.Client.Id, EmailTemplatesTests.Sample(NotificationType.TicketCreated) with { DedupeKey = "created:1", To = "equipo@rtres.net" }, CancellationToken.None);
        await job.SendAsync(seed.Client.Id, EmailTemplatesTests.Sample(NotificationType.AccountAccess) with { DedupeKey = "access:1" }, CancellationToken.None);
        Assert.Equal(2, await db.PortalNotifications.CountAsync()); // el acceso (con contraseña) va solo por email

        var portal = Portal(db, seed, "Cliente", seed.Client.Id);
        var mine = Assert.IsType<OkObjectResult>(await portal.Notifications(null, CancellationToken.None)).Value!;
        Assert.Equal(1, (int)mine.GetType().GetProperty("unread")!.GetValue(mine)!); // el aviso interno de ticket nuevo no lo ve el cliente
        await portal.NotificationsSeen(CancellationToken.None);
        var seen = Assert.IsType<OkObjectResult>(await portal.Notifications(null, CancellationToken.None)).Value!;
        Assert.Equal(0, (int)seen.GetType().GetProperty("unread")!.GetValue(seen)!);

        var staff = Assert.IsType<OkObjectResult>(await Portal(db, seed, "SuperAdmin", null).Notifications(null, CancellationToken.None)).Value!;
        Assert.Equal(2, (int)staff.GetType().GetProperty("unread")!.GetValue(staff)!); // Rtres ve todo, con su propio "leído"
    }

    private static PortalController Portal(RtresDbContext db, Seed seed, string role, Guid? clientId)
    {
        var user = role == "SuperAdmin" ? new UserAccount { Email = "admin@rtres.net", Role = UserRole.SuperAdmin } : seed.User;
        if (role == "SuperAdmin") { db.UserAccounts.Add(user); db.SaveChanges(); }
        Claim[] claims = clientId is Guid id ? [new(ClaimTypes.NameIdentifier, user.Id.ToString()), new("client_id", id.ToString()), new(ClaimTypes.Role, role)] : [new(ClaimTypes.NameIdentifier, user.Id.ToString()), new(ClaimTypes.Role, role)];
        return new PortalController(db, new FakeJobs(), new FakeNotifications(), new ConfigurationBuilder().Build(), NullLogger<PortalController>.Instance) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(new ClaimsIdentity(claims, "test")) } } };
    }

    [Fact]
    public async Task Failure_is_logged_and_rethrown_for_retry()
    {
        using var db = TestData.Db(out var seed);
        var job = Job(db, new FakeEmail { Fail = true });
        await Assert.ThrowsAsync<InvalidOperationException>(() => job.SendAsync(seed.Client.Id, EmailTemplatesTests.Sample(NotificationType.PaymentFailed) with { DedupeKey = "k" }, CancellationToken.None));
        var log = await db.NotificationLogs.SingleAsync();
        Assert.False(log.Success); Assert.Equal("SMTP caído", log.Error);
        Assert.False(await NotificationJob.AlreadySentAsync(db, "k", CancellationToken.None)); // un fallo no bloquea el reintento
    }

    [Fact]
    public async Task Inactive_clients_are_skipped()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.IsActive = false; await db.SaveChangesAsync();
        var email = new FakeEmail();
        await Job(db, email).SendAsync(seed.Client.Id, EmailTemplatesTests.Sample(NotificationType.PaymentFailed), CancellationToken.None);
        Assert.Empty(email.Sent);
    }

    [Fact]
    public void Notification_survives_hangfire_serialization()
    {
        var original = EmailTemplatesTests.Sample(NotificationType.RenewalReminder) with { DedupeKey = "renewal:x" };
        var copy = SerializationHelper.Deserialize<Notification>(SerializationHelper.Serialize(original, SerializationOption.User), SerializationOption.User);
        Assert.Equal(original.Type, copy.Type); Assert.Equal(original.DedupeKey, copy.DedupeKey); Assert.Equal(original.Data, copy.Data);
    }

    internal static NotificationJob Job(RtresDbContext db, IEmailSender email) =>
        new(db, email, new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Frontend:PortalUrl"] = "https://portal.rtres.net" }).Build(), NullLogger<NotificationJob>.Instance);
}

public class RenewalReminderJobTests
{
    private static readonly DateTime Now = new(2026, 9, 1, 13, 0, 0, DateTimeKind.Utc);

    [Theory]
    [InlineData(40, null)]
    [InlineData(30, 30)]
    [InlineData(20, 30)]
    [InlineData(7, 7)]
    [InlineData(5, 7)]
    [InlineData(1, 1)]
    [InlineData(0, 1)]
    [InlineData(-1, null)]
    public async Task Picks_the_right_threshold(int daysLeft, int? expectedThreshold)
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, Now.Date.AddDays(daysLeft));
        var email = new FakeEmail();
        await new RenewalReminderJob(db, new InlineNotifications(db, email)).SendAsync(Now, CancellationToken.None);

        if (expectedThreshold is null) { Assert.Empty(email.Sent); return; }
        Assert.Single(email.Sent);
        Assert.Equal($"renewal:{item.Id}:{item.RenewsAt:yyyyMMdd}:{expectedThreshold}", (await db.NotificationLogs.SingleAsync()).DedupeKey);
        Assert.Equal(ClientProductStatus.PorVencer, item.Status);
    }

    [Fact]
    public async Task Each_threshold_is_sent_once()
    {
        using var db = TestData.Db(out var seed);
        AddProduct(db, seed, Now.Date.AddDays(10));
        var email = new FakeEmail();
        var job = new RenewalReminderJob(db, new InlineNotifications(db, email));
        await job.SendAsync(Now, CancellationToken.None);               // 10 días → aviso de 30
        await job.SendAsync(Now.AddHours(2), CancellationToken.None);   // mismo día → nada
        await job.SendAsync(Now.AddDays(1), CancellationToken.None);    // 9 días → sigue en la ventana de 30
        await job.SendAsync(Now.AddDays(3), CancellationToken.None);    // 7 días → aviso de 7
        await job.SendAsync(Now.AddDays(9), CancellationToken.None);    // 1 día → aviso de 1
        Assert.Equal(3, email.Sent.Count);
    }

    [Theory]
    [InlineData(ClientProductStatus.Activo, -1, ClientProductStatus.Vencido)]
    [InlineData(ClientProductStatus.PorVencer, -3, ClientProductStatus.Vencido)]
    [InlineData(ClientProductStatus.Activo, 0, ClientProductStatus.PorVencer)] // vence hoy: aún se puede renovar
    [InlineData(ClientProductStatus.Cancelado, -1, ClientProductStatus.Cancelado)]
    [InlineData(ClientProductStatus.Pendiente, -1, ClientProductStatus.Pendiente)]
    public async Task Marks_products_past_their_date_as_expired(ClientProductStatus status, int daysLeft, ClientProductStatus expected)
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, Now.Date.AddDays(daysLeft));
        item.Status = status; db.SaveChanges();
        await new RenewalReminderJob(db, new InlineNotifications(db, new FakeEmail())).SendAsync(Now, CancellationToken.None);
        Assert.Equal(expected, (await db.ClientProducts.AsNoTracking().SingleAsync(x => x.Id == item.Id)).Status);
    }

    [Theory]
    [InlineData(ClientProductStatus.Vencido, 60, ClientProductStatus.Activo)]
    [InlineData(ClientProductStatus.Activo, 10, ClientProductStatus.PorVencer)]
    [InlineData(ClientProductStatus.Activo, -2, ClientProductStatus.Vencido)]
    [InlineData(ClientProductStatus.Pendiente, 10, ClientProductStatus.Pendiente)]
    [InlineData(ClientProductStatus.Cancelado, -2, ClientProductStatus.Cancelado)]
    public void Status_follows_the_renewal_date(ClientProductStatus current, int daysLeft, ClientProductStatus expected) =>
        Assert.Equal(expected, RenewalReminderJob.StatusFor(current, Now.Date.AddDays(daysLeft), Now));

    [Fact]
    public void Status_is_unchanged_without_a_renewal_date() =>
        Assert.Equal(ClientProductStatus.Vencido, RenewalReminderJob.StatusFor(ClientProductStatus.Vencido, null, Now));

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, DateTime renewsAt)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Status = ClientProductStatus.Activo, BillingCycle = BillingCycle.Anual, RenewsAt = renewsAt, DomainName = "cabalgatasandinas.com" };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }
}

internal sealed class FakeEmail : IEmailSender
{
    public bool Fail { get; init; }
    public List<EmailMessage> Sent { get; } = [];
    public Task SendAsync(EmailMessage message, CancellationToken cancellationToken = default)
    {
        if (Fail) throw new InvalidOperationException("SMTP caído");
        Sent.Add(message); return Task.CompletedTask;
    }
}

/// <summary>Ejecuta el <see cref="NotificationJob"/> en línea (sin Hangfire) para probar el flujo completo con log y dedupe.</summary>
internal sealed class InlineNotifications(RtresDbContext db, IEmailSender email) : INotificationSender
{
    public Task SendAsync(Client client, Notification notification, CancellationToken cancellationToken = default) =>
        NotificationJobTests.Job(db, email).SendAsync(client.Id, notification, cancellationToken);
}
