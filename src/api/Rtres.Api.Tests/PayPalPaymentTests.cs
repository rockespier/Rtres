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
    public async Task Captured_prepaid_order_extends_the_years_it_was_created_for()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-3Y");
        item.PayPalOrderYears = 3; db.SaveChanges();
        await Webhook(db, new FakePayPal(), new FakeNotifications(), Event("WH-1", "CHECKOUT.ORDER.APPROVED", """{"id":"ORD-3Y"}""", item));
        Assert.InRange(item.RenewsAt!.Value, DateTime.UtcNow.AddYears(3).AddMinutes(-1), DateTime.UtcNow.AddYears(3).AddMinutes(1));
        Assert.Equal(3, (await db.PaymentTransactions.SingleAsync()).Years);
    }

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
        var service = new PayPalPaymentService(db, payPal, notifications, TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

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

        await new PayPalReconciliationJob(db, new PayPalPaymentService(db, payPal, new FakeNotifications(), TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance), NullLogger<PayPalReconciliationJob>.Instance).ReconcileAsync(CancellationToken.None);

        Assert.Equal(ClientProductStatus.Activo, broken.Status);
        Assert.Equal(ClientProductStatus.Cancelado, cancelled.Status);
    }

    [Theory]
    [InlineData(20, true)]    // vence dentro de 30 días: se puede pagar la renovación aunque siga "Activo"
    [InlineData(60, false)]   // aún falta mucho
    public async Task Renewal_can_be_paid_within_30_days_of_expiry(int daysLeft, bool allowed)
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-OLD");
        item.Status = ClientProductStatus.Activo; item.RenewsAt = DateTime.UtcNow.AddDays(daysLeft); db.SaveChanges();
        var controller = Controller(db, new FakePayPal(), new FakeNotifications());
        controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        var result = await controller.Renew(item.Id, null, CancellationToken.None);

        Assert.Equal(allowed, result is OkObjectResult);
        Assert.Equal(allowed ? "ORD-NEW" : "ORD-OLD", item.PayPalOrderId);
    }

    [Fact]
    public async Task Billing_shows_own_payments_to_clients_and_all_or_selected_to_superadmin()
    {
        using var db = TestData.Db(out var seed);
        var mine = AddProduct(db, seed, BillingCycle.Anual, orderId: "ORD-A");
        var otherClient = new Client { CompanyName = "Selva Viva", Email = "s@example.com" };
        var otherProject = new Project { ClientId = otherClient.Id, Name = "Selva", Slug = "selva" };
        db.AddRange(otherClient, otherProject); db.SaveChanges();
        var theirs = AddProduct(db, new Seed(otherClient, otherProject, seed.Ticket, seed.User), BillingCycle.Anual, orderId: "ORD-B");
        db.PaymentTransactions.AddRange(new PaymentTransaction { ClientId = seed.Client.Id, ClientProductId = mine.Id, PayPalOrderIdOrSubscriptionId = "ORD-A", Amount = 120, InternalCode = "RT-INT-000001" }, new PaymentTransaction { ClientId = otherClient.Id, ClientProductId = theirs.Id, PayPalOrderIdOrSubscriptionId = "ORD-B", Amount = 120, InternalCode = "RT-INT-000002" });
        db.SaveChanges();

        async Task<int> Count(ClaimsPrincipal user, Guid? clientId)
        {
            var controller = new AccountController(db, ClientOnboardingTests.AccessEmail(db, new FakeEmail())) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = user } } };
            var ok = Assert.IsType<OkObjectResult>(await controller.Transactions(clientId, CancellationToken.None));
            return ((System.Collections.IEnumerable)ok.Value!).Cast<object>().Count();
        }
        var client = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));
        var superAdmin = new ClaimsPrincipal(new ClaimsIdentity([new Claim(ClaimTypes.Role, "SuperAdmin")], "test"));

        Assert.Equal(1, await Count(client, otherClient.Id));   // un cliente no puede ver pagos ajenos pasando clientId
        Assert.Equal(2, await Count(superAdmin, null));          // SuperAdmin sin selección: todos
        Assert.Equal(1, await Count(superAdmin, otherClient.Id)); // SuperAdmin con cliente seleccionado
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

    internal static PaymentsController PaymentsControllerFor(RtresDbContext db, INotificationSender? notifications = null) => Controller(db, new FakePayPal(), notifications ?? new FakeNotifications());

    private static PaymentsController Controller(RtresDbContext db, IPayPalClient payPal, INotificationSender notifications) =>
        new(db, payPal, new PayPalCheckoutService(payPal, new ConfigurationBuilder().Build()), new PayPalPaymentService(db, payPal, notifications, TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance), notifications, new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["BankTransfer:Instructions"] = "BCP Soles 123-456", ["Notifications:StaffEmail"] = "equipo@rtres.net" }).Build(), NullLogger<PaymentsController>.Instance)
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

        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual, Discount = 20 }, product, local, CancellationToken.None);
        Assert.Equal(("PLAN-1", 2), (product.PayPalPlanId, payPal.PlansCreated)); // descuento → plan propio, el del producto no cambia
        Assert.Equal((90m, (decimal?)70m), payPal.Plans[^1]); // solo el primer mes rebajado, luego precio de catálogo
        product.BasePrice = 95;
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual }, product, local, CancellationToken.None);
        Assert.Equal(("PLAN-3", 95m), (product.PayPalPlanId, product.PayPalPlanPrice)); // cambió el precio base → plan nuevo

        await Assert.ThrowsAsync<InvalidOperationException>(() => checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual, Discount = 95 }, product, local, CancellationToken.None));
    }

    [Fact]
    public async Task Bimonthly_quarterly_and_semiannual_cycles_are_subscriptions_every_2_3_and_6_months()
    {
        using var db = TestData.Db(out _);
        var payPal = new FakePayPal();
        var checkout = new PayPalCheckoutService(payPal, new ConfigurationBuilder().Build());
        var quarterly = new Product { Name = "Soporte", BillingCycle = BillingCycle.Trimestral, BasePrice = 250 };

        var item = new ClientProduct { BillingCycle = BillingCycle.Trimestral };
        await checkout.StartAsync(item, quarterly, null, CancellationToken.None);
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Trimestral }, quarterly, null, CancellationToken.None);
        Assert.Equal(("SUB-1", "PLAN-1", 1), (item.PayPalSubscriptionId, quarterly.PayPalPlanId, payPal.PlansCreated)); // suscripción, plan del catálogo reutilizado
        Assert.Empty(payPal.OrderAmounts);

        // Mismo producto asignado con otro ciclo: plan propio, el del catálogo (trimestral) no se toca.
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Semestral }, quarterly, null, CancellationToken.None);
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Bimestral }, quarterly, null, CancellationToken.None);
        Assert.Equal([3, 6, 2], payPal.PlanMonths); Assert.Equal("PLAN-1", quarterly.PayPalPlanId);

        var now = new DateTime(2026, 1, 31, 0, 0, 0, DateTimeKind.Utc);
        foreach (var (cycle, next) in new[] { (BillingCycle.Bimestral, new DateTime(2026, 3, 31)), (BillingCycle.Trimestral, new DateTime(2026, 4, 30)), (BillingCycle.Semestral, new DateTime(2026, 7, 31)) })
        {
            var paid = new ClientProduct { BillingCycle = cycle };
            PayPalPaymentService.ExtendPeriod(paid, now);
            Assert.Equal((next, (DateTime?)null), (paid.NextChargeAt!.Value.Date, paid.RenewsAt));
            Assert.NotNull(paid.ValidateYears(2)); // varios años por adelantado: solo Anual
        }
    }

    [Fact]
    public async Task Paypal_charges_add_igv_for_peruvian_invoices()
    {
        using var db = TestData.Db(out _);
        var payPal = new FakePayPal();
        var checkout = new PayPalCheckoutService(payPal, new ConfigurationBuilder().Build());
        var annual = new Product { Name = "Hosting", BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Anual }, annual, null, CancellationToken.None, 0.18m);
        Assert.Equal(141.60m, payPal.OrderAmounts.Single());

        // Tres años por adelantado: una sola orden por el total, y la orden recuerda los años para cuando se capture.
        var prepaid = new ClientProduct { BillingCycle = BillingCycle.Anual };
        await checkout.StartAsync(prepaid, annual, null, CancellationToken.None, 0.18m, years: 3);
        Assert.Equal((424.80m, (int?)3), (payPal.OrderAmounts[^1], prepaid.PayPalOrderYears));

        // Mensual con descuento de 20: primer mes (100 + IGV) = 118, luego catálogo (120 + IGV) = 141.60.
        var monthly = new Product { Name = "Soporte", BillingCycle = BillingCycle.Mensual, BasePrice = 120 };
        await checkout.StartAsync(new ClientProduct { BillingCycle = BillingCycle.Mensual, Discount = 20 }, monthly, null, CancellationToken.None, 0.18m);
        Assert.Equal((141.60m, (decimal?)118m), payPal.Plans[^1]);
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
        public List<int> PlanMonths { get; } = [];
        public List<string> ReturnUrls { get; } = [];
        public PayPalSubscriptionInfo? Subscription { get; set; }
        public Dictionary<string, PayPalSubscriptionInfo?> Subscriptions { get; } = [];
        public List<(decimal Price, decimal? FirstCycle)> Plans { get; } = [];
        public Task<string> CreatePlanAsync(string name, decimal price, string currency, int intervalMonths, decimal? firstCyclePrice = null, CancellationToken cancellationToken = default) { Plans.Add((price, firstCyclePrice)); PlanMonths.Add(intervalMonths); return Task.FromResult($"PLAN-{++PlansCreated}"); }
        public Task<PayPalSubscriptionInfo> GetSubscriptionAsync(string subscriptionId, CancellationToken cancellationToken = default) =>
            Subscriptions.TryGetValue(subscriptionId, out var info) ? (info is null ? throw new HttpRequestException("PayPal caído") : Task.FromResult(info)) : Task.FromResult(Subscription!);
        public Task<PayPalCapture> CaptureOrderAsync(string orderId, CancellationToken cancellationToken = default)
        {
            Captures++;
            return Task.FromResult(new PayPalCapture(orderId, CaptureStatus, CaptureStatus == "COMPLETED" ? 120m : null, "USD"));
        }
        public List<decimal> OrderAmounts { get; } = [];
        public Task<PayPalCheckout> CreateOrderAsync(decimal amount, string currency, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default) { ReturnUrls.Add(returnUrl); OrderAmounts.Add(amount); return Task.FromResult(new PayPalCheckout("ORD-NEW", "https://paypal/approve")); }
        public Task<PayPalCheckout> CreateSubscriptionAsync(string planId, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default) { ReturnUrls.Add(returnUrl); return Task.FromResult(new PayPalCheckout($"SUB-{ReturnUrls.Count}", "https://paypal/approve")); }
        public Task CancelSubscriptionAsync(string subscriptionId, string reason, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<bool> VerifyWebhookAsync(string payload, IReadOnlyDictionary<string, string> headers, CancellationToken cancellationToken = default) => Task.FromResult(true);
    }

    internal static TaxDocumentService TaxDocuments(RtresDbContext db) => new(db, NullLogger<TaxDocumentService>.Instance);
}
