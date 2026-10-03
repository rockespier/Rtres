using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class TaxDocumentTests
{
    [Fact]
    public async Task Paid_product_of_a_peruvian_client_gets_numbered_documents_by_product_type()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var hosting = AddProduct(db, seed, TaxDocumentType.Factura);
        var soporte = AddProduct(db, seed, TaxDocumentType.ReciboPorHonorarios);
        var payments = Payments(db);

        await payments.ApplyPaymentAsync(hosting, "ORD-1", 118m, "PEN", CancellationToken.None);
        await payments.ApplyPaymentAsync(hosting, "ORD-2", 236m, "PEN", CancellationToken.None);
        await payments.ApplyPaymentAsync(soporte, "ORD-3", 500m, "PEN", CancellationToken.None);

        var docs = await db.TaxDocuments.OrderBy(x => x.Series).ThenBy(x => x.Number).ToListAsync();
        Assert.Equal([("E001", 1), ("F001", 1), ("F001", 2)], docs.Select(x => (x.Series, x.Number)));
        // Factura: lo cobrado incluye IGV; Recibo por honorarios: sin IGV.
        Assert.Equal((100m, 18m, 118m), (docs[1].BaseAmount, docs[1].IgvAmount, docs[1].TotalAmount));
        Assert.Equal((500m, 0m, TaxDocumentType.ReciboPorHonorarios), (docs[0].BaseAmount, docs[0].IgvAmount, docs[0].Type));
        Assert.All(docs, x => Assert.NotNull(x.PaymentTransactionId));
    }

    [Fact]
    public async Task Foreign_client_payment_does_not_generate_a_document()
    {
        using var db = TestData.Db(out var seed); // RequiresTaxDocument = false por defecto
        await Payments(db).ApplyPaymentAsync(AddProduct(db, seed, TaxDocumentType.Factura), "ORD-1", 120m, "USD", CancellationToken.None);
        Assert.Single(db.PaymentTransactions);
        Assert.Empty(db.TaxDocuments);
    }

    [Fact]
    public async Task Correlative_starts_at_the_configured_number_and_cannot_go_back()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var item = AddProduct(db, seed, TaxDocumentType.Factura);
        var admin = Admin(db);
        Assert.IsType<OkObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, "f002", 120), CancellationToken.None));

        var created = Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(item.Id, new DateOnly(2026, 9, 1), "PEN", 59m, null), CancellationToken.None));
        Assert.Equal(("F002", 120, 50m), (Doc(created).Series, Doc(created).Number, Doc(created).BaseAmount));
        Assert.Equal(121, Doc(Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(item.Id, new DateOnly(2026, 9, 2), "PEN", 59m, null), CancellationToken.None))).Number);

        Assert.IsType<BadRequestObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, FacturaNextNumber: 100), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, FacturaSeries: "B001"), CancellationToken.None));
    }

    [Fact]
    public async Task Factura_and_recibo_can_share_the_sol_series_with_independent_correlatives()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.RequiresTaxDocument = true; db.SaveChanges();
        var factura = AddProduct(db, seed, TaxDocumentType.Factura);
        var recibo = AddProduct(db, seed, TaxDocumentType.ReciboPorHonorarios);
        var admin = Admin(db);
        // Emitidos en SUNAT SOL: última factura E001-418, último recibo E001-189.
        Assert.IsType<OkObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, "E001", 419, "E001", 190), CancellationToken.None));

        var f = Doc(Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(factura.Id, new DateOnly(2026, 10, 1), "PEN", 118m, null), CancellationToken.None)));
        var r = Doc(Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(recibo.Id, new DateOnly(2026, 10, 1), "PEN", 500m, null), CancellationToken.None)));
        Assert.Equal(("E001", 419), (f.Series, f.Number));
        Assert.Equal(("E001", 190), (r.Series, r.Number)); // no sigue desde la factura 419

        // El mismo número en la misma serie es válido si el tipo es distinto.
        Assert.IsType<OkObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, ReciboNextNumber: 419), CancellationToken.None));
        var r2 = Doc(Assert.IsType<CreatedResult>(await admin.CreateTaxDocument(new TaxDocumentRequest(recibo.Id, new DateOnly(2026, 10, 2), "PEN", 500m, null), CancellationToken.None)));
        Assert.Equal(("E001", 419, TaxDocumentType.ReciboPorHonorarios), (r2.Series, r2.Number, r2.Type));

        // Cada tipo solo avanza respecto de sus propios comprobantes.
        Assert.IsType<BadRequestObjectResult>(await admin.UpdateTaxSettings(new TaxSettingsRequest(null, null, ReciboNextNumber: 300), CancellationToken.None));
    }

    [Fact]
    public async Task Manual_document_is_rejected_for_clients_that_do_not_require_it()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, TaxDocumentType.Factura);
        Assert.IsType<BadRequestObjectResult>(await Admin(db).CreateTaxDocument(new TaxDocumentRequest(item.Id, new DateOnly(2026, 9, 1), "PEN", 100m, null), CancellationToken.None));
        Assert.Empty(db.TaxDocuments);
    }

    private static PayPalPaymentService Payments(RtresDbContext db) =>
        new(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static TaxDocument Doc(CreatedResult result) => new() { Series = Prop<string>(result.Value!, "series"), Number = Prop<int>(result.Value!, "number"), BaseAmount = Prop<decimal>(result.Value!, "baseAmount"), Type = Enum.Parse<TaxDocumentType>(Prop<string>(result.Value!, "type")) };
    private static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name)!.GetValue(value)!;

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, TaxDocumentType taxType)
    {
        var product = new Product { Name = taxType.ToString(), Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, TaxDocumentType = taxType };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = ClientProductStatus.Pendiente, BillingCycle = BillingCycle.Anual };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }
}
