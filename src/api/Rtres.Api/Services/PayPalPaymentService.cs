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
public sealed class PayPalPaymentService(RtresDbContext db, IPayPalClient payPal, INotificationSender notifications, ILogger<PayPalPaymentService> logger)
{
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
    /// </summary>
    public async Task<bool> ApplyPaymentAsync(ClientProduct item, string transactionKey, decimal amount, string? currency, CancellationToken ct)
    {
        if (await PaymentExistsAsync(transactionKey, ct)) return false;
        var transaction = new PaymentTransaction { ClientProductId = item.Id, PayPalOrderIdOrSubscriptionId = transactionKey, Amount = amount, Currency = currency ?? item.Product?.Currency ?? "USD", Status = "COMPLETED" };
        transaction.InternalCode = $"RT-INT-{1 + await db.PaymentTransactions.CountAsync(ct):000000}";
        transaction.AmountPen = amount * await db.RateToPenAsync(transaction.Currency, DateOnly.FromDateTime(transaction.CreatedAt), ct);
        db.PaymentTransactions.Add(transaction);
        item.Status = ClientProductStatus.Activo;
        ExtendPeriod(item, DateTime.UtcNow);
        try { await db.SaveChangesAsync(ct); }
        catch (DbUpdateException)
        {
            // Otra vía (webhook o pantalla de retorno) registró el mismo cobro en paralelo: el índice único lo frenó.
            if (!await PaymentExistsAsync(transactionKey, ct)) throw;
            db.Entry(transaction).State = EntityState.Detached;
            await db.Entry(item).ReloadAsync(ct);
            return false;
        }

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
    /// no perder días al renovar antes; si ya venció, desde hoy); Mensual (suscripción) fija el próximo cobro a un mes;
    /// Único no tiene vencimiento.
    /// </summary>
    public static void ExtendPeriod(ClientProduct item, DateTime now)
    {
        switch (item.BillingCycle)
        {
            case BillingCycle.Anual:
                item.RenewsAt = (item.RenewsAt is DateTime renewsAt && renewsAt > now ? renewsAt : now).AddYears(1);
                break;
            case BillingCycle.Mensual:
                item.NextChargeAt = now.AddMonths(1);
                break;
        }
    }

    private Task<bool> PaymentExistsAsync(string transactionKey, CancellationToken ct) =>
        db.PaymentTransactions.AnyAsync(x => x.PayPalOrderIdOrSubscriptionId == transactionKey, ct);
}
