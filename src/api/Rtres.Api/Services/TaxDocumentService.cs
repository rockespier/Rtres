using Microsoft.EntityFrameworkCore;
using Rtres.Api.Jobs;
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
            if (payment.ClientProductId is null || await db.TaxDocuments.AnyAsync(x => x.PaymentTransactionId == payment.Id, ct)) return null;
            var item = await db.ClientProducts.Include(x => x.Product).SingleAsync(x => x.Id == payment.ClientProductId, ct);
            var client = await db.Clients.SingleAsync(x => x.Id == item.ClientId, ct);
            if (!client.RequiresTaxDocument || item.Product is null) return null;
            return await IssueAsync(client.Id, item.Product.TaxDocumentType, LimaToday(payment.CreatedAt), payment.Currency, payment.Amount, payment.Years > 1 ? $"Pago {payment.InternalCode} ({payment.Years} años por adelantado)" : $"Pago {payment.InternalCode}", payment.Id, ct, [new TaxDocumentLine { ClientProductId = item.Id, Description = LineDescription(item), Amount = payment.Amount }]);
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
    public async Task<TaxDocument> IssueAsync(Guid clientId, TaxDocumentType type, DateOnly issueDate, string currency, decimal total, string? notes, Guid? paymentTransactionId, CancellationToken ct, IReadOnlyList<TaxDocumentLine>? lines = null)
    {
        for (var attempt = 1; ; attempt++)
        {
            var settings = await db.TaxSettings.FirstOrDefaultAsync(ct) ?? db.TaxSettings.Add(new TaxSettings()).Entity;
            var isFactura = type == TaxDocumentType.Factura;
            var series = isFactura ? settings.FacturaSeries : settings.ReciboSeries;
            // El próximo correlativo configurado es el piso; si ya hay documentos más altos en la serie, se sigue desde ahí.
            // Se filtra por tipo: factura y recibo pueden compartir serie (E001 en SUNAT SOL) con correlativos independientes.
            var last = await db.TaxDocuments.Where(x => x.Type == type && x.Series == series).MaxAsync(x => (int?)x.Number, ct) ?? 0;
            var number = Math.Max(isFactura ? settings.FacturaNextNumber : settings.ReciboNextNumber, last + 1);
            var baseAmount = isFactura ? Math.Round(total / (1 + settings.IgvRate), 2) : total;
            var document = new TaxDocument { ClientId = clientId, Type = type, Series = series, Number = number, IssueDate = issueDate, Currency = currency, BaseAmount = baseAmount, IgvAmount = total - baseAmount, TotalAmount = total, Notes = notes, PaymentTransactionId = paymentTransactionId };
            db.TaxDocuments.Add(document);
            var docLines = (lines ?? []).Select((x, i) => new TaxDocumentLine { TaxDocumentId = document.Id, ClientProductId = x.ClientProductId, Description = x.Description, Amount = x.Amount, Order = i }).ToList();
            db.TaxDocumentLines.AddRange(docLines);
            if (isFactura) settings.FacturaNextNumber = number + 1; else settings.ReciboNextNumber = number + 1;
            try { await db.SaveChangesAsync(ct); return document; }
            catch (DbUpdateException)
            {
                // Otro documento tomó el mismo correlativo en paralelo (índice único Tipo+Serie+Número): se recalcula.
                // Se suelta el documento para que un SaveChanges posterior del mismo contexto no lo reintente.
                db.Entry(document).State = EntityState.Detached;
                foreach (var line in docLines) db.Entry(line).State = EntityState.Detached;
                await db.Entry(settings).ReloadAsync(ct);
                if (attempt >= MaxAttempts) throw;
            }
        }
    }

    /// <summary>
    /// Extorna un comprobante registrado por error: elimina el documento y su cobro, y deja el producto como estaba antes del
    /// pago. Queda constancia en <see cref="PaymentReversal"/>. No devuelve dinero: un cobro de PayPal se reembolsa en PayPal.
    /// El correlativo solo se libera si no se emitió en SUNAT y es el último de la serie vigente. Devuelve null si no existe.
    /// </summary>
    public async Task<TaxDocumentReversalResult?> ReverseAsync(Guid documentId, string reason, bool notIssued, Guid? userId, CancellationToken ct)
    {
        var document = await db.TaxDocuments.SingleOrDefaultAsync(x => x.Id == documentId, ct);
        if (document is null) return null;
        var payment = document.PaymentTransactionId is Guid paymentId ? await db.PaymentTransactions.SingleOrDefaultAsync(x => x.Id == paymentId, ct) : null;
        var item = payment is null ? null : await RevertProductAsync(payment, reason, ct);
        var numberReleased = notIssued && await ReleaseNumberAsync(document, ct);
        db.PaymentReversals.Add(new PaymentReversal
        {
            ClientId = document.ClientId, ClientProductId = payment?.ClientProductId, PaymentKey = payment?.PayPalOrderIdOrSubscriptionId, Method = payment?.Method, InternalCode = payment?.InternalCode,
            Amount = payment?.Amount ?? document.TotalAmount, Currency = payment?.Currency ?? document.Currency, AmountPen = payment?.AmountPen, PaidAt = payment?.CreatedAt,
            DocumentType = document.Type, Series = document.Series, Number = document.Number, IssueDate = document.IssueDate, Reason = reason, NotIssued = notIssued, NumberReleased = numberReleased, ReversedByUserId = userId,
        });
        db.TaxDocumentLines.RemoveRange(await db.TaxDocumentLines.Where(x => x.TaxDocumentId == document.Id).ToListAsync(ct));
        db.TaxDocuments.Remove(document);
        if (payment is not null)
        {
            // El aviso de "pago recibido" se retira y deja de frenar el de un nuevo registro con el mismo N° de operación.
            var dedupeKey = $"payment:{payment.PayPalOrderIdOrSubscriptionId}";
            db.NotificationLogs.RemoveRange(await db.NotificationLogs.Where(x => x.DedupeKey == dedupeKey).ToListAsync(ct));
            db.PortalNotifications.RemoveRange(await db.PortalNotifications.Where(x => x.DedupeKey == dedupeKey).ToListAsync(ct));
            db.PaymentTransactions.Remove(payment);
        }
        await db.SaveChangesAsync(ct);
        return new TaxDocumentReversalResult(numberReleased, payment?.Method, item?.Status, item?.RenewsAt, item?.NextChargeAt);
    }

    /// <summary>Quita lo que hizo el pago en su producto. El comprobante manual registra el cobro sin tocar la vigencia: ahí no hay nada que deshacer.</summary>
    private async Task<ClientProduct?> RevertProductAsync(PaymentTransaction payment, string reason, CancellationToken ct)
    {
        var report = await db.TransferReports.SingleOrDefaultAsync(x => x.PaymentTransactionId == payment.Id, ct);
        if (report is not null) (report.Status, report.RejectionReason, report.PaymentTransactionId) = (TransferReportStatus.Rechazado, $"Pago extornado: {reason}", null);
        if (payment.ClientProductId is not Guid itemId || payment.PayPalOrderIdOrSubscriptionId.StartsWith("MANUAL-", StringComparison.Ordinal)) return null;
        var item = await db.ClientProducts.SingleOrDefaultAsync(x => x.Id == itemId, ct);
        if (item is null) return null;
        var others = await db.PaymentTransactions.Where(x => x.ClientProductId == itemId && x.Id != payment.Id).Select(x => x.CreatedAt).ToListAsync(ct);
        // El descuento termina con el primer año pagado: los años adicionales se suman después.
        item.OnPaymentReversed(item.BillingCycle == BillingCycle.Anual ? item.RenewsAt?.AddYears(1 - payment.Years) : item.NextChargeAt);
        PayPalPaymentService.RollbackPeriod(item, payment.Years, others.All(x => x <= payment.CreatedAt));
        // Sin otros pagos, lo contratado por el cliente (PayPal o transferencia reportada) vuelve a esperar su primer pago;
        // lo asociado por Rtres nació activo y sigue su fecha de vencimiento.
        if (others.Count == 0 && item.Status != ClientProductStatus.Cancelado && (payment.Method == PaymentMethods.PayPal || report is not null))
        {
            item.Status = ClientProductStatus.Pendiente;
            if (item.RenewsAt == payment.CreatedAt) item.RenewsAt = null;
            if (item.NextChargeAt == payment.CreatedAt) item.NextChargeAt = null;
        }
        else item.Status = RenewalReminderJob.StatusFor(item.Status, item.RenewsAt, DateTime.UtcNow);
        return item;
    }

    private async Task<bool> ReleaseNumberAsync(TaxDocument document, CancellationToken ct)
    {
        var settings = await db.TaxSettings.FirstOrDefaultAsync(ct);
        if (settings is null || await db.TaxDocuments.AnyAsync(x => x.Type == document.Type && x.Series == document.Series && x.Number > document.Number, ct)) return false;
        var isFactura = document.Type == TaxDocumentType.Factura;
        if ((isFactura ? settings.FacturaSeries : settings.ReciboSeries) != document.Series || (isFactura ? settings.FacturaNextNumber : settings.ReciboNextNumber) != document.Number + 1) return false;
        if (isFactura) settings.FacturaNextNumber = document.Number; else settings.ReciboNextNumber = document.Number;
        return true;
    }

    /// <summary>Texto de la línea: producto y, si tiene, su dominio.</summary>
    public static string LineDescription(ClientProduct item)
    {
        var name = item.Product?.Name ?? "Producto";
        var text = string.IsNullOrWhiteSpace(item.DomainName) ? name : $"{name} — {item.DomainName}";
        return text.Length > 300 ? text[..300] : text;
    }
}

/// <summary>Resultado de un extorno; el estado y las fechas son los del producto cuando el pago lo había modificado.</summary>
public sealed record TaxDocumentReversalResult(bool NumberReleased, string? PaymentMethod, ClientProductStatus? ProductStatus, DateTime? RenewsAt, DateTime? NextChargeAt);
