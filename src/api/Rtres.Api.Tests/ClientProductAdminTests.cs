using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class ClientProductAdminTests
{
    [Fact]
    public async Task Unpaid_product_can_be_deleted_and_then_its_project_too()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        db.TransferReports.Add(new TransferReport { ClientId = seed.Client.Id, ClientProductId = item.Id, Amount = 10, Status = TransferReportStatus.Rechazado });
        seed.Ticket.ClientProductId = item.Id; db.Tickets.Remove(seed.Ticket); db.SaveChanges();
        var admin = Admin(db);

        Assert.IsType<ConflictObjectResult>(await admin.DeleteProject(seed.Project.Id, CancellationToken.None));
        Assert.IsType<NoContentResult>(await admin.DeleteClientProduct(item.Id, CancellationToken.None));
        Assert.False(await db.ClientProducts.AnyAsync());
        Assert.False(await db.TransferReports.AnyAsync());
        Assert.IsType<NoContentResult>(await admin.DeleteProject(seed.Project.Id, CancellationToken.None));
    }

    [Fact]
    public async Task Product_with_payments_is_not_deleted_but_can_move_to_another_project()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        db.PaymentTransactions.Add(new PaymentTransaction { ClientId = seed.Client.Id, ClientProductId = item.Id, Amount = 120, Status = "COMPLETED", PayPalOrderIdOrSubscriptionId = "TRF-1" });
        var other = new Project { ClientId = seed.Client.Id, Name = "Web nueva", Slug = "web-nueva" };
        var foreign = new Project { ClientId = Guid.NewGuid(), Name = "Ajeno", Slug = "ajeno" };
        db.Projects.AddRange(other, foreign); db.SaveChanges();
        var admin = Admin(db);

        Assert.IsType<ConflictObjectResult>(await admin.DeleteClientProduct(item.Id, CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await admin.UpdateClientProduct(item.Id, new ClientProductPatchRequest(null, null, null, null, null, null, ProjectId: foreign.Id), CancellationToken.None));
        Assert.IsType<OkObjectResult>(await admin.UpdateClientProduct(item.Id, new ClientProductPatchRequest(null, null, null, null, null, null, ProjectId: other.Id), CancellationToken.None));
        await db.Entry(item).ReloadAsync();
        Assert.Equal(other.Id, item.ProjectId);
    }

    [Fact]
    public async Task Active_paypal_subscription_must_be_cancelled_before_deleting()
    {
        using var db = TestData.Db(out var seed);
        var item = AddProduct(db, seed);
        item.PayPalSubscriptionId = "I-123"; item.Status = ClientProductStatus.Activo; db.SaveChanges();
        var admin = Admin(db);

        Assert.IsType<ConflictObjectResult>(await admin.DeleteClientProduct(item.Id, CancellationToken.None));
        item.Status = ClientProductStatus.Cancelado; db.SaveChanges();
        Assert.IsType<NoContentResult>(await admin.DeleteClientProduct(item.Id, CancellationToken.None));
    }

    private static ClientProduct AddProduct(RtresDbContext db, Seed seed)
    {
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        var item = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = product.Id, Product = product, Status = ClientProductStatus.Pendiente, BillingCycle = BillingCycle.Anual, IsManualBilling = true };
        db.AddRange(product, item); db.SaveChanges();
        return item;
    }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
