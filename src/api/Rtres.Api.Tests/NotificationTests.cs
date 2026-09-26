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

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, DateTime renewsAt)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Status = ClientProductStatus.Activo, BillingCycle = BillingCycle.Anual, RenewsAt = renewsAt, DomainName = "cabalgatasandinas.com" };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }
}

public class PayPalNotificationTests
{
    [Fact]
    public async Task Completed_payment_notifies_once_and_denied_payment_notifies_failure()
    {
        using var db = TestData.Db(out var seed);
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Status = ClientProductStatus.Pendiente, BillingCycle = BillingCycle.Anual };
        db.AddRange(product, item); await db.SaveChangesAsync();
        var notifications = new FakeNotifications();

        await Post(db, notifications, """{"id":"WH-1","event_type":"PAYMENT.CAPTURE.COMPLETED","resource":{"id":"CAP-1","custom_id":"ITEM","amount":{"value":"120.00","currency_code":"USD"},"supplementary_data":{"related_ids":{"order_id":"ORD-1"}}}}""".Replace("ITEM", item.Id.ToString()));
        await Post(db, notifications, """{"id":"WH-2","event_type":"PAYMENT.CAPTURE.COMPLETED","resource":{"id":"CAP-1","custom_id":"ITEM","amount":{"value":"120.00","currency_code":"USD"},"supplementary_data":{"related_ids":{"order_id":"ORD-1"}}}}""".Replace("ITEM", item.Id.ToString()));
        await Post(db, notifications, """{"id":"WH-3","event_type":"PAYMENT.CAPTURE.DENIED","resource":{"id":"CAP-2","custom_id":"ITEM"}}""".Replace("ITEM", item.Id.ToString()));

        Assert.Collection(notifications.Sent,
            paid => { Assert.Equal(NotificationType.PaymentReceived, paid.Type); Assert.Equal("120.00", paid.Data["amount"]); Assert.Equal("Hosting", paid.Data["product"]); Assert.Equal("payment:ORD-1", paid.DedupeKey); },
            failed => { Assert.Equal(NotificationType.PaymentFailed, failed.Type); Assert.Equal("payment-failed:WH-3", failed.DedupeKey); });
    }

    private static async Task Post(RtresDbContext db, INotificationSender notifications, string json)
    {
        var payPal = new AlwaysValidPayPal();
        var controller = new PaymentsController(db, payPal, new PayPalCheckoutService(payPal, new ConfigurationBuilder().Build()), notifications)
        { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { Request = { Body = new MemoryStream(Encoding.UTF8.GetBytes(json)) } } } };
        Assert.IsType<OkResult>(await controller.Webhook(CancellationToken.None));
    }

    private sealed class AlwaysValidPayPal : IPayPalClient
    {
        public Task<PayPalCheckout> CreateOrderAsync(decimal amount, string currency, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<PayPalCheckout> CreateSubscriptionAsync(string planId, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task CancelSubscriptionAsync(string subscriptionId, string reason, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<bool> VerifyWebhookAsync(string payload, IReadOnlyDictionary<string, string> headers, CancellationToken cancellationToken = default) => Task.FromResult(true);
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
