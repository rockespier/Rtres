using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class BankTransferTests
{
    [Fact]
    public async Task Transfer_payment_confirmed_by_rtres_activates_the_product_like_paypal()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, null);
        var notifications = new FakeNotifications();
        var payments = new PayPalPaymentService(db, null!, notifications, PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);
        var admin = Admin(db);

        var ok = Assert.IsType<OkObjectResult>(await admin.RegisterTransferPayment(item.Id, new TransferPaymentRequest(null, new DateOnly(2026, 9, 1), "OP-555"), payments, CancellationToken.None));
        Assert.Equal(ClientProductStatus.Activo, item.Status);
        Assert.Equal(new DateTime(2027, 9, 1, 12, 0, 0, DateTimeKind.Utc), item.RenewsAt); // un año desde la fecha de pago
        var tx = await db.PaymentTransactions.SingleAsync();
        Assert.Equal((PaymentMethods.Transferencia, 141.60m /* cliente en Perú: 120 + IGV */, "TRF-OP-555", new DateTime(2026, 9, 1, 12, 0, 0, DateTimeKind.Utc)), (tx.Method, tx.Amount, tx.PayPalOrderIdOrSubscriptionId, tx.CreatedAt));
        Assert.Single(db.TaxDocuments); // cliente en Perú: comprobante emitido
        Assert.Equal(NotificationType.PaymentReceived, Assert.Single(notifications.Sent).Type);

        // La misma operación no se registra dos veces.
        Assert.IsType<ConflictObjectResult>(await admin.RegisterTransferPayment(item.Id, new TransferPaymentRequest(null, null, "OP-555"), payments, CancellationToken.None));
    }

    [Theory]
    [InlineData(true, TaxDocumentType.Factura, 141.60, true)]               // Perú + Factura: catálogo 120 + IGV
    [InlineData(true, TaxDocumentType.ReciboPorHonorarios, 120, false)]     // recibo por honorarios: sin IGV
    [InlineData(false, TaxDocumentType.Factura, 120, false)]                // cliente del exterior: sin IGV
    public async Task Catalog_prices_are_without_igv_and_it_is_added_only_to_peruvian_invoices(bool peru, TaxDocumentType taxType, decimal expected, bool includesIgv)
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = peru; db.SaveChanges();
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, null);
        item.Product!.TaxDocumentType = taxType; db.SaveChanges();
        var controller = PayPalPaymentTests.PaymentsControllerFor(db);
        controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        var info = Assert.IsType<BankTransferInfoDto>(Assert.IsType<OkObjectResult>(await controller.BankTransfer(item.Id, null, CancellationToken.None)).Value);
        Assert.Equal((expected, includesIgv), (info.Amount, info.IncludesIgv));
    }

    [Fact]
    public async Task Registered_transfer_defaults_to_the_total_with_igv_and_the_invoice_splits_it_back()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, null);
        Assert.Null(item.SetDiscount(20)); db.SaveChanges(); // paga 100 + IGV
        var payments = new PayPalPaymentService(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

        Assert.IsType<OkObjectResult>(await Admin(db).RegisterTransferPayment(item.Id, new TransferPaymentRequest(null, null, null), payments, CancellationToken.None));
        Assert.Equal(118m, (await db.PaymentTransactions.SingleAsync()).Amount);
        var invoice = await db.TaxDocuments.SingleAsync();
        Assert.Equal((100m, 18m, 118m), (invoice.BaseAmount, invoice.IgvAmount, invoice.TotalAmount));
    }

    [Fact]
    public async Task Transfer_payment_is_rejected_for_paypal_products()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Activo, DateTime.UtcNow.AddMonths(1));
        item.IsManualBilling = false; db.SaveChanges();
        var payments = new PayPalPaymentService(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);
        Assert.IsType<BadRequestObjectResult>(await Admin(db).RegisterTransferPayment(item.Id, new TransferPaymentRequest(100m, null, null), payments, CancellationToken.None));
        Assert.Empty(db.PaymentTransactions);
    }

    [Fact]
    public async Task Client_can_request_a_product_paying_by_transfer()
    {
        using var db = TestData.Db(out var seed);
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        db.Products.Add(product); db.SaveChanges();
        var notifications = new FakeNotifications();
        var controller = PayPalPaymentTests.PaymentsControllerFor(db, notifications);
        controller.ControllerContext.HttpContext.User = new ClaimsPrincipal(new ClaimsIdentity([new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test"));

        var ok = Assert.IsType<OkObjectResult>(await controller.Subscribe(new SubscribeRequest(product.Id, seed.Project.Id, BillingCycle.Anual, PaymentMethods.Transferencia), CancellationToken.None));
        var item = await db.ClientProducts.SingleAsync();
        Assert.Equal((ClientProductStatus.Pendiente, true, null), (item.Status, item.IsManualBilling, item.PayPalOrderId)); // sin PayPal
        var info = Assert.IsType<BankTransferInfoDto>(ok.Value!.GetType().GetProperty("bankTransfer")!.GetValue(ok.Value));
        Assert.Equal("BCP Soles 123-456", info.Instructions);
        Assert.Equal(120m, info.Amount);

        // Rtres recibe el aviso del pedido (al email del equipo, no al del cliente).
        var notice = Assert.Single(notifications.Sent);
        Assert.Equal((NotificationType.TransferRequested, "equipo@rtres.net", $"transfer-request:{item.Id}"), (notice.Type, notice.To, notice.DedupeKey));
        Assert.Equal((seed.Client.CompanyName, "Hosting", "120"), (notice.Data["company"], notice.Data["product"], notice.Data["amount"]));
    }

    [Fact]
    public void Transfer_request_notice_is_always_in_spanish_and_links_to_the_client()
    {
        var notice = EmailTemplatesTests.Sample(NotificationType.TransferRequested);
        var (subject, html, text) = Rtres.Infrastructure.Notifications.EmailTemplates.Render(notice, "it", "https://portal.rtres.net");
        Assert.Equal("Pedido por transferencia: Andes Tours — Hosting anual", subject);
        Assert.Contains("https://portal.rtres.net/admin/clients/c-1", text);
        Assert.Contains("Registrar pago", text);
        Assert.Contains("Aviso interno", html);
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, ClientProductStatus status, DateTime? renewsAt)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = status, BillingCycle = BillingCycle.Anual, RenewsAt = renewsAt, IsManualBilling = true };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
