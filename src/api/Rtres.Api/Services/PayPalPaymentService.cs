using System.Globalization;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Services;

/// <summary>
/// Cobro de PayPal: captura las órdenes aprobadas y aplica cada pago confirmado exactamente una vez.
/// Un producto solo pasa a <see cref="ClientProductStatus.Activo"/> (y extiende su vigencia) cuando el cobro
/// está COMPLETED — aprobar la orden en PayPal no es cobrarla.
/// </summary>
public sealed class PayPalPaymentService(RtresDbContext db, IPayPalClient payPal, INotificationSender notifications, TaxDocumentService taxDocuments, ILogger<PayPalPaymentService> logger)
{
    /// <summary>
    /// Confirma el pago de un producto sin esperar al webhook (lo llama la pantalla de retorno de PayPal):
    /// suscripción → consulta su estado y sus cobros; orden → la captura.
    /// </summary>
    public Task ConfirmAsync(ClientProduct item, CancellationToken ct) =>
        item.BillingCycle.IsSubscription() && !string.IsNullOrWhiteSpace(item.PayPalSubscriptionId) ? SyncSubscriptionAsync(item, ct) : CaptureAsync(item, ct);

    /// <summary>
    /// Sincroniza una suscripción: si está activa, aplica sus cobros completados (con el id de la venta, el mismo
    /// que trae el webhook PAYMENT.SALE.COMPLETED, así que no se duplican) y toma el próximo cobro de PayPal.
    /// </summary>
    public async Task SyncSubscriptionAsync(ClientProduct item, CancellationToken ct)
    {
        var subscription = await payPal.GetSubscriptionAsync(item.PayPalSubscriptionId!, ct);
        if (subscription.Status is "CANCELLED" or "EXPIRED" && item.Status != ClientProductStatus.Cancelado)
        {
            item.Status = ClientProductStatus.Cancelado;
            await db.SaveChangesAsync(ct);
            return;
        }
        if (subscription.Status != "ACTIVE")
        {
            logger.LogInformation("Suscripción {SubscriptionId} en estado {Status}; el producto {ClientProductId} no cambia", subscription.Id, subscription.Status, item.Id);
            return;
        }
        foreach (var payment in subscription.Payments) await ApplyPaymentAsync(item, payment.Id, payment.Amount, payment.Currency, ct);
        item.Status = ClientProductStatus.Activo;
        if (subscription.NextBillingTime is DateTime next) item.NextChargeAt = next;
        await db.SaveChangesAsync(ct);
    }

    /// <summary>Captura la orden pendiente del producto (idempotente) y aplica el pago si el cobro quedó completado.</summary>
    public async Task CaptureAsync(ClientProduct item, CancellationToken ct)
    {
        var orderId = item.PayPalOrderId;
        if (string.IsNullOrWhiteSpace(orderId) || await PaymentExistsAsync(orderId, ct)) return;
        var capture = await payPal.CaptureOrderAsync(orderId, ct);
        if (capture.Status == "COMPLETED" && capture.Amount is decimal amount)
            await ApplyPaymentAsync(item, orderId, amount, capture.Currency, ct);
        else
            logger.LogWarning("Orden {OrderId} capturada con estado {Status}; el producto {ClientProductId} sigue sin activar", orderId, capture.Status, item.Id);
    }

    /// <summary>
    /// Registra un cobro confirmado. <paramref name="transactionKey"/> identifica el cobro (id de la orden, o de la
    /// venta en suscripciones): el mismo cobro llega por varias vías (respuesta de la captura, webhook, reintentos) y
    /// solo el primero crea la transacción, extiende la vigencia y avisa al cliente. Devuelve si se aplicó.
    /// <paramref name="years"/>: años pagados por adelantado (productos anuales); si no se indica y el cobro es la orden
    /// de PayPal pendiente, se usan los años con los que se creó esa orden.
    /// </summary>
    public async Task<bool> ApplyPaymentAsync(ClientProduct item, string transactionKey, decimal amount, string? currency, CancellationToken ct, string method = PaymentMethods.PayPal, DateTime? paidAt = null, int? years = null)
    {
        if (await PaymentExistsAsync(transactionKey, ct)) return false;
        var when = paidAt ?? DateTime.UtcNow;
        var paidYears = item.BillingCycle == BillingCycle.Anual ? Math.Clamp(years ?? (transactionKey == item.PayPalOrderId ? item.PayPalOrderYears : null) ?? 1, 1, ClientProductPricing.MaxPrepaidYears) : 1;
        var transaction = new PaymentTransaction { ClientId = item.ClientId, ClientProductId = item.Id, PayPalOrderIdOrSubscriptionId = transactionKey, Amount = amount, Currency = currency ?? item.Product?.Currency ?? "USD", Status = "COMPLETED", Method = method, CreatedAt = when, Years = paidYears };
        transaction.InternalCode = $"RT-INT-{1 + await db.PaymentTransactions.CountAsync(ct):000000}";
        transaction.AmountPen = amount * await db.RateToPenAsync(transaction.Currency, DateOnly.FromDateTime(transaction.CreatedAt), ct);
        db.PaymentTransactions.Add(transaction);
        item.Status = ClientProductStatus.Activo;
        // El descuento cubre solo el primer año pagado: se resuelve tras extender ese año y luego se suman los demás.
        ExtendPeriod(item, when);
        item.OnPaymentApplied();
        for (var year = 1; year < paidYears; year++) ExtendPeriod(item, when);
        try { await db.SaveChangesAsync(ct); }
        catch (DbUpdateException)
        {
            // Otra vía (webhook o pantalla de retorno) registró el mismo cobro en paralelo: el índice único lo frenó.
            if (!await PaymentExistsAsync(transactionKey, ct)) throw;
            db.Entry(transaction).State = EntityState.Detached;
            await db.Entry(item).ReloadAsync(ct);
            return false;
        }

        await taxDocuments.IssueForPaymentAsync(transaction, ct);
        if (await db.Clients.FindAsync([item.ClientId], ct) is Client client)
            await notifications.SendAsync(client, new Notification(NotificationType.PaymentReceived, new()
            {
                ["product"] = item.Product?.Name ?? "",
                ["amount"] = amount.ToString(CultureInfo.InvariantCulture),
                ["currency"] = transaction.Currency,
            }, $"payment:{transactionKey}"), ct);
        return true;
    }

    /// <summary>
    /// Vigencia que compra un pago según el ciclo: Anual suma un año (desde el vencimiento actual si aún no pasó, para
    /// no perder días al renovar antes; si ya venció, desde hoy); las suscripciones (Mensual, Bimestral, Trimestral,
    /// Semestral) fijan el próximo cobro a 1, 2, 3 o 6 meses;
    /// Único no tiene vencimiento.
    /// </summary>
    public static void ExtendPeriod(ClientProduct item, DateTime now)
    {
        switch (item.BillingCycle)
        {
            case BillingCycle.Anual:
                item.RenewsAt = (item.RenewsAt is DateTime renewsAt && renewsAt > now ? renewsAt : now).AddYears(1);
                break;
            case var cycle when cycle.SubscriptionMonths() is int months:
                item.NextChargeAt = now.AddMonths(months);
                break;
        }
    }

    private Task<bool> PaymentExistsAsync(string transactionKey, CancellationToken ct) =>
        db.PaymentTransactions.AnyAsync(x => x.PayPalOrderIdOrSubscriptionId == transactionKey, ct);
}
