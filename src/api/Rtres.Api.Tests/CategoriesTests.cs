using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;

namespace Rtres.Api.Tests;

public class CategoriesTests
{
    [Fact]
    public async Task Expense_categories_are_managed_but_system_and_used_ones_are_protected()
    {
        using var db = TestData.Db(out _);
        var categories = new CategoriesController(db);

        var created = Assert.IsType<CreatedResult>(await categories.CreateExpenseCategory(new CategoryRequest("  Viajes "), CancellationToken.None));
        var viajes = Assert.IsType<CategoryDto>(created.Value);
        Assert.Equal("Viajes", viajes.Name);
        Assert.IsType<ConflictObjectResult>(await categories.CreateExpenseCategory(new CategoryRequest("viajés"), CancellationToken.None)); // mismo nombre sin tildes ni mayúsculas
        Assert.IsType<BadRequestObjectResult>(await categories.CreateExpenseCategory(new CategoryRequest(" "), CancellationToken.None));

        Assert.IsType<NoContentResult>(await categories.RenameExpenseCategory(ExpenseCategoryIds.SuscripcionesIA, new CategoryRequest("Herramientas IA"), CancellationToken.None));
        Assert.Equal("Herramientas IA", (await db.ExpenseCategories.FindAsync(ExpenseCategoryIds.SuscripcionesIA))!.Name);
        Assert.IsType<ConflictObjectResult>(await categories.DeleteExpenseCategory(ExpenseCategoryIds.Otros, CancellationToken.None)); // de sistema

        db.Expenses.Add(new Expense { Description = "Vuelo", CategoryId = viajes.Id, Amount = 1, AmountPen = 1, Currency = "PEN", Date = new DateOnly(2026, 10, 1) }); await db.SaveChangesAsync();
        Assert.IsType<ConflictObjectResult>(await categories.DeleteExpenseCategory(viajes.Id, CancellationToken.None)); // en uso
        db.Expenses.RemoveRange(db.Expenses); await db.SaveChangesAsync();
        Assert.IsType<NoContentResult>(await categories.DeleteExpenseCategory(viajes.Id, CancellationToken.None));
    }

    [Fact]
    public async Task Renaming_a_product_category_updates_its_products()
    {
        using var db = TestData.Db(out _);
        var categories = new CategoriesController(db);
        var web = Assert.IsType<CategoryDto>(Assert.IsType<CreatedResult>(await categories.CreateProductCategory(new CategoryRequest("Sitios web"), CancellationToken.None)).Value);
        db.Products.Add(new Product { Name = "Landing", Category = "Sitios web", Currency = "USD" }); await db.SaveChangesAsync();

        Assert.IsType<NoContentResult>(await categories.RenameProductCategory(web.Id, new CategoryRequest("Web"), CancellationToken.None));
        Assert.Equal("Web", (await db.Products.SingleAsync()).Category);
        Assert.IsType<ConflictObjectResult>(await categories.DeleteProductCategory(web.Id, CancellationToken.None));
        var listed = Assert.IsType<OkObjectResult>(await categories.ProductCategories(CancellationToken.None));
        Assert.Equal(1, Assert.Single(Assert.IsAssignableFrom<IEnumerable<CategoryDto>>(listed.Value)).UsageCount);
    }
}
