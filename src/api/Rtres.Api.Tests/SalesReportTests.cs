using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class SalesReportTests
{
    [Fact]
    public async Task Igv_comes_only_from_invoices_and_is_already_inside_what_was_charged()
    {
        using var db = TestData.Db(out var seed);
        var today = DateTime.UtcNow;
        db.ExchangeRates.Add(new ExchangeRate { Date = DateOnly.FromDateTime(today), CurrencyCode = "USD", RateToPen = 3.75m, Source = "SUNAT" });
        seed.Client.RequiresTaxDocument = true;
        var foreign = new Client { CompanyName = "Roma Srl", Email = "info@roma.it" };
        var foreignProject = new Project { ClientId = foreign.Id, Name = "Web", Slug = "roma-web" };
        db.AddRange(foreign, foreignProject); db.SaveChanges();
        var payments = new PayPalPaymentService(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

        // Cliente en Perú con Factura: 118 PEN cobrados = base 100 + IGV 18.
        await payments.ApplyPaymentAsync(AddProduct(db, seed.Client.Id, seed.Project.Id, TaxDocumentType.Factura), "ORD-PE", 118m, "PEN", CancellationToken.None);
        // Cliente del exterior: 100 USD = 375 PEN, sin IGV ni comprobante.
        await payments.ApplyPaymentAsync(AddProduct(db, foreign.Id, foreignProject.Id, TaxDocumentType.Factura), "ORD-IT", 100m, "USD", CancellationToken.None);
        // Recibo por honorarios emitido a mano (cobro fuera del portal): 200 PEN sin IGV.
        var rxh = AddProduct(db, seed.Client.Id, seed.Project.Id, TaxDocumentType.ReciboPorHonorarios);
        var admin = Admin(db);
        Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(rxh.Id, DateOnly.FromDateTime(today), "PEN", 200m, null), CancellationToken.None));

        var sales = Assert.IsType<OkObjectResult>(await admin.SalesReport(today.Month, today.Year, "PEN", CancellationToken.None)).Value!;
        Assert.Equal((675m, 18m, 693m), (Prop(sales, "baseImponible"), Prop(sales, "igv"), Prop(sales, "total")));

        var tax = Assert.IsType<OkObjectResult>(await admin.TaxSummaryReport(today.Month, today.Year, CancellationToken.None)).Value!;
        // Pago a cuenta de la MYPE: 10 % de 100 (solo la factura); ni el cobro del exterior (375) ni el recibo por honorarios (200) suman.
        // No gravadas: solo el exterior (375); el recibo por honorarios va aparte.
        Assert.Equal((100m, 375m, 18m, 100m, 10m, 200m), (Prop(tax, "ventasGravadasPen"), Prop(tax, "ventasNoGravadasPen"), Prop(tax, "igvEstimado"), Prop(tax, "rentaBasePen"), Prop(tax, "rentaEstimada"), Prop(tax, "ventasPersonaNaturalPen")));

        var net = Assert.IsType<OkObjectResult>(await admin.NetReport(today.Month, today.Year, CancellationToken.None)).Value!;
        Assert.Equal((675m, 10m, 665m), (Prop(net, "ventasPen"), Prop(net, "impuestosPen"), Prop(net, "utilidadNetaPen")));
    }

    [Fact]
    public async Task Sales_follow_the_issue_date_of_documents_and_skip_peruvian_payments_without_one()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true;
        var foreign = new Client { CompanyName = "Roma Srl", Email = "info@roma.it" };
        db.Add(foreign);
        // Cobro del 30/9 en Lima (1/10 02:00 UTC) cuya factura se emitió el 30/9: cuenta en septiembre, no en octubre.
        var september = new PaymentTransaction { ClientId = seed.Client.Id, Amount = 118m, Currency = "PEN", AmountPen = 118m, CreatedAt = new DateTime(2026, 10, 1, 2, 0, 0, DateTimeKind.Utc) };
        // Cobro de octubre de un cliente en Perú sin comprobante: no es venta todavía, se avisa.
        var pending = new PaymentTransaction { ClientId = seed.Client.Id, Amount = 236m, Currency = "PEN", AmountPen = 236m, Method = PaymentMethods.Transferencia, InternalCode = "P-9", CreatedAt = new DateTime(2026, 10, 10, 15, 0, 0, DateTimeKind.Utc) };
        // Cobro de octubre del exterior: venta no gravada sin comprobante.
        var export = new PaymentTransaction { ClientId = foreign.Id, Amount = 100m, Currency = "USD", AmountPen = 350m, CreatedAt = new DateTime(2026, 10, 15, 15, 0, 0, DateTimeKind.Utc) };
        db.AddRange(september, pending, export,
            new TaxDocument { ClientId = seed.Client.Id, Type = TaxDocumentType.Factura, Series = "F001", Number = 1, IssueDate = new DateOnly(2026, 9, 30), Currency = "PEN", BaseAmount = 100m, IgvAmount = 18m, TotalAmount = 118m, PaymentTransactionId = september.Id },
            // Factura de octubre emitida a mano, sin cobro enlazado.
            new TaxDocument { ClientId = seed.Client.Id, Type = TaxDocumentType.Factura, Series = "F001", Number = 2, IssueDate = new DateOnly(2026, 10, 20), Currency = "PEN", BaseAmount = 500m, IgvAmount = 90m, TotalAmount = 590m });
        db.SaveChanges();
        var admin = Admin(db);

        var tax = Assert.IsType<OkObjectResult>(await admin.TaxSummaryReport(10, 2026, CancellationToken.None)).Value!;
        Assert.Equal((500m, 350m, 90m, 500m), (Prop(tax, "ventasGravadasPen"), Prop(tax, "ventasNoGravadasPen"), Prop(tax, "igvEstimado"), Prop(tax, "rentaBasePen")));
        var missing = Assert.Single((System.Collections.IEnumerable)tax.GetType().GetProperty("cobrosSinComprobante")!.GetValue(tax)!);
        Assert.Equal((pending.Id, 236m), ((Guid)missing.GetType().GetProperty("paymentId")!.GetValue(missing)!, Prop(missing, "totalPen")));

        var septemberTax = Assert.IsType<OkObjectResult>(await admin.TaxSummaryReport(9, 2026, CancellationToken.None)).Value!;
        Assert.Equal((100m, 18m), (Prop(septemberTax, "ventasGravadasPen"), Prop(septemberTax, "igvEstimado")));

        var net = Assert.IsType<OkObjectResult>(await admin.NetReport(10, 2026, CancellationToken.None)).Value!;
        Assert.Equal(850m, Prop(net, "ventasPen"));

        // Reporte de ingresos: todo cuenta, también el cobro en Perú sin comprobante.
        var income = Assert.IsType<OkObjectResult>(await admin.IncomeReport(10, 2026, CancellationToken.None)).Value!;
        Assert.Equal((1176m, 90m), (Prop(income, "totalPen"), Prop(income, "igvPen")));
        var tipos = ((System.Collections.IEnumerable)income.GetType().GetProperty("tipos")!.GetValue(income)!).Cast<object>().ToDictionary(x => (string)x.GetType().GetProperty("tipo")!.GetValue(x)!, x => Prop(x, "totalPen"));
        Assert.Equal(new Dictionary<string, decimal> { ["Factura"] = 590m, ["ReciboPorHonorarios"] = 0m, ["Exterior"] = 350m, ["SinComprobante"] = 236m }, tipos);
    }

    private static ClientProduct AddProduct(RtresDbContext db, Guid clientId, Guid projectId, TaxDocumentType taxType)
    {
        var product = new Product { Name = taxType.ToString(), Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, TaxDocumentType = taxType };
        var item = new ClientProduct { ClientId = clientId, ProjectId = projectId, ProductId = product.Id, Product = product, Status = ClientProductStatus.Pendiente, BillingCycle = BillingCycle.Anual };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static decimal Prop(object value, string name) => (decimal)value.GetType().GetProperty(name)!.GetValue(value)!;
}
