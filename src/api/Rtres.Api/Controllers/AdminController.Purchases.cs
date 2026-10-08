using System.Text.RegularExpressions;
using ClosedXML.Excel;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>Registro de Compras: comprobantes de proveedores cuyo IGV puede ser crédito fiscal.</summary>
public sealed partial class AdminController
{
    [HttpGet("purchases")]
    public async Task<ActionResult> Purchases(int year, int? month, CancellationToken ct)
    {
        var (from, to) = Period(month, year);
        var igvRate = await db.IgvRateAsync(ct);
        var items = await db.Purchases.Where(x => x.Period >= from && x.Period <= to).OrderByDescending(x => x.IssueDate).ThenBy(x => x.SupplierName).ToListAsync(ct);
        return Ok(new
        {
            items = items.Select(x => PurchaseDto(x, igvRate)),
            totalPen = Math.Round(items.Sum(x => Signed(x, x.TotalPen)), 2),
            creditoFiscalPen = Math.Round(items.Sum(x => x.TaxCreditPen), 2),
            igvSinCreditoPen = Math.Round(items.Where(x => !x.GivesTaxCredit).Sum(x => Signed(x, x.IgvPen)), 2),
        });
    }

    [HttpPost("purchases")]
    public async Task<ActionResult> CreatePurchase(PurchaseRequest request, CancellationToken ct)
    {
        var purchase = new Purchase();
        if (await ApplyPurchaseAsync(purchase, request, ct) is { } error) return error;
        db.Purchases.Add(purchase);
        if (request.CreateExpense && await LinkExpenseAsync(purchase, request.ExpenseCategoryId, ct) is { } expenseError) return expenseError;
        await db.SaveChangesAsync(ct);
        return Created($"/api/admin/purchases/{purchase.Id}", PurchaseDto(purchase, await db.IgvRateAsync(ct)));
    }

    [HttpPut("purchases/{id:guid}")]
    public async Task<ActionResult> UpdatePurchase(Guid id, PurchaseRequest request, CancellationToken ct)
    {
        var purchase = await db.Purchases.FindAsync([id], ct); if (purchase is null) return NotFound();
        if (await ApplyPurchaseAsync(purchase, request, ct) is { } error) return error;
        if ((request.CreateExpense || purchase.ExpenseId is not null) && await LinkExpenseAsync(purchase, request.ExpenseCategoryId, ct) is { } expenseError) return expenseError;
        await db.SaveChangesAsync(ct);
        return Ok(PurchaseDto(purchase, await db.IgvRateAsync(ct)));
    }

    /// <summary>Con <paramref name="deleteExpense"/> también se borra el gasto que se creó junto con la compra.</summary>
    [HttpDelete("purchases/{id:guid}")]
    public async Task<ActionResult> DeletePurchase(Guid id, bool deleteExpense, CancellationToken ct)
    {
        var purchase = await db.Purchases.FindAsync([id], ct); if (purchase is null) return NotFound();
        if (deleteExpense && purchase.ExpenseId is Guid expenseId && await db.Expenses.FindAsync([expenseId], ct) is { } expense) db.Expenses.Remove(expense);
        db.Purchases.Remove(purchase); await db.SaveChangesAsync(ct); return NoContent();
    }

    [HttpGet("purchases/import/template")]
    public async Task<IActionResult> PurchaseTemplate(CancellationToken ct) => File(CreateWorkbook(
        new("IssueDate", true, "Fecha de emisión: fecha de Excel, o texto 2026-09-28 o 28/09/2026"),
        new("Period", false, "Mes de anotación AAAA-MM (vacío = mes de emisión)"),
        new("DocumentType", true, "Tipo de comprobante", Enum.GetNames<PurchaseDocumentType>()),
        new("Series", false, "Serie, ej. F001 (obligatoria salvo Extranjero u Otro)"),
        new("Number", true, "Número del comprobante"),
        new("SupplierTaxId", true, "RUC de 11 dígitos (o identificación del proveedor extranjero)"),
        new("SupplierName", true, "Razón social del proveedor"),
        new("Currency", true, "PEN, USD o EUR", ["PEN", "USD", "EUR"]),
        new("TaxBase", true, "Base imponible, número con punto decimal"),
        new("Igv", true, "IGV del comprobante (0 si no tiene)"),
        new("NonTaxable", false, "Importe inafecto o exonerado (vacío = 0)"),
        new("UsedForTaxedOperations", false, "SI si la compra es para tus ventas gravadas (vacío = SI); NO para no tomar el crédito fiscal", ["SI", "NO"]),
        new("ExpenseCategory", false, "Si la indicas, se crea el gasto vinculado en esa categoría", [.. await db.ExpenseCategories.OrderBy(x => x.SortOrder).Select(x => x.Name).ToListAsync(ct)])),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "compras-plantilla.xlsx");

    [HttpPost("purchases/import")]
    public async Task<ActionResult> ImportPurchases(IFormFile file, CancellationToken ct)
    {
        var categories = await db.ExpenseCategories.ToListAsync(ct);
        var (failure, created, errors) = await Import(file, "compras", async (row, rowNumber, errors) =>
        {
            var parseError = ParsePurchaseRow(row, categories, out var request);
            var purchase = new Purchase();
            var error = parseError ?? Message(await ApplyPurchaseAsync(purchase, request!, ct));
            if (error is null && request!.CreateExpense) error = Message(await LinkExpenseAsync(purchase, request.ExpenseCategoryId, ct));
            if (error is not null) { errors.Add(new(rowNumber, error)); return false; }
            db.Purchases.Add(purchase); await db.SaveChangesAsync(ct); return true;
        }, ct);
        return failure ?? Ok(new { created, skipped = errors.Count, errors });
    }

    private static string? Message(ActionResult? result) => result switch
    {
        null => null,
        ObjectResult { Value: var value } => value?.GetType().GetProperty("message")?.GetValue(value) as string ?? "Fila inválida.",
        _ => "Fila inválida.",
    };

    private static string? ParsePurchaseRow(IXLRow row, IReadOnlyList<ExpenseCategory> categories, out PurchaseRequest? request)
    {
        request = null;
        if (ReadDate(row.Cell(1)) is not DateOnly issueDate) return "IssueDate inválida: usa 2026-09-28 o 28/09/2026.";
        if (!TryEnum<PurchaseDocumentType>(Cell(row, 3), out var type)) return $"DocumentType inválido: usa {string.Join(", ", Enum.GetNames<PurchaseDocumentType>())}.";
        if (ReadDecimal(row.Cell(9)) is not decimal taxBase) return "TaxBase debe ser un número.";
        if (ReadDecimal(row.Cell(10)) is not decimal igv) return "Igv debe ser un número (0 si no tiene).";
        var nonTaxable = string.IsNullOrWhiteSpace(Cell(row, 11)) ? 0m : ReadDecimal(row.Cell(11)) ?? -1m;
        if (nonTaxable < 0) return "NonTaxable debe ser un número mayor o igual a 0.";
        if (ReadYesNo(Cell(row, 12), defaultValue: true) is not bool taxed) return "UsedForTaxedOperations inválido: usa SI o NO.";
        Guid? categoryId = null;
        var categoryText = Fold(Cell(row, 13));
        if (categoryText.Length > 0)
        {
            if (categories.FirstOrDefault(x => Fold(x.Name) == categoryText || x.Code is not null && Fold(x.Code) == categoryText) is not { } category) return "ExpenseCategory no existe en Configuración → Categorías de gastos.";
            categoryId = category.Id;
        }
        request = new PurchaseRequest(issueDate, EmptyToNull(Cell(row, 2)), type, Cell(row, 4).Trim(), Cell(row, 5).Trim(), Cell(row, 6).Trim(), Cell(row, 7).Trim(),
            Cell(row, 8).Trim().ToUpperInvariant(), taxBase, igv, nonTaxable, taxed, CreateExpense: categoryId is not null, ExpenseCategoryId: categoryId);
        return null;
    }

    /// <summary>Valida y copia la compra; calcula el total, el periodo y los montos en PEN.</summary>
    private async Task<ActionResult?> ApplyPurchaseAsync(Purchase purchase, PurchaseRequest r, CancellationToken ct)
    {
        var peruvian = r.DocumentType is not (PurchaseDocumentType.Extranjero or PurchaseDocumentType.Otro);
        var supplierTaxId = (r.SupplierTaxId ?? "").Trim();
        if (peruvian && !RucRegex().IsMatch(supplierTaxId)) return BadRequest(new { message = "El RUC del proveedor debe tener 11 dígitos." });
        if (supplierTaxId.Length == 0) return BadRequest(new { message = "Indica la identificación del proveedor." });
        if (string.IsNullOrWhiteSpace(r.SupplierName)) return BadRequest(new { message = "Indica el nombre del proveedor." });
        if (peruvian && string.IsNullOrWhiteSpace(r.Series)) return BadRequest(new { message = "Indica la serie del comprobante (ej. F001)." });
        if (string.IsNullOrWhiteSpace(r.Number)) return BadRequest(new { message = "Indica el número del comprobante." });
        var currency = (r.Currency ?? "").Trim().ToUpperInvariant();
        if (currency is not ("PEN" or "USD" or "EUR")) return BadRequest(new { message = "Moneda inválida: usa PEN, USD o EUR." });
        if (r.TaxBase < 0 || r.Igv < 0 || r.NonTaxable < 0 || r.TaxBase + r.Igv + r.NonTaxable <= 0) return BadRequest(new { message = "Los importes no pueden ser negativos y el total debe ser mayor a 0." });
        if (r.Igv > 0 && r.DocumentType is PurchaseDocumentType.Boleta or PurchaseDocumentType.ReciboPorHonorarios) return BadRequest(new { message = "Una boleta o un recibo por honorarios no discrimina IGV: registra el importe como base o inafecto." });

        var issueMonth = new DateOnly(r.IssueDate.Year, r.IssueDate.Month, 1);
        var period = issueMonth;
        if (!string.IsNullOrWhiteSpace(r.Period))
        {
            if (!DateOnly.TryParseExact(r.Period.Trim() + "-01", "yyyy-MM-dd", out period)) return BadRequest(new { message = "Periodo inválido: usa AAAA-MM." });
            if (period < issueMonth) return BadRequest(new { message = "La compra no puede anotarse en un periodo anterior a su emisión." });
        }

        var series = (r.Series ?? "").Trim().ToUpperInvariant(); var number = r.Number.Trim().TrimStart('0'); if (number.Length == 0) number = "0";
        if (await db.Purchases.AnyAsync(x => x.Id != purchase.Id && x.SupplierTaxId == supplierTaxId && x.DocumentType == r.DocumentType && x.Series == series && x.Number == number, ct))
            return Conflict(new { message = $"Ya registraste el comprobante {series}-{number} de ese proveedor." });

        purchase.IssueDate = r.IssueDate; purchase.Period = period; purchase.DocumentType = r.DocumentType; purchase.Series = series; purchase.Number = number;
        purchase.SupplierTaxId = supplierTaxId; purchase.SupplierName = r.SupplierName.Trim(); purchase.Currency = currency;
        purchase.TaxBase = r.TaxBase; purchase.Igv = r.Igv; purchase.NonTaxable = r.NonTaxable; purchase.Total = r.TaxBase + r.Igv + r.NonTaxable;
        purchase.ExchangeRate = await db.RateToPenAsync(currency, r.IssueDate, ct);
        purchase.BasePen = Math.Round(r.TaxBase * purchase.ExchangeRate, 2); purchase.IgvPen = Math.Round(r.Igv * purchase.ExchangeRate, 2); purchase.TotalPen = Math.Round(purchase.Total * purchase.ExchangeRate, 2);
        purchase.GivesTaxCredit = r.UsedForTaxedOperations && r.Igv > 0 && Purchase.AllowsTaxCredit(r.DocumentType);
        purchase.Notes = EmptyToNull(r.Notes);
        return null;
    }

    /// <summary>
    /// Crea o actualiza el gasto vinculado. Si la compra da crédito fiscal, el gasto es la base + inafecto (el IGV se
    /// recupera y no es costo); si no, el total. Una nota de crédito no genera gasto.
    /// </summary>
    private async Task<ActionResult?> LinkExpenseAsync(Purchase purchase, Guid? categoryId, CancellationToken ct)
    {
        if (purchase.DocumentType == PurchaseDocumentType.NotaCredito) return purchase.ExpenseId is null ? null : BadRequest(new { message = "Una nota de crédito no puede tener gasto vinculado." });
        var expense = purchase.ExpenseId is Guid id ? await db.Expenses.FindAsync([id], ct) : null;
        var category = categoryId ?? expense?.CategoryId ?? ExpenseCategoryIds.Otros;
        if (!await db.ExpenseCategories.AnyAsync(x => x.Id == category, ct)) return BadRequest(new { message = "Elige una categoría de gasto válida." });
        if (expense is null) { expense = new Expense { Type = ExpenseType.Variable }; db.Expenses.Add(expense); purchase.ExpenseId = expense.Id; }
        expense.Description = $"{purchase.SupplierName} · {(purchase.Series.Length > 0 ? purchase.Series + "-" : "")}{purchase.Number}";
        expense.CategoryId = category; expense.Currency = purchase.Currency; expense.Date = purchase.IssueDate;
        expense.Amount = purchase.GivesTaxCredit ? purchase.TaxBase + purchase.NonTaxable : purchase.Total;
        expense.AmountPen = Math.Round(expense.Amount * purchase.ExchangeRate, 2);
        return null;
    }

    private static decimal Signed(Purchase x, decimal amount) => x.DocumentType == PurchaseDocumentType.NotaCredito ? -amount : amount;

    /// <summary><c>igvWarning</c>: el IGV no es la tasa configurada sobre la base (aviso, no error: puede haber redondeos o tasas especiales).</summary>
    private static object PurchaseDto(Purchase x, decimal igvRate) => new
    {
        id = x.Id, issueDate = x.IssueDate, period = x.Period.ToString("yyyy-MM"), documentType = x.DocumentType.ToString(), series = x.Series, number = x.Number,
        supplierTaxId = x.SupplierTaxId, supplierName = x.SupplierName, currency = x.Currency, taxBase = x.TaxBase, igv = x.Igv, nonTaxable = x.NonTaxable, total = x.Total,
        exchangeRate = x.ExchangeRate, totalPen = x.TotalPen, igvPen = x.IgvPen, givesTaxCredit = x.GivesTaxCredit, taxCreditPen = x.TaxCreditPen, expenseId = x.ExpenseId, notes = x.Notes,
        igvWarning = x.Igv > 0 && Math.Abs(x.Igv - x.TaxBase * igvRate) > 1m,
    };

    [GeneratedRegex(@"^\d{11}$")]
    private static partial Regex RucRegex();
}

public sealed record PurchaseRequest(DateOnly IssueDate, string? Period, PurchaseDocumentType DocumentType, string? Series, string Number, string SupplierTaxId, string SupplierName,
    string Currency, decimal TaxBase, decimal Igv, decimal NonTaxable = 0, bool UsedForTaxedOperations = true, bool CreateExpense = false, Guid? ExpenseCategoryId = null, string? Notes = null);
