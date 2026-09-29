using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class PrepaidYearsTests
{
    [Fact]
    public async Task Three_years_paid_at_once_extend_three_years_with_one_payment_and_one_invoice()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var renewsAt = new DateTime(2026, 10, 15, 12, 0, 0, DateTimeKind.Utc);
        var item = AddProduct(db, seed, BillingCycle.Anual, ClientProductStatus.PorVencer, renewsAt);
        Assert.Null(item.SetDiscount(20)); db.SaveChanges(); // descuento del periodo actual: ya usado

        var ok = Assert.IsType<OkObjectResult>(await Admin(db).RegisterTransferPayment(item.Id, new TransferPaymentRequest(null, new DateOnly(2026, 9, 20), "OP-1", Years: 3), Payments(db), CancellationToken.None));
        Assert.Equal(renewsAt.AddYears(3), item.RenewsAt); // desde el vencimiento actual, sin perder días
        var tx = await db.PaymentTransactions.SingleAsync();
        Assert.Equal((3, 424.80m), (tx.Years, tx.Amount)); // 3 × 120 + IGV (el descuento ya se había usado)
        var invoice = await db.TaxDocuments.SingleAsync();
        Assert.Equal((360m, 64.80m), (invoice.BaseAmount, invoice.IgvAmount));
        Assert.Contains("3 años", invoice.Notes);
        Assert.Null(item.Discount); // la renovación quitó el descuento
    }

    [Fact]
    public async Task Pending_discount_only_lowers_the_first_of_the_prepaid_years()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, BillingCycle.Anual, ClientProductStatus.Pendiente, null);
        Assert.Null(item.SetDiscount(20)); db.SaveChanges();
        Assert.Equal(340m, item.ChargeTotal(0m, 3)); // 100 + 120 + 120

        await Payments(db).ApplyPaymentAsync(item, "TRF-1", 340m, "USD", CancellationToken.None, PaymentMethods.Transferencia, new DateTime(2026, 9, 1, 12, 0, 0, DateTimeKind.Utc), years: 3);
        Assert.Equal(new DateTime(2029, 9, 1, 12, 0, 0, DateTimeKind.Utc), item.RenewsAt);
        Assert.Equal(new DateTime(2027, 9, 1, 12, 0, 0, DateTimeKind.Utc), item.DiscountEndsAt); // el descuento cubre solo el primer año
        Assert.Equal(120m, item.CurrentPrice(new DateTime(2028, 1, 1, 0, 0, 0, DateTimeKind.Utc)));
    }

    [Fact]
    public async Task Only_annual_products_accept_several_years_and_at_most_five()
    {
        using var db = TestData.Db(out var seed);
        var monthly = AddProduct(db, seed, BillingCycle.Mensual, ClientProductStatus.Activo, null);
        var annual = AddProduct(db, seed, BillingCycle.Anual, ClientProductStatus.Activo, DateTime.UtcNow.AddDays(10));
        Assert.IsType<BadRequestObjectResult>(await Admin(db).RegisterTransferPayment(monthly.Id, new TransferPaymentRequest(null, null, null, Years: 2), Payments(db), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await Admin(db).RegisterTransferPayment(annual.Id, new TransferPaymentRequest(null, null, null, Years: 6), Payments(db), CancellationToken.None));
        Assert.Empty(db.PaymentTransactions);
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, BillingCycle cycle, ClientProductStatus status, DateTime? renewsAt)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = cycle, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = status, BillingCycle = cycle, RenewsAt = renewsAt, IsManualBilling = true };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static PayPalPaymentService Payments(RtresDbContext db) =>
        new(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db)) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
