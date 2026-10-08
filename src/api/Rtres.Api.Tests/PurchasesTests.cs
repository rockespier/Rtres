using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class PurchasesTests
{
    const int Year = 2026;
    const string Ruc = "20100070970";

    static PurchaseRequest Factura(string number, decimal taxBase, decimal igv, int month = 1, PurchaseDocumentType type = PurchaseDocumentType.Factura, bool createExpense = false, string currency = "PEN") =>
        new(new DateOnly(Year, month, 10), null, type, "F001", number, Ruc, "Proveedor SAC", currency, taxBase, igv, CreateExpense: createExpense, ExpenseCategoryId: ExpenseCategoryIds.Hosting);

    [Fact]
    public async Task Purchase_is_validated_and_its_linked_expense_excludes_recoverable_igv()
    {
        using var db = TestData.Db(out _);
        var admin = Admin(db);

        Assert.IsType<BadRequestObjectResult>(await admin.CreatePurchase(Factura("1", 100, 18) with { SupplierTaxId = "123" }, CancellationToken.None)); // RUC inválido
        Assert.IsType<BadRequestObjectResult>(await admin.CreatePurchase(Factura("1", 100, 18, type: PurchaseDocumentType.Boleta), CancellationToken.None)); // boleta sin IGV
        Assert.IsType<BadRequestObjectResult>(await admin.CreatePurchase(Factura("1", 100, 18) with { Period = "2025-12" }, CancellationToken.None)); // antes de la emisión

        Assert.IsType<CreatedResult>(await admin.CreatePurchase(Factura("00001", 100, 18, createExpense: true), CancellationToken.None));
        Assert.IsType<ConflictObjectResult>(await admin.CreatePurchase(Factura("1", 100, 18), CancellationToken.None)); // mismo comprobante (ceros a la izquierda)

        var purchase = await db.Purchases.SingleAsync();
        Assert.Equal((118m, true, new DateOnly(Year, 1, 1)), (purchase.Total, purchase.GivesTaxCredit, purchase.Period));
        var expense = await db.Expenses.SingleAsync();
        Assert.Equal((purchase.ExpenseId, 100m, ExpenseCategoryIds.Hosting), (expense.Id, expense.Amount, expense.CategoryId)); // el IGV recuperable no es gasto

        // Sin destino a operaciones gravadas no hay crédito fiscal: el gasto pasa a ser el total.
        Assert.IsType<OkObjectResult>(await admin.UpdatePurchase(purchase.Id, Factura("1", 100, 18) with { UsedForTaxedOperations = false }, CancellationToken.None));
        Assert.Equal((false, 118m), (purchase.GivesTaxCredit, (await db.Expenses.SingleAsync()).Amount));

        Assert.IsType<NoContentResult>(await admin.DeletePurchase(purchase.Id, deleteExpense: true, CancellationToken.None));
        Assert.False(await db.Purchases.AnyAsync() || await db.Expenses.AnyAsync());
    }

    [Fact]
    public async Task Igv_cascade_carries_the_credit_balance_to_the_next_month()
    {
        using var db = TestData.Db(out var seed);
        var admin = Admin(db);
        AddFacturaSale(db, seed.Client.Id, new DateOnly(Year, 1, 15), 1000m, 180m, 1);
        AddFacturaSale(db, seed.Client.Id, new DateOnly(Year, 2, 15), 1000m, 180m, 2);
        await admin.CreatePurchase(Factura("10", 1666.67m, 300m), CancellationToken.None);                                        // enero: crédito 300
        await admin.CreatePurchase(Factura("11", 111.11m, 20m, month: 2, type: PurchaseDocumentType.NotaCredito), CancellationToken.None); // febrero: la nota de crédito resta 20

        var january = Igv(Assert.IsType<OkObjectResult>(await admin.TaxSummaryReport(1, Year, CancellationToken.None)).Value!);
        Assert.Equal((180m, 300m, 0m, 0m, 120m), (P(january, "debitoFiscal"), P(january, "creditoFiscal"), P(january, "saldoAFavorAnterior"), P(january, "igvAPagar"), P(january, "saldoAFavorSiguiente")));

        var february = Igv(Assert.IsType<OkObjectResult>(await admin.TaxSummaryReport(2, Year, CancellationToken.None)).Value!);
        Assert.Equal((180m, -20m, 120m, 80m, 0m), (P(february, "debitoFiscal"), P(february, "creditoFiscal"), P(february, "saldoAFavorAnterior"), P(february, "igvAPagar"), P(february, "saldoAFavorSiguiente")));

        var year = Igv(Assert.IsType<OkObjectResult>(await admin.TaxSummaryReport(null, Year, CancellationToken.None)).Value!);
        Assert.Equal((360m, 280m, 80m), (P(year, "debitoFiscal"), P(year, "creditoFiscal"), P(year, "igvAPagar")));

        var list = Assert.IsType<OkObjectResult>(await admin.Purchases(Year, 2, CancellationToken.None)).Value!;
        Assert.Equal(-20m, P(list, "creditoFiscalPen"));
    }

    private static void AddFacturaSale(RtresDbContext db, Guid clientId, DateOnly date, decimal baseAmount, decimal igv, int number)
    {
        var payment = new PaymentTransaction { ClientId = clientId, PayPalOrderIdOrSubscriptionId = Guid.NewGuid().ToString("N"), Amount = baseAmount + igv, Currency = "PEN", AmountPen = baseAmount + igv, Status = "COMPLETED", Method = PaymentMethods.Transferencia, CreatedAt = date.ToDateTime(new TimeOnly(12, 0), DateTimeKind.Utc) };
        db.PaymentTransactions.Add(payment);
        db.TaxDocuments.Add(new TaxDocument { PaymentTransactionId = payment.Id, ClientId = clientId, Type = TaxDocumentType.Factura, Series = "E001", Number = number, IssueDate = date, Currency = "PEN", BaseAmount = baseAmount, IgvAmount = igv, TotalAmount = baseAmount + igv });
        db.SaveChanges();
    }

    private static object Igv(object report) => report.GetType().GetProperty("igv")!.GetValue(report)!;
    private static decimal P(object value, string name) => (decimal)value.GetType().GetProperty(name)!.GetValue(value)!;

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
