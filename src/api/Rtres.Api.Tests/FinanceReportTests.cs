using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class FinanceReportTests
{
    const int Year = 2026;

    [Fact]
    public async Task Manual_tax_document_registers_its_payment_and_counts_once()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var item = AddProduct(db, seed, TaxDocumentType.ReciboPorHonorarios);

        Assert.IsType<CreatedResult>(await Admin(db).CreateTaxDocument(new TaxDocumentRequest(item.Id, new DateOnly(Year, 3, 10), "PEN", 1000m, null, 80m), CancellationToken.None));

        var document = db.TaxDocuments.Single();
        var payment = db.PaymentTransactions.Single();
        Assert.Equal(payment.Id, document.PaymentTransactionId);
        Assert.Equal(seed.Client.Id, payment.ClientId);
        var sales = Ok(await Admin(db).SalesReport(3, Year, "PEN", CancellationToken.None));
        Assert.Equal(1000m, Prop(sales, "total"));
    }

    [Fact]
    public async Task Remittance_without_product_counts_in_the_client_ranking()
    {
        using var db = TestData.Db(out var seed);
        var other = new Client { CompanyName = "Roma Srl", Email = "info@roma.it" }; db.Add(other);
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 2, 5), 300m);
        AddPayment(db, other.Id, new DateOnly(Year, 2, 20), 700m, method: PaymentMethods.Remesa);
        AddPayment(db, other.Id, new DateOnly(Year, 1, 20), 350m, method: PaymentMethods.Remesa);

        var report = Ok(await Admin(db).ClientsReport(2, Year, CancellationToken.None));
        var rows = ((IEnumerable<object>)report.GetType().GetProperty("clientes")!.GetValue(report)!).ToList();
        Assert.Equal(1000m, Prop(report, "totalPen"));
        Assert.Equal("Roma Srl", Str(rows[0], "ClientName"));
        Assert.Equal((700m, 70m, 70m, 100m), (Prop(rows[0], "IngresosPen"), Prop(rows[0], "Porcentaje"), Prop(rows[0], "PorcentajeAcumulado"), (decimal)rows[0].GetType().GetProperty("VariacionPorcentaje")!.GetValue(rows[0])!));
        Assert.Equal(100m, Prop(rows[1], "PorcentajeAcumulado"));
    }

    [Fact]
    public async Task Yearly_report_equals_the_sum_of_its_months()
    {
        using var db = TestData.Db(out var seed);
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 1, 31), 100m);
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 6, 1), 250m);
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 12, 31), 50m);
        AddPayment(db, seed.Client.Id, new DateOnly(Year + 1, 1, 1), 999m);
        db.Expenses.Add(new Expense { Description = "VPS", Category = ExpenseCategory.Hosting, Amount = 40m, AmountPen = 40m, Date = new DateOnly(Year, 6, 15) }); db.SaveChanges();

        var admin = Admin(db);
        var year = Ok(await admin.NetReport(null, Year, CancellationToken.None));
        decimal months = 0;
        for (var month = 1; month <= 12; month++) months += Prop(Ok(await admin.NetReport(month, Year, CancellationToken.None)), "ventasPen");
        Assert.Equal(400m, Prop(year, "ventasPen"));
        Assert.Equal(months, Prop(year, "ventasPen"));
        Assert.Equal(12, ((System.Collections.ICollection)year.GetType().GetProperty("serie")!.GetValue(year)!).Count);
    }

    [Fact]
    public async Task Net_profit_always_subtracts_the_renta_advance_on_sales_without_igv()
    {
        using var db = TestData.Db(out var seed);
        db.TaxSettings.Add(new TaxSettings { RentaRate = 0.10m });
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 4, 10), 1000m);
        db.Expenses.Add(new Expense { Description = "Sueldo", Category = ExpenseCategory.Sueldos, Amount = 300m, AmountPen = 300m, Date = new DateOnly(Year, 4, 30) }); db.SaveChanges();

        var net = Ok(await Admin(db).NetReport(4, Year, CancellationToken.None));
        Assert.Equal((0.10m, 100m, 600m), (Prop(net, "rentaRate"), Prop(net, "impuestosPen"), Prop(net, "utilidadNetaPen")));

        // Un pago de Renta registrado no reemplaza al pago a cuenta ni se cuenta como gasto operativo.
        db.Expenses.Add(new Expense { Description = "Pago a cuenta Renta", Category = ExpenseCategory.ImpuestoRenta, Amount = 15m, AmountPen = 15m, Date = new DateOnly(Year, 4, 20) }); db.SaveChanges();
        var withPayment = Ok(await Admin(db).NetReport(4, Year, CancellationToken.None));
        Assert.Equal((300m, 100m, 600m), (Prop(withPayment, "gastosPen"), Prop(withPayment, "impuestosPen"), Prop(withPayment, "utilidadNetaPen")));
    }

    [Fact]
    public async Task Export_returns_an_excel_file()
    {
        using var db = TestData.Db(out var seed);
        AddPayment(db, seed.Client.Id, new DateOnly(Year, 5, 5), 500m);
        var file = Assert.IsType<FileContentResult>(await Admin(db).ExportReport(null, Year, CancellationToken.None));
        Assert.Equal("reporte-2026.xlsx", file.FileDownloadName);
        Assert.NotEmpty(file.FileContents);
    }

    private static void AddPayment(RtresDbContext db, Guid clientId, DateOnly date, decimal amountPen, string method = PaymentMethods.Transferencia)
    {
        db.PaymentTransactions.Add(new PaymentTransaction { ClientId = clientId, PayPalOrderIdOrSubscriptionId = Guid.NewGuid().ToString("N"), Amount = amountPen, Currency = "PEN", AmountPen = amountPen, Status = "COMPLETED", Method = method, CreatedAt = date.ToDateTime(new TimeOnly(12, 0), DateTimeKind.Utc) });
        db.SaveChanges();
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, TaxDocumentType taxType)
    {
        var product = new Product { Name = "Soporte", Type = ProductType.Hosting, BillingCycle = BillingCycle.Mensual, TaxDocumentType = taxType };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, BillingCycle = BillingCycle.Mensual };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static object Ok(ActionResult result) => Assert.IsType<OkObjectResult>(result).Value!;
    private static decimal Prop(object value, string name) => (decimal)value.GetType().GetProperty(name)!.GetValue(value)!;
    private static string Str(object value, string name) => (string)value.GetType().GetProperty(name)!.GetValue(value)!;
}
