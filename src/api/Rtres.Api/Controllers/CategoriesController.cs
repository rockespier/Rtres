using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>Categorías de gastos y de productos (Configuración). Una categoría en uso no se borra; renombrar no cambia a qué apuntan sus registros.</summary>
[ApiController, Authorize(Roles = "SuperAdmin"), Route("api/admin")]
public sealed class CategoriesController(RtresDbContext db) : ControllerBase
{
    [HttpGet("expense-categories")]
    public async Task<ActionResult> ExpenseCategories(CancellationToken ct) => Ok(await db.ExpenseCategories.OrderBy(x => x.SortOrder).ThenBy(x => x.Name)
        .Select(x => new CategoryDto(x.Id, x.Name, x.Code != null, x.IsIncomeTax, db.Expenses.Count(e => e.CategoryId == x.Id))).ToListAsync(ct));

    [HttpPost("expense-categories")]
    public async Task<ActionResult> CreateExpenseCategory(CategoryRequest request, CancellationToken ct)
    {
        if (await ValidateNameAsync(request.Name, db.ExpenseCategories.Select(x => x.Name), ct) is { } error) return error;
        var category = new ExpenseCategory { Name = request.Name.Trim(), SortOrder = await db.ExpenseCategories.CountAsync(ct) };
        db.ExpenseCategories.Add(category); await db.SaveChangesAsync(ct);
        return Created($"/api/admin/expense-categories/{category.Id}", new CategoryDto(category.Id, category.Name, false, false, 0));
    }

    [HttpPatch("expense-categories/{id:guid}")]
    public async Task<ActionResult> RenameExpenseCategory(Guid id, CategoryRequest request, CancellationToken ct)
    {
        var category = await db.ExpenseCategories.FindAsync([id], ct); if (category is null) return NotFound();
        if (await ValidateNameAsync(request.Name, db.ExpenseCategories.Where(x => x.Id != id).Select(x => x.Name), ct) is { } error) return error;
        category.Name = request.Name.Trim(); await db.SaveChangesAsync(ct); return NoContent();
    }

    [HttpDelete("expense-categories/{id:guid}")]
    public async Task<ActionResult> DeleteExpenseCategory(Guid id, CancellationToken ct)
    {
        var category = await db.ExpenseCategories.FindAsync([id], ct); if (category is null) return NotFound();
        if (category.Code is not null) return Conflict(new { message = $"«{category.Name}» es una categoría del sistema: puedes renombrarla, pero no eliminarla." });
        var used = await db.Expenses.CountAsync(x => x.CategoryId == id, ct);
        if (used > 0) return Conflict(new { message = $"«{category.Name}» tiene {used} {(used == 1 ? "gasto" : "gastos")}: cámbialos de categoría antes de eliminarla." });
        db.ExpenseCategories.Remove(category); await db.SaveChangesAsync(ct); return NoContent();
    }

    [HttpGet("product-categories")]
    public async Task<ActionResult> ProductCategories(CancellationToken ct) => Ok(await db.ProductCategories.OrderBy(x => x.SortOrder).ThenBy(x => x.Name)
        .Select(x => new CategoryDto(x.Id, x.Name, false, false, db.Products.Count(p => p.Category == x.Name))).ToListAsync(ct));

    [HttpPost("product-categories")]
    public async Task<ActionResult> CreateProductCategory(CategoryRequest request, CancellationToken ct)
    {
        if (await ValidateNameAsync(request.Name, db.ProductCategories.Select(x => x.Name), ct) is { } error) return error;
        var category = new ProductCategory { Name = request.Name.Trim(), SortOrder = await db.ProductCategories.CountAsync(ct) };
        db.ProductCategories.Add(category); await db.SaveChangesAsync(ct);
        return Created($"/api/admin/product-categories/{category.Id}", new CategoryDto(category.Id, category.Name, false, false, 0));
    }

    /// <summary>El producto guarda el nombre de su categoría (lo usan la web y el catálogo): renombrar actualiza esos productos.</summary>
    [HttpPatch("product-categories/{id:guid}")]
    public async Task<ActionResult> RenameProductCategory(Guid id, CategoryRequest request, CancellationToken ct)
    {
        var category = await db.ProductCategories.FindAsync([id], ct); if (category is null) return NotFound();
        if (await ValidateNameAsync(request.Name, db.ProductCategories.Where(x => x.Id != id).Select(x => x.Name), ct) is { } error) return error;
        var name = request.Name.Trim();
        foreach (var product in await db.Products.Where(x => x.Category == category.Name).ToListAsync(ct)) product.Category = name;
        category.Name = name; await db.SaveChangesAsync(ct); return NoContent();
    }

    [HttpDelete("product-categories/{id:guid}")]
    public async Task<ActionResult> DeleteProductCategory(Guid id, CancellationToken ct)
    {
        var category = await db.ProductCategories.FindAsync([id], ct); if (category is null) return NotFound();
        var used = await db.Products.CountAsync(x => x.Category == category.Name, ct);
        if (used > 0) return Conflict(new { message = $"«{category.Name}» tiene {used} {(used == 1 ? "producto" : "productos")}: cámbialos de categoría antes de eliminarla." });
        db.ProductCategories.Remove(category); await db.SaveChangesAsync(ct); return NoContent();
    }

    private async Task<ActionResult?> ValidateNameAsync(string? name, IQueryable<string> others, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(name)) return BadRequest(new { message = "El nombre es obligatorio." });
        if (name.Trim().Length > 100) return BadRequest(new { message = "El nombre admite hasta 100 caracteres." });
        var folded = AdminController.Fold(name);
        if ((await others.ToListAsync(ct)).Any(x => AdminController.Fold(x) == folded)) return Conflict(new { message = $"Ya existe una categoría «{name.Trim()}»." });
        return null;
    }
}

public sealed record CategoryDto(Guid Id, string Name, bool IsSystem, bool IsIncomeTax, int UsageCount);
public sealed record CategoryRequest(string Name);
