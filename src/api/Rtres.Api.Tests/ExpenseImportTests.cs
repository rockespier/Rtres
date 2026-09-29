using ClosedXML.Excel;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class ExpenseImportTests
{
    [Fact]
    public async Task Template_rows_are_imported_and_invalid_ones_reported()
    {
        using var db = TestData.Db(out _);
        db.ExchangeRates.Add(new ExchangeRate { Date = new DateOnly(2026, 9, 1), CurrencyCode = "USD", RateToPen = 3.75m, Source = "SUNAT" }); db.SaveChanges();
        var admin = Admin(db);

        // Se parte de la plantilla descargable: así el test también cubre que sus columnas coinciden con el importador.
        var template = Assert.IsType<FileContentResult>(admin.ExpenseTemplate());
        using var book = new XLWorkbook(new MemoryStream(template.FileContents));
        Assert.Equal(2, book.Worksheets.Count); // Plantilla + Valores válidos
        var sheet = book.Worksheet(1);
        // Fila 2: número y fecha con tipo de Excel; fila 3: todo como texto; filas 4-6: inválidas.
        sheet.Cell(2, 1).Value = "Servidor VPS"; sheet.Cell(2, 2).Value = "hosting"; sheet.Cell(2, 3).Value = "Fijo"; sheet.Cell(2, 4).Value = 20; sheet.Cell(2, 5).Value = "usd"; sheet.Cell(2, 6).Value = new DateTime(2026, 9, 1); sheet.Cell(2, 7).Value = "SI"; sheet.Cell(2, 8).Value = "Mensual";
        Row(sheet, 3, "Claude", "SuscripcionesIA", "Variable", "49.90", "PEN", "28/09/2026", "", "");
        Row(sheet, 4, "Sin monto", "Otros", "Variable", "0", "PEN", "2026-09-01", "", "");
        Row(sheet, 5, "Mala categoría", "Viajes", "Variable", "10", "PEN", "2026-09-01", "", "");
        Row(sheet, 6, "Recurrente sin ciclo", "Otros", "Fijo", "10", "PEN", "2026-09-01", "SI", "");
        using var stream = new MemoryStream(); book.SaveAs(stream); stream.Position = 0;

        var ok = Assert.IsType<OkObjectResult>(await admin.ImportExpenses(new FormFile(stream, 0, stream.Length, "file", "gastos.xlsx"), CancellationToken.None));
        Assert.Equal((2, 3), (Prop<int>(ok.Value!, "created"), Prop<int>(ok.Value!, "skipped")));
        Assert.Equal([4, 5, 6], Prop<List<ImportError>>(ok.Value!, "errors").Select(x => x.Row));

        var vps = await db.Expenses.SingleAsync(x => x.Description == "Servidor VPS");
        Assert.Equal((ExpenseCategory.Hosting, "USD", 75m, true, (BillingCycle?)BillingCycle.Mensual), (vps.Category, vps.Currency, vps.AmountPen, vps.Recurring, vps.RecurrenceCycle));
        var claude = await db.Expenses.SingleAsync(x => x.Description == "Claude");
        Assert.Equal((49.90m, new DateOnly(2026, 9, 28), false), (claude.Amount, claude.Date, claude.Recurring));
    }

    [Fact]
    public async Task Unreadable_file_is_rejected()
    {
        using var db = TestData.Db(out _);
        using var stream = new MemoryStream("no es excel"u8.ToArray());
        Assert.IsType<BadRequestObjectResult>(await Admin(db).ImportExpenses(new FormFile(stream, 0, stream.Length, "file", "gastos.xlsx"), CancellationToken.None));
        Assert.Empty(db.Expenses);
    }

    private static void Row(IXLWorksheet sheet, int row, params string[] values) { for (var c = 0; c < values.Length; c++) sheet.Cell(row, c + 1).Value = values[c]; }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db)) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    private static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name)!.GetValue(value)!;
}
