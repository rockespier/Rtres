using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Services;

/// <summary>Medios de pago habilitados y datos para pagar por transferencia (cuentas activas y monto en cada moneda).</summary>
public sealed class BankTransferService(RtresDbContext db, IConfiguration configuration)
{
    public async Task<PaymentSettings> SettingsAsync(CancellationToken ct) =>
        await db.PaymentSettings.FirstOrDefaultAsync(ct) ?? db.PaymentSettings.Add(new PaymentSettings()).Entity;

    public Task<List<BankAccount>> ActiveAccountsAsync(CancellationToken ct) =>
        db.BankAccounts.Where(x => x.IsActive).OrderBy(x => x.SortOrder).ThenBy(x => x.Currency).ThenBy(x => x.BankName).ToListAsync(ct);

    /// <summary>
    /// Monto a transferir y las cuentas activas. Las cuentas en otra moneda llevan el monto aproximado al tipo de cambio
    /// del día (vía soles); sin tipo de cambio sincronizado para alguna de las dos monedas no se muestra aproximado.
    /// </summary>
    public async Task<BankTransferInfoDto> InfoAsync(ClientProduct item, decimal igvRate, int years, CancellationToken ct)
    {
        var currency = item.Product?.Currency ?? "USD";
        var amount = item.ChargeTotal(igvRate, years);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var accounts = new List<BankAccountDto>();
        foreach (var account in await ActiveAccountsAsync(ct))
        {
            decimal? approx = null;
            if (amount is decimal value && account.Currency != currency && await HasRateAsync(currency, ct) && await HasRateAsync(account.Currency, ct))
                approx = Math.Round(value * await db.RateToPenAsync(currency, today, ct) / await db.RateToPenAsync(account.Currency, today, ct), 2);
            accounts.Add(BankAccountDto.From(account, approx));
        }
        // Las cuentas en la moneda del producto primero: es lo que se recomienda transferir.
        accounts = [.. accounts.OrderBy(x => x.Currency == currency ? 0 : 1)];
        return new BankTransferInfoDto(configuration["BankTransfer:Instructions"] ?? "", amount, years, currency, igvRate > 0, accounts);
    }

    private async Task<bool> HasRateAsync(string currency, CancellationToken ct) => currency == "PEN" || await db.ExchangeRates.AnyAsync(x => x.CurrencyCode == currency, ct);

    /// <summary>Último reporte de transferencia por producto (el más reciente), para las tarjetas de "Mis servicios".</summary>
    public async Task<Dictionary<Guid, TransferReportSummary>> LatestReportsAsync(IEnumerable<Guid> clientProductIds, CancellationToken ct)
    {
        var ids = clientProductIds.ToList();
        var reports = await db.TransferReports.Where(x => ids.Contains(x.ClientProductId))
            .Select(x => new { x.ClientProductId, x.Id, x.Status, x.CreatedAt, x.RejectionReason }).ToListAsync(ct);
        return reports.GroupBy(x => x.ClientProductId).ToDictionary(g => g.Key, g => g.OrderByDescending(x => x.CreatedAt).Select(x => new TransferReportSummary(x.Id, x.Status, x.CreatedAt, x.RejectionReason)).First());
    }
}

public sealed record BankAccountDto(Guid Id, string BankName, string Holder, string Currency, BankAccountType Type, string AccountNumber, string? Cci, bool IsActive, int SortOrder, decimal? ApproxAmount = null)
{
    public static BankAccountDto From(BankAccount x, decimal? approxAmount = null) => new(x.Id, x.BankName, x.Holder, x.Currency, x.Type, x.AccountNumber, x.Cci, x.IsActive, x.SortOrder, approxAmount);
}

public sealed record BankTransferInfoDto(string Instructions, decimal? Amount, int Years, string Currency, bool IncludesIgv, List<BankAccountDto> Accounts);
