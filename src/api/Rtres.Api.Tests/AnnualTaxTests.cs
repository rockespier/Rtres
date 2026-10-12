using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

/// <summary>Renta anual MYPE y Formulario 1662 (Documentacion/Confirmacion_de_mi_contador.md).</summary>
public class AnnualTaxTests
{
    const int Year = 2025; // año cerrado: sin proyección ni meses futuros

    [Theory]
    [InlineData(50_000, 5_000)]       // caso 1 del contador: no supera 15 UIT
    [InlineData(100_000, 14_436.25)]  // caso 2: 77,250 × 10 % + 22,750 × 29.5 %
    [InlineData(-3_000, 0)]           // con pérdida no hay impuesto
    public void Mype_scale_matches_the_accountant_examples(decimal netIncome, decimal expected)
    {
        var tax = MypeIncomeTax.Compute(netIncome, new AnnualTaxSettings { Year = 2026, Uit = 5_150m });
        Assert.Equal(expected, tax.Total);
    }

    [Fact]
    public async Task Annual_renta_uses_mype_income_deductible_expenses_and_real_advances()
    {
        using var db = TestData.Db(out var seed);
        db.TaxSettings.Add(new TaxSettings { RentaRate = 0.01m });
        db.AnnualTaxSettings.Add(new AnnualTaxSettings { Year = Year, Uit = 5_000m });
        AddSale(db, seed.Client.Id, new DateOnly(Year, 3, 10), 100_000m, null);                                   // sin comprobante: MYPE
        AddSale(db, seed.Client.Id, new DateOnly(Year, 5, 10), 23_600m, TaxDocumentType.Factura, 20_000m);       // factura: MYPE (base sin IGV)
        AddSale(db, seed.Client.Id, new DateOnly(Year, 6, 10), 9_000m, TaxDocumentType.ReciboPorHonorarios, 9_000m, retention: 720m); // persona natural
        var other = db.ExpenseCategories.Add(new ExpenseCategory { Name = "Personal", IsDeductible = false }).Entity;
        db.Expenses.AddRange(
            new Expense { Description = "VPS", CategoryId = ExpenseCategoryIds.Hosting, AmountPen = 10_000m, Amount = 10_000m, Date = new DateOnly(Year, 4, 1) },
            new Expense { Description = "Fracc SUNAT 3/12", CategoryId = ExpenseCategoryIds.Otros, AmountPen = 2_000m, Amount = 2_000m, Date = new DateOnly(Year, 4, 2), IsNonDeductible = true },
            new Expense { Description = "Viaje", CategoryId = other.Id, AmountPen = 500m, Amount = 500m, Date = new DateOnly(Year, 4, 3) },
            new Expense { Description = "Pago a cuenta", CategoryId = ExpenseCategoryIds.ImpuestoRenta, AmountPen = 900m, Amount = 900m, Date = new DateOnly(Year, 4, 20) });
        // Marzo presentado con lo realmente pagado (no el 1 % estimado de 1,000).
        db.TaxDueDates.Add(new TaxDueDate { Period = new DateOnly(Year, 3, 1), FiledAt = DateTime.UtcNow, RentaPaid = 950m });
        db.SaveChanges();

        var report = Ok(await Admin(db).AnnualRentaAsync(Year, new DateTime(2026, 6, 1), CancellationToken.None));
        Assert.Equal(120_000m, Prop(report, "ventasMypePen"));      // sin el recibo por honorarios
        Assert.Equal(10_000m, Prop(report, "gastosDeduciblesPen"));  // sin la cuota SUNAT, la categoría no deducible ni el pago de Renta
        Assert.Equal(2_500m, Prop(report, "noDeduciblesPen"));
        Assert.Equal(110_000m, Prop(report, "rentaNetaPen"));
        var tax = Assert.IsType<MypeIncomeTax>(report.GetType().GetProperty("impuesto")!.GetValue(report));
        Assert.Equal(75_000m * 0.10m + 35_000m * 0.295m, tax.Total);  // 15 UIT = 75,000
        Assert.Equal(950m + 200m, Prop(report, "pagosACuentaPen"));    // marzo real + mayo estimado (1 % de 20,000)
        Assert.Equal(11, (int)report.GetType().GetProperty("pagosEstimados")!.GetValue(report)!);
        Assert.Equal(tax.Total - 1_150m, Prop(report, "saldoPen"));
        var natural = report.GetType().GetProperty("personaNatural")!.GetValue(report)!;
        Assert.Equal((9_000m, 720m), (Prop(natural, "ingresosPen"), Prop(natural, "retencionesPen")));
    }

    [Fact]
    public async Task Annual_renta_requires_the_uit_of_the_year()
    {
        using var db = TestData.Db(out _);
        Assert.IsType<NotFoundObjectResult>(await Admin(db).AnnualRentaAsync(2019, DateTime.UtcNow, CancellationToken.None));
    }

    [Fact]
    public async Task Monthly_renta_advance_excludes_fees_receipts()
    {
        using var db = TestData.Db(out var seed);
        db.TaxSettings.Add(new TaxSettings { RentaRate = 0.01m });
        AddSale(db, seed.Client.Id, new DateOnly(Year, 4, 10), 10_000m, null);
        AddSale(db, seed.Client.Id, new DateOnly(Year, 4, 11), 5_000m, TaxDocumentType.ReciboPorHonorarios, 5_000m);
        var summary = Ok(await Admin(db).TaxSummaryReport(4, Year, CancellationToken.None));
        Assert.Equal((100m, 5_000m), (Prop(summary, "rentaEstimada"), Prop(summary, "ventasPersonaNaturalPen")));
    }

    [Fact]
    public async Task Paid_form_1662_igv_is_tax_credit_only_when_enabled()
    {
        using var db = TestData.Db(out var seed);
        var settings = db.TaxSettings.Add(new TaxSettings()).Entity;
        db.ExchangeRates.Add(new ExchangeRate { Date = new DateOnly(Year, 5, 3), CurrencyCode = "USD", RateToPen = 3.5m, Source = "SUNAT" }); // TC venta del día del pago
        AddSale(db, seed.Client.Id, new DateOnly(Year, 5, 10), 1_180m, TaxDocumentType.Factura, 1_000m); // débito 180
        var claude = new Expense { Description = "Claude Team", CategoryId = ExpenseCategoryIds.SuscripcionesIA, Amount = 100m, Currency = "USD", AmountPen = 350m, Date = new DateOnly(Year, 5, 3) };
        db.Expenses.Add(claude); db.SaveChanges();
        var admin = Admin(db);

        Assert.IsType<BadRequestObjectResult>(await admin.MarkForm1662Paid(claude.Id, new Form1662PaymentRequest(new DateOnly(Year, 5, 20), "123"), CancellationToken.None)); // no marcado como no domiciliado
        Assert.IsType<OkObjectResult>(await admin.UpdateExpense(claude.Id, new ExpensePatchRequest(null, null, null, null, null, null, null, null, IsNonDomiciledService: true, ForeignSupplierName: "Anthropic PBC", ForeignSupplierCountry: "Estados Unidos"), CancellationToken.None));
        var list = Ok(await admin.Form1662List(Year, 5, CancellationToken.None));
        Assert.Equal((63m, 1), (Prop(list, "totalIgvPen"), (int)list.GetType().GetProperty("pendientes")!.GetValue(list)!)); // 18 % de 350

        Assert.IsType<NoContentResult>(await admin.MarkForm1662Paid(claude.Id, new Form1662PaymentRequest(new DateOnly(Year, 5, 20), "123"), CancellationToken.None));
        Assert.Equal(180m, (await admin.IgvMonthsAsync(new DateOnly(Year, 5, 31), CancellationToken.None)).Last().APagar); // apagado: no resta

        settings.Use1662AsCredit = true; db.SaveChanges();
        Assert.Equal(117m, (await admin.IgvMonthsAsync(new DateOnly(Year, 5, 31), CancellationToken.None)).Last().APagar); // 180 − 63
    }

    [Fact]
    public async Task Recurring_expenses_keep_their_tax_flags()
    {
        using var db = TestData.Db(out _);
        db.Expenses.Add(new Expense { Description = "ChatGPT Team", CategoryId = ExpenseCategoryIds.SuscripcionesIA, Amount = 30m, Currency = "PEN", AmountPen = 30m, Date = DateOnly.FromDateTime(DateTime.UtcNow).AddMonths(-1), Recurring = true, RecurrenceCycle = BillingCycle.Mensual, IsNonDomiciledService = true, ForeignSupplierName = "OpenAI OpCo, LLC", ForeignSupplierCountry = "Estados Unidos", Form1662PaidAt = DateOnly.FromDateTime(DateTime.UtcNow) });
        db.SaveChanges();
        await new Rtres.Api.Jobs.RecurringExpenseJob(db, Microsoft.Extensions.Logging.Abstractions.NullLogger<Rtres.Api.Jobs.RecurringExpenseJob>.Instance).GenerateAsync(CancellationToken.None);
        var next = await db.Expenses.OrderByDescending(x => x.Date).FirstAsync();
        Assert.Equal((true, "OpenAI OpCo, LLC", (DateOnly?)null), (next.IsNonDomiciledService, next.ForeignSupplierName, next.Form1662PaidAt));
    }

    private static void AddSale(RtresDbContext db, Guid clientId, DateOnly date, decimal amountPen, TaxDocumentType? type, decimal? basePen = null, decimal? retention = null)
    {
        var payment = new PaymentTransaction { ClientId = clientId, PayPalOrderIdOrSubscriptionId = Guid.NewGuid().ToString("N"), Amount = amountPen, Currency = "PEN", AmountPen = amountPen, Status = "COMPLETED", CreatedAt = date.ToDateTime(new TimeOnly(12, 0), DateTimeKind.Utc) };
        db.PaymentTransactions.Add(payment);
        if (type is TaxDocumentType t)
            db.TaxDocuments.Add(new TaxDocument { ClientId = clientId, PaymentTransactionId = payment.Id, Type = t, Series = "E001", Number = db.TaxDocuments.Local.Count + 1, IssueDate = date, Currency = "PEN", BaseAmount = basePen ?? amountPen, IgvAmount = amountPen - (basePen ?? amountPen), TotalAmount = amountPen, RetentionAmount = retention });
        db.SaveChanges();
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static object Ok(ActionResult result) => Assert.IsType<OkObjectResult>(result).Value!;
    private static decimal Prop(object value, string name) => (decimal)value.GetType().GetProperty(name)!.GetValue(value)!;
}
