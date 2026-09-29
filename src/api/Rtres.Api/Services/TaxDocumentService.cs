using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Services;

/// <summary>
/// Numera y registra Facturas/Recibos por honorarios. El tipo sale del producto, la serie de Configuración de tasas y
/// el correlativo avanza de uno en uno por serie. Solo aplica a clientes con <see cref="Client.RequiresTaxDocument"/>
/// (clientes en Perú); Rtres no timbra nada ante SUNAT, el documento se emite igual en el facturador externo.
/// </summary>
public sealed class TaxDocumentService(RtresDbContext db, ILogger<TaxDocumentService> logger)
{
    const int MaxAttempts = 3;
    static readonly TimeSpan LimaOffset = TimeSpan.FromHours(-5); // Perú no tiene horario de verano.

    public static DateOnly LimaToday(DateTime utc) => DateOnly.FromDateTime(utc + LimaOffset);

    /// <summary>Emite el comprobante de un pago confirmado. No hace nada si el cliente no lo requiere o si ya se emitió.</summary>
    public async Task<TaxDocument?> IssueForPaymentAsync(PaymentTransaction payment, CancellationToken ct)
    {
        try
        {
            if (await db.TaxDocuments.AnyAsync(x => x.PaymentTransactionId == payment.Id, ct)) return null;
            var item = await db.ClientProducts.Include(x => x.Product).SingleAsync(x => x.Id == payment.ClientProductId, ct);
            var client = await db.Clients.SingleAsync(x => x.Id == item.ClientId, ct);
            if (!client.RequiresTaxDocument || item.Product is null) return null;
            return await IssueAsync(client.Id, item.Product.TaxDocumentType, LimaToday(payment.CreatedAt), payment.Currency, payment.Amount, payment.Years > 1 ? $"Pago {payment.InternalCode} ({payment.Years} años por adelantado)" : $"Pago {payment.InternalCode}", payment.Id, ct);
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            // El cobro ya quedó registrado: un fallo aquí no debe revertirlo. Se puede emitir a mano desde Documentos tributarios.
            logger.LogError(ex, "No se pudo emitir el comprobante del pago {PaymentId}", payment.Id);
            return null;
        }
    }

    /// <summary>
    /// Asigna serie y correlativo y guarda el documento. <paramref name="total"/> es lo cobrado: en la Factura incluye
    /// el IGV (se desglosa con la tasa configurada); el Recibo por honorarios no lleva IGV.
    /// </summary>
    public async Task<TaxDocument> IssueAsync(Guid clientId, TaxDocumentType type, DateOnly issueDate, string currency, decimal total, string? notes, Guid? paymentTransactionId, CancellationToken ct)
    {
        for (var attempt = 1; ; attempt++)
        {
            var settings = await db.TaxSettings.FirstOrDefaultAsync(ct) ?? db.TaxSettings.Add(new TaxSettings()).Entity;
            var isFactura = type == TaxDocumentType.Factura;
            var series = isFactura ? settings.FacturaSeries : settings.ReciboSeries;
            // El próximo correlativo configurado es el piso; si ya hay documentos más altos en la serie, se sigue desde ahí.
            var last = await db.TaxDocuments.Where(x => x.Series == series).MaxAsync(x => (int?)x.Number, ct) ?? 0;
            var number = Math.Max(isFactura ? settings.FacturaNextNumber : settings.ReciboNextNumber, last + 1);
            var baseAmount = isFactura ? Math.Round(total / (1 + settings.IgvRate), 2) : total;
            var document = new TaxDocument { ClientId = clientId, Type = type, Series = series, Number = number, IssueDate = issueDate, Currency = currency, BaseAmount = baseAmount, IgvAmount = total - baseAmount, TotalAmount = total, Notes = notes, PaymentTransactionId = paymentTransactionId };
            db.TaxDocuments.Add(document);
            if (isFactura) settings.FacturaNextNumber = number + 1; else settings.ReciboNextNumber = number + 1;
            try { await db.SaveChangesAsync(ct); return document; }
            catch (DbUpdateException)
            {
                // Otro documento tomó el mismo correlativo en paralelo (índice único Serie+Número): se recalcula.
                // Se suelta el documento para que un SaveChanges posterior del mismo contexto no lo reintente.
                db.Entry(document).State = EntityState.Detached;
                await db.Entry(settings).ReloadAsync(ct);
                if (attempt >= MaxAttempts) throw;
            }
        }
    }
}
