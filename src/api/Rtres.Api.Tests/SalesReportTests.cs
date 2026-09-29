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
        Assert.Equal((100m, 575m, 18m, 67.5m), (Prop(tax, "ventasGravadasPen"), Prop(tax, "ventasNoGravadasPen"), Prop(tax, "igvEstimado"), Prop(tax, "rentaEstimada")));

        var net = Assert.IsType<OkObjectResult>(await admin.NetReport(today.Month, today.Year, CancellationToken.None)).Value!;
        Assert.Equal((675m, 67.5m, 607.5m), (Prop(net, "ventasPen"), Prop(net, "impuestosEstimadosPen"), Prop(net, "netoEstimadoPen")));
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
