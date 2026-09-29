using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class DiscountTests
{
    [Fact]
    public async Task Discount_on_an_active_product_covers_the_current_period_and_renewal_is_at_catalog_price()
    {
        using var db = TestData.Db(out var seed);
        var renewsAt = DateTime.UtcNow.AddMonths(3);
        var item = AddProduct(db, seed, ClientProductStatus.Activo, renewsAt);
        var admin = Admin(db);

        var ok = Assert.IsType<OkObjectResult>(await admin.UpdateClientProduct(item.Id, new ClientProductPatchRequest(null, null, null, null, null, null, Discount: 30), CancellationToken.None));
        Assert.Equal((120m, 90m, 120m), (Prop<decimal>(ok.Value!, "listPrice"), Prop<decimal>(ok.Value!, "currentPrice"), Prop<decimal>(ok.Value!, "nextChargePrice")));
        Assert.Equal(renewsAt, item.DiscountEndsAt);

        // Se paga la renovación: precio de catálogo y el descuento desaparece.
        await Payments(db).ApplyPaymentAsync(item, "ORD-REN", 120m, "USD", CancellationToken.None);
        Assert.Equal((null, null, 120m), (item.Discount, item.DiscountEndsAt, item.CurrentPrice(DateTime.UtcNow)));
    }

    [Fact]
    public async Task Discount_on_a_pending_product_is_used_by_the_first_payment_only()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed, ClientProductStatus.Pendiente, null);
        Assert.Null(item.SetDiscount(30));
        Assert.Equal(90m, item.NextChargePrice()); // el primer cobro va con descuento

        await Payments(db).ApplyPaymentAsync(item, "ORD-1", 90m, "USD", CancellationToken.None);
        Assert.Equal(item.RenewsAt, item.DiscountEndsAt); // cubre el año recién pagado
        Assert.Equal((90m, 120m), (item.CurrentPrice(DateTime.UtcNow), item.NextChargePrice()));
        Assert.Equal(120m, item.CurrentPrice(item.RenewsAt!.Value.AddDays(1))); // vencido el periodo, vuelve al catálogo
    }

    [Fact]
    public async Task Discount_can_be_given_when_assigning_and_is_validated()
    {
        using var db = TestData.Db(out var seed);
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        db.Products.Add(product); db.SaveChanges();
        var admin = Admin(db);

        Assert.IsType<BadRequestObjectResult>(await admin.AssignProduct(seed.Client.Id, new AssignProductRequest(product.Id, seed.Project.Id, BillingCycle.Anual, "Manual", null, null, null, Discount: 150), CancellationToken.None));
        var created = Assert.IsType<CreatedResult>(await admin.AssignProduct(seed.Client.Id, new AssignProductRequest(product.Id, seed.Project.Id, BillingCycle.Anual, "Manual", 80m, null, null, new DateOnly(2027, 1, 15), Discount: 20), CancellationToken.None));
        var dto = Prop<object>(created.Value!, "clientProduct");
        // El precio propio se ignora si el producto tiene precio de catálogo: el precio distinto se expresa como descuento.
        Assert.Equal((120m, 100m, 120m), (Prop<decimal>(dto, "listPrice"), Prop<decimal>(dto, "currentPrice"), Prop<decimal>(dto, "nextChargePrice")));
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed, ClientProductStatus status, DateTime? renewsAt)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = status, BillingCycle = BillingCycle.Anual, RenewsAt = renewsAt };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static PayPalPaymentService Payments(RtresDbContext db) =>
        new(db, null!, new FakeNotifications(), PayPalPaymentTests.TaxDocuments(db), NullLogger<PayPalPaymentService>.Instance);

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name)!.GetValue(value)!;
}
