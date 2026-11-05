using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class TaxDocumentReversalTests
{
    static readonly CancellationToken Ct = CancellationToken.None;

    [Fact]
    public async Task Reversal_removes_document_and_payment_restores_the_period_and_leaves_a_record()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        var renewsAt = DateTime.UtcNow.AddMonths(6);
        item.RenewsAt = renewsAt; item.Status = ClientProductStatus.Activo; item.IsManualBilling = true; db.SaveChanges();
        await Payments(db).ApplyPaymentAsync(item, "TRF-1", 236m, "PEN", Ct, PaymentMethods.Transferencia, years: 2);
        Assert.Equal(renewsAt.AddYears(2), item.RenewsAt);

        var result = await Service(db).ReverseAsync(db.TaxDocuments.Single().Id, "Monto equivocado", false, null, Ct);

        Assert.NotNull(result);
        Assert.Empty(db.TaxDocuments); Assert.Empty(db.TaxDocumentLines); Assert.Empty(db.PaymentTransactions);
        Assert.Equal(renewsAt, item.RenewsAt);
        var record = db.PaymentReversals.Single();
        Assert.Equal(("TRF-1", 236m, "F001", 1, "Monto equivocado"), (record.PaymentKey, record.Amount, record.Series, record.Number, record.Reason));
    }

    [Fact]
    public async Task A_reversed_transfer_can_be_registered_again_but_a_paypal_charge_is_not_recreated()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        var payments = Payments(db);
        await payments.ApplyPaymentAsync(item, "TRF-1", 118m, "PEN", Ct, PaymentMethods.Transferencia);
        await payments.ApplyPaymentAsync(item, "SALE-1", 118m, "PEN", Ct);
        foreach (var document in db.TaxDocuments.ToList()) await Service(db).ReverseAsync(document.Id, "Error", false, null, Ct);

        Assert.True(await payments.ApplyPaymentAsync(item, "TRF-1", 118m, "PEN", Ct, PaymentMethods.Transferencia));
        Assert.False(await payments.ApplyPaymentAsync(item, "SALE-1", 118m, "PEN", Ct));
    }

    [Fact]
    public async Task Correlative_is_released_only_when_not_issued_and_last_of_the_series()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        var payments = Payments(db);
        await payments.ApplyPaymentAsync(item, "ORD-1", 118m, "PEN", Ct);
        await payments.ApplyPaymentAsync(item, "ORD-2", 118m, "PEN", Ct);
        await payments.ApplyPaymentAsync(item, "ORD-3", 118m, "PEN", Ct);
        Guid Doc(int number) => db.TaxDocuments.Single(x => x.Number == number).Id;

        Assert.False((await Service(db).ReverseAsync(Doc(1), "No es el último", true, null, Ct))!.NumberReleased);
        Assert.False((await Service(db).ReverseAsync(Doc(3), "Sí se emitió", false, null, Ct))!.NumberReleased);
        Assert.Equal(4, db.TaxSettings.Single().FacturaNextNumber);

        await payments.ApplyPaymentAsync(item, "ORD-4", 118m, "PEN", Ct);
        Assert.True((await Service(db).ReverseAsync(Doc(4), "No se emitió", true, null, Ct))!.NumberReleased);
        await payments.ApplyPaymentAsync(item, "ORD-5", 118m, "PEN", Ct);
        Assert.Equal(4, db.TaxDocuments.Single(x => x.Number > 2).Number);
    }

    [Fact]
    public async Task Internal_codes_do_not_repeat_after_deleting_a_payment_in_the_middle()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        var payments = Payments(db);
        foreach (var key in new[] { "ORD-1", "ORD-2", "ORD-3" }) await payments.ApplyPaymentAsync(item, key, 118m, "PEN", Ct);
        await Service(db).ReverseAsync(db.TaxDocuments.Single(x => x.Number == 2).Id, "Error", false, null, Ct);

        await payments.ApplyPaymentAsync(item, "ORD-4", 118m, "PEN", Ct);

        Assert.Equal("RT-INT-000004", db.PaymentTransactions.Single(x => x.PayPalOrderIdOrSubscriptionId == "ORD-4").InternalCode);
    }

    [Fact]
    public async Task First_payment_of_a_client_contracted_product_goes_back_to_pending_with_its_discount_unused()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        item.Discount = 10m; db.SaveChanges();
        await Payments(db).ApplyPaymentAsync(item, "ORD-1", 118m, "PEN", Ct);
        Assert.NotNull(item.DiscountEndsAt);

        await Service(db).ReverseAsync(db.TaxDocuments.Single().Id, "Error", false, null, Ct);

        Assert.Equal(ClientProductStatus.Pendiente, item.Status);
        Assert.Null(item.RenewsAt); Assert.Null(item.DiscountEndsAt); Assert.Equal(10m, item.Discount);
    }

    [Fact]
    public async Task Approved_transfer_report_is_rejected_so_the_client_can_report_again()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        await Payments(db).ApplyPaymentAsync(item, "TRF-1", 118m, "PEN", Ct, PaymentMethods.Transferencia);
        var payment = db.PaymentTransactions.Single();
        var report = new TransferReport { ClientId = seed.Client.Id, ClientProductId = item.Id, Amount = 118m, Status = TransferReportStatus.Aprobado, PaymentTransactionId = payment.Id };
        db.TransferReports.Add(report); db.SaveChanges();

        await Service(db).ReverseAsync(db.TaxDocuments.Single().Id, "Voucher falso", false, null, Ct);

        Assert.Equal((TransferReportStatus.Rechazado, "Pago extornado: Voucher falso", (Guid?)null), (report.Status, report.RejectionReason, report.PaymentTransactionId));
        Assert.Equal(ClientProductStatus.Pendiente, item.Status);
    }

    [Fact]
    public async Task Unknown_document_returns_null()
    {
        using var db = TestData.Db(out _);
        Assert.Null(await Service(db).ReverseAsync(Guid.NewGuid(), "Error", false, null, Ct));
    }

    private static TaxDocumentService Service(RtresDbContext db) => PayPalPaymentTests.TaxDocuments(db);
    private static PayPalPaymentService Payments(RtresDbContext db) => new(db, null!, new FakeNotifications(), Service(db), NullLogger<PayPalPaymentService>.Instance);

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed)
    {
        seed.Client.RequiresTaxDocument = true;
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, TaxDocumentType = TaxDocumentType.Factura };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = ClientProductStatus.Pendiente, BillingCycle = BillingCycle.Anual };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }
}
