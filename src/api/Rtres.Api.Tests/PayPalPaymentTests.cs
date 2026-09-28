using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
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

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, BillingCycle cycle, string orderId)
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

    private sealed class FakePayPal : IPayPalClient
    {
        public string CaptureStatus { get; init; } = "COMPLETED";
        public int Captures { get; private set; }
        public Task<PayPalCapture> CaptureOrderAsync(string orderId, CancellationToken cancellationToken = default)
        {
            Captures++;
            return Task.FromResult(new PayPalCapture(orderId, CaptureStatus, CaptureStatus == "COMPLETED" ? 120m : null, "USD"));
        }
        public Task<PayPalCheckout> CreateOrderAsync(decimal amount, string currency, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<PayPalCheckout> CreateSubscriptionAsync(string planId, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task CancelSubscriptionAsync(string subscriptionId, string reason, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<bool> VerifyWebhookAsync(string payload, IReadOnlyDictionary<string, string> headers, CancellationToken cancellationToken = default) => Task.FromResult(true);
    }
}
