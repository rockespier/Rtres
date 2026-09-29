using ClosedXML.Excel;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class ImportTemplateTests
{
    [Fact]
    public void Templates_explain_accepted_values_and_offer_dropdowns()
    {
        using var db = TestData.Db(out _);
        var admin = Admin(db);
        foreach (var (result, dropdownColumn, dropdownValues) in new[]
        {
            (admin.ClientTemplate(), 5, "\"es,en,it\""),
            (admin.ProductTemplate(), 1, $"\"{string.Join(",", Enum.GetNames<ProductType>())}\""),
            (admin.ExpenseTemplate(), 2, $"\"{string.Join(",", Enum.GetNames<ExpenseCategory>())}\""),
        })
        {
            using var book = Open(result);
            var sheet = book.Worksheet("Plantilla");
            Assert.True(sheet.Cell(1, 1).HasComment); // nota con lo que acepta la columna
            var validation = Assert.Single(sheet.DataValidations, v => v.Ranges.Any(r => r.FirstCell().Address.ColumnNumber == dropdownColumn));
            Assert.Equal(dropdownValues, validation.Value);
            var help = book.Worksheet("Valores válidos");
            Assert.Equal(sheet.Row(1).CellsUsed().Count(), help.Column(1).CellsUsed().Count() - 2); // encabezado + nota final
        }
    }

    [Fact]
    public async Task Product_import_uses_the_documented_values_and_reports_each_problem()
    {
        using var db = TestData.Db(out _);
        var admin = Admin(db);
        using var book = Open(admin.ProductTemplate());
        var sheet = book.Worksheet("Plantilla");
        Row(sheet, 2, "hosting", "Hosting anual", "Anual", "120.50", "usd", "", "");  // IsActive vacío = SI, comprobante vacío = Factura
        Row(sheet, 3, "Dominio", "Dominio .pe", "Anual", "35", "PEN", "", "NO", "ReciboPorHonorarios");
        Row(sheet, 7, "Ssl", "SSL", "Anual", "10", "USD", "", "", "Boleta");
        Row(sheet, 4, "7", "Tipo numérico", "Anual", "10", "USD", "", "");          // número que no es un tipo
        Row(sheet, 5, "Ssl", "SSL", "Anual", "diez", "USD", "", "");
        Row(sheet, 6, "Ssl", "SSL", "Anual", "10", "GBP", "", "");
        using var stream = new MemoryStream(); book.SaveAs(stream); stream.Position = 0;

        var ok = Assert.IsType<OkObjectResult>(await admin.ImportProducts(new FormFile(stream, 0, stream.Length, "file", "productos.xlsx"), CancellationToken.None));
        var errors = (List<ImportError>)ok.Value!.GetType().GetProperty("errors")!.GetValue(ok.Value)!;
        Assert.Equal([4, 5, 6, 7], errors.Select(x => x.Row));
        Assert.Contains("TaxDocumentType", errors[3].Reason);
        Assert.Contains("Type", errors[0].Reason); Assert.Contains("BasePrice", errors[1].Reason); Assert.Contains("Moneda", errors[2].Reason);

        var hosting = await db.Products.SingleAsync(x => x.Name == "Hosting anual");
        Assert.Equal((ProductType.Hosting, 120.50m, "USD", true, TaxDocumentType.Factura), (hosting.Type, hosting.BasePrice, hosting.Currency, hosting.IsActive, hosting.TaxDocumentType));
        var dominio = await db.Products.SingleAsync(x => x.Name == "Dominio .pe");
        Assert.Equal((false, TaxDocumentType.ReciboPorHonorarios), (dominio.IsActive, dominio.TaxDocumentType));
    }

    private static XLWorkbook Open(IActionResult result) => new(new MemoryStream(Assert.IsType<FileContentResult>(result).FileContents));
    private static void Row(IXLWorksheet sheet, int row, params string[] values) { for (var c = 0; c < values.Length; c++) sheet.Cell(row, c + 1).Value = values[c]; }

    private static AdminController Admin(RtresDbContext db) =>
        new(db, null!, null!, ClientOnboardingTests.AccessEmail(db, new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
