using System.Globalization;
using System.Security.Claims;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Jobs;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>
/// Pago por transferencia: cuentas bancarias de Rtres, medios de pago habilitados, el reporte del cliente (N° de operación
/// y/o constancia) y su revisión por Rtres, que al aprobarse registra el cobro igual que "Registrar pago".
/// </summary>
[ApiController, Authorize, Route("api")]
public sealed partial class BankTransfersController(RtresDbContext db, BankTransferService transfers, PayPalPaymentService payments, INotificationSender notifications, IConfiguration configuration, ILogger<BankTransfersController> logger) : ControllerBase
{
    public const long MaxReceiptBytes = 5 * 1024 * 1024;
    public static readonly string[] Currencies = ["PEN", "USD", "EUR"];
    private static readonly string[] ReceiptTypes = ["image/jpeg", "image/png", "image/webp", "image/heic", "application/pdf"];

    private Guid UserId => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    private bool IsSuperAdmin => User.IsInRole(nameof(UserRole.SuperAdmin));

    // ---- Medios de pago ----

    /// <summary>Qué medios de pago ve el cliente (catálogo, renovación y tarjetas de servicios).</summary>
    [HttpGet("payment-methods")]
    public async Task<ActionResult> EnabledPaymentMethods(CancellationToken ct) { var s = await transfers.SettingsAsync(ct); return Ok(new { payPal = s.PayPalEnabled, bankTransfer = s.BankTransferEnabled }); }

    [HttpPatch("admin/payment-settings"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> UpdatePaymentSettings(PaymentSettingsRequest request, CancellationToken ct)
    {
        var settings = await transfers.SettingsAsync(ct);
        var payPal = request.PayPal ?? settings.PayPalEnabled; var bank = request.BankTransfer ?? settings.BankTransferEnabled;
        if (!payPal && !bank) return BadRequest(new { message = "Deja al menos un medio de pago activo: sin ninguno, los clientes no podrían pagar." });
        if (bank && !settings.BankTransferEnabled && !await db.BankAccounts.AnyAsync(x => x.IsActive, ct)) return BadRequest(new { message = "Agrega al menos una cuenta bancaria activa antes de habilitar la transferencia." });
        (settings.PayPalEnabled, settings.BankTransferEnabled, settings.UpdatedAt) = (payPal, bank, DateTime.UtcNow);
        await db.SaveChangesAsync(ct);
        return Ok(new { payPal, bankTransfer = bank });
    }

    // ---- Cuentas bancarias ----

    [HttpGet("admin/bank-accounts"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Accounts(CancellationToken ct) =>
        Ok((await db.BankAccounts.OrderBy(x => x.SortOrder).ThenBy(x => x.Currency).ThenBy(x => x.BankName).ToListAsync(ct)).Select(x => BankAccountDto.From(x)));

    [HttpPost("admin/bank-accounts"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> CreateAccount(BankAccountRequest request, CancellationToken ct)
    {
        var account = new BankAccount { SortOrder = await db.BankAccounts.CountAsync(ct) };
        if (Apply(account, request) is string error) return BadRequest(new { message = error });
        if (await DuplicateAsync(account, ct)) return Conflict(new { message = "Esa cuenta ya está registrada." });
        db.BankAccounts.Add(account); await db.SaveChangesAsync(ct);
        return Created($"/api/admin/bank-accounts/{account.Id}", BankAccountDto.From(account));
    }

    [HttpPut("admin/bank-accounts/{id:guid}"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> UpdateAccount(Guid id, BankAccountRequest request, CancellationToken ct)
    {
        var account = await db.BankAccounts.FindAsync([id], ct); if (account is null) return NotFound();
        if (Apply(account, request) is string error) return BadRequest(new { message = error });
        if (await DuplicateAsync(account, ct)) return Conflict(new { message = "Esa cuenta ya está registrada." });
        if (!account.IsActive && await LastActiveAccountWithTransferOnAsync(account.Id, ct)) return BadRequest(new { message = "Es la única cuenta activa y la transferencia está habilitada: desactiva primero la transferencia en Medios de pago." });
        await db.SaveChangesAsync(ct);
        return Ok(BankAccountDto.From(account));
    }

    /// <summary>Elimina una cuenta sin pagos reportados; con historial solo se puede desactivar.</summary>
    [HttpDelete("admin/bank-accounts/{id:guid}"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> DeleteAccount(Guid id, CancellationToken ct)
    {
        var account = await db.BankAccounts.FindAsync([id], ct); if (account is null) return NotFound();
        if (await db.TransferReports.AnyAsync(x => x.BankAccountId == id, ct)) return Conflict(new { message = "Esta cuenta tiene pagos reportados: desactívala en lugar de eliminarla." });
        if (account.IsActive && await LastActiveAccountWithTransferOnAsync(id, ct)) return BadRequest(new { message = "Es la única cuenta activa y la transferencia está habilitada: desactiva primero la transferencia en Medios de pago." });
        db.BankAccounts.Remove(account); await db.SaveChangesAsync(ct);
        return NoContent();
    }

    private async Task<bool> LastActiveAccountWithTransferOnAsync(Guid id, CancellationToken ct) =>
        (await transfers.SettingsAsync(ct)).BankTransferEnabled && !await db.BankAccounts.AnyAsync(x => x.IsActive && x.Id != id, ct);

    private Task<bool> DuplicateAsync(BankAccount account, CancellationToken ct) =>
        db.BankAccounts.AnyAsync(x => x.Id != account.Id && x.BankName == account.BankName && x.AccountNumber == account.AccountNumber, ct);

    internal static string? Apply(BankAccount account, BankAccountRequest r)
    {
        var bank = r.BankName?.Trim(); var holder = r.Holder?.Trim(); var currency = r.Currency?.Trim().ToUpperInvariant();
        var number = Digits(r.AccountNumber); var cci = Digits(r.Cci);
        if (string.IsNullOrEmpty(bank) || string.IsNullOrEmpty(holder)) return "El banco y el titular son obligatorios.";
        if (currency is null || !Currencies.Contains(currency)) return "La moneda debe ser PEN, USD o EUR.";
        if (string.IsNullOrEmpty(number) || number.Length < 6 || number.Length > 40) return "Indica un número de cuenta válido.";
        if (cci is { Length: > 0 } && !CciPattern().IsMatch(cci)) return "El CCI tiene 20 dígitos.";
        (account.BankName, account.Holder, account.Currency, account.Type, account.AccountNumber, account.Cci, account.IsActive) = (bank, holder, currency, r.Type, number, cci is { Length: > 0 } ? cci : null, r.IsActive);
        return null;
    }

    /// <summary>Quita espacios (se pegan desde la app del banco); mantiene guiones y letras (cuentas del exterior / IBAN).</summary>
    private static string? Digits(string? value) => value is null ? null : WhitespacePattern().Replace(value, "").ToUpperInvariant();

    [GeneratedRegex(@"^\d{20}$")] private static partial Regex CciPattern();
    [GeneratedRegex(@"\s+")] private static partial Regex WhitespacePattern();

    // ---- Reporte del cliente ----

    /// <summary>
    /// El cliente informa que transfirió: con N° de operación, constancia (foto o PDF) o ambos. Queda en revisión hasta que
    /// Rtres lo apruebe o rechace; mientras tanto no se puede reportar otro pago para el mismo producto.
    /// </summary>
    [HttpPost("client-products/{id:guid}/transfer-reports"), Authorize(Roles = "Cliente,Admin"), RequestSizeLimit(8_000_000), RequestFormLimits(MultipartBodyLengthLimit = 8_000_000)]
    public async Task<ActionResult> Report(Guid id, [FromForm] TransferReportRequest request, CancellationToken ct, IFormFile? receipt = null)
    {
        if (!Guid.TryParse(User.FindFirstValue("client_id"), out var clientId)) return Forbid();
        var settings = await transfers.SettingsAsync(ct);
        if (!settings.BankTransferEnabled) return BadRequest(new { message = "El pago por transferencia no está disponible por ahora." });
        var item = await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == id && x.ClientId == clientId, ct);
        if (item?.Product is null) return NotFound();
        if (!CanPayByTransfer(item, settings)) return BadRequest(new { message = "Este producto no tiene un pago por transferencia pendiente." });
        if (await db.TransferReports.AnyAsync(x => x.ClientProductId == id && x.Status == TransferReportStatus.Pendiente, ct)) return Conflict(new { message = "Ya reportaste un pago para este producto: lo estamos revisando." });
        var account = await db.BankAccounts.SingleOrDefaultAsync(x => x.Id == request.BankAccountId && x.IsActive, ct);
        if (account is null) return BadRequest(new { message = "Elige la cuenta a la que transferiste." });
        var operation = request.OperationNumber?.Trim();
        if (string.IsNullOrEmpty(operation) && receipt is null) return BadRequest(new { message = "Indica el N° de operación o sube la constancia de la transferencia." });
        if (operation is { Length: > 60 }) return BadRequest(new { message = "El N° de operación es demasiado largo." });
        if (request.Amount <= 0) return BadRequest(new { message = "Indica el monto transferido." });
        if (request.PaidAt > DateOnly.FromDateTime(DateTime.UtcNow.AddDays(1)) || request.PaidAt < DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-90))) return BadRequest(new { message = "La fecha de la transferencia no es válida." });
        if (item.ValidateYears(request.Years) is string yearsError) return BadRequest(new { message = yearsError });
        if (!string.IsNullOrEmpty(operation) && await db.TransferReports.AnyAsync(x => x.OperationNumber == operation && x.BankAccountId == account.Id && x.Status != TransferReportStatus.Rechazado, ct))
            return Conflict(new { message = "Ese N° de operación ya fue reportado." });

        var report = new TransferReport { ClientId = clientId, ClientProductId = item.Id, BankAccountId = account.Id, Amount = Math.Round(request.Amount, 2), Currency = account.Currency, PaidAt = request.PaidAt, OperationNumber = string.IsNullOrEmpty(operation) ? null : operation, Years = request.Years, ReportedByUserId = UserId };
        if (receipt is not null)
        {
            if (receipt.Length == 0 || receipt.Length > MaxReceiptBytes) return BadRequest(new { message = "La constancia debe pesar como máximo 5 MB." });
            var type = receipt.ContentType?.ToLowerInvariant() ?? "";
            if (!ReceiptTypes.Contains(type)) return BadRequest(new { message = "La constancia debe ser una imagen (JPG, PNG, WEBP) o un PDF." });
            using var stream = new MemoryStream(); await receipt.CopyToAsync(stream, ct);
            (report.ReceiptFileName, report.ReceiptContentType, report.ReceiptContent) = (Path.GetFileName(receipt.FileName), type, stream.ToArray());
        }
        db.TransferReports.Add(report); await db.SaveChangesAsync(ct);
        await NotifyStaffAsync(report, item, ct);
        return Created($"/api/transfer-reports/{report.Id}", new TransferReportSummary(report.Id, report.Status, report.CreatedAt, null));
    }

    /// <summary>
    /// Mismo criterio que la tarjeta de "Mis servicios": producto pendiente o por renovar (anual en los 30 días previos o
    /// vencido; suscripción por cobrar). Se cobra por transferencia si así se contrató, o si PayPal está deshabilitado y el
    /// producto no tiene una suscripción de PayPal que cobre sola.
    /// </summary>
    internal static bool CanPayByTransfer(ClientProduct item, PaymentSettings settings)
    {
        if (!settings.BankTransferEnabled || item.Status == ClientProductStatus.Cancelado) return false;
        if (!item.IsManualBilling && (settings.PayPalEnabled || !string.IsNullOrWhiteSpace(item.PayPalSubscriptionId))) return false;
        if (item.Status == ClientProductStatus.Pendiente) return true;
        if (item.BillingCycle == BillingCycle.Unico) return false;
        if (item.Status is ClientProductStatus.PorVencer or ClientProductStatus.Vencido) return true;
        var due = item.BillingCycle.IsSubscription() ? item.NextChargeAt : item.RenewsAt;
        return due is DateTime date && date <= DateTime.UtcNow.AddDays(PaymentsController.RenewalWindowDays);
    }

    private async Task NotifyStaffAsync(TransferReport report, ClientProduct item, CancellationToken ct)
    {
        var staffEmail = configuration["Notifications:StaffEmail"] is { Length: > 0 } configured ? configured : configuration["Smtp:From"];
        if (string.IsNullOrWhiteSpace(staffEmail)) { logger.LogWarning("Pago reportado {ReportId} sin aviso: falta Notifications:StaffEmail", report.Id); return; }
        var client = await db.Clients.SingleAsync(x => x.Id == report.ClientId, ct);
        var data = new Dictionary<string, string> { ["reportId"] = report.Id.ToString(), ["company"] = client.CompanyName, ["product"] = item.Product?.Name ?? "", ["amount"] = report.Amount.ToString(CultureInfo.InvariantCulture), ["currency"] = report.Currency };
        if (report.OperationNumber is not null) data["operation"] = report.OperationNumber;
        await notifications.SendAsync(client, new Notification(NotificationType.TransferReported, data, $"transfer-reported:{report.Id}", staffEmail), ct);
    }

    /// <summary>Constancia subida por el cliente: la ve el cliente dueño y Rtres.</summary>
    [HttpGet("transfer-reports/{id:guid}/receipt")]
    public async Task<ActionResult> Receipt(Guid id, CancellationToken ct)
    {
        var report = await db.TransferReports.SingleOrDefaultAsync(x => x.Id == id, ct);
        if (report?.ReceiptContent is null) return NotFound();
        if (!IsSuperAdmin && (!Guid.TryParse(User.FindFirstValue("client_id"), out var clientId) || clientId != report.ClientId)) return NotFound();
        Response.Headers.CacheControl = "private, no-store";
        return File(report.ReceiptContent, report.ReceiptContentType ?? "application/octet-stream", report.ReceiptFileName);
    }

    // ---- Revisión de Rtres ----

    [HttpGet("admin/transfer-reports"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Reports(TransferReportStatus? status, CancellationToken ct)
    {
        var query = from report in db.TransferReports
                    join client in db.Clients on report.ClientId equals client.Id
                    join item in db.ClientProducts on report.ClientProductId equals item.Id
                    join product in db.Products on item.ProductId equals product.Id
                    join account in db.BankAccounts on report.BankAccountId equals account.Id into accounts
                    from account in accounts.DefaultIfEmpty()
                    where status == null || report.Status == status
                    orderby report.Status == TransferReportStatus.Pendiente descending, report.CreatedAt descending
                    select new TransferReportDto(report.Id, report.ClientId, client.CompanyName, report.ClientProductId, product.Name, item.DomainName, product.Currency, report.Amount, report.Currency, report.PaidAt, report.OperationNumber, report.Years,
                        account == null ? null : account.BankName + " " + account.Currency + " · " + account.AccountNumber, report.ReceiptContent != null, report.ReceiptContentType, report.Status, report.RejectionReason, report.CreatedAt, report.ReviewedAt);
        return Ok(await query.Take(200).ToListAsync(ct));
    }

    /// <summary>
    /// Confirma el pago: registra el cobro con lo que Rtres verificó en su banco (por defecto, lo reportado), activa o
    /// renueva el producto, emite el comprobante y avisa al cliente, igual que "Registrar pago" en el detalle del cliente.
    /// </summary>
    [HttpPost("admin/transfer-reports/{id:guid}/approve"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Approve(Guid id, ApproveTransferRequest request, CancellationToken ct)
    {
        var report = await db.TransferReports.SingleOrDefaultAsync(x => x.Id == id, ct); if (report is null) return NotFound();
        if (report.Status != TransferReportStatus.Pendiente) return Conflict(new { message = "Este pago ya fue revisado." });
        var item = await db.ClientProducts.Include(x => x.Product).Include(x => x.Project).SingleAsync(x => x.Id == report.ClientProductId, ct);
        var amount = Math.Round(request.Amount ?? report.Amount, 2);
        if (amount <= 0) return BadRequest(new { message = "Indica un monto mayor a 0." });
        var operation = (request.OperationNumber ?? report.OperationNumber)?.Trim();
        var paidAt = request.PaidAt ?? report.PaidAt;
        var key = string.IsNullOrEmpty(operation) ? $"TRF-R{report.Id:N}" : $"TRF-{operation}";
        if (key.Length > 100) return BadRequest(new { message = "El N° de operación es demasiado largo." });
        // Quien paga por transferencia (aunque se haya contratado por PayPal) pasa a cobro manual: las próximas renovaciones van por transferencia.
        item.IsManualBilling = true;
        if (!await payments.ApplyPaymentAsync(item, key, amount, report.Currency, ct, PaymentMethods.Transferencia, DateTime.SpecifyKind(paidAt.ToDateTime(TimeOnly.MinValue), DateTimeKind.Utc), report.Years))
            return Conflict(new { message = "Esa transferencia (N° de operación) ya está registrada como pago." });
        item.Status = RenewalReminderJob.StatusFor(item.Status, item.RenewsAt, DateTime.UtcNow);
        (report.Status, report.Amount, report.OperationNumber, report.PaidAt, report.ReviewedAt, report.ReviewedByUserId) = (TransferReportStatus.Aprobado, amount, string.IsNullOrEmpty(operation) ? null : operation, paidAt, DateTime.UtcNow, UserId);
        report.PaymentTransactionId = await db.PaymentTransactions.Where(x => x.PayPalOrderIdOrSubscriptionId == key).Select(x => (Guid?)x.Id).SingleOrDefaultAsync(ct);
        await db.SaveChangesAsync(ct);
        return Ok(new { status = report.Status, clientProductStatus = item.Status });
    }

    [HttpPost("admin/transfer-reports/{id:guid}/reject"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Reject(Guid id, RejectTransferRequest request, CancellationToken ct)
    {
        var report = await db.TransferReports.SingleOrDefaultAsync(x => x.Id == id, ct); if (report is null) return NotFound();
        if (report.Status != TransferReportStatus.Pendiente) return Conflict(new { message = "Este pago ya fue revisado." });
        var reason = request.Reason?.Trim();
        if (string.IsNullOrEmpty(reason)) return BadRequest(new { message = "Indica el motivo: el cliente lo recibirá por correo." });
        if (reason.Length > 500) return BadRequest(new { message = "El motivo es demasiado largo (máximo 500 caracteres)." });
        (report.Status, report.RejectionReason, report.ReviewedAt, report.ReviewedByUserId) = (TransferReportStatus.Rechazado, reason, DateTime.UtcNow, UserId);
        await db.SaveChangesAsync(ct);
        var product = await db.ClientProducts.Where(x => x.Id == report.ClientProductId).Select(x => x.DomainName ?? x.Product!.Name).SingleAsync(ct);
        if (await db.Clients.FindAsync([report.ClientId], ct) is Client client)
            await notifications.SendAsync(client, new Notification(NotificationType.TransferRejected, new() { ["product"] = product, ["amount"] = report.Amount.ToString(CultureInfo.InvariantCulture), ["currency"] = report.Currency, ["reason"] = reason }, $"transfer-rejected:{report.Id}"), ct);
        return Ok(new { status = report.Status });
    }
}

public sealed record PaymentSettingsRequest(bool? PayPal, bool? BankTransfer);
public sealed record BankAccountRequest(string? BankName, string? Holder, string? Currency, BankAccountType Type, string? AccountNumber, string? Cci, bool IsActive = true);
public sealed class TransferReportRequest { public Guid BankAccountId { get; set; } public decimal Amount { get; set; } public DateOnly PaidAt { get; set; } public string? OperationNumber { get; set; } public int Years { get; set; } = 1; }
public sealed record ApproveTransferRequest(decimal? Amount, DateOnly? PaidAt, string? OperationNumber);
public sealed record RejectTransferRequest(string? Reason);
public sealed record TransferReportDto(Guid Id, Guid ClientId, string Company, Guid ClientProductId, string Product, string? DomainName, string ProductCurrency, decimal Amount, string Currency, DateOnly PaidAt, string? OperationNumber, int Years, string? Account, bool HasReceipt, string? ReceiptContentType, TransferReportStatus Status, string? RejectionReason, DateTime CreatedAt, DateTime? ReviewedAt);
