using System.Text.Json;
using System.Text.Json.Serialization;
using Rtres.Api.Controllers;

namespace Rtres.Api.Tests;

/// <summary>Los campos de valor obligatorios de los requests no pueden faltar en el JSON (under-posting): ASP.NET responde 400.</summary>
public class RequestContractTests
{
    private static readonly JsonSerializerOptions Web = new(JsonSerializerDefaults.Web) { Converters = { new JsonStringEnumConverter() } };

    [Fact]
    public void Missing_required_value_field_is_rejected()
    {
        const string withoutAmount = """{"description":"VPS","categoryId":"6f1c1e7a-0000-0000-0000-000000000001","type":"Fijo","currency":"USD","date":"2026-11-01","recurring":false}""";
        Assert.Throws<JsonException>(() => JsonSerializer.Deserialize<ExpenseRequest>(withoutAmount, Web));

        var complete = JsonSerializer.Deserialize<ExpenseRequest>(withoutAmount.Replace("\"recurring\"", "\"amount\":49.9,\"recurring\""), Web);
        Assert.Equal(49.9m, complete!.Amount);
    }

    [Fact]
    public void Tax_document_with_items_does_not_need_total_amount()
    {
        const string json = """{"issueDate":"2026-11-01","currency":"PEN","notes":null,"items":[{"clientProductId":"6f1c1e7a-0000-0000-0000-000000000002","amount":118}]}""";
        var request = JsonSerializer.Deserialize<TaxDocumentRequest>(json, Web);
        Assert.Null(request!.TotalAmount);
        Assert.Single(request.Items!);
    }
}
