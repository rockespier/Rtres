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
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class TransferReportTests
{
    [Fact]
    public async Task Reported_transfer_is_reviewed_and_approval_activates_the_product()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, manual: true);
        var account = AddAccount(db, "USD");
        var notifications = new FakeNotifications();

        var created = await Client(db, seed, notifications).Report(item.Id, Request(account, operation: "OP-123"), CancellationToken.None);
        Assert.IsType<CreatedResult>(created);
        var report = await db.TransferReports.SingleAsync();
        Assert.Equal((TransferReportStatus.Pendiente, "USD", 120m), (report.Status, report.Currency, report.Amount));
        Assert.Equal(NotificationType.TransferReported, Assert.Single(notifications.Sent).Type);
        Assert.Equal("equipo@rtres.net", notifications.Sent[0].To);
        // Mientras se revisa, no se puede reportar otro pago del mismo producto.
        Assert.IsType<ConflictObjectResult>(await Client(db, seed, notifications).Report(item.Id, Request(account, operation: "OP-999"), CancellationToken.None));

        Assert.IsType<OkObjectResult>(await Admin(db, notifications).Approve(report.Id, new ApproveTransferRequest(null, null, null), CancellationToken.None));
        await db.Entry(item).ReloadAsync();
        var payment = await db.PaymentTransactions.SingleAsync();
        Assert.Equal((ClientProductStatus.Activo, "TRF-OP-123", PaymentMethods.Transferencia, 120m), (item.Status, payment.PayPalOrderIdOrSubscriptionId, payment.Method, payment.Amount));
        Assert.NotNull(item.RenewsAt);
        await db.Entry(report).ReloadAsync();
        Assert.Equal((TransferReportStatus.Aprobado, payment.Id), (report.Status, report.PaymentTransactionId));
        Assert.Contains(notifications.Sent, x => x.Type == NotificationType.PaymentReceived);
        // Ya revisado: no se aprueba ni rechaza dos veces.
        Assert.IsType<ConflictObjectResult>(await Admin(db, notifications).Approve(report.Id, new ApproveTransferRequest(null, null, null), CancellationToken.None));
    }

    [Fact]
    public async Task Rejection_notifies_the_reason_and_the_client_can_report_again()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, manual: true);
        var account = AddAccount(db, "USD");
        var notifications = new FakeNotifications();
        await Client(db, seed, notifications).Report(item.Id, Request(account, operation: "OP-1"), CancellationToken.None);
        var report = await db.TransferReports.SingleAsync();

        Assert.IsType<BadRequestObjectResult>(await Admin(db, notifications).Reject(report.Id, new RejectTransferRequest(" "), CancellationToken.None));
        Assert.IsType<OkObjectResult>(await Admin(db, notifications).Reject(report.Id, new RejectTransferRequest("No encontramos el abono en la cuenta."), CancellationToken.None));
        var rejected = Assert.Single(notifications.Sent, x => x.Type == NotificationType.TransferRejected);
        Assert.Equal("No encontramos el abono en la cuenta.", rejected.Data["reason"]);
        Assert.Null(rejected.To); // va al cliente, no al equipo
        await db.Entry(item).ReloadAsync();
        Assert.Equal(ClientProductStatus.Pendiente, item.Status);

        // El mismo N° de operación se puede volver a reportar tras un rechazo (p. ej. con la constancia correcta).
        Assert.IsType<CreatedResult>(await Client(db, seed, notifications).Report(item.Id, Request(account, operation: "OP-1"), CancellationToken.None));
    }

    [Fact]
    public async Task Report_needs_operation_number_or_a_valid_receipt()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, manual: true);
        var account = AddAccount(db, "PEN");
        var client = Client(db, seed, new FakeNotifications());

        Assert.IsType<BadRequestObjectResult>(await client.Report(item.Id, Request(account, operation: null), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await client.Report(item.Id, Request(account, operation: null), CancellationToken.None, File("virus.exe", "application/x-msdownload")));
        Assert.IsType<BadRequestObjectResult>(await client.Report(item.Id, Request(account, operation: "1", accountId: Guid.NewGuid()), CancellationToken.None));
        Assert.IsType<CreatedResult>(await client.Report(item.Id, Request(account, operation: null), CancellationToken.None, File("constancia.jpg", "image/jpeg")));

        var report = await db.TransferReports.SingleAsync();
        Assert.Equal(("constancia.jpg", "image/jpeg", "PEN"), (report.ReceiptFileName, report.ReceiptContentType, report.Currency));
        var receipt = Assert.IsType<FileContentResult>(await client.Receipt(report.Id, CancellationToken.None));
        Assert.Equal("image/jpeg", receipt.ContentType);
        // Otro cliente no ve la constancia.
        var other = new Client { CompanyName = "Otra" }; db.Clients.Add(other); db.SaveChanges();
        Assert.IsType<NotFoundResult>(await Controller(db, new FakeNotifications(), new Claim("client_id", other.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")).Receipt(report.Id, CancellationToken.None));
    }

    [Fact]
    public async Task Only_products_due_for_payment_can_be_reported()
    {
        using var db = TestData.Db(out var seed);
        var active = AddProduct(db, seed, ClientProductStatus.Activo, manual: true, renewsAt: DateTime.UtcNow.AddMonths(6));
        var paypal = AddProduct(db, seed, ClientProductStatus.Pendiente, manual: false);
        var account = AddAccount(db, "USD");
        var client = Client(db, seed, new FakeNotifications());

        Assert.IsType<BadRequestObjectResult>(await client.Report(active.Id, Request(account, "A"), CancellationToken.None)); // falta mucho para renovar
        Assert.IsType<BadRequestObjectResult>(await client.Report(paypal.Id, Request(account, "B"), CancellationToken.None)); // se paga por PayPal

        // Con PayPal deshabilitado, un producto contratado por PayPal (sin suscripción que cobre sola) se puede pagar por transferencia.
        db.PaymentSettings.Add(new PaymentSettings { PayPalEnabled = false }); db.SaveChanges();
        Assert.IsType<CreatedResult>(await client.Report(paypal.Id, Request(account, "B"), CancellationToken.None));
        var report = await db.TransferReports.SingleAsync();
        await Admin(db, new FakeNotifications()).Approve(report.Id, new ApproveTransferRequest(null, null, null), CancellationToken.None);
        await db.Entry(paypal).ReloadAsync();
        Assert.True(paypal.IsManualBilling); // las próximas renovaciones van por transferencia
    }

    [Fact]
    public async Task Payment_methods_can_be_toggled_but_not_both_off()
    {
        using var db = TestData.Db(out var seed);
        var admin = Admin(db, new FakeNotifications());

        Assert.IsType<BadRequestObjectResult>(await admin.UpdatePaymentSettings(new PaymentSettingsRequest(false, false), CancellationToken.None));
        Assert.IsType<OkObjectResult>(await admin.UpdatePaymentSettings(new PaymentSettingsRequest(false, null), CancellationToken.None));

        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120, IsActive = true };
        db.Products.Add(product); db.SaveChanges();
        var payments = PayPalPaymentTests.PaymentsControllerFor(db);
        payments.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));
        Assert.IsType<BadRequestObjectResult>(await payments.Subscribe(new SubscribeRequest(product.Id, seed.Project.Id, BillingCycle.Anual, PaymentMethods.PayPal), CancellationToken.None));

        // Sin cuentas activas no se puede habilitar la transferencia ni dejar a la última sin desactivar la transferencia.
        Assert.IsType<OkObjectResult>(await admin.UpdatePaymentSettings(new PaymentSettingsRequest(true, false), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await admin.UpdatePaymentSettings(new PaymentSettingsRequest(null, true), CancellationToken.None));
        var account = AddAccount(db, "PEN");
        Assert.IsType<OkObjectResult>(await admin.UpdatePaymentSettings(new PaymentSettingsRequest(null, true), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await admin.DeleteAccount(account.Id, CancellationToken.None));
    }

    [Fact]
    public async Task Client_without_projects_gets_one_named_after_the_product()
    {
        using var db = TestData.Db(out var seed);
        db.Projects.Add(new Project { ClientId = Guid.NewGuid(), Name = "Otro", Slug = "cabalgatas-andinas-hosting-web" }); // slug ya usado por otro cliente
        var product = new Product { Name = "Hosting Web", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120, IsActive = true };
        db.Products.Add(product); db.SaveChanges();
        var payments = PayPalPaymentTests.PaymentsControllerFor(db);
        payments.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        Assert.IsType<OkObjectResult>(await payments.Subscribe(new SubscribeRequest(product.Id, null, BillingCycle.Anual, PaymentMethods.Transferencia), CancellationToken.None));
        var item = await db.ClientProducts.SingleAsync();
        var project = await db.Projects.SingleAsync(x => x.Id == item.ProjectId);
        Assert.Equal((seed.Client.Id, "Hosting Web", "cabalgatas-andinas-hosting-web-2"), (project.ClientId, project.Name, project.Slug));
    }

    [Theory]
    [InlineData("BCP", "Rtres SAC", "PEN", "191 2345678 0 12", "00219100234567801252", null)]
    [InlineData("BCP", "Rtres SAC", "USD", "1912345678112", null, null)]
    [InlineData("BCP", "Rtres SAC", "GBP", "1912345678112", null, "La moneda debe ser PEN, USD o EUR.")]
    [InlineData("BCP", "Rtres SAC", "PEN", "1912345678112", "123", "El CCI tiene 20 dígitos.")]
    [InlineData("", "Rtres SAC", "PEN", "1912345678112", null, "El banco y el titular son obligatorios.")]
    public void Bank_accounts_are_validated(string bank, string holder, string currency, string number, string? cci, string? error)
    {
        var account = new BankAccount();
        Assert.Equal(error, BankTransfersController.Apply(account, new BankAccountRequest(bank, holder, currency, BankAccountType.Ahorros, number, cci)));
        if (error is null) Assert.DoesNotContain(" ", account.AccountNumber); // se guardan sin espacios
    }

    [Fact]
    public async Task Transfer_info_lists_active_accounts_with_amount_in_their_currency()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, manual: true);
        AddAccount(db, "PEN"); AddAccount(db, "USD"); AddAccount(db, "EUR", active: false);
        db.ExchangeRates.Add(new ExchangeRate { Date = DateOnly.FromDateTime(DateTime.UtcNow), CurrencyCode = "USD", RateToPen = 3.5m, Source = "test" }); db.SaveChanges();

        var info = await new BankTransferService(db, new ConfigurationBuilder().Build()).InfoAsync(item, 0m, 1, CancellationToken.None);
        Assert.Equal(["USD", "PEN"], info.Accounts.Select(x => x.Currency)); // primero la moneda del producto; la inactiva no aparece
        Assert.Equal((null, 420m), (info.Accounts[0].ApproxAmount, info.Accounts[1].ApproxAmount));
    }

    private static TransferReportRequest Request(BankAccount account, string? operation, Guid? accountId = null) =>
        new() { BankAccountId = accountId ?? account.Id, Amount = 120m, PaidAt = DateOnly.FromDateTime(DateTime.UtcNow), OperationNumber = operation };

    private static FormFile File(string name, string type)
    {
        var bytes = Encoding.UTF8.GetBytes("contenido");
        return new FormFile(new MemoryStream(bytes), 0, bytes.Length, "receipt", name) { Headers = new HeaderDictionary(), ContentType = type };
    }

    private static BankTransfersController Client(RtresDbContext db, Seed seed, FakeNotifications notifications) =>
        Controller(db, notifications, new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente"), new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()));

    private static BankTransfersController Admin(RtresDbContext db, FakeNotifications notifications) =>
        Controller(db, notifications, new Claim(ClaimTypes.Role, nameof(UserRole.SuperAdmin)), new Claim(ClaimTypes.NameIdentifier, Guid.NewGuid().ToString()));

    private static BankTransfersController Controller(RtresDbContext db, FakeNotifications notifications, params Claim[] claims)
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Notifications:StaffEmail"] = "equipo@rtres.net" }).Build();
        var payments = new PayPalPaymentService(db, null!, notifications, PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);
        return new BankTransfersController(db, new BankTransferService(db, config), payments, notifications, config, NullLogger<BankTransfersController>.Instance)
        { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(new ClaimsIdentity(claims, "test")) } } };
    }

    private static BankAccount AddAccount(RtresDbContext db, string currency, bool active = true)
    {
        var account = new BankAccount { BankName = "BCP", Holder = "Rtres SAC", Currency = currency, AccountNumber = $"191{currency}{Guid.NewGuid():N}"[..20], IsActive = active };
        db.BankAccounts.Add(account); db.SaveChanges();
        return account;
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, ClientProductStatus status, bool manual, DateTime? renewsAt = null)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120, Currency = "USD" };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = status, BillingCycle = BillingCycle.Anual, RenewsAt = renewsAt, IsManualBilling = manual };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }
}
