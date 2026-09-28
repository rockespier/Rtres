using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Jobs;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class PayPalPaymentTests
{
    [Fact]
    public async Task Approved_order_is_captured_and_activated_once()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-1");
        var payPal = new FakePayPal();
        var notifications = new FakeNotifications();

        await Webhook(db, payPal, notifications, Event("WH-1", "CHECKOUT.ORDER.APPROVED", """{"id":"ORD-1","purchase_units":[{"custom_id":"ITEM"}]}""", item));
        Assert.Equal(ClientProductStatus.Activo, item.Status);
        var renewsAt = item.RenewsAt!.Value;
        Assert.InRange(renewsAt, DateTime.UtcNow.AddYears(1).AddMinutes(-1), DateTime.UtcNow.AddYears(1).AddMinutes(1));

        // PayPal también avisa de la captura: el mismo cobro no se vuelve a aplicar (ni otro año, ni otra transacción).
        await Webhook(db, payPal, notifications, Event("WH-2", "PAYMENT.CAPTURE.COMPLETED", """{"id":"CAP-1","custom_id":"ITEM","amount":{"value":"120.00","currency_code":"USD"},"supplementary_data":{"related_ids":{"order_id":"ORD-1"}}}""", item));
        Assert.Equal(renewsAt, (await db.ClientProducts.SingleAsync()).RenewsAt);
        var transaction = await db.PaymentTransactions.SingleAsync();
        Assert.Equal(("ORD-1", 120m, "USD"), (transaction.PayPalOrderIdOrSubscriptionId, transaction.Amount, transaction.Currency));
        var paid = Assert.Single(notifications.Sent);
        Assert.Equal(NotificationType.PaymentReceived, paid.Type); Assert.Equal("payment:ORD-1", paid.DedupeKey);
    }

    [Fact]
    public async Task Approval_alone_does_not_activate_when_capture_is_not_completed()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-1");
        await Webhook(db, new FakePayPal { CaptureStatus = "PENDING" }, new FakeNotifications(), Event("WH-1", "CHECKOUT.ORDER.APPROVED", """{"id":"ORD-1"}""", item));
        Assert.Equal(ClientProductStatus.Pendiente, item.Status);
        Assert.Null(item.RenewsAt);
        Assert.Empty(db.PaymentTransactions);
    }

    [Fact]
    public async Task Return_page_capture_is_idempotent_and_one_time_products_get_no_expiry()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Unico, orderId: "ORD-9");
        var payPal = new FakePayPal();
        var controller = Controller(db, payPal, new FakeNotifications());
        controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        await controller.Capture(item.Id, null, CancellationToken.None);
        await controller.Capture(item.Id, null, CancellationToken.None);

        Assert.Equal(1, payPal.Captures);
        Assert.Equal(ClientProductStatus.Activo, item.Status);
        Assert.Null(item.RenewsAt);
        Assert.Single(db.PaymentTransactions);
    }

    [Fact]
    public async Task Denied_payment_notifies_failure()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-1");
        var notifications = new FakeNotifications();
        await Webhook(db, new FakePayPal(), notifications, Event("WH-3", "PAYMENT.CAPTURE.DENIED", """{"id":"CAP-2","custom_id":"ITEM"}""", item));
        var failed = Assert.Single(notifications.Sent);
        Assert.Equal(NotificationType.PaymentFailed, failed.Type); Assert.Equal("payment-failed:WH-3", failed.DedupeKey);
        Assert.Equal(ClientProductStatus.Pendiente, item.Status);
    }

    [Theory]
    [InlineData(BillingCycle.Anual, 30, 365 + 30)]   // renovación anticipada: suma desde el vencimiento actual
    [InlineData(BillingCycle.Anual, -10, 365)]       // ya vencido: suma desde hoy
    [InlineData(BillingCycle.Anual, null, 365)]      // primera compra
    public void Annual_period_extends_from_the_right_date(BillingCycle cycle, int? renewsInDays, int expectedDays)
    {
        var now = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);
        var item = new ClientProduct { BillingCycle = cycle, RenewsAt = renewsInDays is int d ? now.AddDays(d) : null };
        PayPalPaymentService.ExtendPeriod(item, now);
        Assert.Equal(expectedDays, (item.RenewsAt!.Value - now).Days);
    }

    [Fact]
    public void Monthly_sets_next_charge_and_one_time_sets_nothing()
    {
        var now = new DateTime(2026, 1, 31, 0, 0, 0, DateTimeKind.Utc);
        var monthly = new ClientProduct { BillingCycle = BillingCycle.Mensual };
        PayPalPaymentService.ExtendPeriod(monthly, now);
        Assert.Equal(new DateTime(2026, 2, 28, 0, 0, 0, DateTimeKind.Utc), monthly.NextChargeAt);
        Assert.Null(monthly.RenewsAt);

        var once = new ClientProduct { BillingCycle = BillingCycle.Unico };
        PayPalPaymentService.ExtendPeriod(once, now);
        Assert.Null(once.RenewsAt); Assert.Null(once.NextChargeAt);
    }

    [Fact]
    public void Parses_paypal_capture_response()
    {
        const string json = """
        {"id":"ORD-1","status":"COMPLETED","purchase_units":[{"reference_id":"default","payments":{"captures":[
          {"id":"CAP-1","status":"COMPLETED","amount":{"currency_code":"EUR","value":"99.90"}}]}}]}
        """;
        Assert.Equal(new PayPalCapture("ORD-1", "COMPLETED", 99.90m, "EUR"), PayPalClient.ParseCapture("ORD-1", json));
        Assert.Equal(new PayPalCapture("ORD-2", "APPROVED", null, null), PayPalClient.ParseCapture("ORD-2", """{"id":"ORD-2","status":"APPROVED"}"""));
    }

    [Fact]
    public async Task Reconciliation_records_the_first_charge_that_arrives_after_activation()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Mensual, orderId: null);
        item.PayPalSubscriptionId = "SUB-7"; db.SaveChanges();
        var next = new DateTime(2026, 10, 28, 10, 0, 0, DateTimeKind.Utc);
        var payPal = new FakePayPal { Subscription = new PayPalSubscriptionInfo("SUB-7", "ACTIVE", next, []) };
        var notifications = new FakeNotifications();
        var service = new PayPalPaymentService(db, payPal, notifications, NullLogger<PayPalPaymentService>.Instance);

        await service.ConfirmAsync(item, CancellationToken.None); // vuelta de PayPal: activa pero el cobro aún no existe
        Assert.Equal(ClientProductStatus.Activo, item.Status);
        Assert.Empty(db.PaymentTransactions);

        payPal.Subscription = new PayPalSubscriptionInfo("SUB-7", "ACTIVE", next, [new("SALE-1", 90m, "USD")]); // minutos después
        var job = new PayPalReconciliationJob(db, service, NullLogger<PayPalReconciliationJob>.Instance);
        await job.ReconcileAsync(CancellationToken.None);
        await job.ReconcileAsync(CancellationToken.None);
        Assert.Equal("SALE-1", (await db.PaymentTransactions.SingleAsync()).PayPalOrderIdOrSubscriptionId);
        Assert.Equal(next, item.NextChargeAt);
        Assert.Single(notifications.Sent);
    }

    [Fact]
    public async Task Reconciliation_cancels_subscriptions_cancelled_in_paypal_and_survives_errors()
    {
        using var db = TestData.Db(out var seed);
        var broken = AddProduct(db, seed, BillingCycle.Mensual, orderId: null);
        var cancelled = AddProduct(db, seed, BillingCycle.Mensual, orderId: null);
        broken.PayPalSubscriptionId = "SUB-X"; cancelled.PayPalSubscriptionId = "SUB-C";
        broken.Status = cancelled.Status = ClientProductStatus.Activo; db.SaveChanges();
        var payPal = new FakePayPal();
        payPal.Subscriptions["SUB-X"] = null; // PayPal falla para esta
        payPal.Subscriptions["SUB-C"] = new PayPalSubscriptionInfo("SUB-C", "CANCELLED", null, []);

        await new PayPalReconciliationJob(db, new PayPalPaymentService(db, payPal, new FakeNotifications(), NullLogger<PayPalPaymentService>.Instance), NullLogger<PayPalReconciliationJob>.Instance).ReconcileAsync(CancellationToken.None);

        Assert.Equal(ClientProductStatus.Activo, broken.Status);
        Assert.Equal(ClientProductStatus.Cancelado, cancelled.Status);
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, BillingCycle cycle, string? orderId)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = cycle, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = ClientProductStatus.Pendiente, BillingCycle = cycle, Price = 120, PayPalOrderId = orderId };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static string Event(string id, string type, string resource, ClientProduct item) =>
        $$"""{"id":"{{id}}","event_type":"{{type}}","resource":{{resource.Replace("ITEM", item.Id.ToString())}}}""";

    private static PaymentsController Controller(RtresDbContext db, IPayPalClient payPal, INotificationSender notifications) =>
        new(db, payPal, new PayPalCheckoutService(payPal, new ConfigurationBuilder().Build()), new PayPalPaymentService(db, payPal, notifications, NullLogger<PayPalPaymentService>.Instance), notifications, NullLogger<PaymentsController>.Instance)
        { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static async Task Webhook(RtresDbContext db, IPayPalClient payPal, INotificationSender notifications, string json)
    {
        var controller = Controller(db, payPal, notifications);
        controller.ControllerContext.HttpContext.Request.Body = new MemoryStream(Encoding.UTF8.GetBytes(json));
        Assert.IsType<OkResult>(await controller.Webhook(CancellationToken.None));
    }

    [Fact]
    public async Task Checkout_returns_to_the_calling_portal_and_reuses_the_monthly_plan()
    {
        using var db = TestData.Db(out var seed);
        var payPal = new FakePayPal();
        var checkout = new PayPalCheckoutService(payPal, new ConfigurationBuilder().Build());
        var product = new Product { Name = "Soporte mensual", BillingCycle = BillingCycle.Mensual, BasePrice = 90 };
        var local = new DefaultHttpContext().Request; local.Headers.Origin = "http://localhost:4200";
        var evil = new DefaultHttpContext().Request; evil.Headers.Origin = "https://evil.example";

        var first = new ClientProduct { BillingCycle = BillingCycle.Mensual, Price = 90 };
        await checkout.StartAsync(first, product, local, CancellationToken.None);
        var second = new ClientProduct { BillingCycle = BillingCycle.Mensual, Price = 90 };
        await checkout.StartAsync(second, product, evil, CancellationToken.None);

        Assert.Equal(["http://localhost:4200/billing/return", "https://portal.rtres.net/billing/return"], payPal.ReturnUrls.Select(x => x.Split('?')[0]));
        Assert.Equal(1, payPal.PlansCreated); // mismo precio base → mismo plan
        Assert.Equal("PLAN-1", first.PayPalPlanId); Assert.Equal("PLAN-1", second.PayPalPlanId); Assert.Equal("SUB-1", first.PayPalSubscriptionId);

        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual, Price = 70 }, product, local, CancellationToken.None);
        Assert.Equal(("PLAN-1", 2), (product.PayPalPlanId, payPal.PlansCreated)); // precio especial → plan propio, el del producto no cambia
        product.BasePrice = 95;
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual }, product, local, CancellationToken.None);
        Assert.Equal(("PLAN-3", 95m), (product.PayPalPlanId, product.PayPalPlanPrice)); // cambió el precio base → plan nuevo

        await Assert.ThrowsAsync<InvalidOperationException>(() => checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual, Price = 0 }, product, local, CancellationToken.None));
    }

    [Fact]
    public async Task Active_subscription_is_confirmed_without_webhook_and_its_sales_are_not_duplicated()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Mensual, orderId: null);
        item.PayPalSubscriptionId = "SUB-7"; db.SaveChanges();
        var next = new DateTime(2026, 11, 1, 10, 0, 0, DateTimeKind.Utc);
        var payPal = new FakePayPal { Subscription = new PayPalSubscriptionInfo("SUB-7", "ACTIVE", next, [new("SALE-1", 90m, "USD")]) };
        var notifications = new FakeNotifications();
        var controller = Controller(db, payPal, notifications);
        controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        await controller.Capture(item.Id, null, CancellationToken.None);
        Assert.Equal((ClientProductStatus.Activo, next), (item.Status, item.NextChargeAt));
        Assert.Equal("SALE-1", (await db.PaymentTransactions.SingleAsync()).PayPalOrderIdOrSubscriptionId);

        // Llega después el webhook del mismo cobro: se encuentra el producto por billing_agreement_id y no se duplica.
        await Webhook(db, payPal, notifications, Event("WH-9", "PAYMENT.SALE.COMPLETED", """{"id":"SALE-1","billing_agreement_id":"SUB-7","amount":{"total":"90.00","currency":"USD"}}""", item));
        Assert.Single(db.PaymentTransactions);
        Assert.Single(notifications.Sent);

        // El cobro del mes siguiente solo llega por webhook y sí se registra.
        await Webhook(db, payPal, notifications, Event("WH-10", "PAYMENT.SALE.COMPLETED", """{"id":"SALE-2","billing_agreement_id":"SUB-7","amount":{"total":"90.00","currency":"USD"}}""", item));
        Assert.Equal(2, await db.PaymentTransactions.CountAsync());
    }

    [Fact]
    public void Parses_paypal_subscription_and_transactions()
    {
        var info = PayPalClient.ParseSubscription(
            """{"id":"SUB-7","status":"ACTIVE","billing_info":{"next_billing_time":"2026-11-01T10:00:00Z"}}""",
            """{"transactions":[{"id":"SALE-1","status":"COMPLETED","amount_with_breakdown":{"gross_amount":{"currency_code":"USD","value":"90.00"}},"time":"2026-10-01T10:00:00Z"},{"id":"SALE-0","status":"DECLINED","amount_with_breakdown":{"gross_amount":{"currency_code":"USD","value":"90.00"}}}]}""");
        Assert.Equal(("SUB-7", "ACTIVE", new DateTime(2026, 11, 1, 10, 0, 0, DateTimeKind.Utc)), (info.Id, info.Status, info.NextBillingTime));
        Assert.Equal([new PayPalSubscriptionPayment("SALE-1", 90m, "USD")], info.Payments);
    }

    private sealed class FakePayPal : IPayPalClient
    {
        public string CaptureStatus { get; init; } = "COMPLETED";
        public int Captures { get; private set; }
        public int PlansCreated { get; private set; }
        public List<string> ReturnUrls { get; } = [];
        public PayPalSubscriptionInfo? Subscription { get; set; }
        public Dictionary<string, PayPalSubscriptionInfo?> Subscriptions { get; } = [];
        public Task<string> CreateMonthlyPlanAsync(string name, decimal price, string currency, CancellationToken cancellationToken = default) => Task.FromResult($"PLAN-{++PlansCreated}");
        public Task<PayPalSubscriptionInfo> GetSubscriptionAsync(string subscriptionId, CancellationToken cancellationToken = default) =>
            Subscriptions.TryGetValue(subscriptionId, out var info) ? (info is null ? throw new HttpRequestException("PayPal caído") : Task.FromResult(info)) : Task.FromResult(Subscription!);
        public Task<PayPalCapture> CaptureOrderAsync(string orderId, CancellationToken cancellationToken = default)
        {
            Captures++;
            return Task.FromResult(new PayPalCapture(orderId, CaptureStatus, CaptureStatus == "COMPLETED" ? 120m : null, "USD"));
        }
        public Task<PayPalCheckout> CreateOrderAsync(decimal amount, string currency, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default) { ReturnUrls.Add(returnUrl); return Task.FromResult(new PayPalCheckout("ORD-NEW", "https://paypal/approve")); }
        public Task<PayPalCheckout> CreateSubscriptionAsync(string planId, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default) { ReturnUrls.Add(returnUrl); return Task.FromResult(new PayPalCheckout($"SUB-{ReturnUrls.Count}", "https://paypal/approve")); }
        public Task CancelSubscriptionAsync(string subscriptionId, string reason, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<bool> VerifyWebhookAsync(string payload, IReadOnlyDictionary<string, string> headers, CancellationToken cancellationToken = default) => Task.FromResult(true);
    }
}
