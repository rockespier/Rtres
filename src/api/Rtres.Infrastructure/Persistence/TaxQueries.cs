using Microsoft.EntityFrameworkCore;
using Rtres.Domain;

namespace Rtres.Infrastructure.Persistence;

public static class TaxQueries
{
    /// <summary>Tasa de IGV configurada (0.18 si aún no hay fila de configuración).</summary>
    public static async Task<decimal> IgvRateAsync(this RtresDbContext db, CancellationToken ct) =>
        await db.TaxSettings.Select(x => (decimal?)x.IgvRate).FirstOrDefaultAsync(ct) ?? new TaxSettings().IgvRate;

    /// <summary>IGV que se suma al cobrar este producto a este cliente (ver <see cref="ClientProductPricing.IgvRateFor"/>).</summary>
    public static async Task<decimal> IgvRateForAsync(this RtresDbContext db, Guid clientId, Product product, CancellationToken ct)
    {
        if (product.TaxDocumentType != TaxDocumentType.Factura) return 0m;
        var client = await db.Clients.SingleOrDefaultAsync(x => x.Id == clientId, ct);
        return client is null ? 0m : ClientProductPricing.IgvRateFor(client, product, await db.IgvRateAsync(ct));
    }
}
