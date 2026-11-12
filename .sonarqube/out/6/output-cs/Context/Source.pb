�
6C:\repo\rtres-net\Rtres\src\api\Rtres.Api\Contracts.cs�using Rtres.Domain;

namespace Rtres.Api;

public record LoginRequest(string Email, string Password);
public record TicketAttachmentDto(Guid Id, string FileName, string ContentType, long SizeBytes);
public record CreateTicketRequest(Guid ProjectId, TicketType Type, string Title, string Description, string? CurrentBehavior, string? ExpectedBehavior, string? StepsToReproduce, string? Environment, string? AcceptanceCriteria, string? EstimatedImpact, Guid? RepositoryId = null, Guid? ClientProductId = null);
public record CreateTicketCommentRequest(string Body);
public record UpdateTicketStatusRequest(TicketStatus Status);
public record TicketCommentDto(Guid Id, string Body, bool FromGithub, string? AuthorName, DateTime CreatedAt);
ParseOptions.0.json��
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\AccountController.cs��using System.Security.Claims;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using Hangfire;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ClosedXML.Excel;
using Rtres.Api.Jobs;
using Rtres.Api.Notifications;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

[ApiController, Authorize, Route("api")]
public sealed class AccountController(RtresDbContext db, AccessEmailService accessEmail) : ControllerBase
{
    private Guid UserId => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    private bool TryGetClientId(out Guid clientId) => Guid.TryParse(User.FindFirstValue("client_id"), out clientId);
    internal static readonly PasswordHasher<UserAccount> Hasher = new();

    [HttpGet("profile")]
    public async Task<ActionResult> Profile(CancellationToken ct) { var user = await db.UserAccounts.FindAsync([UserId], ct); return user is null ? NotFound() : Ok(new { name = user.Name, email = user.Email }); }
    [HttpPatch("profile")]
    public async Task<ActionResult> UpdateProfile(ProfileRequest request, CancellationToken ct) { if (string.IsNullOrWhiteSpace(request.Name)) return BadRequest(new { message = "El nombre es obligatorio." }); var user = await db.UserAccounts.FindAsync([UserId], ct); if (user is null) return NotFound(); user.Name = request.Name.Trim(); await db.SaveChangesAsync(ct); return Ok(); }
    [HttpPost("profile/change-password")]
    public async Task<ActionResult> ChangePassword(ChangePasswordRequest request, CancellationToken ct) { var user = await db.UserAccounts.FindAsync([UserId], ct); if (user is null) return NotFound(); if (Hasher.VerifyHashedPassword(user, user.PasswordHash, request.CurrentPassword) == PasswordVerificationResult.Failed) return BadRequest(new { message = "La contraseña actual no coincide." }); if (string.IsNullOrWhiteSpace(request.NewPassword)) return BadRequest(new { message = "La nueva contraseña es obligatoria." }); user.PasswordHash = Hasher.HashPassword(user, request.NewPassword); await db.SaveChangesAsync(ct); return Ok(); }
    /// <summary>Contraseña temporal aleatoria: solo se devuelve una vez (en la respuesta que crea/restablece el acceso).</summary>
    internal static string TemporaryPassword() => Convert.ToBase64String(RandomNumberGenerator.GetBytes(12)).Replace("+", "A").Replace("/", "B");

    [HttpGet("billing/transactions")]
    public async Task<ActionResult> Transactions(Guid? clientId, CancellationToken ct)
    {
        // Cliente/Admin: siempre sus propios pagos. SuperAdmin: los del cliente seleccionado o, sin selección, los de todos.
        Guid? scope;
        if (User.IsInRole(nameof(UserRole.SuperAdmin))) scope = clientId;
        else if (TryGetClientId(out var own)) scope = own;
        else return Ok(Array.Empty<object>());
        return Ok(await (from transaction in db.PaymentTransactions
                         join client in db.Clients on transaction.ClientId equals client.Id
                         where scope == null || transaction.ClientId == scope
                         orderby transaction.CreatedAt descending
                         // Un cobro sin producto (ej. remesa por un desarrollo) muestra su nota en lugar del producto.
                         let product = (from clientProduct in db.ClientProducts join p in db.Products on clientProduct.ProductId equals p.Id where clientProduct.Id == transaction.ClientProductId select p.Name).FirstOrDefault()
                         select new { id = transaction.Id, createdAt = transaction.CreatedAt, product = product ?? transaction.Notes ?? transaction.Method, clientName = client.CompanyName, amount = transaction.Amount, currency = transaction.Currency, status = transaction.Status, internalCode = transaction.InternalCode }).ToListAsync(ct));
    }
    [HttpGet("team/users"), Authorize(Roles = "Admin")]
    public async Task<ActionResult> Team(CancellationToken ct) { if (!TryGetClientId(out var clientId)) return Forbid(); return Ok(await db.UserAccounts.Where(x => x.ClientId == clientId).OrderBy(x => x.Name).Select(x => new { id = x.Id, name = x.Name, email = x.Email, role = x.Role.ToString(), isActive = x.IsActive }).ToListAsync(ct)); }
    [HttpPost("team/users"), Authorize(Roles = "Admin")]
    public async Task<ActionResult> Invite(InviteRequest request, CancellationToken ct) { if (!TryGetClientId(out var clientId)) return Forbid(); if (string.IsNullOrWhiteSpace(request.Name) || string.IsNullOrWhiteSpace(request.Email)) return BadRequest(new { message = "Nombre y email son obligatorios." }); if (await db.UserAccounts.AnyAsync(x => x.Email == request.Email, ct)) return Conflict(new { message = "El email ya está registrado." }); var temporaryPassword = TemporaryPassword(); var user = new UserAccount { ClientId = clientId, Name = request.Name.Trim(), Email = request.Email.Trim(), Role = UserRole.Cliente }; user.PasswordHash = Hasher.HashPassword(user, temporaryPassword); db.UserAccounts.Add(user); await db.SaveChangesAsync(ct); var client = await db.Clients.FindAsync([clientId], ct); var emailSent = client is not null && await accessEmail.SendAsync(client, user.Name, user.Email, temporaryPassword, Request, ct); return Created($"/api/team/users/{user.Id}", new { id = user.Id, temporaryPassword, emailSent }); }
    [HttpPatch("team/users/{id:guid}"), Authorize(Roles = "Admin")]
    public async Task<ActionResult> UpdateTeam(Guid id, UpdateTeamRequest request, CancellationToken ct) { if (!TryGetClientId(out var clientId)) return Forbid(); var user = await db.UserAccounts.SingleOrDefaultAsync(x => x.Id == id && x.ClientId == clientId, ct); if (user is null) return NotFound(); if (id == UserId && ((request.Role is UserRole.Cliente) || request.IsActive is false)) return BadRequest(new { message = "No puedes bajar tu rol ni desactivarte." }); if (request.Role is UserRole role && role is not (UserRole.Cliente or UserRole.Admin)) return BadRequest(); if (request.Role is UserRole validRole) user.Role = validRole; if (request.IsActive is bool active) user.IsActive = active; await db.SaveChangesAsync(ct); return Ok(); }
}

[ApiController, Authorize(Roles = "SuperAdmin"), Route("api/admin")]
public sealed partial class AdminController(RtresDbContext db, PayPalCheckoutService checkoutService, ExchangeRateSyncJob exchangeRateSync, AccessEmailService accessEmail, TaxDocumentService taxDocuments, IBackgroundJobClient jobs, INotificationSender notifications) : ControllerBase
{
    private Guid UserId => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    [HttpGet("tickets")]
    public async Task<ActionResult> Tickets(TicketStatus? status, Guid? clientId, Guid? projectId, int page = 1, CancellationToken ct = default)
    {
        page = Math.Max(page, 1);
        var query = from ticket in db.Tickets
                    join client in db.Clients on ticket.ClientId equals client.Id
                    join project in db.Projects on ticket.ProjectId equals project.Id
                    where (status == null || ticket.Status == status) && (clientId == null || ticket.ClientId == clientId) && (projectId == null || ticket.ProjectId == projectId)
                    orderby ticket.UpdatedAt descending
                    select new { ticket, client, project };
        var total = await query.CountAsync(ct);
        var items = await query.Skip((page - 1) * 20).Take(20).Select(x => new { id = x.ticket.Id, code = x.ticket.Code, clientId = x.ticket.ClientId, projectId = x.ticket.ProjectId, type = x.ticket.Type.ToString(), status = x.ticket.Status.ToString(), title = x.ticket.Title, description = x.ticket.Description, createdAt = x.ticket.CreatedAt, updatedAt = x.ticket.UpdatedAt, githubIssueNumber = x.ticket.GithubIssueNumber, githubIssueUrl = x.ticket.GithubIssueUrl, client = new { id = x.client.Id, name = x.client.CompanyName }, project = new { id = x.project.Id, name = x.project.Name }, managedIn = db.ProjectRepositories.Any(r => r.ProjectId == x.project.Id) ? "GitHub" : "Portal" }).ToListAsync(ct);
        return Ok(new { items, page, totalPages = (int)Math.Ceiling(total / 20d) });
    }
    [HttpPatch("tickets/{id:guid}")]
    public async Task<ActionResult> UpdateTicket(Guid id, UpdateTicketStatusRequest request, CancellationToken ct)
    {
        var entry = await (from ticket in db.Tickets join project in db.Projects on ticket.ProjectId equals project.Id where ticket.Id == id select new { ticket, project }).SingleOrDefaultAsync(ct); if (entry is null) return NotFound();
        if (await db.ProjectRepositories.AnyAsync(x => x.ProjectId == entry.project.Id, ct)) return Conflict(new { message = "El estado de este ticket se gestiona en GitHub" });
        if (entry.ticket.Status == request.Status) return Ok(new { status = entry.ticket.Status.ToString() });
        entry.ticket.Status = request.Status; entry.ticket.UpdatedAt = DateTime.UtcNow; await db.SaveChangesAsync(ct);
        var client = await db.Clients.SingleAsync(x => x.Id == entry.ticket.ClientId, ct);
        await notifications.SendAsync(client, new Notification(NotificationType.TicketStatusChanged, new() { ["ticketId"] = entry.ticket.Id.ToString(), ["code"] = entry.ticket.Code, ["title"] = entry.ticket.Title, ["status"] = entry.ticket.Status.ToString() }, $"ticket-status:{entry.ticket.Id}:{entry.ticket.UpdatedAt.Ticks}"), ct);
        return Ok(new { status = entry.ticket.Status.ToString() });
    }
    [HttpPost("tickets/{id:guid}/comments")]
    public async Task<ActionResult> AddTicketComment(Guid id, CreateTicketCommentRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Body)) return BadRequest(new { message = "El comentario no puede estar vacío." });
        var entry = await (from ticket in db.Tickets join project in db.Projects on ticket.ProjectId equals project.Id where ticket.Id == id select new { ticket, project }).SingleOrDefaultAsync(ct); if (entry is null) return NotFound();
        var comment = new TicketComment { TicketId = id, AuthorUserId = UserId, Body = request.Body.Trim() }; db.TicketComments.Add(comment); entry.ticket.UpdatedAt = DateTime.UtcNow; await db.SaveChangesAsync(ct);
        if (await db.ProjectRepositories.AnyAsync(x => x.ProjectId == entry.project.Id, ct)) jobs.Enqueue<GitHubIssueSyncJob>(j => j.PostCommentAsync(comment.Id, CancellationToken.None));
        var client = await db.Clients.SingleAsync(x => x.Id == entry.ticket.ClientId, ct);
        await notifications.SendAsync(client, new Notification(NotificationType.TicketReply, new() { ["ticketId"] = entry.ticket.Id.ToString(), ["code"] = entry.ticket.Code, ["title"] = entry.ticket.Title, ["author"] = "Rtres", ["body"] = comment.Body }, $"ticket-reply:portal:{comment.Id}"), ct);
        return Ok(await PortalController.ToCommentDtos(db, db.TicketComments.Where(x => x.Id == comment.Id)).SingleAsync(ct));
    }
    [HttpGet("exchange-rates")]
    public async Task<ActionResult> ExchangeRates(DateOnly? from, DateOnly? to, CancellationToken ct) => Ok(await db.ExchangeRates
        .Where(x => (from == null || x.Date >= from) && (to == null || x.Date <= to)).OrderByDescending(x => x.Date)
        .Select(x => new { date = x.Date, currencyCode = x.CurrencyCode, rateToPen = x.RateToPen, source = x.Source }).ToListAsync(ct));

    [HttpPost("exchange-rates/sync")]
    public async Task<ActionResult> SyncExchangeRates(CancellationToken ct)
    {
        await exchangeRateSync.SyncAsync(ct);
        return Ok(await db.ExchangeRates.OrderByDescending(x => x.Date).Take(2).Select(x => new { date = x.Date, currencyCode = x.CurrencyCode, rateToPen = x.RateToPen, source = x.Source }).ToListAsync(ct));
    }

    [HttpGet("tax-settings")]
    public async Task<ActionResult> TaxSettings(CancellationToken ct) => Ok(TaxSettingsDto(await TaxSettingsRow(ct)));

    [HttpPatch("tax-settings")]
    public async Task<ActionResult> UpdateTaxSettings(TaxSettingsRequest request, CancellationToken ct)
    {
        if (request.IgvRate is decimal igv && (igv < 0 || igv > 1) || request.RentaRate is decimal renta0 && (renta0 < 0 || renta0 > 1)) return BadRequest(new { message = "Las tasas deben estar entre 0 y 1 (ej. 0.18 para 18%)." });
        var settings = await TaxSettingsRow(ct);
        var facturaSeries = request.FacturaSeries?.Trim().ToUpperInvariant() ?? settings.FacturaSeries; var reciboSeries = request.ReciboSeries?.Trim().ToUpperInvariant() ?? settings.ReciboSeries;
        // Facturas: F### si se emiten desde un sistema propio, E### si se emiten desde SUNAT SOL (la misma E001 que los recibos:
        // cada tipo de comprobante lleva su propio correlativo aunque compartan serie).
        if (!Regex.IsMatch(facturaSeries, "^[FE][A-Z0-9]{3}$") || !Regex.IsMatch(reciboSeries, "^E[A-Z0-9]{3}$")) return BadRequest(new { message = "La serie tiene 4 caracteres: la de facturas empieza con F o E (ej. F001, o E001 si la emites desde SUNAT SOL) y la de recibos por honorarios con E (ej. E001)." });
        var facturaNext = request.FacturaNextNumber ?? settings.FacturaNextNumber; var reciboNext = request.ReciboNextNumber ?? settings.ReciboNextNumber;
        if (facturaNext < 1 || reciboNext < 1) return BadRequest(new { message = "El próximo correlativo debe ser mayor a 0." });
        // Bajar el correlativo por debajo de lo ya emitido repetiría números: la serie solo puede avanzar.
        if (await LastNumberAsync(TaxDocumentType.Factura, facturaSeries, ct) is int lastF && facturaNext <= lastF) return BadRequest(new { message = $"La serie {facturaSeries} de facturas ya llegó al {lastF}: el próximo correlativo debe ser mayor." });
        if (await LastNumberAsync(TaxDocumentType.ReciboPorHonorarios, reciboSeries, ct) is int lastR && reciboNext <= lastR) return BadRequest(new { message = $"La serie {reciboSeries} de recibos ya llegó al {lastR}: el próximo correlativo debe ser mayor." });
        var ruc = request.Ruc is null ? settings.Ruc : request.Ruc.Trim() is { Length: > 0 } trimmed ? trimmed : null;
        if (ruc is not null && !Regex.IsMatch(ruc, "^(10|15|17|20)[0-9]{9}$")) return BadRequest(new { message = "El RUC tiene 11 dígitos y empieza con 10, 15, 17 o 20." });
        settings.Ruc = ruc;
        if (request.IsGoodTaxpayer is bool goodTaxpayer) settings.IsGoodTaxpayer = goodTaxpayer;
        if (request.Use1662AsCredit is bool use1662) settings.Use1662AsCredit = use1662;
        if (request.IgvRate is decimal igvRate) settings.IgvRate = igvRate;
        if (request.RentaRate is decimal rentaRate) settings.RentaRate = rentaRate;
        (settings.FacturaSeries, settings.FacturaNextNumber, settings.ReciboSeries, settings.ReciboNextNumber) = (facturaSeries, facturaNext, reciboSeries, reciboNext);
        settings.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return Ok(TaxSettingsDto(settings));
    }

    private Task<int?> LastNumberAsync(TaxDocumentType type, string series, CancellationToken ct) => db.TaxDocuments.Where(x => x.Type == type && x.Series == series).MaxAsync(x => (int?)x.Number, ct);
    private static object TaxSettingsDto(TaxSettings x) => new { igvRate = x.IgvRate, rentaRate = x.RentaRate, facturaSeries = x.FacturaSeries, facturaNextNumber = x.FacturaNextNumber, reciboSeries = x.ReciboSeries, reciboNextNumber = x.ReciboNextNumber, ruc = x.Ruc, isGoodTaxpayer = x.IsGoodTaxpayer, use1662AsCredit = x.Use1662AsCredit };

    private async Task<TaxSettings> TaxSettingsRow(CancellationToken ct)
    {
        var settings = await db.TaxSettings.FirstOrDefaultAsync(ct);
        if (settings is not null) return settings;
        settings = new TaxSettings(); db.TaxSettings.Add(settings); await db.SaveChangesAsync(ct); return settings;
    }

    [HttpGet("tax-documents")]
    public async Task<ActionResult> TaxDocuments(Guid? clientId, int? month, int? year, CancellationToken ct)
    {
        var rows = await db.TaxDocuments
            .Where(x => (clientId == null || x.ClientId == clientId) && (month == null || x.IssueDate.Month == month) && (year == null || x.IssueDate.Year == year))
            .OrderByDescending(x => x.IssueDate).ThenByDescending(x => x.Number)
            .Select(x => new { Document = x, Payment = db.PaymentTransactions.Where(p => p.Id == x.PaymentTransactionId).Select(p => new { p.Amount, p.AmountPen, p.Method }).FirstOrDefault() })
            .ToListAsync(ct);
        var docIds = rows.Select(x => x.Document.Id).ToList();
        var lines = (await db.TaxDocumentLines.Where(x => docIds.Contains(x.TaxDocumentId)).OrderBy(x => x.Order).ToListAsync(ct)).ToLookup(x => x.TaxDocumentId);
        var result = new List<object>(rows.Count);
        foreach (var x in rows)
        {
            // Mismo tipo de cambio que los reportes de impuestos: el que se guardó en el cobro (AmountPen / Amount).
            var rate = x.Payment is { Amount: > 0 } p ? p.AmountPen / p.Amount : await db.RateToPenAsync(x.Document.Currency, x.Document.IssueDate, ct);
            result.Add(TaxDocumentDto(x.Document, rate, lines[x.Document.Id], x.Payment?.Method));
        }
        return Ok(result);
    }

    /// <summary>
    /// Emisión manual (cobros fuera de PayPal) con uno o más productos del mismo cliente. Todos deben generar el mismo tipo de
    /// comprobante; el total es la suma de las líneas y la serie/correlativo se asignan solos.
    /// </summary>
    [HttpPost("tax-documents")]
    public async Task<ActionResult> CreateTaxDocument(TaxDocumentRequest request, CancellationToken ct)
    {
        IReadOnlyList<TaxDocumentItemRequest> items = request.Items is { Count: > 0 } list ? list : request.ClientProductId is Guid single ? [new TaxDocumentItemRequest(single, request.TotalAmount)] : [];
        if (string.IsNullOrWhiteSpace(request.Currency) || items.Count == 0) return BadRequest(new { message = "Moneda y al menos un producto son obligatorios." });
        if (items.Any(x => x.Amount <= 0)) return BadRequest(new { message = "Cada producto debe tener un importe mayor a 0." });
        if (items.Select(x => x.ClientProductId).Distinct().Count() != items.Count) return BadRequest(new { message = "Un producto aparece más de una vez." });
        var ids = items.Select(x => x.ClientProductId).ToList();
        var products = await db.ClientProducts.Include(x => x.Product).Where(x => ids.Contains(x.Id)).ToListAsync(ct);
        if (products.Count != items.Count || products.Any(x => x.Product is null)) return NotFound(new { message = "Producto del cliente no encontrado." });
        if (products.Select(x => x.ClientId).Distinct().Count() > 1) return BadRequest(new { message = "Todos los productos deben ser del mismo cliente." });
        var types = products.Select(x => x.Product!.TaxDocumentType).Distinct().ToList();
        if (types.Count > 1) return BadRequest(new { message = "No se pueden mezclar productos de Factura y de Recibo por honorarios en un mismo comprobante: emite uno por cada tipo." });
        var client = await db.Clients.FindAsync([products[0].ClientId], ct);
        if (client is null || !client.RequiresTaxDocument) return BadRequest(new { message = "Este cliente no requiere comprobante tributario (solo se emite a clientes en Perú)." });
        var total = items.Sum(x => x.Amount);
        if (request.RetentionAmount is < 0 || request.RetentionAmount > total) return BadRequest(new { message = "La retención debe estar entre 0 y el total." });
        // El comprobante manual es de un cobro fuera del portal: se registra el cobro para que cuente una sola vez en los reportes.
        // Con varios productos el cobro no apunta a uno solo: el detalle queda en las líneas del comprobante.
        var currency = request.Currency.Trim().ToUpperInvariant();
        var payment = new PaymentTransaction { ClientId = client.Id, ClientProductId = items.Count == 1 ? items[0].ClientProductId : null, Amount = total, Currency = currency, Status = "COMPLETED", Method = PaymentMethods.Transferencia, CreatedAt = request.IssueDate.ToDateTime(new TimeOnly(12, 0), DateTimeKind.Utc), Notes = EmptyToNull(request.Notes) };
        payment.PayPalOrderIdOrSubscriptionId = $"MANUAL-{payment.Id:N}";
        payment.InternalCode = await db.NextInternalCodeAsync(ct);
        payment.AmountPen = payment.Amount * await db.RateToPenAsync(currency, request.IssueDate, ct);
        db.PaymentTransactions.Add(payment); await db.SaveChangesAsync(ct);
        var lines = items.Select(x => new TaxDocumentLine { ClientProductId = x.ClientProductId, Description = TaxDocumentService.LineDescription(products.Single(p => p.Id == x.ClientProductId)), Amount = x.Amount }).ToList();
        var document = await taxDocuments.IssueAsync(client.Id, types[0], request.IssueDate, currency, total, EmptyToNull(request.Notes), payment.Id, ct, lines);
        if (request.RetentionAmount > 0) { document.RetentionAmount = request.RetentionAmount; await db.SaveChangesAsync(ct); }
        var saved = await db.TaxDocumentLines.Where(x => x.TaxDocumentId == document.Id).OrderBy(x => x.Order).ToListAsync(ct);
        return Created($"/api/admin/tax-documents/{document.Id}", TaxDocumentDto(document, payment.Amount > 0 ? payment.AmountPen / payment.Amount : 1m, saved, payment.Method));
    }

    /// <summary>Extorno de un comprobante registrado por error: lo elimina junto con su cobro. Ver <see cref="TaxDocumentService.ReverseAsync"/>.</summary>
    [HttpPost("tax-documents/{id:guid}/reverse")]
    public async Task<ActionResult> ReverseTaxDocument(Guid id, ReverseTaxDocumentRequest request, CancellationToken ct)
    {
        var reason = request.Reason?.Trim();
        if (string.IsNullOrEmpty(reason)) return BadRequest(new { message = "Indica el motivo del extorno." });
        if (reason.Length > 500) return BadRequest(new { message = "El motivo no puede pasar de 500 caracteres." });
        return await taxDocuments.ReverseAsync(id, reason, request.NotIssued, UserId, ct) is TaxDocumentReversalResult result ? Ok(result) : NotFound();
    }

    [HttpGet("expenses")]
    public async Task<ActionResult> Expenses(int? month, int? year, Guid? categoryId, CancellationToken ct) => Ok(await db.Expenses.Include(x => x.Category)
        .Where(x => (month == null || x.Date.Month == month) && (year == null || x.Date.Year == year) && (categoryId == null || x.CategoryId == categoryId))
        .OrderByDescending(x => x.Date).Select(x => ExpenseDto(x)).ToListAsync(ct));

    [HttpPost("expenses")]
    public async Task<ActionResult> CreateExpense(ExpenseRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Description) || string.IsNullOrWhiteSpace(request.Currency) || request.Amount <= 0) return BadRequest(new { message = "Descripción, moneda y un monto mayor a 0 son obligatorios." });
        if (!await db.ExpenseCategories.AnyAsync(x => x.Id == request.CategoryId, ct)) return BadRequest(new { message = "Elige una categoría válida." });
        var expense = new Expense { Description = request.Description.Trim(), CategoryId = request.CategoryId, Type = request.Type, Amount = request.Amount, Currency = request.Currency.Trim().ToUpperInvariant(), Date = request.Date, Recurring = request.Recurring, RecurrenceCycle = request.RecurrenceCycle, IsNonDeductible = request.IsNonDeductible };
        ApplyForeignService(expense, request.IsNonDomiciledService, request.ForeignSupplierName, request.ForeignSupplierCountry);
        expense.AmountPen = expense.Amount * await db.RateToPenAsync(expense.Currency, expense.Date, ct);
        db.Expenses.Add(expense); await db.SaveChangesAsync(ct);
        await db.Entry(expense).Reference(x => x.Category).LoadAsync(ct);
        return Created($"/api/admin/expenses/{expense.Id}", ExpenseDto(expense));
    }

    [HttpGet("expenses/import/template")]
    public async Task<IActionResult> ExpenseTemplate(CancellationToken ct) => File(CreateWorkbook(
        new("Description", true, "Texto libre, ej. Servidor VPS"),
        new("Category", true, "Una de la lista (Configuración → Categorías de gastos)", [.. await db.ExpenseCategories.OrderBy(x => x.SortOrder).ThenBy(x => x.Name).Select(x => x.Name).ToListAsync(ct)]),
        new("Type", true, "Fijo o Variable", Enum.GetNames<ExpenseType>()),
        new("Amount", true, "Número mayor a 0 con punto decimal, ej. 49.90"),
        new("Currency", true, "PEN, USD o EUR", ["PEN", "USD", "EUR"]),
        new("Date", true, "Fecha de Excel, o texto 2026-09-28 o 28/09/2026"),
        new("Recurring", false, "SI o NO (vacío = NO)", ["SI", "NO"]),
        new("RecurrenceCycle", false, "Mensual o Anual — obligatorio si Recurring es SI", ["Mensual", "Anual"])),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "gastos-plantilla.xlsx");

    /// <summary>Importa gastos desde la plantilla: cada fila válida se guarda con su monto en PEN al tipo de cambio de su fecha; las inválidas se informan.</summary>
    [HttpPost("expenses/import")]
    public async Task<ActionResult> ImportExpenses(IFormFile file, CancellationToken ct)
    {
        var categories = await db.ExpenseCategories.ToListAsync(ct);
        var (failure, created, errors) = await Import(file, "gastos", async (row, rowNumber, errors) =>
        {
            var error = ParseExpenseRow(row, categories, out var expense);
            if (error is not null) { errors.Add(new(rowNumber, error)); return false; }
            expense!.AmountPen = expense.Amount * await db.RateToPenAsync(expense.Currency, expense.Date, ct);
            db.Expenses.Add(expense); return true;
        }, ct);
        return failure ?? Ok(new { created, skipped = errors.Count, errors });
    }

    private static string? ParseProductRow(IXLRow row, out Product? product)
    {
        product = null;
        if (!TryEnum<ProductType>(Cell(row, 1), out var type)) return $"Type inválido: usa {string.Join(", ", Enum.GetNames<ProductType>())}.";
        var name = Cell(row, 2).Trim();
        if (string.IsNullOrWhiteSpace(name)) return "El nombre es obligatorio.";
        if (!TryEnum<BillingCycle>(Cell(row, 3), out var cycle)) return "BillingCycle inválido: usa Unico, Mensual, Bimestral, Trimestral, Semestral o Anual.";
        if (ReadDecimal(row.Cell(4)) is not decimal price || price < 0) return "BasePrice debe ser un número mayor o igual a 0.";
        var currency = Cell(row, 5).Trim().ToUpperInvariant();
        if (currency is not ("PEN" or "USD" or "EUR")) return "Moneda inválida: usa PEN, USD o EUR.";
        if (ReadYesNo(Cell(row, 7), defaultValue: true) is not bool active) return "IsActive inválido: usa SI o NO.";
        var taxText = Cell(row, 8).Trim(); var taxType = TaxDocumentType.Factura;
        if (taxText != "" && !TryEnum(taxText, out taxType)) return "TaxDocumentType inválido: usa Factura o ReciboPorHonorarios.";
        if (ReadYesNo(Cell(row, 11), defaultValue: false) is not bool allowsTickets) return "AllowsTickets inválido: usa SI o NO.";
        product = new Product { Type = type, Name = name, BillingCycle = cycle, BasePrice = price, Currency = currency, Description = EmptyToNull(Cell(row, 6)), IsActive = active, TaxDocumentType = taxType, Category = EmptyToNull(Cell(row, 9)), Tags = NormalizeTags(Cell(row, 10)), AllowsTickets = allowsTickets };
        return null;
    }

    // Enum.TryParse acepta números ("7") aunque no sean un valor del enum: se exige que exista.
    private static bool TryEnum<T>(string value, out T result) where T : struct, Enum => Enum.TryParse(value.Trim(), true, out result) && Enum.IsDefined(result) && !int.TryParse(value.Trim(), out _);

    /// <summary>SI/NO (también TRUE/FALSE, VERDADERO/FALSO o 1/0, como los escribe Excel); vacío = <paramref name="defaultValue"/>; otro valor = null.</summary>
    private static bool? ReadYesNo(string value, bool defaultValue) => value.Trim().ToUpperInvariant() switch
    {
        "" => defaultValue,
        "SI" or "SÍ" or "TRUE" or "VERDADERO" or "1" => true,
        "NO" or "FALSE" or "FALSO" or "0" => false,
        _ => null,
    };

    private static string? ParseExpenseRow(IXLRow row, IReadOnlyList<ExpenseCategory> categories, out Expense? expense)
    {
        expense = null;
        var description = Cell(row, 1).Trim();
        if (string.IsNullOrWhiteSpace(description)) return "La descripción es obligatoria.";
        // Por nombre o por el código de las de sistema (ej. "SuscripcionesIA", como en plantillas antiguas), sin importar tildes ni mayúsculas.
        var categoryText = Fold(Cell(row, 2));
        if (categories.FirstOrDefault(x => Fold(x.Name) == categoryText || x.Code is not null && Fold(x.Code) == categoryText) is not { } category) return $"Categoría inválida: usa {string.Join(", ", categories.OrderBy(x => x.SortOrder).Select(x => x.Name))}.";
        if (!TryEnum<ExpenseType>(Cell(row, 3), out var type)) return "Tipo inválido: usa Fijo o Variable.";
        if (ReadDecimal(row.Cell(4)) is not decimal amount || amount <= 0) return "El monto debe ser un número mayor a 0.";
        var currency = Cell(row, 5).Trim().ToUpperInvariant();
        if (currency is not ("PEN" or "USD" or "EUR")) return "Moneda inválida: usa PEN, USD o EUR.";
        if (ReadDate(row.Cell(6)) is not DateOnly date) return "Fecha inválida: usa 2026-09-28 o 28/09/2026.";
        if (ReadYesNo(Cell(row, 7), defaultValue: false) is not bool recurring) return "Recurring inválido: usa SI o NO.";
        BillingCycle? cycle = null;
        if (recurring)
        {
            if (!TryEnum<BillingCycle>(Cell(row, 8), out var parsed) || parsed is not (BillingCycle.Mensual or BillingCycle.Anual)) return "Un gasto recurrente necesita RecurrenceCycle: Mensual o Anual.";
            cycle = parsed;
        }
        expense = new Expense { Description = description, CategoryId = category.Id, Type = type, Amount = amount, Currency = currency, Date = date, Recurring = recurring, RecurrenceCycle = cycle };
        return null;
    }

    // Excel guarda números y fechas con tipo propio; si vienen como texto se aceptan los formatos habituales.
    private static decimal? ReadDecimal(IXLCell cell) =>
        cell.DataType == XLDataType.Number ? (decimal)cell.GetDouble()
        : decimal.TryParse(cell.GetString().Trim(), System.Globalization.NumberStyles.Number, System.Globalization.CultureInfo.InvariantCulture, out var value) ? value : null;

    private static DateOnly? ReadDate(IXLCell cell) =>
        cell.DataType == XLDataType.DateTime ? DateOnly.FromDateTime(cell.GetDateTime())
        : DateOnly.TryParseExact(cell.GetString().Trim(), ["yyyy-MM-dd", "dd/MM/yyyy", "d/M/yyyy"], System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None, out var date) ? date : null;

    [HttpDelete("expenses/{id:guid}")]
    public async Task<ActionResult> DeleteExpense(Guid id, CancellationToken ct)
    {
        var expense = await db.Expenses.FindAsync([id], ct); if (expense is null) return NotFound();
        db.Expenses.Remove(expense); await db.SaveChangesAsync(ct); return NoContent();
    }

    /// <summary>
    /// Da de baja un gasto recurrente: borra los pagos de la serie posteriores a <c>EndsAt</c> y marca los que quedan con esa
    /// fecha de fin. Los pagos se guardan como filas sueltas, así que la serie es "mismo concepto, categoría y moneda".
    /// Con <c>dryRun</c> solo informa cuántos se borrarían, para confirmarlo antes.
    /// </summary>
    [HttpPost("expenses/{id:guid}/end-recurrence")]
    public async Task<ActionResult> EndRecurrence(Guid id, EndRecurrenceRequest request, bool dryRun, CancellationToken ct)
    {
        var expense = await db.Expenses.FindAsync([id], ct); if (expense is null) return NotFound();
        if (!expense.Recurring) return BadRequest(new { message = "El gasto no es recurrente." });
        var series = await ExpenseSeries(expense).ToListAsync(ct);
        var removed = series.Where(x => x.Date > request.EndsAt).ToList();
        if (!dryRun)
        {
            db.Expenses.RemoveRange(removed);
            foreach (var kept in series.Except(removed)) kept.RecurrenceEndsAt = request.EndsAt;
            await db.SaveChangesAsync(ct);
        }
        return Ok(new { removed = removed.Count, kept = series.Count - removed.Count, removedTotalPen = Math.Round(removed.Sum(x => x.AmountPen), 2) });
    }

    /// <summary>Reactiva un gasto recurrente dado de baja (no recrea los pagos borrados).</summary>
    [HttpDelete("expenses/{id:guid}/end-recurrence")]
    public async Task<ActionResult> ResumeRecurrence(Guid id, CancellationToken ct)
    {
        var expense = await db.Expenses.FindAsync([id], ct); if (expense is null) return NotFound();
        foreach (var x in await ExpenseSeries(expense).ToListAsync(ct)) x.RecurrenceEndsAt = null;
        await db.SaveChangesAsync(ct); return NoContent();
    }

    private IQueryable<Expense> ExpenseSeries(Expense expense)
    {
        var description = expense.Description.Trim();
        return db.Expenses.Where(x => x.Recurring && x.Description.Trim() == description && x.CategoryId == expense.CategoryId && x.Currency == expense.Currency);
    }

    [HttpPatch("expenses/{id:guid}")]
    public async Task<ActionResult> UpdateExpense(Guid id, ExpensePatchRequest request, CancellationToken ct)
    {
        var expense = await db.Expenses.FindAsync([id], ct); if (expense is null) return NotFound();
        if (request.Description is not null) expense.Description = request.Description.Trim();
        if (request.CategoryId is Guid categoryId)
        {
            if (!await db.ExpenseCategories.AnyAsync(x => x.Id == categoryId, ct)) return BadRequest(new { message = "Elige una categoría válida." });
            expense.CategoryId = categoryId;
        }
        if (request.Type is ExpenseType type) expense.Type = type;
        if (request.Amount is decimal amount) expense.Amount = amount;
        if (request.Currency is not null) expense.Currency = request.Currency.Trim().ToUpperInvariant();
        if (request.Date is DateOnly date) expense.Date = date;
        if (request.Recurring is bool recurring) expense.Recurring = recurring;
        if (request.RecurrenceCycle is BillingCycle cycle) expense.RecurrenceCycle = cycle;
        if (request.IsNonDeductible is bool nonDeductible) expense.IsNonDeductible = nonDeductible;
        if (request.IsNonDomiciledService is bool foreign) ApplyForeignService(expense, foreign, request.ForeignSupplierName, request.ForeignSupplierCountry);
        if (string.IsNullOrWhiteSpace(expense.Description) || string.IsNullOrWhiteSpace(expense.Currency) || expense.Amount <= 0) return BadRequest(new { message = "Descripción, moneda y un monto mayor a 0 son obligatorios." });
        expense.AmountPen = expense.Amount * await db.RateToPenAsync(expense.Currency, expense.Date, ct);
        await db.SaveChangesAsync(ct); await db.Entry(expense).Reference(x => x.Category).LoadAsync(ct); return Ok(ExpenseDto(expense));
    }

    private const string TaxDisclaimer = "Estimación calculada con las tasas configuradas por el usuario en Configuración de tasas — no es una liquidación oficial ante SUNAT. El IGV sale de las facturas emitidas a clientes en Perú; las ventas al exterior y los recibos por honorarios no llevan IGV. El régimen tributario real (RER/MYPE/General) puede calcular la Renta sobre una base distinta (utilidad neta, no ventas brutas); confirma con tu contador antes de declarar.";

    /// <summary>Periodo de un reporte: el mes indicado o, sin mes, el año completo.</summary>
    private static (DateOnly From, DateOnly To) Period(int? month, int year) =>
        month is int m ? (new DateOnly(year, m, 1), new DateOnly(year, m, 1).AddMonths(1).AddDays(-1)) : (new DateOnly(year, 1, 1), new DateOnly(year, 12, 31));

    /// <summary>Periodo anterior de igual duración: el mes anterior o el año anterior.</summary>
    private static (DateOnly From, DateOnly To) PreviousPeriod(int? month, int year) =>
        month is int m ? Period(m == 1 ? 12 : m - 1, m == 1 ? year - 1 : year) : Period(null, year - 1);

    /// <summary>
    /// <see cref="PersonaNatural"/>: cobro con recibo por honorarios, ingreso de 4ta categoría del titular como persona natural.
    /// No entra en la Renta de la MYPE (facturas y cobros sin comprobante) ni en su pago a cuenta.
    /// </summary>
    private sealed record Sale(Guid ClientId, DateOnly Date, decimal BasePen, decimal IgvPen, bool Gravada, decimal RetentionPen, bool PersonaNatural = false)
    {
        public bool Mype => !PersonaNatural;
    }

    /// <summary>
    /// Ventas del periodo en PEN, una por cobro (cada cobro es un ingreso; su comprobante no se cuenta aparte). Lo cobrado ya
    /// incluye el IGV cuando hay Factura (se desglosa con la proporción base/total del comprobante); sin comprobante (cliente
    /// del exterior) o con Recibo por honorarios, todo lo cobrado es base sin IGV. La retención del recibo es Renta ya pagada.
    /// </summary>
    private async Task<List<Sale>> SalesAsync(DateOnly from, DateOnly to, CancellationToken ct)
    {
        var start = from.ToDateTime(TimeOnly.MinValue); var end = to.AddDays(1).ToDateTime(TimeOnly.MinValue);
        var payments = await db.PaymentTransactions.Where(x => x.CreatedAt >= start && x.CreatedAt < end)
            .Select(x => new { x.ClientId, x.CreatedAt, x.AmountPen, Document = db.TaxDocuments.FirstOrDefault(d => d.PaymentTransactionId == x.Id) }).ToListAsync(ct);
        return payments.Select(x =>
        {
            var document = x.Document is { TotalAmount: > 0 } d ? d : null;
            var isFactura = document?.Type == TaxDocumentType.Factura;
            var basePen = isFactura ? x.AmountPen * document!.BaseAmount / document.TotalAmount : x.AmountPen;
            var retentionPen = document?.RetentionAmount is decimal retention ? x.AmountPen * retention / document.TotalAmount : 0m;
            return new Sale(x.ClientId, DateOnly.FromDateTime(x.CreatedAt), basePen, x.AmountPen - basePen, isFactura, retentionPen, document?.Type == TaxDocumentType.ReciboPorHonorarios);
        }).ToList();
    }

    [HttpGet("reports/sales")]
    public async Task<ActionResult> SalesReport(int? month, int year, string currency, CancellationToken ct)
    {
        if (currency is not ("PEN" or "USD" or "EUR")) return BadRequest(new { message = "Moneda inválida." });
        var (from, to) = Period(month, year);
        var sales = await SalesAsync(from, to, ct);
        decimal basePen = sales.Sum(x => x.BasePen), igvPen = sales.Sum(x => x.IgvPen);
        var rate = currency == "PEN" ? 1m : await db.RateToPenAsync(currency, to, ct);
        return Ok(new { baseImponible = Math.Round(basePen / rate, 2), igv = Math.Round(igvPen / rate, 2), total = Math.Round((basePen + igvPen) / rate, 2) });
    }

    [HttpGet("reports/tax-summary")]
    public async Task<ActionResult> TaxSummaryReport(int? month, int year, CancellationToken ct)
    {
        var settings = await TaxSettingsRow(ct);
        var (from, to) = Period(month, year);
        var sales = await SalesAsync(from, to, ct);
        decimal basePen = sales.Sum(x => x.BasePen), gravadasPen = sales.Where(x => x.Gravada).Sum(x => x.BasePen);
        var igv = (await IgvMonthsAsync(to, ct)).Where(x => x.Month >= from).ToList();
        // El pago a cuenta de la MYPE se estima sobre sus ventas sin IGV (gravadas y no gravadas); los recibos por honorarios son del titular.
        return Ok(new
        {
            ventasGravadasPen = Math.Round(gravadasPen, 2), ventasNoGravadasPen = Math.Round(basePen - gravadasPen, 2), igvEstimado = Math.Round(sales.Sum(x => x.IgvPen), 2), rentaEstimada = Math.Round(sales.Where(x => x.Mype).Sum(x => x.BasePen) * settings.RentaRate, 2), ventasPersonaNaturalPen = Math.Round(sales.Where(x => x.PersonaNatural).Sum(x => x.BasePen), 2), tasa = new { igvRate = settings.IgvRate, rentaRate = settings.RentaRate }, disclaimer = TaxDisclaimer,
            // Cascada del IGV: débito (ventas) − crédito fiscal (compras) − saldo a favor del mes anterior.
            igv = new
            {
                debitoFiscal = Math.Round(igv.Sum(x => x.Debito), 2), creditoFiscal = Math.Round(igv.Sum(x => x.Credito), 2),
                saldoAFavorAnterior = Math.Round(igv.FirstOrDefault()?.SaldoAnterior ?? 0m, 2), igvAPagar = Math.Round(igv.Sum(x => x.APagar), 2),
                saldoAFavorSiguiente = Math.Round(igv.LastOrDefault()?.SaldoSiguiente ?? 0m, 2),
                meses = igv.Select(x => new { mes = x.Month.ToString("yyyy-MM"), debitoFiscal = Math.Round(x.Debito, 2), creditoFiscal = Math.Round(x.Credito, 2), saldoAFavorAnterior = Math.Round(x.SaldoAnterior, 2), igvAPagar = Math.Round(x.APagar, 2), saldoAFavorSiguiente = Math.Round(x.SaldoSiguiente, 2) }),
            },
        });
    }

    internal sealed record IgvMonth(DateOnly Month, decimal Debito, decimal Credito, decimal SaldoAnterior, decimal APagar, decimal SaldoSiguiente);

    /// <summary>
    /// IGV mes a mes desde el primer mes con ventas o compras hasta <paramref name="to"/>: a pagar = débito − crédito −
    /// saldo a favor anterior; si sale negativo, es saldo a favor y se arrastra al mes siguiente.
    /// </summary>
    internal async Task<List<IgvMonth>> IgvMonthsAsync(DateOnly to, CancellationToken ct)
    {
        var end = new DateOnly(to.Year, to.Month, 1);
        DateOnly? firstSale = await db.PaymentTransactions.OrderBy(x => x.CreatedAt).Select(x => (DateTime?)x.CreatedAt).FirstOrDefaultAsync(ct) is DateTime d ? DateOnly.FromDateTime(d) : null;
        DateOnly? firstPurchase = await db.Purchases.OrderBy(x => x.Period).Select(x => (DateOnly?)x.Period).FirstOrDefaultAsync(ct);
        var first = new[] { firstSale, firstPurchase }.Where(x => x is not null).Select(x => x!.Value).DefaultIfEmpty(end).Min();
        var start = new DateOnly(first.Year, first.Month, 1);
        if (start > end) start = end;
        var sales = await SalesAsync(start, end.AddMonths(1).AddDays(-1), ct);
        var purchases = await db.Purchases.Where(x => x.Period >= start && x.Period <= end).ToListAsync(ct);
        // IGV pagado con el Formulario 1662: crédito fiscal del mes en que se pagó, solo si está habilitado en Configuración.
        var settings = await TaxSettingsRow(ct);
        var form1662 = settings.Use1662AsCredit
            ? (await db.Expenses.Where(x => x.IsNonDomiciledService && x.Form1662PaidAt != null && x.Form1662PaidAt >= start && x.Form1662PaidAt <= end.AddMonths(1).AddDays(-1)).ToListAsync(ct))
                .GroupBy(x => new DateOnly(x.Form1662PaidAt!.Value.Year, x.Form1662PaidAt.Value.Month, 1)).ToDictionary(g => g.Key, g => g.Sum(x => Form1662.Igv(x, settings.IgvRate)))
            : [];
        var months = new List<IgvMonth>(); var carry = 0m;
        for (var month = start; month <= end; month = month.AddMonths(1))
        {
            var monthEnd = month.AddMonths(1).AddDays(-1);
            var debito = sales.Where(x => x.Date >= month && x.Date <= monthEnd).Sum(x => x.IgvPen);
            var credito = purchases.Where(x => x.Period == month).Sum(x => x.TaxCreditPen) + form1662.GetValueOrDefault(month);
            var result = debito - credito - carry;
            months.Add(new IgvMonth(month, debito, credito, carry, Math.Max(result, 0m), Math.Max(-result, 0m)));
            carry = Math.Max(-result, 0m);
        }
        return months;
    }

    [HttpGet("reports/expenses")]
    public async Task<ActionResult> ExpensesReport(int? month, int year, CancellationToken ct)
    {
        var (from, to) = Period(month, year);
        var expenses = await db.Expenses.Include(x => x.Category).Where(x => x.Date >= from && x.Date <= to).ToListAsync(ct);
        return Ok(new { total = Math.Round(expenses.Sum(x => x.AmountPen), 2), porCategoria = expenses.GroupBy(x => x.Category?.Name ?? "Sin categoría").OrderByDescending(g => g.Sum(x => x.AmountPen)).Select(g => new { categoria = g.Key, monto = Math.Round(g.Sum(x => x.AmountPen), 2) }) });
    }

    /// <summary>
    /// Utilidad del periodo: ventas sin IGV − gastos operativos = utilidad operativa; − Renta = utilidad neta. La Renta es
    /// siempre el pago a cuenta con la tasa configurada (MYPE: 1 %) sobre las ventas sin IGV de cada mes; no se usan pagos
    /// registrados ni retenciones. El IGV no es costo (se cobra aparte y se traslada a SUNAT).
    /// </summary>
    [HttpGet("reports/net")]
    public async Task<ActionResult> NetReport(int? month, int year, CancellationToken ct)
    {
        var settings = await TaxSettingsRow(ct);
        var (from, to) = Period(month, year);
        var sales = await SalesAsync(from, to, ct);
        var expenses = await db.Expenses.Include(x => x.Category).Where(x => x.Date >= from && x.Date <= to).ToListAsync(ct);
        var result = NetFigures(sales, expenses, settings.RentaRate);
        var serie = Enumerable.Range(0, month is null ? 12 : 1).Select(i => from.AddMonths(i)).Select(start =>
        {
            var end = start.AddMonths(1).AddDays(-1);
            var n = NetFigures(sales.Where(x => x.Date >= start && x.Date <= end), expenses.Where(x => x.Date >= start && x.Date <= end), settings.RentaRate);
            return new NetPoint(start.ToString("yyyy-MM"), Math.Round(n.Ventas, 2), Math.Round(n.Gastos, 2), Math.Round(n.Impuestos, 2), Math.Round(n.Neta, 2));
        }).ToList();
        return Ok(new
        {
            ventasPen = Math.Round(result.Ventas, 2), gastosPen = Math.Round(result.Gastos, 2), utilidadOperativaPen = Math.Round(result.Ventas - result.Gastos, 2),
            rentaRate = settings.RentaRate, impuestosPen = Math.Round(result.Impuestos, 2),
            utilidadNetaPen = Math.Round(result.Neta, 2), margen = result.Ventas == 0 ? 0m : Math.Round(result.Neta / result.Ventas * 100, 1),
            serie, disclaimer = TaxDisclaimer,
        });
    }

    private sealed record NetPoint(string Mes, decimal VentasPen, decimal GastosPen, decimal ImpuestosPen, decimal UtilidadNetaPen);

    /// <remarks>Los gastos de categoría ImpuestoRenta no son gasto operativo; tampoco se restan aparte para no contar dos veces la Renta.</remarks>
    private static (decimal Ventas, decimal Gastos, decimal Impuestos, decimal Neta) NetFigures(IEnumerable<Sale> sales, IEnumerable<Expense> expenses, decimal rentaRate)
    {
        var ventas = sales.Sum(x => x.BasePen);
        var gastos = expenses.Where(x => x.Category?.IsIncomeTax != true).Sum(x => x.AmountPen);
        var impuestos = sales.Where(x => x.Mype).Sum(x => x.BasePen) * rentaRate; // pago a cuenta de la MYPE
        return (ventas, gastos, impuestos, ventas - gastos - impuestos);
    }

    /// <summary>Ranking de clientes por ingresos sin IGV del periodo, con su participación, el acumulado (Pareto) y la variación contra el periodo anterior.</summary>
    [HttpGet("reports/clients")]
    public async Task<ActionResult> ClientsReport(int? month, int year, CancellationToken ct)
    {
        var (total, clientes) = await ClientRankingAsync(month, year, ct);
        return Ok(new { totalPen = total, clientes });
    }

    private sealed record ClientRankingRow(Guid ClientId, string ClientName, decimal IngresosPen, decimal Porcentaje, decimal PorcentajeAcumulado, int Cobros, DateOnly UltimoCobro, decimal PeriodoAnteriorPen, decimal? VariacionPorcentaje);

    private async Task<(decimal Total, List<ClientRankingRow> Rows)> ClientRankingAsync(int? month, int year, CancellationToken ct)
    {
        var (from, to) = Period(month, year); var (previousFrom, previousTo) = PreviousPeriod(month, year);
        var sales = await SalesAsync(from, to, ct);
        var previous = (await SalesAsync(previousFrom, previousTo, ct)).GroupBy(x => x.ClientId).ToDictionary(g => g.Key, g => g.Sum(x => x.BasePen));
        var names = await db.Clients.ToDictionaryAsync(x => x.Id, x => x.CompanyName, ct);
        var total = sales.Sum(x => x.BasePen); var accumulated = 0m;
        var rows = sales.GroupBy(x => x.ClientId).Select(g => new { ClientId = g.Key, Pen = g.Sum(x => x.BasePen), Count = g.Count(), Last = g.Max(x => x.Date) }).OrderByDescending(x => x.Pen).Select(x =>
        {
            accumulated += x.Pen;
            var before = previous.GetValueOrDefault(x.ClientId);
            return new ClientRankingRow(x.ClientId, names.GetValueOrDefault(x.ClientId) ?? "(cliente eliminado)", Math.Round(x.Pen, 2), total == 0 ? 0 : Math.Round(x.Pen / total * 100, 1), total == 0 ? 0 : Math.Round(accumulated / total * 100, 1), x.Count, x.Last, Math.Round(before, 2), before > 0 ? Math.Round((x.Pen - before) / before * 100, 1) : null);
        }).ToList();
        return (Math.Round(total, 2), rows);
    }

    /// <summary>Excel con la utilidad (y su serie mensual) y el ranking de clientes del periodo.</summary>
    [HttpGet("reports/export")]
    public async Task<IActionResult> ExportReport(int? month, int year, CancellationToken ct)
    {
        var settings = await TaxSettingsRow(ct);
        var (from, to) = Period(month, year);
        var sales = await SalesAsync(from, to, ct);
        var expenses = await db.Expenses.Include(x => x.Category).Where(x => x.Date >= from && x.Date <= to).ToListAsync(ct);
        var net = NetFigures(sales, expenses, settings.RentaRate);
        var (_, ranking) = await ClientRankingAsync(month, year, ct);

        using var book = new XLWorkbook();
        var summary = book.AddWorksheet("Utilidad");
        (string Label, decimal Value)[] figures = [("Ventas sin IGV (PEN)", net.Ventas), ("Gastos operativos (PEN)", net.Gastos), ("Utilidad operativa (PEN)", net.Ventas - net.Gastos), ($"Renta, pago a cuenta {settings.RentaRate * 100:0.##} % (PEN)", net.Impuestos), ("Utilidad neta (PEN)", net.Neta), ("Margen neto %", net.Ventas == 0 ? 0 : net.Neta / net.Ventas * 100)];
        for (var i = 0; i < figures.Length; i++) { summary.Cell(i + 1, 1).Value = figures[i].Label; summary.Cell(i + 1, 2).Value = Math.Round(figures[i].Value, 2); }
        var row = figures.Length + 2;
        string[] header = ["Mes", "Ventas", "Gastos", "Renta", "Utilidad neta"];
        for (var c = 0; c < header.Length; c++) summary.Cell(row, c + 1).Value = header[c];
        foreach (var start in Enumerable.Range(0, month is null ? 12 : 1).Select(i => from.AddMonths(i)))
        {
            var end = start.AddMonths(1).AddDays(-1);
            var n = NetFigures(sales.Where(x => x.Date >= start && x.Date <= end), expenses.Where(x => x.Date >= start && x.Date <= end), settings.RentaRate);
            row++; summary.Cell(row, 1).Value = start.ToString("yyyy-MM");
            summary.Cell(row, 2).Value = Math.Round(n.Ventas, 2); summary.Cell(row, 3).Value = Math.Round(n.Gastos, 2); summary.Cell(row, 4).Value = Math.Round(n.Impuestos, 2); summary.Cell(row, 5).Value = Math.Round(n.Neta, 2);
        }
        summary.Columns().AdjustToContents();

        var clients = book.AddWorksheet("Clientes");
        string[] clientHeader = ["Cliente", "Ingresos sin IGV (PEN)", "% del total", "% acumulado", "Cobros", "Último cobro", "Periodo anterior (PEN)", "Variación %"];
        for (var c = 0; c < clientHeader.Length; c++) clients.Cell(1, c + 1).Value = clientHeader[c];
        var r = 1;
        foreach (var x in ranking)
        {
            r++;
            clients.Cell(r, 1).Value = x.ClientName; clients.Cell(r, 2).Value = x.IngresosPen; clients.Cell(r, 3).Value = x.Porcentaje; clients.Cell(r, 4).Value = x.PorcentajeAcumulado;
            clients.Cell(r, 5).Value = x.Cobros; clients.Cell(r, 6).Value = x.UltimoCobro.ToDateTime(TimeOnly.MinValue); clients.Cell(r, 7).Value = x.PeriodoAnteriorPen;
            if (x.VariacionPorcentaje is decimal variation) clients.Cell(r, 8).Value = variation;
        }
        clients.Column(6).Style.DateFormat.Format = "dd/mm/yyyy"; clients.Columns().AdjustToContents();

        using var stream = new MemoryStream(); book.SaveAs(stream);
        return File(stream.ToArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", month is int m ? $"reporte-{year}-{m:00}.xlsx" : $"reporte-{year}.xlsx");
    }

    [HttpGet("clients")]
    public async Task<ActionResult> Clients(CancellationToken ct) => Ok(await db.Clients.OrderBy(x => x.CompanyName).Select(x => new { id = x.Id, companyName = x.CompanyName, isActive = x.IsActive, requiresTaxDocument = x.RequiresTaxDocument, activeProducts = db.ClientProducts.Count(p => p.ClientId == x.Id && p.Status == ClientProductStatus.Activo), expiringProducts = db.ClientProducts.Count(p => p.ClientId == x.Id && p.Status == ClientProductStatus.PorVencer), expiredProducts = db.ClientProducts.Count(p => p.ClientId == x.Id && p.Status == ClientProductStatus.Vencido), openTickets = db.Tickets.Count(t => t.ClientId == x.Id && (t.Status == TicketStatus.Abierto || t.Status == TicketStatus.EnProgreso)) }).ToListAsync(ct));

    [HttpGet("clients/{id:guid}")]
    public async Task<ActionResult> Client(Guid id, CancellationToken ct)
    {
        var client = await db.Clients.FindAsync([id], ct);
        if (client is null) return NotFound();
        var products = await db.ClientProducts.Include(x => x.Product).Include(x => x.Project).Where(x => x.ClientId == id).ToListAsync(ct);
        var igvRate = await db.IgvRateAsync(ct);
        return Ok(new { client = ClientDto(client), products = products.Select(x => ClientProductDto(x, x.Product is null ? 0m : ClientProductPricing.IgvRateFor(client, x.Product, igvRate))) });
    }

    [HttpPost("clients")]
    public async Task<ActionResult> CreateClient(ClientRequest request, CancellationToken ct)
    {
        var error = ValidateClient(request); if (error is not null) return BadRequest(new { message = error });
        var email = request.Email.Trim();
        if (await db.Clients.AnyAsync(x => x.Email == email, ct) || await db.UserAccounts.AnyAsync(x => x.Email == email, ct)) return Conflict(new { message = "El email ya está registrado." });
        var client = new Client { CompanyName = request.CompanyName.Trim(), ContactName = request.ContactName.Trim(), Email = email, Phone = EmptyToNull(request.Phone), PreferredLanguage = request.PreferredLanguage.Trim().ToLowerInvariant(), RequiresTaxDocument = request.RequiresTaxDocument };
        db.Clients.Add(client);
        // Sin usuario el cliente no podría entrar nunca: se crea su primer Admin con el contacto y email del cliente.
        var access = AddAdminUser(client);
        await db.SaveChangesAsync(ct);
        access = await EmailAccessAsync(client, access, ct);
        return Created($"/api/admin/clients/{client.Id}", new { client = ClientDto(client), access });
    }

    [HttpPatch("clients/{id:guid}")]
    public async Task<ActionResult> UpdateClient(Guid id, ClientPatchRequest request, CancellationToken ct)
    {
        var client = await db.Clients.FindAsync([id], ct); if (client is null) return NotFound();
        if (request.CompanyName is not null) client.CompanyName = request.CompanyName.Trim();
        if (request.ContactName is not null) client.ContactName = request.ContactName.Trim();
        if (request.Phone is not null) client.Phone = EmptyToNull(request.Phone);
        if (request.PreferredLanguage is not null) { var lang = request.PreferredLanguage.Trim().ToLowerInvariant(); if (lang is not ("es" or "en" or "it")) return BadRequest(new { message = "Idioma inválido." }); client.PreferredLanguage = lang; }
        if (request.Email is not null) { var email = request.Email.Trim(); if (string.IsNullOrWhiteSpace(email)) return BadRequest(new { message = "El email es obligatorio." }); if (await db.Clients.AnyAsync(x => x.Email == email && x.Id != id, ct)) return Conflict(new { message = "El email ya está registrado." }); client.Email = email; }
        if (request.IsActive is bool active) client.IsActive = active;
        if (request.RequiresTaxDocument is bool requiresTax) client.RequiresTaxDocument = requiresTax;
        await db.SaveChangesAsync(ct); return Ok(ClientDto(client));
    }

    [HttpGet("clients/import/template")]
    public IActionResult ClientTemplate() => File(CreateWorkbook(
        new("CompanyName", true, "Razón social o nombre comercial"),
        new("ContactName", true, "Nombre de la persona de contacto"),
        new("Email", true, "Email válido y no registrado: será el usuario del portal y recibe el acceso por correo"),
        new("Phone", false, "Texto libre, ej. +51 999 888 777"),
        new("PreferredLanguage", true, "es (español), en (inglés) o it (italiano)", ["es", "en", "it"]),
        new("RequiresTaxDocument", false, "SI solo para clientes en Perú: cada pago genera su Factura o Recibo por honorarios (vacío = NO)", ["SI", "NO"])),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "clientes-plantilla.xlsx");

    [HttpPost("clients/import")]
    public async Task<ActionResult> ImportClients(IFormFile file, CancellationToken ct)
    {
        var created_ = new List<(Client Client, ClientAccess Access)>();
        var (failure, created, errors) = await Import(file, "clientes", async (row, rowNumber, errors) =>
        {
            var requiresTax = ReadYesNo(Cell(row, 6), defaultValue: false);
            var request = new ClientRequest(Cell(row, 1), Cell(row, 2), Cell(row, 3), Cell(row, 4), Cell(row, 5), requiresTax ?? false); var error = requiresTax is null ? "RequiresTaxDocument inválido: usa SI o NO." : ValidateClient(request);
            var email = request.Email.Trim();
            if (error is not null || await db.Clients.AnyAsync(x => x.Email == email, ct) || await db.UserAccounts.AnyAsync(x => x.Email == email, ct)) { errors.Add(new(rowNumber, error ?? "El email ya está registrado.")); return false; }
            var client = new Client { CompanyName = request.CompanyName.Trim(), ContactName = request.ContactName.Trim(), Email = email, Phone = EmptyToNull(request.Phone), PreferredLanguage = request.PreferredLanguage.Trim().ToLowerInvariant(), RequiresTaxDocument = request.RequiresTaxDocument };
            db.Clients.Add(client); created_.Add((client, AddAdminUser(client))); return true;
        }, ct);
        if (failure is not null) return failure;
        var accesses = new List<ClientAccess>();
        foreach (var (client, access) in created_) accesses.Add(await EmailAccessAsync(client, access, ct));
        return Ok(new { created, skipped = errors.Count, errors, accesses });
    }

    /// <summary>
    /// Genera (o restablece) el acceso del cliente: crea su usuario Admin con el email del cliente si no existe, o le
    /// asigna una contraseña temporal nueva y lo reactiva. Sirve para clientes creados antes de que el alta creara el usuario.
    /// </summary>
    [HttpPost("clients/{id:guid}/access")]
    public async Task<ActionResult> ClientAccess(Guid id, CancellationToken ct)
    {
        var client = await db.Clients.FindAsync([id], ct); if (client is null) return NotFound();
        var user = await db.UserAccounts.SingleOrDefaultAsync(x => x.Email == client.Email, ct);
        if (user is not null && user.ClientId != client.Id) return Conflict(new { message = "El email del cliente ya lo usa un usuario de otra cuenta." });
        ClientAccess access;
        if (user is null) access = AddAdminUser(client);
        else
        {
            var temporaryPassword = AccountController.TemporaryPassword();
            user.PasswordHash = AccountController.Hasher.HashPassword(user, temporaryPassword); user.IsActive = true;
            access = new ClientAccess(client.CompanyName, user.Email, temporaryPassword);
        }
        await db.SaveChangesAsync(ct);
        return Ok(await EmailAccessAsync(client, access, ct));
    }

    [HttpPost("clients/{clientId:guid}/projects")]
    public async Task<ActionResult> CreateProject(Guid clientId, ProjectRequest request, CancellationToken ct)
    {
        if (!await db.Clients.AnyAsync(x => x.Id == clientId, ct)) return NotFound();
        if (string.IsNullOrWhiteSpace(request.Name)) return BadRequest(new { message = "El nombre del proyecto es obligatorio." });
        var slug = Slugify(string.IsNullOrWhiteSpace(request.Slug) ? request.Name : request.Slug);
        if (slug.Length == 0) return BadRequest(new { message = "Slug inválido." });
        if (await db.Projects.AnyAsync(x => x.Slug == slug, ct)) return Conflict(new { message = $"Ya existe un proyecto con el slug «{slug}»." });
        var project = new Project { ClientId = clientId, Name = request.Name.Trim(), Slug = slug };
        // El repo indicado al crear el proyecto queda como su repositorio principal; los demás se agregan aparte.
        if (!string.IsNullOrWhiteSpace(request.GithubRepoOwner) && !string.IsNullOrWhiteSpace(request.GithubRepoName))
        {
            var repository = new ProjectRepository { ProjectId = project.Id, Owner = request.GithubRepoOwner.Trim(), Name = request.GithubRepoName.Trim(), IsDefault = true };
            if (await RepositoryConflictAsync(repository.Owner, repository.Name, null, ct) is { } conflict) return conflict;
            project.Repositories.Add(repository);
        }
        db.Projects.Add(project); await db.SaveChangesAsync(ct);
        return Created($"/api/admin/projects/{project.Id}", ProjectDto(project));
    }

    [HttpPatch("projects/{id:guid}")]
    public async Task<ActionResult> UpdateProject(Guid id, ProjectRequest request, CancellationToken ct)
    {
        var project = await db.Projects.Include(x => x.Repositories).SingleOrDefaultAsync(x => x.Id == id, ct); if (project is null) return NotFound();
        if (request.Name is not null) { if (string.IsNullOrWhiteSpace(request.Name)) return BadRequest(new { message = "El nombre del proyecto es obligatorio." }); project.Name = request.Name.Trim(); }
        await db.SaveChangesAsync(ct); return Ok(ProjectDto(project));
    }

    /// <summary>Solo proyectos sin productos ni tickets: borrarlos dejaría cobros o issues huérfanos. Sus repos se quitan con él.</summary>
    [HttpDelete("projects/{id:guid}")]
    public async Task<ActionResult> DeleteProject(Guid id, CancellationToken ct)
    {
        var project = await db.Projects.Include(x => x.Repositories).SingleOrDefaultAsync(x => x.Id == id, ct); if (project is null) return NotFound();
        var products = await db.ClientProducts.CountAsync(x => x.ProjectId == id, ct);
        var tickets = await db.Tickets.CountAsync(x => x.ProjectId == id, ct);
        if (products + tickets > 0)
            return Conflict(new { message = $"«{project.Name}» tiene {Count(products, "producto", "productos")}{(products > 0 && tickets > 0 ? " y " : "")}{Count(tickets, "ticket", "tickets")}: {(products > 0 ? "muévelos a otro proyecto o elimínalos desde la tabla de productos" : "los tickets conservan el historial del proyecto, así que no se puede borrar")}." });
        db.ProjectRepositories.RemoveRange(project.Repositories); db.Projects.Remove(project);
        await db.SaveChangesAsync(ct); return NoContent();
    }

    private static string Count(int n, string one, string many) => n == 0 ? "" : n == 1 ? $"1 {one}" : $"{n} {many}";

    [HttpPost("projects/{id:guid}/repositories")]
    public async Task<ActionResult> AddRepository(Guid id, RepositoryRequest request, CancellationToken ct)
    {
        var project = await db.Projects.Include(x => x.Repositories).SingleOrDefaultAsync(x => x.Id == id, ct); if (project is null) return NotFound();
        if (string.IsNullOrWhiteSpace(request.Owner) || string.IsNullOrWhiteSpace(request.Name)) return BadRequest(new { message = "Indica el dueño y el nombre del repositorio." });
        var repository = new ProjectRepository { ProjectId = id, Owner = request.Owner.Trim(), Name = request.Name.Trim(), Label = EmptyToNull(request.Label), IsDefault = project.Repositories.Count == 0 || request.IsDefault == true };
        if (await RepositoryConflictAsync(repository.Owner, repository.Name, null, ct) is { } conflict) return conflict;
        if (repository.IsDefault) foreach (var other in project.Repositories) other.IsDefault = false;
        db.ProjectRepositories.Add(repository); project.Repositories.Add(repository); await db.SaveChangesAsync(ct);
        return Ok(ProjectDto(project));
    }

    [HttpPatch("repositories/{id:guid}")]
    public async Task<ActionResult> UpdateRepository(Guid id, RepositoryRequest request, CancellationToken ct)
    {
        var repository = await db.ProjectRepositories.FindAsync([id], ct); if (repository is null) return NotFound();
        var project = await db.Projects.Include(x => x.Repositories).SingleAsync(x => x.Id == repository.ProjectId, ct);
        var owner = request.Owner?.Trim() ?? repository.Owner; var name = request.Name?.Trim() ?? repository.Name;
        if (owner.Length == 0 || name.Length == 0) return BadRequest(new { message = "Indica el dueño y el nombre del repositorio." });
        // Los issues ya creados viven en el repo actual: cambiarlo rompería la sincronización de esos tickets.
        if ((owner != repository.Owner || name != repository.Name) && await db.Tickets.AnyAsync(x => x.RepositoryId == id && x.GithubIssueNumber != null, ct))
            return Conflict(new { message = "El repositorio ya tiene issues de tickets: agrega uno nuevo en lugar de cambiarlo." });
        if (await RepositoryConflictAsync(owner, name, id, ct) is { } conflict) return conflict;
        repository.Owner = owner; repository.Name = name;
        if (request.Label is not null) repository.Label = EmptyToNull(request.Label);
        if (request.IsDefault == true) foreach (var other in project.Repositories) other.IsDefault = other.Id == id;
        await db.SaveChangesAsync(ct); return Ok(ProjectDto(project));
    }

    [HttpDelete("repositories/{id:guid}")]
    public async Task<ActionResult> DeleteRepository(Guid id, CancellationToken ct)
    {
        var repository = await db.ProjectRepositories.FindAsync([id], ct); if (repository is null) return NotFound();
        if (await db.Tickets.AnyAsync(x => x.RepositoryId == id, ct)) return Conflict(new { message = "El repositorio tiene tickets asociados: no se puede quitar." });
        var project = await db.Projects.Include(x => x.Repositories).SingleAsync(x => x.Id == repository.ProjectId, ct);
        project.Repositories.Remove(repository); db.ProjectRepositories.Remove(repository);
        if (repository.IsDefault && project.Repositories.FirstOrDefault() is { } next) next.IsDefault = true;
        await db.SaveChangesAsync(ct); return Ok(ProjectDto(project));
    }

    private async Task<ActionResult?> RepositoryConflictAsync(string owner, string name, Guid? exceptId, CancellationToken ct) =>
        await db.ProjectRepositories.AnyAsync(x => x.Owner == owner && x.Name == name && x.Id != exceptId, ct)
            ? Conflict(new { message = $"El repositorio {owner}/{name} ya está asociado a un proyecto." }) : null;

    /// <summary>Envía el acceso por email al cliente; el resultado indica si llegó a enviarse (si no, se entrega a mano).</summary>
    private async Task<ClientAccess> EmailAccessAsync(Client client, ClientAccess access, CancellationToken ct) =>
        access with { EmailSent = await accessEmail.SendAsync(client, client.ContactName, access.Email, access.TemporaryPassword, Request, ct) };

    private ClientAccess AddAdminUser(Client client)
    {
        var temporaryPassword = AccountController.TemporaryPassword();
        var user = new UserAccount { ClientId = client.Id, Name = client.ContactName, Email = client.Email, Role = UserRole.Admin };
        user.PasswordHash = AccountController.Hasher.HashPassword(user, temporaryPassword);
        db.UserAccounts.Add(user);
        return new ClientAccess(client.CompanyName, user.Email, temporaryPassword);
    }

    internal static string Slugify(string value)
    {
        var normalized = value.Trim().ToLowerInvariant().Normalize(System.Text.NormalizationForm.FormD);
        var chars = normalized.Where(c => System.Globalization.CharUnicodeInfo.GetUnicodeCategory(c) != System.Globalization.UnicodeCategory.NonSpacingMark).Select(c => char.IsLetterOrDigit(c) ? c : '-');
        return System.Text.RegularExpressions.Regex.Replace(new string(chars.ToArray()), "-{2,}", "-").Trim('-');
    }

    [HttpGet("products")]
    public async Task<ActionResult> Products(CancellationToken ct) => Ok((await db.Products.OrderBy(x => x.Name).ToListAsync(ct)).Select(ProductDto));

    [HttpPost("products")]
    public async Task<ActionResult> CreateProduct(ProductRequest request, CancellationToken ct)
    {
        var error = ValidateProduct(request); if (error is not null) return BadRequest(new { message = error });
        var product = ToProduct(request); db.Products.Add(product); await EnsureProductCategoryAsync(product.Category, ct); await db.SaveChangesAsync(ct); return Created($"/api/admin/products/{product.Id}", ProductDto(product));
    }

    [HttpPatch("products/{id:guid}")]
    public async Task<ActionResult> UpdateProduct(Guid id, ProductPatchRequest request, CancellationToken ct)
    {
        var product = await db.Products.FindAsync([id], ct); if (product is null) return NotFound();
        if (request.Type is ProductType type) product.Type = type; if (request.Name is not null) product.Name = request.Name.Trim(); if (request.BillingCycle is BillingCycle cycle) product.BillingCycle = cycle; if (request.BasePrice is not null) product.BasePrice = request.BasePrice; if (request.Currency is not null) product.Currency = request.Currency.Trim().ToUpperInvariant(); if (request.Description is not null) product.Description = EmptyToNull(request.Description); if (request.IsActive is bool active) product.IsActive = active; if (request.Category is not null) product.Category = EmptyToNull(request.Category); if (request.Tags is not null) product.Tags = NormalizeTags(request.Tags); if (request.AllowsTickets is bool allowsTickets) product.AllowsTickets = allowsTickets; if (request.TaxDocumentType is TaxDocumentType taxType) product.TaxDocumentType = taxType;
        if (string.IsNullOrWhiteSpace(product.Name) || string.IsNullOrWhiteSpace(product.Currency)) return BadRequest(new { message = "Nombre y moneda son obligatorios." });
        await EnsureProductCategoryAsync(product.Category, ct);
        await db.SaveChangesAsync(ct); return Ok(ProductDto(product));
    }

    [HttpGet("products/import/template")]
    public IActionResult ProductTemplate() => File(CreateWorkbook(
        new("Type", true, "Una de la lista", Enum.GetNames<ProductType>()),
        new("Name", true, "Nombre que ve el cliente, ej. Hosting anual"),
        new("BillingCycle", true, "Unico, Mensual, Bimestral, Trimestral, Semestral o Anual", ["Unico", "Mensual", "Bimestral", "Trimestral", "Semestral", "Anual"]),
        new("BasePrice", true, "Precio de catálogo SIN IGV (a clientes en Perú con Factura se les suma al cobrar), número mayor o igual a 0 con punto decimal, ej. 120.00"),
        new("Currency", true, "PEN, USD o EUR", ["PEN", "USD", "EUR"]),
        new("Description", false, "Texto libre"),
        new("IsActive", false, "SI o NO (vacío = SI)", ["SI", "NO"]),
        new("TaxDocumentType", false, "Comprobante que genera para clientes en Perú (vacío = Factura)", Enum.GetNames<TaxDocumentType>()),
        new("Category", false, "Agrupa el catálogo, ej. Sitios web"),
        new("Tags", false, "Palabras para el buscador del catálogo, separadas por coma, ej. web, página, tienda online"),
        new("AllowsTickets", false, "SI o NO (vacío = NO): el cliente puede registrar tickets desde este producto", ["SI", "NO"])),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "productos-plantilla.xlsx");

    [HttpPost("products/import")]
    public async Task<ActionResult> ImportProducts(IFormFile file, CancellationToken ct)
    {
        var (failure, created, errors) = await Import(file, "productos", async (row, rowNumber, errors) =>
    {
        var error = ParseProductRow(row, out var product);
        if (error is not null) { errors.Add(new(rowNumber, error)); return false; }
        db.Products.Add(product!); await EnsureProductCategoryAsync(product!.Category, ct); return true;
        }, ct);
        return failure ?? Ok(new { created, skipped = errors.Count, errors });
    }

    [HttpPost("clients/{clientId:guid}/products")]
    public async Task<ActionResult> AssignProduct(Guid clientId, AssignProductRequest request, CancellationToken ct)
    {
        if (!await db.Clients.AnyAsync(x => x.Id == clientId, ct) || !await db.Projects.AnyAsync(x => x.Id == request.ProjectId && x.ClientId == clientId, ct)) return NotFound();
        var product = await db.Products.FindAsync([request.ProductId], ct); if (product is null) return NotFound();
        if (request.BillingMode is not ("Manual" or "PayPal")) return BadRequest(new { message = "Modo de facturación inválido." });
        if (request.BillingMode == "PayPal" && await db.PaymentSettings.AnyAsync(x => !x.PayPalEnabled, ct)) return BadRequest(new { message = "PayPal está deshabilitado en Medios de pago: asocia el producto con cobro manual." });
        var item = new ClientProduct { ClientId = clientId, ProjectId = request.ProjectId, ProductId = product.Id, BillingCycle = request.BillingCycle, IsManualBilling = request.BillingMode == "Manual", Status = request.BillingMode == "Manual" ? ClientProductStatus.Activo : ClientProductStatus.Pendiente, Price = product.BasePrice is null ? request.Price : null, DomainName = EmptyToNull(request.DomainName), PriceLabelOverride = EmptyToNull(request.PriceLabelOverride), RenewsAt = ToUtcDate(request.RenewsAt), NextChargeAt = ToUtcDate(request.NextChargeAt), Product = product };
        item.Status = RenewalReminderJob.StatusFor(item.Status, item.RenewsAt, DateTime.UtcNow);
        if (item.SetDiscount(request.Discount) is string discountError) return BadRequest(new { message = discountError });
        db.ClientProducts.Add(item);
        var igvRate = await db.IgvRateForAsync(clientId, product, ct);
        if (request.BillingMode == "PayPal")
        {
            try
            {
                var checkout = await checkoutService.StartAsync(item, product, Request, ct, igvRate);
                await db.SaveChangesAsync(ct);
                return Created($"/api/admin/client-products/{item.Id}", new { clientProduct = ClientProductDto(item, igvRate), approvalUrl = checkout.ApprovalUrl });
            }
            catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
        }
        await db.SaveChangesAsync(ct); return Created($"/api/admin/client-products/{item.Id}", new { clientProduct = ClientProductDto(item, igvRate), approvalUrl = (string?)null });
    }

    /// <summary>
    /// Registra un pago por transferencia confirmado por Rtres: activa el producto, extiende su vigencia, consume o quita el
    /// descuento, emite el comprobante (clientes en Perú) y avisa al cliente, igual que un cobro de PayPal. El N° de
    /// operación evita registrar dos veces la misma transferencia.
    /// </summary>
    [HttpPost("client-products/{id:guid}/payments")]
    public async Task<ActionResult> RegisterTransferPayment(Guid id, TransferPaymentRequest request, [FromServices] PayPalPaymentService payments, CancellationToken ct)
    {
        var item = await db.ClientProducts.Include(x => x.Product).Include(x => x.Project).SingleOrDefaultAsync(x => x.Id == id, ct); if (item is null) return NotFound();
        if (!item.IsManualBilling) return BadRequest(new { message = "Este producto se cobra por PayPal: sus pagos se registran solos." });
        if (item.ValidateYears(request.Years) is string yearsError) return BadRequest(new { message = yearsError });
        var igvRate = item.Product is null ? 0m : await db.IgvRateForAsync(item.ClientId, item.Product, ct);
        var amount = request.Amount ?? item.ChargeTotal(igvRate, request.Years); // lo transferido incluye el IGV si corresponde
        if (amount is not decimal value || value <= 0) return BadRequest(new { message = "Indica un monto mayor a 0." });
        var reference = request.Reference?.Trim();
        var key = string.IsNullOrWhiteSpace(reference) ? $"TRF-{Guid.NewGuid():N}" : $"TRF-{reference}";
        if (key.Length > 100) return BadRequest(new { message = "El N° de operación es demasiado largo." });
        var paidAt = ToUtcDate(request.PaidAt);
        if (paidAt > DateTime.UtcNow.AddDays(1)) return BadRequest(new { message = "La fecha de pago no puede ser futura." });
        if (!await payments.ApplyPaymentAsync(item, key, value, item.Product?.Currency, ct, PaymentMethods.Transferencia, paidAt, request.Years)) return Conflict(new { message = "Esa transferencia (N° de operación) ya está registrada." });
        // La vigencia pudo quedar en el pasado si el pago es antiguo: el estado sigue a la fecha de vencimiento.
        item.Status = RenewalReminderJob.StatusFor(item.Status, item.RenewsAt, DateTime.UtcNow); await db.SaveChangesAsync(ct);
        return Ok(ClientProductDto(item, igvRate));
    }

    [HttpPatch("client-products/{id:guid}")]
    public async Task<ActionResult> UpdateClientProduct(Guid id, ClientProductPatchRequest request, CancellationToken ct)
    {
        var item = await db.ClientProducts.Include(x => x.Product).Include(x => x.Project).SingleOrDefaultAsync(x => x.Id == id, ct); if (item is null) return NotFound();
        if (request.Price is not null) item.Price = request.Price; if (request.Status is ClientProductStatus status) item.Status = status; if (request.BillingCycle is BillingCycle cycle) item.BillingCycle = cycle; if (request.DomainName is not null) item.DomainName = EmptyToNull(request.DomainName); if (request.PriceLabelOverride is not null) item.PriceLabelOverride = EmptyToNull(request.PriceLabelOverride); if (request.IsManualBilling is bool manual) item.IsManualBilling = manual;
        if (request.Discount is not null && item.SetDiscount(request.Discount) is string discountError) return BadRequest(new { message = discountError });
        // Mover a otro proyecto del mismo cliente (p. ej. para poder borrar el proyecto original). Sus tickets se quedan donde están.
        if (request.ProjectId is Guid projectId && projectId != item.ProjectId)
        {
            var project = await db.Projects.SingleOrDefaultAsync(x => x.Id == projectId && x.ClientId == item.ClientId, ct);
            if (project is null) return BadRequest(new { message = "El proyecto no pertenece a este cliente." });
            (item.ProjectId, item.Project) = (project.Id, project);
        }
        await db.SaveChangesAsync(ct); return Ok(await ClientProductDtoAsync(item, ct));
    }

    /// <summary>
    /// Quita un producto asociado por error o que nunca se pagó. Con pagos registrados no se borra (son ingresos con
    /// comprobante): se marca Cancelado o se mueve de proyecto. Una suscripción de PayPal activa se cancela antes en PayPal.
    /// </summary>
    [HttpDelete("client-products/{id:guid}")]
    public async Task<ActionResult> DeleteClientProduct(Guid id, CancellationToken ct)
    {
        var item = await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == id, ct); if (item is null) return NotFound();
        var payments = await db.PaymentTransactions.CountAsync(x => x.ClientProductId == id, ct);
        if (payments == 0) payments = await db.TaxDocumentLines.CountAsync(x => x.ClientProductId == id, ct); // comprobante con varios productos
        if (payments > 0) return Conflict(new { message = $"«{item.Product?.Name}» tiene {Count(payments, "pago registrado", "pagos registrados")}: no se elimina para no perder el historial contable. Márcalo como Cancelado o muévelo a otro proyecto." });
        if (!string.IsNullOrWhiteSpace(item.PayPalSubscriptionId) && item.Status != ClientProductStatus.Cancelado) return Conflict(new { message = "Tiene una suscripción de PayPal: cancélala primero (estado Cancelado) para que no siga cobrando." });
        // Los tickets registrados desde este producto se conservan, sin el vínculo; los reportes de transferencia (sin aprobar) se descartan.
        await db.Tickets.Where(x => x.ClientProductId == id).ForEachAsync(x => x.ClientProductId = null, ct);
        db.TransferReports.RemoveRange(await db.TransferReports.Where(x => x.ClientProductId == id).ToListAsync(ct));
        db.ClientProducts.Remove(item);
        await db.SaveChangesAsync(ct); return NoContent();
    }

    /// <summary>
    /// Fija las fechas de un producto (null las borra): <c>RenewsAt</c> para Anual/Único, <c>NextChargeAt</c> para
    /// Mensual. Es lo que permite que los productos de facturación manual reciban los avisos de vencimiento; el estado se
    /// recalcula con la nueva fecha (Vencido, Por vencer o Activo).
    /// </summary>
    [HttpPut("client-products/{id:guid}/dates")]
    public async Task<ActionResult> UpdateClientProductDates(Guid id, ClientProductDatesRequest request, CancellationToken ct)
    {
        var item = await db.ClientProducts.Include(x => x.Product).Include(x => x.Project).SingleOrDefaultAsync(x => x.Id == id, ct); if (item is null) return NotFound();
        item.RenewsAt = ToUtcDate(request.RenewsAt); item.NextChargeAt = ToUtcDate(request.NextChargeAt);
        item.Status = RenewalReminderJob.StatusFor(item.Status, item.RenewsAt, DateTime.UtcNow);
        item.OnDatesChanged();
        await db.SaveChangesAsync(ct); return Ok(await ClientProductDtoAsync(item, ct));
    }

    /// <summary>Una fecha elegida en el portal se guarda a las 12:00 UTC: así se ve el mismo día en cualquier zona horaria (Lima incluida).</summary>
    internal static DateTime? ToUtcDate(DateOnly? date) => date?.ToDateTime(new TimeOnly(12, 0), DateTimeKind.Utc);

    private async Task<(ActionResult? Failure, int Created, List<ImportError> Errors)> Import(IFormFile file, string kind, Func<IXLRow, int, List<ImportError>, Task<bool>> addRow, CancellationToken ct)
    {
        var errors = new List<ImportError>(); var created = 0;
        if (file is null || file.Length == 0) return (BadRequest(new { message = "Selecciona un archivo .xlsx." }), 0, errors);
        try { using var stream = file.OpenReadStream(); using var book = new XLWorkbook(stream); var sheet = book.Worksheets.First(); foreach (var row in sheet.RowsUsed().Skip(1)) if (await addRow(row, row.RowNumber(), errors)) { await db.SaveChangesAsync(ct); created++; } }
        catch (Exception ex) when (ex is not DbUpdateException) { return (BadRequest(new { message = $"No se pudo leer la plantilla de {kind}." }), 0, errors); }
        return (null, created, errors);
    }
    private static string Cell(IXLRow row, int col) => row.Cell(col).GetString();
    /// <summary>
    /// Plantilla de importación: encabezados (el importador lee por posición), una nota en cada encabezado y una lista
    /// desplegable donde hay valores fijos, más la hoja "Valores válidos" con qué acepta cada columna.
    /// </summary>
    private static byte[] CreateWorkbook(params TemplateColumn[] columns)
    {
        const int LastDataRow = 1000;
        using var book = new XLWorkbook(); var sheet = book.AddWorksheet("Plantilla");
        var help = book.AddWorksheet("Valores válidos");
        help.Cell(1, 1).Value = "Columna"; help.Cell(1, 2).Value = "Obligatoria"; help.Cell(1, 3).Value = "Valores aceptados"; help.Row(1).Style.Font.Bold = true;
        for (var i = 0; i < columns.Length; i++)
        {
            var column = columns[i]; var accepted = column.Options is null ? column.Accepted : $"{column.Accepted}: {string.Join(", ", column.Options)}";
            var header = sheet.Cell(1, i + 1); header.Value = column.Name;
            header.CreateComment().AddText($"{(column.Required ? "Obligatoria" : "Opcional")}. {accepted}");
            if (column.Required) header.Style.Fill.BackgroundColor = XLColor.FromHtml("#FFF2CC");
            if (column.Options is not null)
            {
                var validation = sheet.Range(2, i + 1, LastDataRow, i + 1).CreateDataValidation();
                validation.List($"\"{string.Join(",", column.Options)}\"", true);
                validation.ErrorTitle = column.Name; validation.ErrorMessage = $"Valores aceptados: {string.Join(", ", column.Options)}";
            }
            help.Cell(i + 2, 1).Value = column.Name; help.Cell(i + 2, 2).Value = column.Required ? "Sí" : "No"; help.Cell(i + 2, 3).Value = accepted;
        }
        sheet.Row(1).Style.Font.Bold = true; sheet.Columns().AdjustToContents(); help.Columns().AdjustToContents();
        help.Cell(columns.Length + 3, 1).Value = "Las columnas amarillas son obligatorias. El importador solo lee la hoja Plantilla, desde la fila 2.";
        using var stream = new MemoryStream(); book.SaveAs(stream); return stream.ToArray();
    }
    private static string? EmptyToNull(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
    private static string? ValidateClient(ClientRequest request) => string.IsNullOrWhiteSpace(request.CompanyName) || string.IsNullOrWhiteSpace(request.ContactName) || string.IsNullOrWhiteSpace(request.Email) || !request.Email.Contains('@') ? "Empresa, contacto y email válido son obligatorios." : request.PreferredLanguage.Trim().ToLowerInvariant() is not ("es" or "en" or "it") ? "Idioma inválido." : null;
    private static string? ValidateProduct(ProductRequest request) => string.IsNullOrWhiteSpace(request.Name) || string.IsNullOrWhiteSpace(request.Currency) ? "Nombre y moneda son obligatorios." : null;
    /// <summary>Una categoría escrita en un producto (o en la importación) que aún no existe se agrega a la lista administrable.</summary>
    private async Task EnsureProductCategoryAsync(string? name, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(name)) return;
        name = name.Trim();
        if (db.ProductCategories.Local.Any(x => x.Name.Equals(name, StringComparison.OrdinalIgnoreCase)) || await db.ProductCategories.AnyAsync(x => x.Name == name, ct)) return;
        db.ProductCategories.Add(new ProductCategory { Name = name, SortOrder = await db.ProductCategories.CountAsync(ct) + db.ProductCategories.Local.Count });
    }

    /// <summary>Minúsculas y sin tildes, para comparar nombres escritos a mano.</summary>
    internal static string Fold(string value) => new(value.Trim().ToLowerInvariant().Normalize(System.Text.NormalizationForm.FormD)
        .Where(c => System.Globalization.CharUnicodeInfo.GetUnicodeCategory(c) != System.Globalization.UnicodeCategory.NonSpacingMark).ToArray());

    private static Product ToProduct(ProductRequest r) => new() { Type = r.Type, Name = r.Name.Trim(), BillingCycle = r.BillingCycle, BasePrice = r.BasePrice, Currency = r.Currency.Trim().ToUpperInvariant(), Description = EmptyToNull(r.Description), IsActive = r.IsActive, TaxDocumentType = r.TaxDocumentType, Category = EmptyToNull(r.Category), Tags = NormalizeTags(r.Tags), AllowsTickets = r.AllowsTickets };
    /// <summary>Etiquetas sin espacios sobrantes ni repetidas, separadas por ", "; null si no hay ninguna.</summary>
    private static string? NormalizeTags(string? tags) => tags?.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).Distinct(StringComparer.OrdinalIgnoreCase).ToArray() is { Length: > 0 } list ? string.Join(", ", list) : null;
    private static object ClientDto(Client x) => new { id = x.Id, companyName = x.CompanyName, contactName = x.ContactName, email = x.Email, phone = x.Phone, preferredLanguage = x.PreferredLanguage, isActive = x.IsActive, requiresTaxDocument = x.RequiresTaxDocument };
    private static object ProjectDto(Project x) => new { id = x.Id, clientId = x.ClientId, name = x.Name, slug = x.Slug, repositories = x.Repositories.OrderByDescending(r => r.IsDefault).ThenBy(r => r.Name).Select(r => new { id = r.Id, owner = r.Owner, name = r.Name, label = r.Label, isDefault = r.IsDefault }) };
    private static object ProductDto(Product x) => new { id = x.Id, type = x.Type.ToString(), name = x.Name, billingCycle = x.BillingCycle.ToString(), basePrice = x.BasePrice, currency = x.Currency, description = x.Description, isActive = x.IsActive, taxDocumentType = x.TaxDocumentType.ToString(), category = x.Category, tags = x.Tags, allowsTickets = x.AllowsTickets };
    private async Task<object> ClientProductDtoAsync(ClientProduct x, CancellationToken ct) => ClientProductDto(x, x.Product is null ? 0m : await db.IgvRateForAsync(x.ClientId, x.Product, ct));
    /// <summary>Precios sin IGV; <c>nextChargeTotal</c> es lo que se cobra, con el IGV de <paramref name="igvRate"/> (Perú + Factura).</summary>
    private static object ClientProductDto(ClientProduct x, decimal igvRate) => new { igvRate, nextChargeTotal = x.NextChargeTotal(igvRate), id = x.Id, clientId = x.ClientId, projectId = x.ProjectId, projectName = x.Project?.Name, productId = x.ProductId, productName = x.Product?.Name, productType = x.Product?.Type.ToString(), currency = x.Product?.Currency ?? "USD", billingCycle = x.BillingCycle.ToString(), isManualBilling = x.IsManualBilling, status = x.Status.ToString(), price = x.Price, listPrice = x.ListPrice(), discount = x.Discount, discountEndsAt = x.DiscountEndsAt == ClientProductPricing.NoEnd ? null : x.DiscountEndsAt, currentPrice = x.CurrentPrice(DateTime.UtcNow), nextChargePrice = x.NextChargePrice(), domainName = x.DomainName, priceLabelOverride = x.PriceLabelOverride, renewsAt = x.RenewsAt, nextChargeAt = x.NextChargeAt };
    /// <summary>Comprobante con sus importes en soles al tipo de cambio <paramref name="rateToPen"/> (1 si ya está en PEN).</summary>
    private static object TaxDocumentDto(TaxDocument x, decimal rateToPen, IEnumerable<TaxDocumentLine> lines, string? paymentMethod) => new { paymentMethod, lines = lines.Select(l => new { clientProductId = l.ClientProductId, description = l.Description, amount = l.Amount }).ToList(), id = x.Id, paymentTransactionId = x.PaymentTransactionId, clientId = x.ClientId, type = x.Type.ToString(), series = x.Series, number = x.Number, issueDate = x.IssueDate, currency = x.Currency, baseAmount = x.BaseAmount, igvAmount = x.IgvAmount, totalAmount = x.TotalAmount, notes = x.Notes, retentionAmount = x.RetentionAmount,
        exchangeRate = x.Currency == "PEN" ? 1m : Math.Round(rateToPen, 3), basePen = Math.Round(x.BaseAmount * rateToPen, 2), igvPen = Math.Round(x.IgvAmount * rateToPen, 2), totalPen = Math.Round(x.TotalAmount * rateToPen, 2) };
    /// <summary>Servicio de no domiciliado: el proveedor del exterior se guarda solo si el gasto está marcado (lo pide el 1662).</summary>
    private static void ApplyForeignService(Expense expense, bool foreign, string? name, string? country)
    {
        expense.IsNonDomiciledService = foreign;
        (expense.ForeignSupplierName, expense.ForeignSupplierCountry) = foreign ? (EmptyToNull(name), EmptyToNull(country)) : (null, null);
        if (!foreign) (expense.Form1662PaidAt, expense.Form1662Number) = (null, null);
    }

    private static object ExpenseDto(Expense x) => new { id = x.Id, description = x.Description, categoryId = x.CategoryId, categoryName = x.Category?.Name ?? "", type = x.Type.ToString(), amount = x.Amount, currency = x.Currency, amountPen = x.AmountPen, date = x.Date, recurring = x.Recurring, recurrenceCycle = x.RecurrenceCycle?.ToString(), recurrenceEndsAt = x.RecurrenceEndsAt, isNonDeductible = x.IsNonDeductible, isNonDomiciledService = x.IsNonDomiciledService, foreignSupplierName = x.ForeignSupplierName, foreignSupplierCountry = x.ForeignSupplierCountry, form1662PaidAt = x.Form1662PaidAt, form1662Number = x.Form1662Number };
}

public sealed record ProfileRequest(string Name);
public sealed record ChangePasswordRequest(string CurrentPassword, string NewPassword);
public sealed record InviteRequest(string Name, string Email);
public sealed record UpdateTeamRequest(UserRole? Role, bool? IsActive);
public sealed record ClientRequest(string CompanyName, string ContactName, string Email, string? Phone, string PreferredLanguage, bool RequiresTaxDocument = false);
public sealed record ClientPatchRequest(string? CompanyName, string? ContactName, string? Email, string? Phone, string? PreferredLanguage, bool? IsActive, bool? RequiresTaxDocument = null);
public sealed record ProductRequest(ProductType Type, string Name, BillingCycle BillingCycle, decimal? BasePrice, string Currency, string? Description, bool IsActive, TaxDocumentType TaxDocumentType = TaxDocumentType.Factura, string? Category = null, string? Tags = null, bool AllowsTickets = false);
public sealed record ProductPatchRequest(ProductType? Type, string? Name, BillingCycle? BillingCycle, decimal? BasePrice, string? Currency, string? Description, bool? IsActive, TaxDocumentType? TaxDocumentType = null, string? Category = null, string? Tags = null, bool? AllowsTickets = null);
public sealed record AssignProductRequest(Guid ProductId, Guid ProjectId, BillingCycle BillingCycle, string BillingMode, decimal? Price, string? DomainName, string? PriceLabelOverride, DateOnly? RenewsAt = null, DateOnly? NextChargeAt = null, decimal? Discount = null);
public sealed record TransferPaymentRequest(decimal? Amount, DateOnly? PaidAt, string? Reference, int Years = 1);
public sealed record ClientProductDatesRequest(DateOnly? RenewsAt, DateOnly? NextChargeAt);
public sealed record ClientProductPatchRequest(decimal? Price, ClientProductStatus? Status, BillingCycle? BillingCycle, bool? IsManualBilling, string? DomainName, string? PriceLabelOverride, decimal? Discount = null, Guid? ProjectId = null);
public sealed record ImportError(int Row, string Reason);
/// <summary>Columna de una plantilla de importación: <paramref name="Options"/> genera una lista desplegable en Excel.</summary>
public sealed record TemplateColumn(string Name, bool Required, string Accepted, string[]? Options = null);
public sealed record ClientAccess(string ClientName, string Email, string TemporaryPassword, bool EmailSent = false);
public sealed record ProjectRequest(string? Name, string? Slug, string? GithubRepoOwner, string? GithubRepoName);
public sealed record RepositoryRequest(string? Owner, string? Name, string? Label = null, bool? IsDefault = null);
public sealed record TaxSettingsRequest(decimal? IgvRate, decimal? RentaRate, string? FacturaSeries = null, int? FacturaNextNumber = null, string? ReciboSeries = null, int? ReciboNextNumber = null, string? Ruc = null, bool? IsGoodTaxpayer = null, bool? Use1662AsCredit = null);
/// <summary>Varios productos van en <c>Items</c>; <c>ClientProductId</c> + <c>TotalAmount</c> se mantienen para emitir con uno solo.</summary>
public sealed record TaxDocumentRequest(Guid? ClientProductId, DateOnly IssueDate, string Currency, decimal TotalAmount, string? Notes, decimal? RetentionAmount = null, IReadOnlyList<TaxDocumentItemRequest>? Items = null);
public sealed record TaxDocumentItemRequest(Guid ClientProductId, decimal Amount);
public sealed record ReverseTaxDocumentRequest(string? Reason, bool NotIssued);
public sealed record ExpenseRequest(string Description, Guid CategoryId, ExpenseType Type, decimal Amount, string Currency, DateOnly Date, bool Recurring, BillingCycle? RecurrenceCycle, bool IsNonDeductible = false, bool IsNonDomiciledService = false, string? ForeignSupplierName = null, string? ForeignSupplierCountry = null);
public sealed record EndRecurrenceRequest(DateOnly EndsAt);
public sealed record ExpensePatchRequest(string? Description, Guid? CategoryId, ExpenseType? Type, decimal? Amount, string? Currency, DateOnly? Date, bool? Recurring, BillingCycle? RecurrenceCycle, bool? IsNonDeductible = null, bool? IsNonDomiciledService = null, string? ForeignSupplierName = null, string? ForeignSupplierCountry = null);
ParseOptions.0.json�I
RC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\AdminController.AnnualTax.cs�Husing Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;

namespace Rtres.Api.Controllers;

/// <summary>
/// Renta anual del Régimen MYPE Tributario y Formulario 1662. Respuestas del contador en
/// Documentacion/Confirmacion_de_mi_contador.md; decisiones en PLAN-contabilidad-sunat.md.
/// </summary>
public sealed partial class AdminController
{
    // ---- Parámetros por año ----

    [HttpGet("annual-tax-settings")]
    public async Task<ActionResult> AnnualTaxSettings(CancellationToken ct) => Ok(await db.AnnualTaxSettings.OrderByDescending(x => x.Year).ToListAsync(ct));

    [HttpPut("annual-tax-settings/{year:int}")]
    public async Task<ActionResult> SaveAnnualTaxSettings(int year, AnnualTaxSettingsRequest request, CancellationToken ct)
    {
        if (year is < 2000 or > 2100) return BadRequest(new { message = "Año inválido." });
        if (request.Uit <= 0) return BadRequest(new { message = "Indica el valor de la UIT del año." });
        if (request.ThresholdUits <= 0 || request.LowRate is < 0 or > 1 || request.HighRate is < 0 or > 1) return BadRequest(new { message = "Las tasas van entre 0 y 1 (ej. 0.10 para 10 %) y el límite del primer tramo debe ser mayor a 0." });
        var row = await db.AnnualTaxSettings.SingleOrDefaultAsync(x => x.Year == year, ct);
        if (row is null) { row = new AnnualTaxSettings { Year = year }; db.AnnualTaxSettings.Add(row); }
        (row.Uit, row.ThresholdUits, row.LowRate, row.HighRate) = (request.Uit, request.ThresholdUits, request.LowRate, request.HighRate);
        await db.SaveChangesAsync(ct);
        return Ok(row);
    }

    // ---- Renta anual ----

    /// <summary>
    /// Estimación de la Renta anual de la MYPE: ventas sin IGV (facturas y cobros sin comprobante) − gastos deducibles =
    /// renta neta; impuesto por tramos; menos los pagos a cuenta (los registrados al presentar cada mes o, si faltan, el
    /// estimado). Los recibos por honorarios son del titular como persona natural: se informan aparte. Para el año en
    /// curso agrega una proyección al cierre con el promedio de los meses ya cerrados.
    /// </summary>
    [HttpGet("reports/annual-renta")]
    public async Task<ActionResult> AnnualRentaReport(int year, CancellationToken ct) => await AnnualRentaAsync(year, DateTime.UtcNow, ct);

    internal async Task<ActionResult> AnnualRentaAsync(int year, DateTime utcNow, CancellationToken ct)
    {
        var annual = await db.AnnualTaxSettings.SingleOrDefaultAsync(x => x.Year == year, ct);
        if (annual is null) return NotFound(new { message = $"Configura la UIT de {year} en Configuración → Renta anual." });
        var settings = await TaxSettingsRow(ct);
        var (from, to) = (new DateOnly(year, 1, 1), new DateOnly(year, 12, 31));
        var sales = await SalesAsync(from, to, ct);
        var expenses = await db.Expenses.Include(x => x.Category).Where(x => x.Date >= from && x.Date <= to).ToListAsync(ct);
        var filed = await db.TaxDueDates.Where(x => x.Period >= from && x.Period <= to).ToDictionaryAsync(x => x.Period.Month, ct);
        var today = DateOnly.FromDateTime(utcNow.AddHours(-5));
        // Meses que ya cuentan: todo el año si ya pasó; si es el año en curso, hasta el mes actual (incluido).
        var lastMonth = year < today.Year ? 12 : year == today.Year ? today.Month : 0;

        var months = Enumerable.Range(1, 12).Select(m =>
        {
            var start = new DateOnly(year, m, 1); var end = start.AddMonths(1).AddDays(-1);
            var ventas = sales.Where(x => x.Mype && x.Date >= start && x.Date <= end).Sum(x => x.BasePen);
            var gastos = expenses.Where(x => x.Date >= start && x.Date <= end && IsDeductible(x)).Sum(x => x.AmountPen);
            var paid = filed.TryGetValue(m, out var row) ? row.RentaPaid : null;
            var pago = m > lastMonth ? 0m : paid ?? Math.Round(ventas * settings.RentaRate, 2);
            return new AnnualMonth(start.ToString("yyyy-MM"), Math.Round(ventas, 2), Math.Round(gastos, 2), pago, m <= lastMonth && paid is null);
        }).ToList();

        var ventasMype = months.Sum(x => x.VentasPen); var deducibles = months.Sum(x => x.GastosPen);
        var noDeducibles = expenses.Where(x => !IsDeductible(x) && x.Category?.IsIncomeTax != true).GroupBy(x => x.Description.Trim()).Select(g => new { descripcion = g.Key, monto = Math.Round(g.Sum(x => x.AmountPen), 2) }).OrderByDescending(x => x.monto).ToList();
        var renta = ventasMype - deducibles;
        var impuesto = MypeIncomeTax.Compute(renta, annual);
        var pagos = months.Sum(x => x.PagoACuentaPen);

        // Proyección: promedio de los meses cerrados (sin el mes en curso) × 12, solo para el año en curso.
        object? proyeccion = null;
        if (year == today.Year && today.Month < 12 && today.Month > 1)
        {
            var closed = months.Take(today.Month - 1).ToList();
            var ventasP = closed.Average(x => x.VentasPen) * 12; var gastosP = closed.Average(x => x.GastosPen) * 12;
            var impuestoP = MypeIncomeTax.Compute(ventasP - gastosP, annual);
            var pagosP = Math.Round(ventasP * settings.RentaRate, 2);
            proyeccion = new { mesesBase = closed.Count, ventasPen = Math.Round(ventasP, 2), gastosDeduciblesPen = Math.Round(gastosP, 2), rentaNetaPen = Math.Round(ventasP - gastosP, 2), impuesto = impuestoP, pagosACuentaPen = pagosP, saldoPen = Math.Round(impuestoP.Total - pagosP, 2) };
        }

        var natural = sales.Where(x => x.PersonaNatural).ToList();
        return Ok(new
        {
            year, uit = annual.Uit, tasas = new { annual.ThresholdUits, annual.LowRate, annual.HighRate, pagoACuenta = settings.RentaRate },
            ventasMypePen = Math.Round(ventasMype, 2), gastosDeduciblesPen = Math.Round(deducibles, 2), noDeducibles, noDeduciblesPen = noDeducibles.Sum(x => x.monto),
            rentaNetaPen = Math.Round(renta, 2), impuesto, pagosACuentaPen = Math.Round(pagos, 2), pagosEstimados = months.Count(x => x.Estimado),
            saldoPen = Math.Round(impuesto.Total - pagos, 2), meses = months, proyeccion,
            personaNatural = new { ingresosPen = Math.Round(natural.Sum(x => x.BasePen), 2), retencionesPen = Math.Round(natural.Sum(x => x.RetentionPen), 2) },
            disclaimer = TaxDisclaimer,
        });
    }

    /// <summary>Deducible en la Renta: ni pago de Renta, ni categoría no deducible, ni gasto marcado como no deducible.</summary>
    private static bool IsDeductible(Expense x) => x.Category?.IsIncomeTax != true && x.Category?.IsDeductible != false && !x.IsNonDeductible;

    private sealed record AnnualMonth(string Mes, decimal VentasPen, decimal GastosPen, decimal PagoACuentaPen, bool Estimado);

    // ---- Formulario 1662 ----

    /// <summary>Pagos a proveedores no domiciliados del mes (cada uno es un 1662 aparte: tributo 1041, periodo = mes del pago).</summary>
    [HttpGet("form-1662")]
    public async Task<ActionResult> Form1662List(int year, int month, CancellationToken ct)
    {
        var settings = await TaxSettingsRow(ct);
        var rows = await db.Expenses.Where(x => x.IsNonDomiciledService && x.Date.Year == year && x.Date.Month == month).OrderBy(x => x.Date).ToListAsync(ct);
        var items = rows.Select(x => new { id = x.Id, date = x.Date, description = x.Description, supplier = x.ForeignSupplierName, country = x.ForeignSupplierCountry, amount = x.Amount, currency = x.Currency, exchangeRate = x.Amount == 0 ? 0 : Math.Round(x.AmountPen / x.Amount, 3), basePen = Math.Round(x.AmountPen, 2), igvPen = Form1662.Igv(x, settings.IgvRate), paidAt = x.Form1662PaidAt, number = x.Form1662Number }).ToList();
        return Ok(new { periodo = $"{month:00}/{year}", tributo = "1041", igvRate = settings.IgvRate, usedAsCredit = settings.Use1662AsCredit, totalIgvPen = items.Sum(x => x.igvPen), pendientes = items.Count(x => x.paidAt is null), items });
    }

    [HttpPost("expenses/{id:guid}/form-1662")]
    public async Task<ActionResult> MarkForm1662Paid(Guid id, Form1662PaymentRequest request, CancellationToken ct)
    {
        var expense = await db.Expenses.FindAsync([id], ct); if (expense is null) return NotFound();
        if (!expense.IsNonDomiciledService) return BadRequest(new { message = "Este gasto no está marcado como servicio de un proveedor no domiciliado." });
        if (request.PaidAt < expense.Date) return BadRequest(new { message = "El 1662 se paga después del pago al proveedor." });
        (expense.Form1662PaidAt, expense.Form1662Number) = (request.PaidAt, EmptyToNull(request.Number));
        await db.SaveChangesAsync(ct); return NoContent();
    }

    [HttpDelete("expenses/{id:guid}/form-1662")]
    public async Task<ActionResult> UnmarkForm1662Paid(Guid id, CancellationToken ct)
    {
        var expense = await db.Expenses.FindAsync([id], ct); if (expense is null) return NotFound();
        (expense.Form1662PaidAt, expense.Form1662Number) = (null, null);
        await db.SaveChangesAsync(ct); return NoContent();
    }
}

public sealed record AnnualTaxSettingsRequest(decimal Uit, decimal ThresholdUits = 15m, decimal LowRate = 0.10m, decimal HighRate = 0.295m);
public sealed record Form1662PaymentRequest(DateOnly PaidAt, string? Number);
ParseOptions.0.json�n
RC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\AdminController.Purchases.cs�musing System.Text.RegularExpressions;
using ClosedXML.Excel;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>Registro de Compras: comprobantes de proveedores cuyo IGV puede ser crédito fiscal.</summary>
public sealed partial class AdminController
{
    [HttpGet("purchases")]
    public async Task<ActionResult> Purchases(int year, int? month, CancellationToken ct)
    {
        var (from, to) = Period(month, year);
        var igvRate = await db.IgvRateAsync(ct);
        var items = await db.Purchases.Where(x => x.Period >= from && x.Period <= to).OrderByDescending(x => x.IssueDate).ThenBy(x => x.SupplierName).ToListAsync(ct);
        return Ok(new
        {
            items = items.Select(x => PurchaseDto(x, igvRate)),
            totalPen = Math.Round(items.Sum(x => Signed(x, x.TotalPen)), 2),
            creditoFiscalPen = Math.Round(items.Sum(x => x.TaxCreditPen), 2),
            igvSinCreditoPen = Math.Round(items.Where(x => !x.GivesTaxCredit).Sum(x => Signed(x, x.IgvPen)), 2),
        });
    }

    [HttpPost("purchases")]
    public async Task<ActionResult> CreatePurchase(PurchaseRequest request, CancellationToken ct)
    {
        var purchase = new Purchase();
        if (await ApplyPurchaseAsync(purchase, request, ct) is { } error) return error;
        db.Purchases.Add(purchase);
        if (request.CreateExpense && await LinkExpenseAsync(purchase, request.ExpenseCategoryId, ct) is { } expenseError) return expenseError;
        await db.SaveChangesAsync(ct);
        return Created($"/api/admin/purchases/{purchase.Id}", PurchaseDto(purchase, await db.IgvRateAsync(ct)));
    }

    [HttpPut("purchases/{id:guid}")]
    public async Task<ActionResult> UpdatePurchase(Guid id, PurchaseRequest request, CancellationToken ct)
    {
        var purchase = await db.Purchases.FindAsync([id], ct); if (purchase is null) return NotFound();
        if (await ApplyPurchaseAsync(purchase, request, ct) is { } error) return error;
        if ((request.CreateExpense || purchase.ExpenseId is not null) && await LinkExpenseAsync(purchase, request.ExpenseCategoryId, ct) is { } expenseError) return expenseError;
        await db.SaveChangesAsync(ct);
        return Ok(PurchaseDto(purchase, await db.IgvRateAsync(ct)));
    }

    /// <summary>Con <paramref name="deleteExpense"/> también se borra el gasto que se creó junto con la compra.</summary>
    [HttpDelete("purchases/{id:guid}")]
    public async Task<ActionResult> DeletePurchase(Guid id, bool deleteExpense, CancellationToken ct)
    {
        var purchase = await db.Purchases.FindAsync([id], ct); if (purchase is null) return NotFound();
        if (deleteExpense && purchase.ExpenseId is Guid expenseId && await db.Expenses.FindAsync([expenseId], ct) is { } expense) db.Expenses.Remove(expense);
        db.Purchases.Remove(purchase); await db.SaveChangesAsync(ct); return NoContent();
    }

    [HttpGet("purchases/import/template")]
    public async Task<IActionResult> PurchaseTemplate(CancellationToken ct) => File(CreateWorkbook(
        new("IssueDate", true, "Fecha de emisión: fecha de Excel, o texto 2026-09-28 o 28/09/2026"),
        new("Period", false, "Mes de anotación AAAA-MM (vacío = mes de emisión)"),
        new("DocumentType", true, "Tipo de comprobante", Enum.GetNames<PurchaseDocumentType>()),
        new("Series", false, "Serie, ej. F001 (obligatoria salvo Extranjero u Otro)"),
        new("Number", true, "Número del comprobante"),
        new("SupplierTaxId", true, "RUC de 11 dígitos (o identificación del proveedor extranjero)"),
        new("SupplierName", true, "Razón social del proveedor"),
        new("Currency", true, "PEN, USD o EUR", ["PEN", "USD", "EUR"]),
        new("TaxBase", true, "Base imponible, número con punto decimal"),
        new("Igv", true, "IGV del comprobante (0 si no tiene)"),
        new("NonTaxable", false, "Importe inafecto o exonerado (vacío = 0)"),
        new("UsedForTaxedOperations", false, "SI si la compra es para tus ventas gravadas (vacío = SI); NO para no tomar el crédito fiscal", ["SI", "NO"]),
        new("ExpenseCategory", false, "Si la indicas, se crea el gasto vinculado en esa categoría", [.. await db.ExpenseCategories.OrderBy(x => x.SortOrder).Select(x => x.Name).ToListAsync(ct)])),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "compras-plantilla.xlsx");

    [HttpPost("purchases/import")]
    public async Task<ActionResult> ImportPurchases(IFormFile file, CancellationToken ct)
    {
        var categories = await db.ExpenseCategories.ToListAsync(ct);
        var (failure, created, errors) = await Import(file, "compras", async (row, rowNumber, errors) =>
        {
            var parseError = ParsePurchaseRow(row, categories, out var request);
            var purchase = new Purchase();
            var error = parseError ?? Message(await ApplyPurchaseAsync(purchase, request!, ct));
            if (error is null && request!.CreateExpense) error = Message(await LinkExpenseAsync(purchase, request.ExpenseCategoryId, ct));
            if (error is not null) { errors.Add(new(rowNumber, error)); return false; }
            db.Purchases.Add(purchase); await db.SaveChangesAsync(ct); return true;
        }, ct);
        return failure ?? Ok(new { created, skipped = errors.Count, errors });
    }

    private static string? Message(ActionResult? result) => result switch
    {
        null => null,
        ObjectResult { Value: var value } => value?.GetType().GetProperty("message")?.GetValue(value) as string ?? "Fila inválida.",
        _ => "Fila inválida.",
    };

    private static string? ParsePurchaseRow(IXLRow row, IReadOnlyList<ExpenseCategory> categories, out PurchaseRequest? request)
    {
        request = null;
        if (ReadDate(row.Cell(1)) is not DateOnly issueDate) return "IssueDate inválida: usa 2026-09-28 o 28/09/2026.";
        if (!TryEnum<PurchaseDocumentType>(Cell(row, 3), out var type)) return $"DocumentType inválido: usa {string.Join(", ", Enum.GetNames<PurchaseDocumentType>())}.";
        if (ReadDecimal(row.Cell(9)) is not decimal taxBase) return "TaxBase debe ser un número.";
        if (ReadDecimal(row.Cell(10)) is not decimal igv) return "Igv debe ser un número (0 si no tiene).";
        var nonTaxable = string.IsNullOrWhiteSpace(Cell(row, 11)) ? 0m : ReadDecimal(row.Cell(11)) ?? -1m;
        if (nonTaxable < 0) return "NonTaxable debe ser un número mayor o igual a 0.";
        if (ReadYesNo(Cell(row, 12), defaultValue: true) is not bool taxed) return "UsedForTaxedOperations inválido: usa SI o NO.";
        Guid? categoryId = null;
        var categoryText = Fold(Cell(row, 13));
        if (categoryText.Length > 0)
        {
            if (categories.FirstOrDefault(x => Fold(x.Name) == categoryText || x.Code is not null && Fold(x.Code) == categoryText) is not { } category) return "ExpenseCategory no existe en Configuración → Categorías de gastos.";
            categoryId = category.Id;
        }
        request = new PurchaseRequest(issueDate, EmptyToNull(Cell(row, 2)), type, Cell(row, 4).Trim(), Cell(row, 5).Trim(), Cell(row, 6).Trim(), Cell(row, 7).Trim(),
            Cell(row, 8).Trim().ToUpperInvariant(), taxBase, igv, nonTaxable, taxed, CreateExpense: categoryId is not null, ExpenseCategoryId: categoryId);
        return null;
    }

    /// <summary>Valida y copia la compra; calcula el total, el periodo y los montos en PEN.</summary>
    private async Task<ActionResult?> ApplyPurchaseAsync(Purchase purchase, PurchaseRequest r, CancellationToken ct)
    {
        var peruvian = r.DocumentType is not (PurchaseDocumentType.Extranjero or PurchaseDocumentType.Otro);
        var supplierTaxId = (r.SupplierTaxId ?? "").Trim();
        if (peruvian && !RucRegex().IsMatch(supplierTaxId)) return BadRequest(new { message = "El RUC del proveedor debe tener 11 dígitos." });
        if (supplierTaxId.Length == 0) return BadRequest(new { message = "Indica la identificación del proveedor." });
        if (string.IsNullOrWhiteSpace(r.SupplierName)) return BadRequest(new { message = "Indica el nombre del proveedor." });
        if (peruvian && string.IsNullOrWhiteSpace(r.Series)) return BadRequest(new { message = "Indica la serie del comprobante (ej. F001)." });
        if (string.IsNullOrWhiteSpace(r.Number)) return BadRequest(new { message = "Indica el número del comprobante." });
        var currency = (r.Currency ?? "").Trim().ToUpperInvariant();
        if (currency is not ("PEN" or "USD" or "EUR")) return BadRequest(new { message = "Moneda inválida: usa PEN, USD o EUR." });
        if (r.TaxBase < 0 || r.Igv < 0 || r.NonTaxable < 0 || r.TaxBase + r.Igv + r.NonTaxable <= 0) return BadRequest(new { message = "Los importes no pueden ser negativos y el total debe ser mayor a 0." });
        if (r.Igv > 0 && r.DocumentType is PurchaseDocumentType.Boleta or PurchaseDocumentType.ReciboPorHonorarios) return BadRequest(new { message = "Una boleta o un recibo por honorarios no discrimina IGV: registra el importe como base o inafecto." });

        var issueMonth = new DateOnly(r.IssueDate.Year, r.IssueDate.Month, 1);
        var period = issueMonth;
        if (!string.IsNullOrWhiteSpace(r.Period))
        {
            if (!DateOnly.TryParseExact(r.Period.Trim() + "-01", "yyyy-MM-dd", out period)) return BadRequest(new { message = "Periodo inválido: usa AAAA-MM." });
            if (period < issueMonth) return BadRequest(new { message = "La compra no puede anotarse en un periodo anterior a su emisión." });
        }

        var series = (r.Series ?? "").Trim().ToUpperInvariant(); var number = r.Number.Trim().TrimStart('0'); if (number.Length == 0) number = "0";
        if (await db.Purchases.AnyAsync(x => x.Id != purchase.Id && x.SupplierTaxId == supplierTaxId && x.DocumentType == r.DocumentType && x.Series == series && x.Number == number, ct))
            return Conflict(new { message = $"Ya registraste el comprobante {series}-{number} de ese proveedor." });

        purchase.IssueDate = r.IssueDate; purchase.Period = period; purchase.DocumentType = r.DocumentType; purchase.Series = series; purchase.Number = number;
        purchase.SupplierTaxId = supplierTaxId; purchase.SupplierName = r.SupplierName.Trim(); purchase.Currency = currency;
        purchase.TaxBase = r.TaxBase; purchase.Igv = r.Igv; purchase.NonTaxable = r.NonTaxable; purchase.Total = r.TaxBase + r.Igv + r.NonTaxable;
        purchase.ExchangeRate = await db.RateToPenAsync(currency, r.IssueDate, ct);
        purchase.BasePen = Math.Round(r.TaxBase * purchase.ExchangeRate, 2); purchase.IgvPen = Math.Round(r.Igv * purchase.ExchangeRate, 2); purchase.TotalPen = Math.Round(purchase.Total * purchase.ExchangeRate, 2);
        purchase.GivesTaxCredit = r.UsedForTaxedOperations && r.Igv > 0 && Purchase.AllowsTaxCredit(r.DocumentType);
        purchase.Notes = EmptyToNull(r.Notes);
        return null;
    }

    /// <summary>
    /// Crea o actualiza el gasto vinculado. Si la compra da crédito fiscal, el gasto es la base + inafecto (el IGV se
    /// recupera y no es costo); si no, el total. Una nota de crédito no genera gasto.
    /// </summary>
    private async Task<ActionResult?> LinkExpenseAsync(Purchase purchase, Guid? categoryId, CancellationToken ct)
    {
        if (purchase.DocumentType == PurchaseDocumentType.NotaCredito) return purchase.ExpenseId is null ? null : BadRequest(new { message = "Una nota de crédito no puede tener gasto vinculado." });
        var expense = purchase.ExpenseId is Guid id ? await db.Expenses.FindAsync([id], ct) : null;
        var category = categoryId ?? expense?.CategoryId ?? ExpenseCategoryIds.Otros;
        if (!await db.ExpenseCategories.AnyAsync(x => x.Id == category, ct)) return BadRequest(new { message = "Elige una categoría de gasto válida." });
        if (expense is null) { expense = new Expense { Type = ExpenseType.Variable }; db.Expenses.Add(expense); purchase.ExpenseId = expense.Id; }
        expense.Description = $"{purchase.SupplierName} · {(purchase.Series.Length > 0 ? purchase.Series + "-" : "")}{purchase.Number}";
        expense.CategoryId = category; expense.Currency = purchase.Currency; expense.Date = purchase.IssueDate;
        expense.Amount = purchase.GivesTaxCredit ? purchase.TaxBase + purchase.NonTaxable : purchase.Total;
        expense.AmountPen = Math.Round(expense.Amount * purchase.ExchangeRate, 2);
        return null;
    }

    private static decimal Signed(Purchase x, decimal amount) => x.DocumentType == PurchaseDocumentType.NotaCredito ? -amount : amount;

    /// <summary><c>igvWarning</c>: el IGV no es la tasa configurada sobre la base (aviso, no error: puede haber redondeos o tasas especiales).</summary>
    private static object PurchaseDto(Purchase x, decimal igvRate) => new
    {
        id = x.Id, issueDate = x.IssueDate, period = x.Period.ToString("yyyy-MM"), documentType = x.DocumentType.ToString(), series = x.Series, number = x.Number,
        supplierTaxId = x.SupplierTaxId, supplierName = x.SupplierName, currency = x.Currency, taxBase = x.TaxBase, igv = x.Igv, nonTaxable = x.NonTaxable, total = x.Total,
        exchangeRate = x.ExchangeRate, totalPen = x.TotalPen, igvPen = x.IgvPen, givesTaxCredit = x.GivesTaxCredit, taxCreditPen = x.TaxCreditPen, expenseId = x.ExpenseId, notes = x.Notes,
        igvWarning = x.Igv > 0 && Math.Abs(x.Igv - x.TaxBase * igvRate) > 1m,
    };

    [GeneratedRegex(@"^\d{11}$")]
    private static partial Regex RucRegex();
}

public sealed record PurchaseRequest(DateOnly IssueDate, string? Period, PurchaseDocumentType DocumentType, string? Series, string Number, string SupplierTaxId, string SupplierName,
    string Currency, decimal TaxBase, decimal Igv, decimal NonTaxable = 0, bool UsedForTaxedOperations = true, bool CreateExpense = false, Guid? ExpenseCategoryId = null, string? Notes = null);
ParseOptions.0.json�
GC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\AuthController.cs�using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;
namespace Rtres.Api.Controllers;
[ApiController, Route("api/auth")]
public sealed class AuthController(RtresDbContext db, JwtSettings jwt, IMemoryCache cache) : ControllerBase
{
    public const string LoginRateLimitPolicy = "login";
    // Además del límite por IP (Program.cs), bloquea una cuenta tras varios fallos seguidos desde cualquier IP.
    const int MaxFailedAttempts = 5;
    static readonly TimeSpan LockoutWindow = TimeSpan.FromMinutes(15);
    sealed class FailedLogins { public int Count; }
 [HttpPost("login"), EnableRateLimiting(LoginRateLimitPolicy)] public async Task<ActionResult> Login(LoginRequest request, CancellationToken ct) { var failKey="login-fail:"+request.Email.Trim().ToLowerInvariant(); if(cache.TryGetValue(failKey,out FailedLogins? fails)&&fails!.Count>=MaxFailedAttempts)return StatusCode(429,new{message="Demasiados intentos fallidos para esta cuenta. Inténtalo de nuevo en 15 minutos."}); var u=await db.UserAccounts.SingleOrDefaultAsync(x=>x.Email==request.Email&&x.IsActive,ct); if(u is null||new PasswordHasher<UserAccount>().VerifyHashedPassword(u,u.PasswordHash,request.Password)==PasswordVerificationResult.Failed){ var f=cache.GetOrCreate(failKey,e=>{e.AbsoluteExpirationRelativeToNow=LockoutWindow;return new FailedLogins();})!; Interlocked.Increment(ref f.Count); return Unauthorized(new {message="Credenciales inválidas."}); } cache.Remove(failKey); var c=u.ClientId is Guid clientId?await db.Clients.FindAsync([clientId],ct):null; if(c is not null&&!c.IsActive)return StatusCode(403,new{message="Este cliente está dado de baja. Contacta a Rtres."}); var claims=new List<Claim>{new(JwtRegisteredClaimNames.Sub,u.Id.ToString()),new(ClaimTypes.NameIdentifier,u.Id.ToString()),new(ClaimTypes.Role,u.Role.ToString())}; if(u.ClientId is Guid id)claims.Add(new Claim("client_id",id.ToString())); var token=new JwtSecurityToken(jwt.Issuer,jwt.Audience,claims,expires:DateTime.UtcNow.AddHours(8),signingCredentials:new SigningCredentials(jwt.SigningKey,SecurityAlgorithms.HmacSha256)); var initials=string.Concat(u.Name.Split(' ',StringSplitOptions.RemoveEmptyEntries).Take(2).Select(x=>x[0])).ToUpperInvariant(); return Ok(new {token=new JwtSecurityTokenHandler().WriteToken(token),user=new{name=u.Name,initials,clientName=c?.CompanyName,role=u.Role.ToString()}}); }
}
ParseOptions.0.json٤
PC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\BankTransfersController.cs�using System.Globalization;
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
ParseOptions.0.json�6
MC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\CategoriesController.cs�5using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>Categorías de gastos y de productos (Configuración). Una categoría en uso no se borra; renombrar no cambia a qué apuntan sus registros.</summary>
[ApiController, Authorize(Roles = "SuperAdmin"), Route("api/admin")]
public sealed class CategoriesController(RtresDbContext db) : ControllerBase
{
    [HttpGet("expense-categories")]
    public async Task<ActionResult> ExpenseCategories(CancellationToken ct) => Ok(await db.ExpenseCategories.OrderBy(x => x.SortOrder).ThenBy(x => x.Name)
        .Select(x => new CategoryDto(x.Id, x.Name, x.Code != null, x.IsIncomeTax, db.Expenses.Count(e => e.CategoryId == x.Id), x.IsDeductible && !x.IsIncomeTax)).ToListAsync(ct));

    /// <summary>Si los gastos de la categoría se restan en la Renta anual. Las de impuesto a la Renta nunca son deducibles.</summary>
    [HttpPatch("expense-categories/{id:guid}/deductible")]
    public async Task<ActionResult> SetExpenseCategoryDeductible(Guid id, CategoryDeductibleRequest request, CancellationToken ct)
    {
        var category = await db.ExpenseCategories.FindAsync([id], ct); if (category is null) return NotFound();
        if (category.IsIncomeTax && request.IsDeductible) return BadRequest(new { message = "Los pagos de Renta no son gasto deducible." });
        category.IsDeductible = request.IsDeductible; await db.SaveChangesAsync(ct); return NoContent();
    }

    [HttpPost("expense-categories")]
    public async Task<ActionResult> CreateExpenseCategory(CategoryRequest request, CancellationToken ct)
    {
        if (await ValidateNameAsync(request.Name, db.ExpenseCategories.Select(x => x.Name), ct) is { } error) return error;
        var category = new ExpenseCategory { Name = request.Name.Trim(), SortOrder = await db.ExpenseCategories.CountAsync(ct) };
        db.ExpenseCategories.Add(category); await db.SaveChangesAsync(ct);
        return Created($"/api/admin/expense-categories/{category.Id}", new CategoryDto(category.Id, category.Name, false, false, 0));
    }

    [HttpPatch("expense-categories/{id:guid}")]
    public async Task<ActionResult> RenameExpenseCategory(Guid id, CategoryRequest request, CancellationToken ct)
    {
        var category = await db.ExpenseCategories.FindAsync([id], ct); if (category is null) return NotFound();
        if (await ValidateNameAsync(request.Name, db.ExpenseCategories.Where(x => x.Id != id).Select(x => x.Name), ct) is { } error) return error;
        category.Name = request.Name.Trim(); await db.SaveChangesAsync(ct); return NoContent();
    }

    [HttpDelete("expense-categories/{id:guid}")]
    public async Task<ActionResult> DeleteExpenseCategory(Guid id, CancellationToken ct)
    {
        var category = await db.ExpenseCategories.FindAsync([id], ct); if (category is null) return NotFound();
        if (category.Code is not null) return Conflict(new { message = $"«{category.Name}» es una categoría del sistema: puedes renombrarla, pero no eliminarla." });
        var used = await db.Expenses.CountAsync(x => x.CategoryId == id, ct);
        if (used > 0) return Conflict(new { message = $"«{category.Name}» tiene {used} {(used == 1 ? "gasto" : "gastos")}: cámbialos de categoría antes de eliminarla." });
        db.ExpenseCategories.Remove(category); await db.SaveChangesAsync(ct); return NoContent();
    }

    [HttpGet("product-categories")]
    public async Task<ActionResult> ProductCategories(CancellationToken ct) => Ok(await db.ProductCategories.OrderBy(x => x.SortOrder).ThenBy(x => x.Name)
        .Select(x => new CategoryDto(x.Id, x.Name, false, false, db.Products.Count(p => p.Category == x.Name))).ToListAsync(ct));

    [HttpPost("product-categories")]
    public async Task<ActionResult> CreateProductCategory(CategoryRequest request, CancellationToken ct)
    {
        if (await ValidateNameAsync(request.Name, db.ProductCategories.Select(x => x.Name), ct) is { } error) return error;
        var category = new ProductCategory { Name = request.Name.Trim(), SortOrder = await db.ProductCategories.CountAsync(ct) };
        db.ProductCategories.Add(category); await db.SaveChangesAsync(ct);
        return Created($"/api/admin/product-categories/{category.Id}", new CategoryDto(category.Id, category.Name, false, false, 0));
    }

    /// <summary>El producto guarda el nombre de su categoría (lo usan la web y el catálogo): renombrar actualiza esos productos.</summary>
    [HttpPatch("product-categories/{id:guid}")]
    public async Task<ActionResult> RenameProductCategory(Guid id, CategoryRequest request, CancellationToken ct)
    {
        var category = await db.ProductCategories.FindAsync([id], ct); if (category is null) return NotFound();
        if (await ValidateNameAsync(request.Name, db.ProductCategories.Where(x => x.Id != id).Select(x => x.Name), ct) is { } error) return error;
        var name = request.Name.Trim();
        foreach (var product in await db.Products.Where(x => x.Category == category.Name).ToListAsync(ct)) product.Category = name;
        category.Name = name; await db.SaveChangesAsync(ct); return NoContent();
    }

    [HttpDelete("product-categories/{id:guid}")]
    public async Task<ActionResult> DeleteProductCategory(Guid id, CancellationToken ct)
    {
        var category = await db.ProductCategories.FindAsync([id], ct); if (category is null) return NotFound();
        var used = await db.Products.CountAsync(x => x.Category == category.Name, ct);
        if (used > 0) return Conflict(new { message = $"«{category.Name}» tiene {used} {(used == 1 ? "producto" : "productos")}: cámbialos de categoría antes de eliminarla." });
        db.ProductCategories.Remove(category); await db.SaveChangesAsync(ct); return NoContent();
    }

    private async Task<ActionResult?> ValidateNameAsync(string? name, IQueryable<string> others, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(name)) return BadRequest(new { message = "El nombre es obligatorio." });
        if (name.Trim().Length > 100) return BadRequest(new { message = "El nombre admite hasta 100 caracteres." });
        var folded = AdminController.Fold(name);
        if ((await others.ToListAsync(ct)).Any(x => AdminController.Fold(x) == folded)) return Conflict(new { message = $"Ya existe una categoría «{name.Trim()}»." });
        return null;
    }
}

public sealed record CategoryDto(Guid Id, string Name, bool IsSystem, bool IsIncomeTax, int UsageCount, bool IsDeductible = true);
public sealed record CategoryDeductibleRequest(bool IsDeductible);
public sealed record CategoryRequest(string Name);
ParseOptions.0.json�"
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\ContactController.cs�!using System.Net.Mail;
using Hangfire;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Notifications;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>
/// Formulario de contacto del sitio público: guarda el lead y avisa al equipo (email y campana) en segundo plano. Contra
/// bots: límite de envíos por IP y un campo trampa (<see cref="ContactRequest.Website"/>) que una persona no ve.
/// </summary>
[ApiController]
public sealed class ContactController(RtresDbContext db, IBackgroundJobClient jobs) : ControllerBase
{
    public const string RateLimitPolicy = "contact";
    public static readonly string[] Locales = ["es", "en", "it"];

    [HttpPost("api/public/contact"), EnableRateLimiting(RateLimitPolicy)]
    public async Task<ActionResult> Submit(ContactRequest request, CancellationToken ct)
    {
        // Un bot llena el campo oculto: se responde igual que a una persona, sin guardar ni avisar.
        if (!string.IsNullOrWhiteSpace(request.Website)) return Accepted();
        var name = request.Name?.Trim(); var email = request.Email?.Trim(); var message = request.Message?.Trim();
        if (string.IsNullOrEmpty(name) || name.Length > 150) return BadRequest(new { field = "name", message = "Indica tu nombre." });
        if (string.IsNullOrEmpty(email) || email.Length > 200 || !MailAddress.TryCreate(email, out _)) return BadRequest(new { field = "email", message = "Indica un email válido." });
        if (string.IsNullOrEmpty(message) || message.Length < 10 || message.Length > 4000) return BadRequest(new { field = "message", message = "Cuéntanos en unas líneas qué necesitas (10 a 4000 caracteres)." });
        var lead = new ContactLead
        {
            Name = name, Email = email, Message = message,
            Phone = Clip(request.Phone, 40), Company = Clip(request.Company, 150), Service = Clip(request.Service, 60),
            Locale = Locales.Contains(request.Locale) ? request.Locale! : "es", SourcePage = Clip(request.Page, 200),
        };
        db.ContactLeads.Add(lead); await db.SaveChangesAsync(ct);
        var data = new Dictionary<string, string> { ["leadId"] = lead.Id.ToString(), ["name"] = lead.Name, ["email"] = lead.Email, ["message"] = lead.Message, ["locale"] = lead.Locale };
        if (lead.Phone is not null) data["phone"] = lead.Phone;
        if (lead.Company is not null) data["company"] = lead.Company;
        if (lead.Service is not null) data["service"] = lead.Service;
        if (lead.SourcePage is not null) data["page"] = lead.SourcePage;
        jobs.Enqueue<StaffNotifier>(x => x.SendAsync(new Notification(NotificationType.ContactLead, data, $"contact-lead:{lead.Id}", null), CancellationToken.None));
        return Accepted();
    }

    [HttpGet("api/admin/leads"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Leads(ContactLeadStatus? status, CancellationToken ct) =>
        Ok(await db.ContactLeads.Where(x => status == null || x.Status == status).OrderByDescending(x => x.CreatedAt).Take(300).ToListAsync(ct));

    [HttpPatch("api/admin/leads/{id:guid}"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> UpdateLead(Guid id, ContactLeadPatch request, CancellationToken ct)
    {
        var lead = await db.ContactLeads.FindAsync([id], ct); if (lead is null) return NotFound();
        if (request.Status is ContactLeadStatus status) lead.Status = status;
        if (request.Notes is not null) lead.Notes = Clip(request.Notes, 1000);
        await db.SaveChangesAsync(ct); return Ok(lead);
    }

    private static string? Clip(string? value, int max) => string.IsNullOrWhiteSpace(value) ? null : value.Trim() is var v && v.Length > max ? v[..max] : value.Trim();
}

/// <summary><see cref="Website"/>: campo trampa oculto; si llega con valor, es un bot.</summary>
public sealed record ContactRequest(string? Name, string? Email, string? Phone, string? Company, string? Service, string? Message, string? Locale, string? Page, string? Website = null);
public sealed record ContactLeadPatch(ContactLeadStatus? Status, string? Notes);
ParseOptions.0.json�

PC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\GitHubWebhookController.cs�	using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Rtres.Api.GitHub;
using Rtres.Domain;

namespace Rtres.Api.Controllers;

[ApiController, Route("api/webhooks/github")]
public sealed class GitHubWebhookController(GitHubWebhookProcessor processor, IConfiguration configuration, ILogger<GitHubWebhookController> logger) : ControllerBase
{
    [HttpPost]
    public async Task<ActionResult> Receive(CancellationToken ct)
    {
        using var buffer = new MemoryStream();
        await Request.Body.CopyToAsync(buffer, ct);
        var body = buffer.ToArray();
        var secret = configuration["GitHub:WebhookSecret"] ?? string.Empty;
        if (!GitHubWebhookSignature.IsValid(secret, body, Request.Headers["X-Hub-Signature-256"]))
        {
            logger.LogWarning("Webhook de GitHub rechazado: firma inválida o GitHub:WebhookSecret sin configurar");
            return Unauthorized();
        }

        var eventName = Request.Headers["X-GitHub-Event"].ToString();
        if (eventName == "ping") return Ok();
        using var payload = JsonDocument.Parse(body);
        await processor.ProcessAsync(eventName, payload.RootElement, ct);
        return Ok();
    }
}
ParseOptions.0.json�.
QC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\LearningVideosController.cs�-using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>Videos de la página Recursos: el portal los administra y el sitio lee los publicados de su idioma.</summary>
[ApiController]
public sealed partial class LearningVideosController(RtresDbContext db) : ControllerBase
{
    [HttpGet("api/public/{locale}/videos")]
    public async Task<ActionResult> PublicVideos(string locale, CancellationToken ct)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        return Ok(await db.LearningVideos.Where(x => x.IsPublished && (x.Language == null || x.Language == locale))
            .OrderBy(x => x.SortOrder).ThenByDescending(x => x.CreatedAt)
            .Select(x => new PublicVideoDto(x.YoutubeId, x.Title, x.Category, x.Description)).ToListAsync(ct));
    }

    [HttpGet("api/admin/learning-videos"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> List(CancellationToken ct) =>
        Ok(await db.LearningVideos.OrderBy(x => x.SortOrder).ThenByDescending(x => x.CreatedAt).Select(x => ToDto(x)).ToListAsync(ct));

    [HttpPost("api/admin/learning-videos"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Create(LearningVideoRequest request, CancellationToken ct)
    {
        var video = new LearningVideo { SortOrder = await db.LearningVideos.CountAsync(ct) };
        if (Apply(video, request) is { } error) return BadRequest(new { message = error });
        if (await db.LearningVideos.AnyAsync(x => x.YoutubeId == video.YoutubeId, ct)) return Conflict(new { message = "Ese video ya está en la lista." });
        db.LearningVideos.Add(video); await db.SaveChangesAsync(ct);
        return Created($"/api/admin/learning-videos/{video.Id}", ToDto(video));
    }

    [HttpPut("api/admin/learning-videos/{id:guid}"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Update(Guid id, LearningVideoRequest request, CancellationToken ct)
    {
        var video = await db.LearningVideos.FindAsync([id], ct); if (video is null) return NotFound();
        if (Apply(video, request) is { } error) return BadRequest(new { message = error });
        if (await db.LearningVideos.AnyAsync(x => x.Id != id && x.YoutubeId == video.YoutubeId, ct)) return Conflict(new { message = "Ese video ya está en la lista." });
        await db.SaveChangesAsync(ct); return Ok(ToDto(video));
    }

    [HttpDelete("api/admin/learning-videos/{id:guid}"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Delete(Guid id, CancellationToken ct)
    {
        var video = await db.LearningVideos.FindAsync([id], ct); if (video is null) return NotFound();
        db.LearningVideos.Remove(video); await db.SaveChangesAsync(ct); return NoContent();
    }

    /// <summary>Nuevo orden de la lista: los ids en el orden en que deben mostrarse.</summary>
    [HttpPost("api/admin/learning-videos/reorder"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Reorder(IReadOnlyList<Guid> ids, CancellationToken ct)
    {
        var videos = await db.LearningVideos.ToListAsync(ct);
        foreach (var v in videos) v.SortOrder = ids.Contains(v.Id) ? ids.ToList().IndexOf(v.Id) : ids.Count + v.SortOrder;
        await db.SaveChangesAsync(ct); return NoContent();
    }

    private static string? Apply(LearningVideo video, LearningVideoRequest r)
    {
        if (ParseYoutubeId(r.Url) is not { } youtubeId) return "Pega el enlace de un video de YouTube (ej. https://www.youtube.com/watch?v=…).";
        if (string.IsNullOrWhiteSpace(r.Title)) return "El título es obligatorio.";
        if (string.IsNullOrWhiteSpace(r.Category)) return "La categoría es obligatoria.";
        var language = string.IsNullOrWhiteSpace(r.Language) ? null : r.Language.Trim().ToLowerInvariant();
        if (language is not (null or "es" or "en" or "it")) return "Idioma inválido: es, en, it o vacío para todos.";
        video.YoutubeId = youtubeId; video.Title = r.Title.Trim(); video.Category = r.Category.Trim(); video.Language = language;
        video.Description = string.IsNullOrWhiteSpace(r.Description) ? null : r.Description.Trim(); video.IsPublished = r.IsPublished;
        return null;
    }

    /// <summary>Acepta youtube.com/watch?v=, youtu.be/, /embed/, /shorts/, /live/ o el id de 11 caracteres solo.</summary>
    public static string? ParseYoutubeId(string? input)
    {
        if (string.IsNullOrWhiteSpace(input)) return null;
        var value = input.Trim();
        if (YoutubeIdRegex().IsMatch(value)) return value;
        var match = YoutubeUrlRegex().Match(value);
        return match.Success ? match.Groups["id"].Value : null;
    }

    [GeneratedRegex("^[A-Za-z0-9_-]{11}$")]
    private static partial Regex YoutubeIdRegex();

    [GeneratedRegex(@"^(?:https?://)?(?:www\.|m\.|music\.)?(?:youtube\.com/(?:watch\?(?:.*&)?v=|embed/|shorts/|live/)|youtu\.be/)(?<id>[A-Za-z0-9_-]{11})(?:[?&#/].*)?$", RegexOptions.IgnoreCase)]
    private static partial Regex YoutubeUrlRegex();

    private static LearningVideoDto ToDto(LearningVideo x) => new(x.Id, x.YoutubeId, x.Title, x.Category, x.Language, x.Description, x.SortOrder, x.IsPublished);
}

public sealed record LearningVideoRequest(string Url, string Title, string Category, string? Language, string? Description, bool IsPublished = true);
public sealed record LearningVideoDto(Guid Id, string YoutubeId, string Title, string Category, string? Language, string? Description, int SortOrder, bool IsPublished);
public sealed record PublicVideoDto(string YoutubeId, string Title, string Category, string? Description);
ParseOptions.0.jsonރ
KC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\PaymentsController.cs��using System.Globalization;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

[ApiController, Route("api")]
public sealed class PaymentsController(RtresDbContext db, IPayPalClient payPal, PayPalCheckoutService checkoutService, PayPalPaymentService payments, BankTransferService transfers, INotificationSender notifications, IConfiguration configuration, ILogger<PaymentsController> logger) : ControllerBase
{
    /// <summary>Días antes del vencimiento en que se puede pagar la renovación (igual que el primer recordatorio por email).</summary>
    public const int RenewalWindowDays = 30;

    private IActionResult? ClientScope(Guid? requested, out Guid clientId)
    {
        clientId = Guid.Empty;
        if (User.IsInRole(nameof(UserRole.SuperAdmin))) { if (requested is not Guid value) return BadRequest(new { message = "clientId es obligatorio para SuperAdmin." }); clientId = value; return null; }
        return Guid.TryParse(User.FindFirstValue("client_id"), out clientId) ? null : Forbid();
    }

    [Authorize, HttpGet("catalog/products")]
    public async Task<IActionResult> Catalog(CancellationToken ct)
    {
        // Precios sin IGV; igvRate indica si a este cliente se le suma (Perú + Factura) para mostrar "+ IGV".
        var client = Guid.TryParse(User.FindFirstValue("client_id"), out var clientId) ? await db.Clients.SingleOrDefaultAsync(x => x.Id == clientId, ct) : null;
        var igvRate = await db.IgvRateAsync(ct);
        var products = await db.Products.Where(x => x.IsActive).OrderBy(x => x.Name).ToListAsync(ct);
        return Ok(products.Select(x => new { id = x.Id, type = x.Type, name = x.Name, billingCycle = x.BillingCycle, basePrice = x.BasePrice, currency = x.Currency, description = x.Description, category = x.Category, tags = x.Tags, allowsTickets = x.AllowsTickets, isActive = x.IsActive, igvRate = client is null ? 0m : ClientProductPricing.IgvRateFor(client, x, igvRate) }));
    }

    [Authorize(Roles = "Cliente,Admin"), HttpPost("subscriptions")]
    public async Task<IActionResult> Subscribe(SubscribeRequest request, CancellationToken ct)
    {
        var scope = ClientScope(null, out var clientId); if (scope is not null) return scope;
        var product = await db.Products.SingleOrDefaultAsync(x => x.Id == request.ProductId && x.IsActive, ct);
        if (product is null) return NotFound();
        var projectId = request.ProjectId;
        if (projectId is null) projectId = (await NewProjectAsync(clientId, product.Name, ct)).Id;
        else if (!await db.Projects.AnyAsync(x => x.Id == projectId && x.ClientId == clientId, ct)) return NotFound();
        if (request.BillingCycle != product.BillingCycle) return BadRequest(new { message = "El ciclo debe coincidir con el producto seleccionado." });
        if (request.PaymentMethod is not (PaymentMethods.PayPal or PaymentMethods.Transferencia)) return BadRequest(new { message = "Método de pago inválido." });
        var transfer = request.PaymentMethod == PaymentMethods.Transferencia;
        var settings = await transfers.SettingsAsync(ct);
        if (transfer ? !settings.BankTransferEnabled : !settings.PayPalEnabled) return BadRequest(new { message = transfer ? "El pago por transferencia no está disponible por ahora." : "El pago con PayPal no está disponible por ahora." });
        var item = new ClientProduct { ClientId = clientId, ProjectId = projectId.Value, ProductId = product.Id, Product = product, BillingCycle = request.BillingCycle, Status = ClientProductStatus.Pendiente, Price = product.BasePrice, IsManualBilling = transfer };
        if (item.ValidateYears(request.Years) is string yearsError) return BadRequest(new { message = yearsError });
        db.ClientProducts.Add(item);
        var igvRate = await db.IgvRateForAsync(clientId, product, ct);
        // Transferencia: queda Pendiente hasta que Rtres registre el pago (Detalle del cliente → Registrar pago).
        if (transfer)
        {
            await db.SaveChangesAsync(ct);
            await NotifyTransferRequestAsync(item, product, igvRate, request.Years, ct);
            return Ok(new { clientProductId = item.Id, approvalUrl = (string?)null, bankTransfer = await transfers.InfoAsync(item, igvRate, request.Years, ct) });
        }
        try { var checkout = await checkoutService.StartAsync(item, product, Request, ct, igvRate, request.Years); await db.SaveChangesAsync(ct); return Ok(new { clientProductId = item.Id, approvalUrl = checkout.ApprovalUrl }); } catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
    }

    /// <summary>
    /// Proyecto creado al contratar sin elegir uno: se llama como el producto. El slug es único en todo el portal, así que
    /// lleva la empresa y, si ya existe, un número.
    /// </summary>
    private async Task<Project> NewProjectAsync(Guid clientId, string productName, CancellationToken ct)
    {
        var company = await db.Clients.Where(x => x.Id == clientId).Select(x => x.CompanyName).SingleAsync(ct);
        var baseSlug = AdminController.Slugify($"{company} {productName}");
        if (baseSlug.Length == 0) baseSlug = "proyecto";
        var slug = baseSlug;
        for (var n = 2; await db.Projects.AnyAsync(x => x.Slug == slug, ct); n++) slug = $"{baseSlug}-{n}";
        var project = new Project { ClientId = clientId, Name = productName, Slug = slug };
        db.Projects.Add(project);
        return project;
    }

    /// <summary>Datos para pagar por transferencia (cuentas bancarias activas) y el monto a transferir por <paramref name="years"/> años.</summary>
    [Authorize, HttpGet("client-products/{id:guid}/bank-transfer")]
    public async Task<IActionResult> BankTransfer(Guid id, Guid? clientId, CancellationToken ct, int years = 1)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct);
        if (item?.Product is null) return NotFound();
        if (item.ValidateYears(years) is string yearsError) return BadRequest(new { message = yearsError });
        return Ok(await transfers.InfoAsync(item, await db.IgvRateForAsync(owner, item.Product, ct), years, ct));
    }

    /// <summary>
    /// Avisa a Rtres (<c>Notifications:StaffEmail</c>, o el remitente <c>Smtp:From</c> si no está) que hay un pedido por
    /// transferencia esperando el pago. Va por la cola como el resto de avisos: un SMTP caído no frena el pedido.
    /// </summary>
    private async Task NotifyTransferRequestAsync(ClientProduct item, Product product, decimal igvRate, int years, CancellationToken ct)
    {
        var staffEmail = configuration["Notifications:StaffEmail"] is { Length: > 0 } configured ? configured : configuration["Smtp:From"];
        if (string.IsNullOrWhiteSpace(staffEmail)) { logger.LogWarning("Pedido por transferencia {ClientProductId} sin aviso: falta Notifications:StaffEmail", item.Id); return; }
        var client = await db.Clients.SingleAsync(x => x.Id == item.ClientId, ct);
        var project = await db.Projects.Where(x => x.Id == item.ProjectId).Select(x => x.Name).SingleAsync(ct);
        var data = new Dictionary<string, string> { ["clientId"] = client.Id.ToString(), ["company"] = client.CompanyName, ["product"] = years > 1 ? $"{product.Name} ({years} años)" : product.Name, ["project"] = project, ["currency"] = product.Currency };
        if (item.ChargeTotal(igvRate, years) is decimal amount) data["amount"] = amount.ToString(CultureInfo.InvariantCulture);
        await notifications.SendAsync(client, new Notification(NotificationType.TransferRequested, data, $"transfer-request:{item.Id}", staffEmail), ct);
    }

    [Authorize(Roles = "Cliente,Admin"), HttpPost("client-products/{id:guid}/renew")]
    public async Task<IActionResult> Renew(Guid id, Guid? clientId, CancellationToken ct, int years = 1)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct);
        if (item?.Product is null) return NotFound();
        // Renovar (Anual por vencer o vencido; el pago único no se renueva) o reintentar un pago que quedó a medias (Pendiente, cualquier ciclo).
        var renewable = item.BillingCycle == BillingCycle.Anual && (item.Status is ClientProductStatus.PorVencer or ClientProductStatus.Vencido || item.RenewsAt <= DateTime.UtcNow.AddDays(RenewalWindowDays));
        if (item.IsManualBilling || !(renewable || item.Status == ClientProductStatus.Pendiente)) return BadRequest(new { message = "Este producto no se puede renovar en línea." });
        if (!(await transfers.SettingsAsync(ct)).PayPalEnabled) return BadRequest(new { message = "El pago con PayPal no está disponible por ahora." });
        try { var checkout = await checkoutService.StartAsync(item, item.Product, Request, ct, await db.IgvRateForAsync(owner, item.Product, ct), years); await db.SaveChangesAsync(ct); return Ok(new { approvalUrl = checkout.ApprovalUrl }); } catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
    }

    [Authorize(Roles = "Cliente,Admin"), HttpPost("client-products/{id:guid}/cancel")]
    public async Task<IActionResult> Cancel(Guid id, Guid? clientId, CancellationToken ct)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct);
        if (item is null) return NotFound();
        if (item.IsManualBilling || item.Status != ClientProductStatus.Activo || !item.BillingCycle.IsSubscription() || string.IsNullOrWhiteSpace(item.PayPalSubscriptionId)) return BadRequest(new { message = "Este producto no tiene una suscripción cancelable." });
        await payPal.CancelSubscriptionAsync(item.PayPalSubscriptionId, "Cancelada por el cliente desde el portal Rtres.", ct); item.Status = ClientProductStatus.Cancelado; await db.SaveChangesAsync(ct); return Ok();
    }

    /// <summary>La llama la pantalla de retorno de PayPal: captura el cobro sin esperar al webhook (idempotente con él).</summary>
    [Authorize(Roles = "Cliente,Admin"), HttpPost("client-products/{id:guid}/capture")]
    public async Task<IActionResult> Capture(Guid id, Guid? clientId, CancellationToken ct)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct);
        if (item is null) return NotFound();
        try { await payments.ConfirmAsync(item, ct); }
        catch (HttpRequestException ex) { logger.LogWarning(ex, "Captura de {ClientProductId} fallida; queda a la espera del webhook", id); }
        return Ok(new { status = item.Status.ToString() });
    }

    [Authorize(Roles = "Cliente,Admin"), HttpGet("client-products/{id:guid}")]
    public async Task<IActionResult> ClientProduct(Guid id, Guid? clientId, CancellationToken ct)
    {
        var scope = ClientScope(clientId, out var owner); if (scope is not null) return scope;
        var item = await db.ClientProducts.Include(x => x.Product).Include(x => x.Project).SingleOrDefaultAsync(x => x.Id == id && x.ClientId == owner, ct); return item is null ? NotFound() : Ok(item);
    }

    [HttpPost("payments/webhooks/paypal")]
    public async Task<IActionResult> Webhook(CancellationToken ct)
    {
        using var reader = new StreamReader(Request.Body); var payload = await reader.ReadToEndAsync(ct); var headers = Request.Headers.ToDictionary(x => x.Key.ToLowerInvariant(), x => x.Value.ToString());
        if (!await payPal.VerifyWebhookAsync(payload, headers, ct)) return Unauthorized();
        using var json = JsonDocument.Parse(payload); var root = json.RootElement; var eventType = Find(root, "event_type"); if (!root.TryGetProperty("resource", out var resource)) return Ok();
        var resourceId = Find(resource, "id"); var orderId = Nested(resource, "supplementary_data", "related_ids", "order_id") ?? resourceId; var customId = Find(resource, "custom_id") ?? Find(resource, "custom") ?? Find(root, "custom_id") ?? PurchaseUnit(resource, "custom_id");
        // En los cobros de una suscripción, el recurso es la venta y la suscripción viene en billing_agreement_id.
        var subscriptionId = Find(resource, "billing_agreement_id") ?? resourceId;
        ClientProduct? item = Guid.TryParse(customId, out var customGuid) ? await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == customGuid, ct) : null;
        item ??= !string.IsNullOrWhiteSpace(orderId) ? await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.PayPalSubscriptionId == subscriptionId || x.PayPalOrderId == orderId, ct) : null;
        if (item is null) return Ok();
        if (eventType is "BILLING.SUBSCRIPTION.ACTIVATED" or "BILLING.SUBSCRIPTION.CANCELLED") { item.Status = eventType.EndsWith("ACTIVATED") ? ClientProductStatus.Activo : ClientProductStatus.Cancelado; item.PayPalSubscriptionId ??= resourceId; }
        // Aprobar no es cobrar: con la orden aprobada se captura aquí (idempotente con la captura de la pantalla de retorno).
        if (eventType is "CHECKOUT.ORDER.APPROVED") { item.PayPalOrderId ??= orderId; await db.SaveChangesAsync(ct); await payments.CaptureAsync(item, ct); }
        // Cobro confirmado: el pago se aplica una sola vez por orden (o por venta, en suscripciones).
        if (eventType is "PAYMENT.CAPTURE.COMPLETED" or "PAYMENT.SALE.COMPLETED" && Amount(resource) is (decimal amount, var currency) && orderId is not null)
            await payments.ApplyPaymentAsync(item, orderId, amount, currency, ct);
        Notification? failure = null;
        if (eventType is "PAYMENT.CAPTURE.DENIED" or "PAYMENT.SALE.DENIED" or "BILLING.SUBSCRIPTION.PAYMENT.FAILED")
            failure = new Notification(NotificationType.PaymentFailed, new() { ["product"] = item.Product?.Name ?? "" }, $"payment-failed:{Find(root, "id") ?? resourceId}");
        await db.SaveChangesAsync(ct);
        if (failure is not null && await db.Clients.FindAsync([item.ClientId], ct) is Client client) await notifications.SendAsync(client, failure, ct);
        return Ok();
    }

    private static string? Find(JsonElement value, string property) => value.TryGetProperty(property, out var item) && item.ValueKind == JsonValueKind.String ? item.GetString() : null;
    private static string? Nested(JsonElement value, params string[] path) { foreach (var property in path) { if (!value.TryGetProperty(property, out value)) return null; } return value.ValueKind == JsonValueKind.String ? value.GetString() : null; }
    private static string? PurchaseUnit(JsonElement resource, string property) => resource.TryGetProperty("purchase_units", out var units) && units.ValueKind == JsonValueKind.Array && units.GetArrayLength() > 0 ? Find(units[0], property) : null;
    private static (decimal? amount, string? currency) Amount(JsonElement resource)
    {
        // Órdenes/capturas: amount.value + currency_code. Ventas de suscripción (PAYMENT.SALE.*): amount.total + currency.
        foreach (var name in new[] { "amount", "gross_amount" }) if (resource.TryGetProperty(name, out var value) && (value.TryGetProperty("value", out var amount) || value.TryGetProperty("total", out amount)) && decimal.TryParse(amount.GetString(), System.Globalization.NumberStyles.Number, System.Globalization.CultureInfo.InvariantCulture, out var parsed)) return (parsed, Find(value, "currency_code") ?? Find(value, "currency"));
        if (resource.TryGetProperty("purchase_units", out var units) && units.ValueKind == JsonValueKind.Array && units.GetArrayLength() > 0) return Amount(units[0]);
        return (null, null);
    }
}

/// <summary><see cref="ProjectId"/> null: se crea un proyecto con el nombre del producto (clientes sin proyectos).</summary>
public sealed record SubscribeRequest(Guid ProductId, Guid? ProjectId, BillingCycle BillingCycle, string PaymentMethod = PaymentMethods.PayPal, int Years = 1);
ParseOptions.0.json�m
IC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\PortalController.cs�lusing System.Text.Json;
using System.Security.Claims;
using Hangfire;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Jobs;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

[ApiController, Authorize, Route("api")]
public sealed class PortalController(RtresDbContext db, IBackgroundJobClient jobs, INotificationSender notifications, IConfiguration configuration, ILogger<PortalController> logger, BankTransferService transfers) : ControllerBase
{
    private Guid UserId => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    private bool IsSuperAdmin => User.IsInRole(nameof(UserRole.SuperAdmin));
    private IActionResult? ResolveClientId(Guid? clientId, out Guid value)
    {
        value = Guid.Empty;
        if (IsSuperAdmin)
        {
            if (clientId is not Guid requested) return BadRequest(new { message = "clientId es obligatorio para SuperAdmin." });
            value = requested;
            return null;
        }
        var claim = User.FindFirstValue("client_id");
        if (!Guid.TryParse(claim, out value)) return Forbid();
        return null;
    }

    [HttpGet("dashboard/summary")]
    public async Task<IActionResult> Summary(Guid? clientId, CancellationToken ct)
    {
        var error = ResolveClientId(clientId, out var id); if (error is not null) return error;
        var p = db.ClientProducts.Where(x => x.ClientId == id);
        var next = await p.Include(x => x.Product).Where(x => x.NextChargeAt != null).OrderBy(x => x.NextChargeAt).FirstOrDefaultAsync(ct);
        var nextPaymentAmount = next?.Product is null ? null : next.NextChargeTotal(await db.IgvRateForAsync(id, next.Product, ct));
        return Ok(new { activeProducts = await p.CountAsync(x => x.Status == ClientProductStatus.Activo, ct), expiringSoon = await p.CountAsync(x => x.Status == ClientProductStatus.PorVencer, ct), openTickets = await db.Tickets.CountAsync(x => x.ClientId == id && (x.Status == TicketStatus.Abierto || x.Status == TicketStatus.EnProgreso), ct), nextPaymentAmount });
    }
    [HttpGet("client-products")]
    public async Task<IActionResult> Products(Guid? clientId, CancellationToken ct)
    {
        var error = ResolveClientId(clientId, out var id); if (error is not null) return error;
        var items = await db.ClientProducts.Include(x => x.Product).Include(x => x.Project).Where(x => x.ClientId == id).ToListAsync(ct);
        // Precios sin IGV: se indica cuánto IGV se suma a cada producto para que el portal muestre "+ IGV".
        var client = await db.Clients.SingleOrDefaultAsync(x => x.Id == id, ct); var igvRate = await db.IgvRateAsync(ct);
        var reports = await transfers.LatestReportsAsync(items.Select(x => x.Id), ct);
        foreach (var item in items)
        {
            item.AppliedIgvRate = client is null || item.Product is null ? 0m : ClientProductPricing.IgvRateFor(client, item.Product, igvRate);
            // Solo interesa en la tarjeta mientras se revisa o si se rechazó; un pago aprobado ya se ve en el estado del producto.
            item.TransferReport = reports.TryGetValue(item.Id, out var report) && report.Status != TransferReportStatus.Aprobado ? report : null;
        }
        return Ok(items);
    }
    [HttpGet("projects")] public async Task<IActionResult> Projects(Guid? clientId, CancellationToken ct) { var error = ResolveClientId(clientId, out var id); if (error is not null) return error; var projects = await db.Projects.Include(x => x.Repositories).Where(x => x.ClientId == id).ToListAsync(ct); foreach (var p in projects) p.Repositories = [.. p.Repositories.OrderByDescending(r => r.IsDefault).ThenBy(r => r.Name)]; return Ok(projects); }
    [HttpGet("tickets")] public async Task<IActionResult> Tickets(Guid? clientId, TicketStatus? status = null, TicketType? type = null, int page = 1, CancellationToken ct = default) { var error = ResolveClientId(clientId, out var id); if (error is not null) return error; page = Math.Max(page, 1); var q = db.Tickets.Where(x => x.ClientId == id && (status == null || x.Status == status) && (type == null || x.Type == type)).OrderByDescending(x => x.UpdatedAt); var n = await q.CountAsync(ct); return Ok(new { items = await q.Skip((page - 1) * 20).Take(20).ToListAsync(ct), page, totalPages = (int)Math.Ceiling(n / 20d) }); }
    [HttpGet("tickets/{id:guid}")]
    public async Task<IActionResult> Ticket(Guid id, Guid? clientId, CancellationToken ct)
    {
        // SuperAdmin sin cliente seleccionado: abre cualquier ticket desde la bandeja de atención.
        var anyClient = IsSuperAdmin && clientId is null; var client = Guid.Empty;
        if (!anyClient && ResolveClientId(clientId, out client) is { } error) return error;
        var t = await db.Tickets.SingleOrDefaultAsync(x => x.Id == id && (anyClient || x.ClientId == client), ct); if (t is null) return NotFound();
        var project = await db.Projects.Include(x => x.Repositories).Where(x => x.Id == t.ProjectId).SingleAsync(ct);
        // El componente solo aporta si el proyecto tiene varios repos; con uno es siempre el mismo.
        var component = project.Repositories.Count > 1 ? project.Repositories.RepositoryFor(t.RepositoryId) is { } r ? r.Label ?? r.Name : null : null;
        var createdBy = await db.UserAccounts.Where(x => x.Id == t.CreatedByUserId).Select(x => x.Name == "" ? x.Email : x.Name).SingleOrDefaultAsync(ct);
        var attachments = await db.TicketAttachments.Where(x => x.TicketId == id).OrderBy(x => x.CreatedAt).Select(x => new TicketAttachmentDto(x.Id, x.FileName, x.ContentType, x.SizeBytes)).ToListAsync(ct);
        var comments = await ToCommentDtos(db, db.TicketComments.Where(x => x.TicketId == id).OrderBy(x => x.CreatedAt)).ToListAsync(ct);
        return Ok(new { ticket = t, projectName = project.Name, componentName = component, createdByName = createdBy, attachments, comments });
    }

    [HttpGet("tickets/{id:guid}/attachments/{attachmentId:guid}")]
    public async Task<IActionResult> Attachment(Guid id, Guid attachmentId, Guid? clientId, CancellationToken ct)
    {
        var anyClient = IsSuperAdmin && clientId is null; var client = Guid.Empty;
        if (!anyClient && ResolveClientId(clientId, out client) is { } error) return error;
        var a = await db.TicketAttachments.SingleOrDefaultAsync(x => x.Id == attachmentId && x.TicketId == id && db.Tickets.Any(t => t.Id == id && (anyClient || t.ClientId == client)), ct);
        return a is null ? NotFound() : File(a.Content, a.ContentType, a.FileName);
    }
    [HttpPost("tickets/{id:guid}/comments")]
    public async Task<IActionResult> AddComment(Guid id, CreateTicketCommentRequest r, CancellationToken ct)
    {
        if (IsSuperAdmin) return Forbid();
        var error = ResolveClientId(null, out var client); if (error is not null) return error;
        if (string.IsNullOrWhiteSpace(r.Body)) return BadRequest(new { message = "El comentario no puede estar vacío." });
        var ticket = await db.Tickets.SingleOrDefaultAsync(x => x.Id == id && x.ClientId == client, ct); if (ticket is null) return NotFound();
        var comment = new TicketComment { TicketId = id, AuthorUserId = UserId, Body = r.Body.Trim() };
        db.TicketComments.Add(comment); ticket.UpdatedAt = DateTime.UtcNow; await db.SaveChangesAsync(ct);
        jobs.Enqueue<GitHubIssueSyncJob>(j => j.PostCommentAsync(comment.Id, CancellationToken.None));
        return Ok(await ToCommentDtos(db, db.TicketComments.Where(x => x.Id == comment.Id)).SingleAsync(ct));
    }
    // Filtrar siempre antes de proyectar: SQL Server no traduce filtros sobre el DTO construido por constructor.
    internal static IQueryable<TicketCommentDto> ToCommentDtos(RtresDbContext db, IQueryable<TicketComment> comments) => comments
        .Select(x => new TicketCommentDto(x.Id, x.Body, x.FromGithub, x.FromGithub ? x.GithubAuthorLogin : db.UserAccounts.Where(u => u.Id == x.AuthorUserId).Select(u => u.Role == UserRole.SuperAdmin ? "Rtres" : u.Name == "" ? u.Email : u.Name).FirstOrDefault(), x.CreatedAt));
    public const int MaxAttachments = 5;
    public const long MaxAttachmentBytes = 10 * 1024 * 1024;

    /// <summary>Multipart: los campos del ticket y los adjuntos (<c>files</c>) llegan juntos, así el job de GitHub ya los tiene al crear el issue.</summary>
    [HttpPost("tickets"), RequestSizeLimit(60_000_000), RequestFormLimits(MultipartBodyLengthLimit = 60_000_000)]
    public async Task<IActionResult> CreateTicket([FromForm] CreateTicketRequest r, Guid? clientId, CancellationToken ct, [FromForm] List<IFormFile>? files = null)
    {
        var error = ResolveClientId(clientId, out var clientIdValue); if (error is not null) return error;
        files ??= [];
        if (files.Count > MaxAttachments) return BadRequest(new { message = $"Máximo {MaxAttachments} adjuntos por ticket." });
        if (files.FirstOrDefault(x => x.Length == 0 || x.Length > MaxAttachmentBytes) is { } invalid) return BadRequest(new { message = $"«{invalid.FileName}» está vacío o pesa más de 10 MB." });
        var project = await db.Projects.Include(x => x.Repositories).SingleOrDefaultAsync(x => x.Id == r.ProjectId && x.ClientId == clientIdValue, ct); if (project is null) return NotFound();
        if (r.RepositoryId is Guid repositoryId && project.Repositories.All(x => x.Id != repositoryId)) return BadRequest(new { message = "El repositorio no pertenece al proyecto." });
        if (r.ClientProductId is Guid clientProductId && !await db.ClientProducts.AnyAsync(x => x.Id == clientProductId && x.ClientId == clientIdValue && x.ProjectId == r.ProjectId && x.Product!.AllowsTickets, ct))
            return BadRequest(new { message = "Ese producto no admite tickets." });
        var ticket = new Ticket { Code = $"RT-{101 + await db.Tickets.CountAsync(ct)}", ClientId = clientIdValue, ProjectId = r.ProjectId, RepositoryId = r.RepositoryId, ClientProductId = r.ClientProductId, CreatedByUserId = UserId, Type = r.Type, Title = r.Title, Description = r.Description, CurrentBehavior = r.CurrentBehavior, ExpectedBehavior = r.ExpectedBehavior, StepsToReproduce = r.StepsToReproduce, Environment = r.Environment, AcceptanceCriteria = r.AcceptanceCriteria, EstimatedImpact = r.EstimatedImpact };
        db.Tickets.Add(ticket);
        foreach (var file in files)
        {
            using var stream = new MemoryStream(); await file.CopyToAsync(stream, ct);
            db.TicketAttachments.Add(new TicketAttachment { TicketId = ticket.Id, FileName = Path.GetFileName(file.FileName), ContentType = string.IsNullOrWhiteSpace(file.ContentType) ? "application/octet-stream" : file.ContentType, SizeBytes = file.Length, Content = stream.ToArray() });
        }
        await db.SaveChangesAsync(ct);
        jobs.Enqueue<GitHubIssueSyncJob>(j => j.CreateIssueAsync(ticket.Id, CancellationToken.None));
        if (project.Repositories.Count == 0) await NotifyPortalTicketAsync(ticket, project, ct);
        return Created($"/api/tickets/{ticket.Id}", ticket);
    }
    /// <summary>
    /// Últimos avisos de la campana y cuántos no leyó el usuario. El cliente ve los suyos; SuperAdmin, los del cliente que
    /// está viendo o, sin cliente seleccionado, todos (incluidos los internos: ticket nuevo, pedido por transferencia).
    /// </summary>
    [HttpGet("notifications")]
    public async Task<IActionResult> Notifications(Guid? clientId, CancellationToken ct)
    {
        var query = db.PortalNotifications.AsQueryable();
        if (!(IsSuperAdmin && clientId is null))
        {
            var error = ResolveClientId(clientId, out var id); if (error is not null) return error;
            query = query.Where(x => x.ClientId == id && !x.ForStaff);
        }
        var seenAt = await db.UserAccounts.Where(x => x.Id == UserId).Select(x => x.NotificationsSeenAt).SingleOrDefaultAsync(ct);
        var unread = await query.CountAsync(x => seenAt == null || x.CreatedAt > seenAt, ct);
        var rows = await query.OrderByDescending(x => x.CreatedAt).Take(20)
            .Select(x => new { x.Id, x.ClientId, x.Type, x.ForStaff, x.DataJson, x.CreatedAt, Company = db.Clients.Where(c => c.Id == x.ClientId).Select(c => c.CompanyName).FirstOrDefault() })
            .ToListAsync(ct);
        var items = rows.Select(x => new { id = x.Id, clientId = x.ClientId, company = x.Company, type = x.Type, forStaff = x.ForStaff, createdAt = x.CreatedAt, unread = seenAt == null || x.CreatedAt > seenAt, data = JsonSerializer.Deserialize<Dictionary<string, string>>(x.DataJson) ?? [] });
        return Ok(new { items, unread });
    }

    [HttpPost("notifications/seen")]
    public async Task<IActionResult> NotificationsSeen(CancellationToken ct)
    {
        var user = await db.UserAccounts.SingleOrDefaultAsync(x => x.Id == UserId, ct); if (user is null) return NotFound();
        user.NotificationsSeenAt = DateTime.UtcNow; await db.SaveChangesAsync(ct); return NoContent();
    }

    private async Task NotifyPortalTicketAsync(Ticket ticket, Project project, CancellationToken ct)
    {
        var staffEmail = configuration["Notifications:StaffEmail"] is { Length: > 0 } configured ? configured : configuration["Smtp:From"];
        if (string.IsNullOrWhiteSpace(staffEmail)) { logger.LogWarning("Ticket {Code} sin aviso interno: falta Notifications:StaffEmail", ticket.Code); return; }
        var client = await db.Clients.SingleAsync(x => x.Id == ticket.ClientId, ct);
        await notifications.SendAsync(client, new Notification(NotificationType.TicketCreated, new() { ["ticketId"] = ticket.Id.ToString(), ["code"] = ticket.Code, ["title"] = ticket.Title, ["company"] = client.CompanyName, ["project"] = project.Name, ["body"] = ticket.Description }, $"ticket-created:{ticket.Id}", staffEmail), ct);
    }
}
ParseOptions.0.json�"
PC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\PublicContentController.cs�!using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

[ApiController, Route("api/public")]
public sealed class PublicContentController(IWordPressContentClient content, RtresDbContext db) : ControllerBase
{
    [HttpGet("{locale}/pages/{slug}")]
    public async Task<ActionResult<WordPressPage>> GetPage(string locale, string slug, CancellationToken cancellationToken)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        return await content.GetPageAsync(locale, slug, cancellationToken) is { } page ? Ok(page) : NotFound();
    }

    [HttpGet("{locale}/projects")]
    public async Task<ActionResult<IReadOnlyList<WordPressProject>>> GetProjects(string locale, CancellationToken cancellationToken)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        return Ok(await content.GetProjectsAsync(locale, cancellationToken));
    }

    [HttpGet("{locale}/reviews")]
    public async Task<ActionResult<IReadOnlyList<WordPressReview>>> GetReviews(string locale, CancellationToken cancellationToken)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        return Ok(await content.GetReviewsAsync(locale, cancellationToken));
    }

    /// <summary>Lista del blog (sin el contenido). Un post nuevo aparece aquí sin publicar el sitio; el caché dura 5 minutos.</summary>
    [HttpGet("{locale}/blog")]
    public async Task<ActionResult<IReadOnlyList<BlogPostSummaryDto>>> GetBlogPosts(string locale, CancellationToken cancellationToken)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        try { return Ok((await content.GetBlogPostsAsync(locale, cancellationToken)).Select(Summary).ToList()); }
        catch (HttpRequestException) { return StatusCode(StatusCodes.Status503ServiceUnavailable); }
    }

    [HttpGet("{locale}/blog/{slug}")]
    public async Task<ActionResult<BlogPostDto>> GetBlogPost(string locale, string slug, CancellationToken cancellationToken)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        IReadOnlyList<WordPressBlogPost> posts;
        try { posts = await content.GetBlogPostsAsync(locale, cancellationToken); }
        catch (HttpRequestException) { return StatusCode(StatusCodes.Status503ServiceUnavailable); }
        if (posts.FirstOrDefault(x => x.Slug == slug) is not { } post) return NotFound();
        // "Sigue leyendo": primero los del mismo tema; la lista ya viene del más reciente al más antiguo.
        var related = posts.Where(x => x.Slug != slug).OrderByDescending(x => post.Tag is not null && x.Tag == post.Tag).Take(2).Select(Summary).ToList();
        return Ok(new BlogPostDto(post.Slug, post.Title, post.Excerpt, post.Html, post.Tag, post.PublishedAt, post.UpdatedAt, post.ReadingMinutes, post.CoverUrl, post.CoverAlt, related));
    }

    private static BlogPostSummaryDto Summary(WordPressBlogPost x) => new(x.Slug, x.Title, x.Excerpt, x.Tag, x.PublishedAt, x.ReadingMinutes, x.CoverUrl, x.CoverAlt);

    [HttpGet("hero-photo")]
    public async Task<ActionResult> GetHeroPhoto(CancellationToken cancellationToken)
    {
        var url = await content.GetHeroPhotoUrlAsync(cancellationToken);
        return url is null ? NotFound() : Ok(new { url });
    }

    /// <summary>Cifras del sitio (Quiénes somos): clientes activos registrados en el portal. Solo el total, sin datos de nadie.</summary>
    [HttpGet("stats")]
    public async Task<ActionResult<PublicStatsDto>> GetStats(CancellationToken cancellationToken) =>
        Ok(new PublicStatsDto(await db.Clients.CountAsync(x => x.IsActive, cancellationToken)));
}

public sealed record PublicStatsDto(int ActiveClients);
public sealed record BlogPostSummaryDto(string Slug, string Title, string Excerpt, string? Tag, DateTimeOffset PublishedAt, int ReadingMinutes, string? CoverUrl, string? CoverAlt);
public sealed record BlogPostDto(string Slug, string Title, string Excerpt, string Html, string? Tag, DateTimeOffset PublishedAt, DateTimeOffset UpdatedAt, int ReadingMinutes, string? CoverUrl, string? CoverAlt, IReadOnlyList<BlogPostSummaryDto> Related);
ParseOptions.0.json�;
NC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Controllers\TaxCalendarController.cs�:using System.Globalization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Jobs;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>
/// Cronograma de vencimientos de SUNAT (declaración mensual IGV-Renta): la tabla anual por último dígito del RUC, la fecha
/// que le toca a Rtres y la marca de periodo presentado. SUNAT publica el cronograma de cada año en diciembre: se carga aquí.
/// </summary>
[ApiController, Authorize(Roles = "SuperAdmin"), Route("api/admin/tax-calendar")]
public sealed class TaxCalendarController(RtresDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult> Get(int? year, CancellationToken ct) => Ok(await GetAsync(year, DateTime.UtcNow, ct));

    internal async Task<TaxCalendarDto> GetAsync(int? year, DateTime utcNow, CancellationToken ct)
    {
        var settings = await db.TaxSettings.FirstOrDefaultAsync(ct) ?? new TaxSettings();
        var today = TaxDueReminderJob.LimaToday(utcNow);
        var selected = year ?? today.Year;
        var years = await db.TaxDueDates.Select(x => x.Period.Year).Distinct().OrderBy(x => x).ToListAsync(ct);
        var rows = await db.TaxDueDates.Where(x => x.Period.Year == selected).OrderBy(x => x.Period).ToListAsync(ct);
        // Próximo vencimiento sin presentar (de cualquier año) y periodos vencidos sin marcar como presentados.
        var pending = (await db.TaxDueDates.Where(x => x.FiledAt == null).OrderBy(x => x.Period).ToListAsync(ct))
            .Select(x => (Row: x, Due: x.DueFor(settings.Ruc, settings.IsGoodTaxpayer))).Where(x => x.Due is not null).ToList();
        var next = pending.FirstOrDefault(x => x.Due >= today && x.Row.Period <= today);
        var overdue = pending.Where(x => x.Due < today).Select(x => Month(x.Row.Period)).ToList();
        return new TaxCalendarDto(settings.Ruc, settings.IsGoodTaxpayer, today, selected, years,
            rows.Select(x => ToDto(x, settings)).ToList(),
            next.Row is null ? null : ToDto(next.Row, settings), overdue,
            // El cronograma del año siguiente se necesita desde el periodo diciembre (vence en enero).
            MissingNextYear: today.Month == 12 && !years.Contains(today.Year + 1));
    }

    /// <summary>Crea o corrige la fila de un periodo (yyyy-MM) con las fechas que publicó SUNAT.</summary>
    [HttpPut("{period}")]
    public async Task<ActionResult> Upsert(string period, TaxDueDateRequest request, CancellationToken ct)
    {
        if (!DateOnly.TryParseExact(period + "-01", "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var start)) return BadRequest(new { message = "El periodo debe tener el formato AAAA-MM." });
        DateOnly[] dates = [request.Digit0, request.Digit1, request.Digit2And3, request.Digit4And5, request.Digit6And7, request.Digit8And9, request.GoodTaxpayer];
        // La declaración de un mes se presenta el mes siguiente (o, a lo sumo, el subsiguiente).
        if (dates.Any(d => d < start.AddMonths(1) || d >= start.AddMonths(3))) return BadRequest(new { message = $"Las fechas de vencimiento de {Month(start)} deben caer en los dos meses siguientes al periodo." });
        if (dates.Any(d => d.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday)) return BadRequest(new { message = "Hay una fecha en sábado o domingo: SUNAT solo fija vencimientos en días hábiles." });
        var row = await db.TaxDueDates.SingleOrDefaultAsync(x => x.Period == start, ct);
        if (row is null) { row = new TaxDueDate { Period = start }; db.TaxDueDates.Add(row); }
        (row.Digit0, row.Digit1, row.Digit2And3, row.Digit4And5, row.Digit6And7, row.Digit8And9, row.GoodTaxpayer) = (request.Digit0, request.Digit1, request.Digit2And3, request.Digit4And5, request.Digit6And7, request.Digit8And9, request.GoodTaxpayer);
        await db.SaveChangesAsync(ct);
        return Ok(ToDto(row, await db.TaxSettings.FirstOrDefaultAsync(ct) ?? new TaxSettings()));
    }

    /// <summary>Marca el periodo como presentado y, opcionalmente, lo pagado (IGV y Renta): la Renta anual usa esos montos reales.</summary>
    [HttpPost("{id:guid}/filed")]
    public async Task<ActionResult> MarkFiled(Guid id, TaxPeriodPaymentRequest? request, CancellationToken ct)
    {
        if (request?.IgvPaid < 0 || request?.RentaPaid < 0) return BadRequest(new { message = "Los montos pagados no pueden ser negativos." });
        var row = await db.TaxDueDates.FindAsync([id], ct); if (row is null) return NotFound();
        (row.IgvPaid, row.RentaPaid) = (request?.IgvPaid, request?.RentaPaid);
        return await SetFiledAsync(id, DateTime.UtcNow, ct);
    }

    [HttpDelete("{id:guid}/filed")]
    public async Task<ActionResult> UnmarkFiled(Guid id, CancellationToken ct)
    {
        var row = await db.TaxDueDates.FindAsync([id], ct); if (row is null) return NotFound();
        (row.IgvPaid, row.RentaPaid) = (null, null);
        return await SetFiledAsync(id, null, ct);
    }

    /// <summary>Marca como presentados todos los periodos ya vencidos (para ponerse al día al empezar a usar el calendario).</summary>
    [HttpPost("filed-overdue")]
    public async Task<ActionResult> MarkOverdueFiled(CancellationToken ct)
    {
        var settings = await db.TaxSettings.FirstOrDefaultAsync(ct) ?? new TaxSettings();
        var today = TaxDueReminderJob.LimaToday(DateTime.UtcNow);
        var overdue = (await db.TaxDueDates.Where(x => x.FiledAt == null && x.Period < today).ToListAsync(ct)).Where(x => x.DueFor(settings.Ruc, settings.IsGoodTaxpayer) < today).ToList();
        foreach (var row in overdue) row.FiledAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return Ok(new { marked = overdue.Count });
    }

    private async Task<ActionResult> SetFiledAsync(Guid id, DateTime? filedAt, CancellationToken ct)
    {
        var row = await db.TaxDueDates.FindAsync([id], ct); if (row is null) return NotFound();
        row.FiledAt = filedAt; await db.SaveChangesAsync(ct);
        return Ok(ToDto(row, await db.TaxSettings.FirstOrDefaultAsync(ct) ?? new TaxSettings()));
    }

    private static string Month(DateOnly period) => period.ToString("MMMM yyyy", CultureInfo.GetCultureInfo("es-PE")).ToLowerInvariant();

    private static TaxDueDateDto ToDto(TaxDueDate x, TaxSettings settings) => new(x.Id, x.Period.ToString("yyyy-MM", CultureInfo.InvariantCulture),
        x.Digit0, x.Digit1, x.Digit2And3, x.Digit4And5, x.Digit6And7, x.Digit8And9, x.GoodTaxpayer, x.DueFor(settings.Ruc, settings.IsGoodTaxpayer), x.FiledAt, x.IgvPaid, x.RentaPaid);
}

public sealed record TaxDueDateRequest(DateOnly Digit0, DateOnly Digit1, DateOnly Digit2And3, DateOnly Digit4And5, DateOnly Digit6And7, DateOnly Digit8And9, DateOnly GoodTaxpayer);
public sealed record TaxDueDateDto(Guid Id, string Period, DateOnly Digit0, DateOnly Digit1, DateOnly Digit2And3, DateOnly Digit4And5, DateOnly Digit6And7, DateOnly Digit8And9, DateOnly GoodTaxpayer, DateOnly? DueDate, DateTime? FiledAt, decimal? IgvPaid = null, decimal? RentaPaid = null);
public sealed record TaxPeriodPaymentRequest(decimal? IgvPaid, decimal? RentaPaid);
public sealed record TaxCalendarDto(string? Ruc, bool IsGoodTaxpayer, DateOnly Today, int Year, List<int> Years, List<TaxDueDateDto> Rows, TaxDueDateDto? Next, List<string> Overdue, bool MissingNextYear);
ParseOptions.0.json�,
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\GitHub\GitHubWebhookProcessor.cs�,using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.GitHub;

/// <summary>Aplica los eventos <c>issues</c> e <c>issue_comment</c> de GitHub sobre los tickets del portal.</summary>
public sealed class GitHubWebhookProcessor(RtresDbContext db, INotificationSender notifications, ILogger<GitHubWebhookProcessor> logger)
{
    public async Task ProcessAsync(string eventName, JsonElement payload, CancellationToken ct)
    {
        if (eventName is not ("issues" or "issue_comment")) return;
        if (!payload.TryGetProperty("issue", out var issue) || !payload.TryGetProperty("repository", out var repo)) return;
        if (issue.TryGetProperty("pull_request", out _)) return; // comentarios en PRs no son tickets

        var owner = repo.GetProperty("owner").GetProperty("login").GetString();
        var name = repo.GetProperty("name").GetString();
        var number = issue.GetProperty("number").GetInt32();
        var ticket = await db.Tickets
            .Join(db.ProjectRepositories, t => t.RepositoryId, r => (Guid?)r.Id, (t, r) => new { t, r })
            .Where(x => x.t.GithubIssueNumber == number && x.r.Owner == owner && x.r.Name == name)
            .Select(x => x.t).SingleOrDefaultAsync(ct);
        if (ticket is null) { logger.LogDebug("Issue {Owner}/{Repo}#{Number} no corresponde a ningún ticket", owner, name, number); return; }

        var action = payload.GetProperty("action").GetString();
        if (eventName == "issues") { if (!AffectsStatus(action, payload)) return; await ApplyIssueAsync(ticket, issue, ct); }
        else await ApplyCommentAsync(ticket, action, payload.GetProperty("comment"), ct);
        await db.SaveChangesAsync(ct);
    }

    /// <summary>
    /// Solo abrir/cerrar y los labels <c>estado:*</c> cambian el estado. Otros eventos (editar, asignar, labels como "bug")
    /// no lo recalculan: si no, un issue movido de columna en el GitHub Project volvería al estado de sus labels viejos.
    /// </summary>
    internal static bool AffectsStatus(string? action, JsonElement payload) => action switch
    {
        "closed" or "reopened" => true,
        "labeled" or "unlabeled" => !payload.TryGetProperty("label", out var label) || (label.GetProperty("name").GetString() ?? "").StartsWith(GitHubLabels.StatusPrefix, StringComparison.OrdinalIgnoreCase),
        _ => false,
    };

    private async Task ApplyIssueAsync(Ticket ticket, JsonElement issue, CancellationToken ct)
    {
        var labels = issue.TryGetProperty("labels", out var l) && l.ValueKind == JsonValueKind.Array
            ? l.EnumerateArray().Select(x => x.GetProperty("name").GetString() ?? string.Empty)
            : [];
        var stateReason = issue.TryGetProperty("state_reason", out var r) && r.ValueKind == JsonValueKind.String ? r.GetString() : null;
        var newStatus = GitHubLabels.ResolveStatus(issue.GetProperty("state").GetString() ?? "open", stateReason, labels);
        if (newStatus == ticket.Status) return;

        ticket.Status = newStatus; ticket.UpdatedAt = DateTime.UtcNow;
        await NotifyAsync(ticket, NotificationType.TicketStatusChanged, new() { ["status"] = newStatus.ToString() }, null, ct);
    }

    private Task NotifyAsync(Ticket ticket, NotificationType type, Dictionary<string, string> data, string? dedupeKey, CancellationToken ct) =>
        NotifyTicketAsync(db, notifications, ticket, type, data, dedupeKey, ct);

    internal static async Task NotifyTicketAsync(RtresDbContext db, INotificationSender notifications, Ticket ticket, NotificationType type, Dictionary<string, string> data, string? dedupeKey, CancellationToken ct)
    {
        var client = await db.Clients.FindAsync([ticket.ClientId], ct);
        if (client is null) return;
        data["ticketId"] = ticket.Id.ToString(); data["code"] = ticket.Code; data["title"] = ticket.Title;
        await notifications.SendAsync(client, new Notification(type, data, dedupeKey), ct);
    }

    private async Task ApplyCommentAsync(Ticket ticket, string? action, JsonElement comment, CancellationToken ct)
    {
        var commentId = comment.GetProperty("id").GetInt64();
        var user = comment.GetProperty("user");
        if (user.GetProperty("type").GetString() == "Bot") return;
        var body = comment.GetProperty("body").GetString() ?? string.Empty;
        if (body.Contains(GitHubLabels.PortalCommentMarker, StringComparison.Ordinal)) return; // eco de un comentario publicado desde el portal
        var existing = await db.TicketComments.SingleOrDefaultAsync(x => x.TicketId == ticket.Id && x.GithubCommentId == commentId, ct);
        switch (action)
        {
            case "created" when existing is null:
                var login = user.GetProperty("login").GetString();
                db.TicketComments.Add(new TicketComment { TicketId = ticket.Id, Body = body, FromGithub = true, GithubCommentId = commentId, GithubAuthorLogin = login });
                await NotifyAsync(ticket, NotificationType.TicketReply, new() { ["author"] = login ?? "Rtres", ["body"] = body }, $"ticket-reply:{commentId}", ct);
                break;
            case "edited" when existing is not null:
                existing.Body = body;
                break;
            case "deleted" when existing is not null:
                db.TicketComments.Remove(existing);
                break;
            default:
                return;
        }
        ticket.UpdatedAt = DateTime.UtcNow;
    }
}
ParseOptions.0.json�
EC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\ExchangeRateSyncJob.cs�using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Job diario: sincroniza el tipo de cambio USD/PEN (SUNAT) y EUR/PEN (BCRP) del día. Si una fuente falla
/// (fin de semana, feriado, error de red), reutiliza el último <c>ExchangeRate</c> ya guardado para esa moneda
/// — nunca deja una <c>PaymentTransaction</c> sin <c>AmountPen</c> por falta de tipo de cambio.
/// </summary>
public sealed class ExchangeRateSyncJob(RtresDbContext db, IExchangeRateClient client, ILogger<ExchangeRateSyncJob> logger)
{
    public async Task SyncAsync(CancellationToken cancellationToken)
    {
        await SyncCurrencyAsync("USD", client.GetUsdAsync, cancellationToken);
        await SyncCurrencyAsync("EUR", client.GetEurAsync, cancellationToken);
        await db.SaveChangesAsync(cancellationToken);
    }

    private async Task SyncCurrencyAsync(string currency, Func<CancellationToken, Task<ExchangeRateQuote?>> fetch, CancellationToken cancellationToken)
    {
        ExchangeRateQuote? quote = null;
        try { quote = await fetch(cancellationToken); }
        catch (Exception ex) { logger.LogWarning(ex, "No se pudo obtener el tipo de cambio de {Currency}", currency); }

        if (quote is null)
        {
            var last = await db.ExchangeRates.Where(x => x.CurrencyCode == currency).OrderByDescending(x => x.Date).FirstOrDefaultAsync(cancellationToken);
            if (last is null) { logger.LogWarning("Sin tipo de cambio previo de {Currency}; no hay fallback posible", currency); return; }
            quote = new ExchangeRateQuote(DateOnly.FromDateTime(DateTime.UtcNow), last.RateToPen, $"fallback:{last.Source}");
        }

        if (await db.ExchangeRates.AnyAsync(x => x.Date == quote.Date && x.CurrencyCode == currency, cancellationToken)) return;
        db.ExchangeRates.Add(new ExchangeRate { Date = quote.Date, CurrencyCode = currency, RateToPen = quote.RateToPen, Source = quote.Source });
    }
}
ParseOptions.0.json�#
DC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\GitHubIssueSyncJob.cs�"using Hangfire;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Sincroniza tickets del portal hacia GitHub: crea el issue y publica los comentarios hechos en el portal.
/// Se encola desde <c>PortalController</c>; Hangfire reintenta si GitHub falla, y cada paso es idempotente.
/// </summary>
public sealed class GitHubIssueSyncJob(RtresDbContext db, IGitHubIssuesClient github, ILogger<GitHubIssueSyncJob> logger)
{
    [AutomaticRetry(Attempts = 5)]
    public async Task CreateIssueAsync(Guid ticketId, CancellationToken cancellationToken)
    {
        var ticket = await db.Tickets.SingleOrDefaultAsync(x => x.Id == ticketId, cancellationToken);
        if (ticket is null) { logger.LogWarning("Ticket {TicketId} no existe; no se crea issue", ticketId); return; }
        var project = await db.Projects.Include(x => x.Repositories).SingleAsync(x => x.Id == ticket.ProjectId, cancellationToken);
        if (project.Repositories.RepositoryFor(ticket.RepositoryId) is not { } repository)
        {
            logger.LogWarning("Proyecto {Project} no tiene repo de GitHub configurado; ticket {Code} queda sin issue", project.Slug, ticket.Code);
            return;
        }
        if (ticket.GithubIssueNumber is null)
        {
            // Primero los adjuntos (cada uno se guarda al subir: un reintento no los duplica), luego el issue que los enlaza.
            var attachments = await db.TicketAttachments.Where(x => x.TicketId == ticket.Id).OrderBy(x => x.CreatedAt).ToListAsync(cancellationToken);
            foreach (var attachment in attachments.Where(x => x.Url.Length == 0))
            {
                attachment.Url = await github.UploadFileAsync(repository, GitHubIssuesClient.AttachmentPath(ticket, attachment), attachment.Content, $"Adjunto de {ticket.Code}: {attachment.FileName}", cancellationToken);
                await db.SaveChangesAsync(cancellationToken);
            }
            var issue = await github.CreateIssueAsync(project, repository, ticket, attachments, cancellationToken);
            ticket.RepositoryId = repository.Id; ticket.GithubIssueNumber = issue.Number; ticket.GithubIssueUrl = issue.Url; ticket.UpdatedAt = DateTime.UtcNow;
            await db.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Ticket {Code} sincronizado con {Owner}/{Repo}#{Number}", ticket.Code, repository.Owner, repository.Name, issue.Number);
        }

        // Comentarios hechos en el portal antes de que existiera el issue.
        var pending = await db.TicketComments.Where(x => x.TicketId == ticket.Id && !x.FromGithub && x.GithubCommentId == null).OrderBy(x => x.CreatedAt).ToListAsync(cancellationToken);
        foreach (var comment in pending) await PublishAsync(repository, ticket, comment, cancellationToken);
    }

    [AutomaticRetry(Attempts = 5)]
    public async Task PostCommentAsync(Guid commentId, CancellationToken cancellationToken)
    {
        var comment = await db.TicketComments.SingleOrDefaultAsync(x => x.Id == commentId, cancellationToken);
        if (comment is null || comment.FromGithub || comment.GithubCommentId is not null) return;
        var ticket = await db.Tickets.SingleAsync(x => x.Id == comment.TicketId, cancellationToken);
        if (ticket.GithubIssueNumber is null) return; // CreateIssueAsync lo publica al crear el issue
        var repository = await db.ProjectRepositories.SingleOrDefaultAsync(x => x.Id == ticket.RepositoryId, cancellationToken);
        if (repository is null) return;
        await PublishAsync(repository, ticket, comment, cancellationToken);
    }

    private async Task PublishAsync(ProjectRepository repository, Ticket ticket, TicketComment comment, CancellationToken cancellationToken)
    {
        var author = await db.UserAccounts.Where(x => x.Id == comment.AuthorUserId).Select(x => x.Role == UserRole.SuperAdmin ? "Rtres" : x.Name == "" ? x.Email : x.Name).SingleOrDefaultAsync(cancellationToken) ?? "Cliente";
        comment.GithubCommentId = await github.CreateCommentAsync(repository, ticket.GithubIssueNumber!.Value, GitHubIssuesClient.BuildCommentBody(comment, author), cancellationToken);
        await db.SaveChangesAsync(cancellationToken);
    }

}
ParseOptions.0.json�
LC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\GitHubProjectStatusSyncJob.cs�using Hangfire;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.GitHub;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Copia al ticket la columna "Status" del GitHub Project donde está su issue (Recibido, En progreso, Resuelto, Publicado).
/// GitHub no avisa por webhook de los movimientos en proyectos de usuario, así que se consulta cada pocos minutos.
/// Solo se aplica cuando la columna cambia respecto a la última vista: así no pisa estados puestos por label o al cerrar.
/// </summary>
public sealed class GitHubProjectStatusSyncJob(RtresDbContext db, IGitHubIssuesClient github, INotificationSender notifications, ILogger<GitHubProjectStatusSyncJob> logger)
{
    [AutomaticRetry(Attempts = 0), DisableConcurrentExecution(timeoutInSeconds: 300)]
    public async Task SyncAsync(CancellationToken cancellationToken)
    {
        var tickets = await db.Tickets.Where(x => x.GithubIssueNumber != null && x.RepositoryId != null && x.Status != TicketStatus.Cerrado).ToListAsync(cancellationToken);
        var repositoryIds = tickets.Select(x => x.RepositoryId!.Value).Distinct().ToList();
        var repositories = await db.ProjectRepositories.Where(x => repositoryIds.Contains(x.Id)).ToListAsync(cancellationToken);

        foreach (var repository in repositories)
        {
            var group = tickets.Where(x => x.RepositoryId == repository.Id).ToList();
            IReadOnlyDictionary<int, GitHubIssueState> states;
            try { states = await github.GetIssueStatesAsync(repository, group.Select(x => x.GithubIssueNumber!.Value).ToList(), cancellationToken); }
            catch (Exception ex) when (ex is HttpRequestException or InvalidOperationException)
            {
                // Un repo sin token o sin permiso no frena al resto.
                logger.LogWarning(ex, "No se pudo leer el estado de los issues de {Owner}/{Repo}", repository.Owner, repository.Name);
                continue;
            }

            foreach (var ticket in group)
            {
                if (!states.TryGetValue(ticket.GithubIssueNumber!.Value, out var state) || state.ProjectStatus is null || state.ProjectStatus == ticket.GithubProjectStatus) continue;
                ticket.GithubProjectStatus = state.ProjectStatus;
                if (GitHubProjectStatus.Resolve(state) is { } status && status != ticket.Status)
                {
                    ticket.Status = status; ticket.UpdatedAt = DateTime.UtcNow;
                    await GitHubWebhookProcessor.NotifyTicketAsync(db, notifications, ticket, NotificationType.TicketStatusChanged, new() { ["status"] = status.ToString() }, null, cancellationToken);
                    logger.LogInformation("Ticket {Code} → {Status} (columna «{Column}» en GitHub)", ticket.Code, status, state.ProjectStatus);
                }
            }
            await db.SaveChangesAsync(cancellationToken);
        }
    }
}
ParseOptions.0.json�
IC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\PayPalReconciliationJob.cs�using Hangfire;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Concilia cada hora las suscripciones de PayPal con el portal: registra los cobros que no llegaron por webhook
/// (el primer cobro se procesa minutos después de activar la suscripción; en local el webhook no llega nunca; en
/// producción un webhook puede perderse), actualiza el próximo cobro y marca las suscripciones canceladas en PayPal.
/// Cada cobro se aplica una sola vez, así que es seguro que coincida con el webhook.
/// </summary>
public sealed class PayPalReconciliationJob(RtresDbContext db, PayPalPaymentService payments, ILogger<PayPalReconciliationJob> logger)
{
    [AutomaticRetry(Attempts = 0)] // corre cada hora: no hace falta reintentar
    public async Task ReconcileAsync(CancellationToken ct)
    {
        var items = await db.ClientProducts.Include(x => x.Product)
            .Where(x => x.PayPalSubscriptionId != null && !x.IsManualBilling && x.Status != ClientProductStatus.Cancelado)
            .ToListAsync(ct);
        foreach (var item in items)
        {
            try { await payments.SyncSubscriptionAsync(item, ct); }
            catch (Exception ex) when (ex is HttpRequestException or InvalidOperationException)
            {
                logger.LogWarning(ex, "No se pudo conciliar la suscripción {SubscriptionId} del producto {ClientProductId}", item.PayPalSubscriptionId, item.Id);
            }
        }
    }
}
ParseOptions.0.json�
EC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\RecurringExpenseJob.cs�using Hangfire;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Programa los pagos de los gastos recurrentes: crea los que caen en los próximos <see cref="DaysAhead"/> días para que
/// aparezcan como "Por pagar". Una serie es "mismo concepto, categoría y moneda" (igual que al finalizarla) y sigue hasta
/// que se finaliza. Solo programa hacia adelante: los pagos que faltan en el pasado no se inventan (se registran a mano).
/// </summary>
public sealed class RecurringExpenseJob(RtresDbContext db, ILogger<RecurringExpenseJob> logger)
{
    public const int DaysAhead = 30;

    [AutomaticRetry(Attempts = 3), DisableConcurrentExecution(timeoutInSeconds: 300)]
    public async Task GenerateAsync(CancellationToken cancellationToken) => await GenerateAsync(DateOnly.FromDateTime(DateTime.UtcNow.AddHours(-5)), cancellationToken);

    /// <param name="today">Fecha de Lima; parámetro para poder probarlo.</param>
    public async Task<int> GenerateAsync(DateOnly today, CancellationToken cancellationToken)
    {
        var recurring = await db.Expenses.Where(x => x.Recurring && x.RecurrenceCycle != null && x.RecurrenceCycle != BillingCycle.Unico).ToListAsync(cancellationToken);
        var until = today.AddDays(DaysAhead);
        var created = 0;
        foreach (var series in recurring.GroupBy(x => (Description: x.Description.Trim().ToLowerInvariant(), x.CategoryId, x.Currency)))
        {
            // Una serie finalizada no se programa más, aunque alguna fila vieja no tenga la marca.
            if (series.Any(x => x.RecurrenceEndsAt is not null)) continue;
            var last = series.MaxBy(x => x.Date)!;
            var months = last.RecurrenceCycle!.Value.Months();
            // El día del mes sale del primer pago: así un gasto del 31 no se corre al 28 para siempre tras pasar por febrero.
            var anchor = series.Min(x => x.Date);
            var step = 1;
            for (var next = anchor.AddMonths(months); next <= until; next = anchor.AddMonths(months * ++step))
            {
                if (next <= last.Date || next < today) continue;
                db.Expenses.Add(new Expense
                {
                    Description = last.Description, CategoryId = last.CategoryId, Type = last.Type, Amount = last.Amount, Currency = last.Currency,
                    Date = next, Recurring = true, RecurrenceCycle = last.RecurrenceCycle,
                    // Hereda cómo cuenta para impuestos (no deducible, servicio de no domiciliado); el pago del 1662 es de cada cuota.
                    IsNonDeductible = last.IsNonDeductible, IsNonDomiciledService = last.IsNonDomiciledService, ForeignSupplierName = last.ForeignSupplierName, ForeignSupplierCountry = last.ForeignSupplierCountry,
                    // Tipo de cambio más cercano disponible: para una fecha futura es una estimación.
                    AmountPen = last.Amount * await db.RateToPenAsync(last.Currency, next, cancellationToken),
                });
                created++;
                logger.LogInformation("Gasto recurrente «{Description}» programado para {Date}", last.Description, next);
            }
        }
        await db.SaveChangesAsync(cancellationToken);
        return created;
    }
}
ParseOptions.0.json�"
DC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\RenewalReminderJob.cs�!using System.Globalization;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Notifications;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Job diario: avisa a 30, 7 y 1 día del vencimiento (<c>RenewsAt</c>) y marca el producto como PorVencer; cuando la
/// fecha ya pasó sin renovarse, lo marca Vencido. Cada umbral se envía una sola vez por fecha de vencimiento, aunque el
/// job corra varias veces o se salte un día.
/// </summary>
public sealed class RenewalReminderJob(RtresDbContext db, INotificationSender notifications)
{
    public static readonly int[] ThresholdDays = [30, 7, 1];

    public async Task SendAsync(CancellationToken cancellationToken) => await SendAsync(DateTime.UtcNow, cancellationToken);

    public async Task SendAsync(DateTime now, CancellationToken cancellationToken)
    {
        var today = now.Date;
        var limit = today.AddDays(ThresholdDays.Max() + 1);
        var expired = await db.ClientProducts
            .Where(x => (x.Status == ClientProductStatus.Activo || x.Status == ClientProductStatus.PorVencer) && x.BillingCycle != BillingCycle.Unico && x.RenewsAt != null && x.RenewsAt < today)
            .ToListAsync(cancellationToken);
        foreach (var item in expired) item.Status = ClientProductStatus.Vencido;
        var due = await db.ClientProducts.Include(x => x.Product)
            .Where(x => (x.Status == ClientProductStatus.Activo || x.Status == ClientProductStatus.PorVencer) && x.BillingCycle != BillingCycle.Unico && x.RenewsAt != null && x.RenewsAt >= today && x.RenewsAt < limit)
            .Join(db.Clients.Where(c => c.IsActive), product => product.ClientId, client => client.Id, (product, client) => new { product, client })
            .ToListAsync(cancellationToken);

        var igvRate = await db.IgvRateAsync(cancellationToken);
        foreach (var (item, client) in due.Select(x => (x.product, x.client)))
        {
            var renewsAt = item.RenewsAt!.Value;
            var days = (renewsAt.Date - today).Days;
            var threshold = ThresholdDays.Where(t => days <= t).Min();
            item.Status = ClientProductStatus.PorVencer;
            var key = $"renewal:{item.Id}:{renewsAt:yyyyMMdd}:{threshold}";
            if (await NotificationJob.AlreadySentAsync(db, key, cancellationToken)) continue;
            var data = new Dictionary<string, string>
            {
                ["product"] = item.Product?.Name ?? "",
                ["renewsAt"] = renewsAt.ToString("O", CultureInfo.InvariantCulture),
                ["days"] = days.ToString(CultureInfo.InvariantCulture),
                ["autoRenew"] = item.PayPalSubscriptionId is null ? "false" : "true",
            };
            if (!string.IsNullOrWhiteSpace(item.DomainName)) data["domain"] = item.DomainName;
            // La renovación va a precio de catálogo si el descuento ya se usó, más IGV si es Factura a un cliente en Perú.
            if (item.NextChargeTotal(item.Product is null ? 0m : ClientProductPricing.IgvRateFor(client, item.Product, igvRate)) is decimal price)
            {
                data["amount"] = price.ToString(CultureInfo.InvariantCulture);
                data["currency"] = item.Product?.Currency ?? "USD";
            }
            await notifications.SendAsync(client, new Notification(NotificationType.RenewalReminder, data, key), cancellationToken);
        }
        await db.SaveChangesAsync(cancellationToken);
    }

    /// <summary>
    /// Estado que corresponde a un vencimiento, con el mismo criterio que el job (vencido si la fecha ya pasó, por vencer
    /// dentro de los 30 días). Solo toca productos vigentes: Pendiente y Cancelado, o sin <c>RenewsAt</c>, no cambian.
    /// </summary>
    public static ClientProductStatus StatusFor(ClientProductStatus current, DateTime? renewsAt, DateTime now)
    {
        if (current is not (ClientProductStatus.Activo or ClientProductStatus.PorVencer or ClientProductStatus.Vencido) || renewsAt is not DateTime date) return current;
        var today = now.Date;
        return date < today ? ClientProductStatus.Vencido : date < today.AddDays(ThresholdDays.Max() + 1) ? ClientProductStatus.PorVencer : ClientProductStatus.Activo;
    }
}
ParseOptions.0.json�
CC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Jobs\TaxDueReminderJob.cs�using System.Globalization;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Notifications;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Job diario: avisa a Rtres (<c>Notifications:StaffEmail</c> y la campana de SuperAdmin) a 7, 3 y 1 día y el mismo día del
/// vencimiento de la declaración mensual, según el último dígito del RUC configurado. No avisa los periodos ya marcados como
/// presentados. Cada umbral se envía una sola vez por periodo, aunque el job corra varias veces o se salte un día.
/// </summary>
public sealed class TaxDueReminderJob(RtresDbContext db, StaffNotifier staff, ILogger<TaxDueReminderJob> logger)
{
    public static readonly int[] ThresholdDays = [7, 3, 1, 0];

    public async Task SendAsync(CancellationToken cancellationToken) => await SendAsync(DateTime.UtcNow, cancellationToken);

    public async Task SendAsync(DateTime utcNow, CancellationToken cancellationToken)
    {
        var settings = await db.TaxSettings.FirstOrDefaultAsync(cancellationToken);
        if (settings is null || (settings.Ruc is null && !settings.IsGoodTaxpayer)) { logger.LogInformation("Recordatorio SUNAT omitido: falta el RUC en Configuración tributaria"); return; }
        var today = LimaToday(utcNow);
        // Un periodo vence el mes siguiente: basta mirar los dos últimos periodos.
        var from = new DateOnly(today.Year, today.Month, 1).AddMonths(-2);
        var rows = await db.TaxDueDates.Where(x => x.FiledAt == null && x.Period >= from && x.Period <= today).ToListAsync(cancellationToken);
        foreach (var row in rows)
        {
            if (row.DueFor(settings.Ruc, settings.IsGoodTaxpayer) is not DateOnly due) continue;
            var days = due.DayNumber - today.DayNumber;
            if (days < 0 || days > ThresholdDays.Max()) continue;
            var threshold = ThresholdDays.Where(t => days <= t).Min();
            var key = $"tax-due:{row.Period:yyyyMM}:{due:yyyyMMdd}:{threshold}";
            if (await NotificationJob.AlreadySentAsync(db, key, cancellationToken)) continue;
            var data = new Dictionary<string, string>
            {
                ["period"] = row.Period.ToString("yyyy-MM", CultureInfo.InvariantCulture),
                ["dueDate"] = due.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture),
                ["days"] = days.ToString(CultureInfo.InvariantCulture),
            };
            await staff.SendAsync(new Notification(NotificationType.TaxDueReminder, data, key), cancellationToken);
        }
    }

    /// <summary>Fecha de hoy en Lima (UTC−5, sin horario de verano): los vencimientos de SUNAT son fechas locales.</summary>
    public static DateOnly LimaToday(DateTime utcNow) => DateOnly.FromDateTime(utcNow.AddHours(-5));
}
ParseOptions.0.json�
MC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Notifications\AccessEmailService.cs�using Rtres.Api.Services;
using Rtres.Domain;

namespace Rtres.Api.Notifications;

/// <summary>
/// Envía por email el acceso (usuario + contraseña temporal) a un usuario nuevo o con la contraseña restablecida.
/// Se envía en el momento, sin pasar por la cola de Hangfire: sus argumentos se guardan en la base de datos y la
/// contraseña quedaría ahí en texto plano. Si el envío falla, el portal muestra la contraseña para entregarla a mano.
/// </summary>
public sealed class AccessEmailService(NotificationJob job, IConfiguration configuration, ILogger<AccessEmailService> logger)
{
    public async Task<bool> SendAsync(Client client, string name, string email, string temporaryPassword, HttpRequest? request, CancellationToken ct)
    {
        var notification = new Notification(NotificationType.AccountAccess, new()
        {
            ["name"] = name,
            ["company"] = client.CompanyName,
            ["email"] = email,
            ["password"] = temporaryPassword,
            ["portalUrl"] = PayPalCheckoutService.PortalBaseUrl(request, configuration),
        }, To: email);
        try
        {
            return await job.SendAsync(client.Id, notification, ct);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "No se pudo enviar el email de acceso a {Email}", email);
            return false;
        }
    }
}
ParseOptions.0.json�$
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Notifications\NotificationJob.cs�#using System.Text.Json;
using Hangfire;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Notifications;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Notifications;

/// <summary>
/// Envía un aviso por email en segundo plano (así un SMTP lento no frena los webhooks) y lo registra en
/// <see cref="NotificationLog"/>. Un aviso con <see cref="Notification.DedupeKey"/> ya enviado con éxito no se repite.
/// </summary>
public sealed class NotificationJob(RtresDbContext db, IEmailSender email, IConfiguration configuration, ILogger<NotificationJob> logger)
{
    [AutomaticRetry(Attempts = 3)]
    /// <returns>Si el email se envió (false si se omitió: ya enviado, cliente inactivo o sin email).</returns>
    public async Task<bool> SendAsync(Guid clientId, Notification notification, CancellationToken cancellationToken)
    {
        await AddToInboxAsync(clientId, notification, cancellationToken);
        if (notification.DedupeKey is not null && await AlreadySentAsync(db, notification.DedupeKey, cancellationToken)) return false;
        var client = await db.Clients.SingleOrDefaultAsync(x => x.Id == clientId, cancellationToken);
        if (client is null || !client.IsActive || string.IsNullOrWhiteSpace(client.Email))
        {
            logger.LogInformation("Aviso {Type} omitido: cliente {ClientId} inexistente, inactivo o sin email", notification.Type, clientId);
            return false;
        }

        var portalUrl = notification.Data.TryGetValue("portalUrl", out var url) ? url : configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net";
        var (subject, html, text) = EmailTemplates.Render(notification, client.PreferredLanguage, portalUrl);
        var recipient = notification.To ?? client.Email;
        var log = new NotificationLog { ClientId = client.Id, Type = notification.Type.ToString(), Channel = "email", Recipient = recipient, DedupeKey = notification.DedupeKey };
        db.NotificationLogs.Add(log);
        try
        {
            await email.SendAsync(new EmailMessage(recipient, subject, html, text), cancellationToken);
            log.Success = true;
        }
        catch (Exception ex)
        {
            log.Error = ex.Message.Length > 1000 ? ex.Message[..1000] : ex.Message;
            await db.SaveChangesAsync(cancellationToken);
            throw; // Hangfire reintenta
        }
        await db.SaveChangesAsync(cancellationToken);
        return true;
    }

    /// <summary>Bandeja de la campana: una entrada por aviso aunque el email falle y se reintente (la clave lo evita).</summary>
    private async Task AddToInboxAsync(Guid clientId, Notification notification, CancellationToken cancellationToken)
    {
        if (notification.Type == NotificationType.AccountAccess) return; // lleva la contraseña temporal: solo por email
        if (notification.DedupeKey is not null && await db.PortalNotifications.AnyAsync(x => x.DedupeKey == notification.DedupeKey, cancellationToken)) return;
        if (!await db.Clients.AnyAsync(x => x.Id == clientId, cancellationToken)) return;
        db.PortalNotifications.Add(new PortalNotification
        {
            ClientId = clientId, Type = notification.Type.ToString(), DedupeKey = notification.DedupeKey,
            ForStaff = notification.Type is NotificationType.TicketCreated or NotificationType.TransferRequested or NotificationType.TransferReported,
            DataJson = JsonSerializer.Serialize(notification.Data.Where(x => x.Key != "portalUrl").ToDictionary()),
        });
        await db.SaveChangesAsync(cancellationToken);
    }

    public static Task<bool> AlreadySentAsync(RtresDbContext db, string dedupeKey, CancellationToken cancellationToken) =>
        db.NotificationLogs.AnyAsync(x => x.DedupeKey == dedupeKey && x.Success, cancellationToken);
}

public sealed class QueuedNotificationSender(IBackgroundJobClient jobs) : INotificationSender
{
    public Task SendAsync(Client client, Notification notification, CancellationToken cancellationToken = default)
    {
        // Sin clave propia se le asigna una: así un reintento del job no duplica el email ni la entrada de la campana.
        var keyed = notification.DedupeKey is null ? notification with { DedupeKey = $"auto:{Guid.NewGuid():N}" } : notification;
        jobs.Enqueue<NotificationJob>(j => j.SendAsync(client.Id, keyed, CancellationToken.None));
        return Task.CompletedTask;
    }
}
ParseOptions.0.json�
HC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Notifications\StaffNotifier.cs�using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Notifications;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Notifications;

/// <summary>
/// Aviso interno sin cliente (ClientId vacío): entra en la campana de SuperAdmin y se envía por email al equipo
/// (<c>Notifications:StaffEmail</c>, o <c>Smtp:From</c>). Lo usan los recordatorios de SUNAT y los contactos de la web.
/// Si el email falla, el log queda sin éxito y se relanza para que Hangfire reintente; la clave evita duplicar la campana.
/// </summary>
public sealed class StaffNotifier(RtresDbContext db, IEmailSender email, IConfiguration configuration, ILogger<StaffNotifier> logger)
{
    [Hangfire.AutomaticRetry(Attempts = 3)]
    public async Task SendAsync(Notification notification, CancellationToken cancellationToken)
    {
        if (notification.DedupeKey is not null && await NotificationJob.AlreadySentAsync(db, notification.DedupeKey, cancellationToken)) return;
        if (!await db.PortalNotifications.AnyAsync(x => x.DedupeKey == notification.DedupeKey, cancellationToken))
            db.PortalNotifications.Add(new PortalNotification { ClientId = Guid.Empty, Type = notification.Type.ToString(), ForStaff = true, DedupeKey = notification.DedupeKey, DataJson = JsonSerializer.Serialize(notification.Data) });
        var staffEmail = configuration["Notifications:StaffEmail"] is { Length: > 0 } configured ? configured : configuration["Smtp:From"];
        if (string.IsNullOrWhiteSpace(staffEmail)) { logger.LogWarning("Aviso interno {Type} sin email: falta Notifications:StaffEmail", notification.Type); await db.SaveChangesAsync(cancellationToken); return; }
        var (subject, html, text) = EmailTemplates.Render(notification, "es", configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net");
        var log = new NotificationLog { ClientId = Guid.Empty, Type = notification.Type.ToString(), Channel = "email", Recipient = staffEmail, DedupeKey = notification.DedupeKey };
        db.NotificationLogs.Add(log);
        try
        {
            await email.SendAsync(new EmailMessage(staffEmail, subject, html, text), cancellationToken);
            log.Success = true;
        }
        catch (Exception ex)
        {
            log.Error = ex.Message.Length > 1000 ? ex.Message[..1000] : ex.Message;
            await db.SaveChangesAsync(cancellationToken);
            throw;
        }
        await db.SaveChangesAsync(cancellationToken);
    }
}
ParseOptions.0.json�/
4C:\repo\rtres-net\Rtres\src\api\Rtres.Api\Program.cs�.using System.Text.Json.Serialization;
using System.Threading.RateLimiting;
using Hangfire;
using Hangfire.SqlServer;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.IdentityModel.Tokens;
using Rtres.Api.Controllers;
using Rtres.Api.GitHub;
using Rtres.Api.Jobs;
using Rtres.Api.Notifications;
using Rtres.Domain;
using Rtres.Api.Services;
using Rtres.Infrastructure;
using Rtres.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.local.json", optional: true, reloadOnChange: true);
builder.Services.AddControllers().AddJsonOptions(o => o.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));
builder.Services.AddOpenApi();
builder.Services.AddRtresInfrastructure(builder.Configuration);
builder.Services.AddScoped<GitHubWebhookProcessor>();
builder.Services.AddScoped<ExchangeRateSyncJob>();
builder.Services.AddScoped<INotificationSender, QueuedNotificationSender>();
builder.Services.AddScoped<NotificationJob>();
builder.Services.AddScoped<AccessEmailService>();
builder.Services.AddScoped<PayPalCheckoutService>();
builder.Services.AddScoped<PayPalPaymentService>();
builder.Services.AddScoped<TaxDocumentService>();
builder.Services.AddScoped<BankTransferService>();
builder.Services.AddScoped<StaffNotifier>();
builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy
    .WithOrigins(PayPalCheckoutService.AllowedOrigins(builder.Configuration))
    .AllowAnyHeader().AllowAnyMethod()));
// Falla al arrancar si Jwt:Key no está definida o es insegura: nunca se firma con una clave conocida.
var jwt = JwtSettings.FromConfiguration(builder.Configuration);
builder.Services.AddSingleton(jwt);
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options => options.TokenValidationParameters = new TokenValidationParameters
{
    ValidateIssuer = true, ValidateAudience = true, ValidateLifetime = true, ValidateIssuerSigningKey = true,
    ValidIssuer = jwt.Issuer, ValidAudience = jwt.Audience, IssuerSigningKey = jwt.SigningKey,
    ClockSkew = TimeSpan.FromMinutes(1)
});
builder.Services.AddAuthorization();
builder.Services.AddMemoryCache();
// Detrás de nginx la IP real llega en X-Forwarded-For; sin esto todos los logins compartirían el límite del proxy.
builder.Services.Configure<ForwardedHeadersOptions>(o =>
{
    o.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    o.KnownIPNetworks.Clear(); o.KnownProxies.Clear();
});
builder.Services.AddRateLimiter(o =>
{
    o.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    o.OnRejected = (ctx, ct) => new ValueTask(ctx.HttpContext.Response.WriteAsJsonAsync(new { message = ctx.HttpContext.Request.Path.StartsWithSegments("/api/public/contact")
        ? "Recibimos varios mensajes desde tu conexión. Espera unos minutos o escríbenos a info@rtres.net."
        : "Demasiados intentos de inicio de sesión. Espera un minuto e inténtalo de nuevo." }, ct));
    // Formulario de contacto: 5 envíos cada 10 minutos por IP.
    o.AddPolicy(ContactController.RateLimitPolicy, http => RateLimitPartition.GetFixedWindowLimiter(
        http.Connection.RemoteIpAddress?.ToString() ?? "unknown",
        _ => new FixedWindowRateLimiterOptions { PermitLimit = 5, Window = TimeSpan.FromMinutes(10), QueueLimit = 0 }));
    o.AddPolicy(AuthController.LoginRateLimitPolicy, http => RateLimitPartition.GetFixedWindowLimiter(
        http.Connection.RemoteIpAddress?.ToString() ?? "unknown",
        _ => new FixedWindowRateLimiterOptions { PermitLimit = 10, Window = TimeSpan.FromMinutes(1), QueueLimit = 0 }));
});
// SqlServer (no MemoryStorage): los jobs encolados (recordatorios, sync de tipo de cambio) sobreviven a un reinicio de la API.
builder.Services.AddHangfire(config => config.UseSqlServerStorage(builder.Configuration.GetConnectionString("SqlServer"), new SqlServerStorageOptions { PrepareSchemaIfNecessary = true }));
builder.Services.AddHangfireServer();

var app = builder.Build();
app.UseForwardedHeaders();
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    using var scope = app.Services.CreateScope();
    await DbSeeder.SeedAsync(scope.ServiceProvider.GetRequiredService<RtresDbContext>());
}
app.UseHttpsRedirection();
app.UseCors();
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
app.UseHangfireDashboard("/jobs");
// 13:00 UTC = 8:00 en Lima.
RecurringJob.AddOrUpdate<RenewalReminderJob>("renewal-reminders", job => job.SendAsync(CancellationToken.None), Cron.Daily(13));
// 11:00 UTC = 6:00 en Lima, antes que corra cualquier otro job del día.
RecurringJob.AddOrUpdate<ExchangeRateSyncJob>("exchange-rate-sync", job => job.SyncAsync(CancellationToken.None), Cron.Daily(11));
// Cobros de suscripciones PayPal que no llegaron por webhook (ver PayPalReconciliationJob).
// 12:00 UTC = 7:00 en Lima, después del tipo de cambio: programa los pagos de gastos recurrentes de los próximos 30 días.
RecurringJob.AddOrUpdate<RecurringExpenseJob>("recurring-expenses", job => job.GenerateAsync(CancellationToken.None), Cron.Daily(12));
// Columna "Status" de los GitHub Projects → estado del ticket (GitHub no envía webhooks de proyectos de usuario).
RecurringJob.AddOrUpdate<GitHubProjectStatusSyncJob>("github-project-status", job => job.SyncAsync(CancellationToken.None), "*/5 * * * *");
// 13:30 UTC = 8:30 en Lima: vencimientos de la declaración mensual de SUNAT.
RecurringJob.AddOrUpdate<TaxDueReminderJob>("tax-due-reminders", job => job.SendAsync(CancellationToken.None), "30 13 * * *");
RecurringJob.AddOrUpdate<PayPalReconciliationJob>("paypal-reconciliation", job => job.ReconcileAsync(CancellationToken.None), Cron.Hourly);
app.MapControllers();
app.Run();

public partial class Program;
ParseOptions.0.json�
IC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Services\BankTransferService.cs�using Microsoft.EntityFrameworkCore;
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
ParseOptions.0.json�

AC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Services\JwtSettings.cs�	using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace Rtres.Api.Services;

/// <summary>Configuración JWT validada al arrancar: sin una Jwt:Key real la API no inicia.</summary>
public sealed record JwtSettings(string Issuer, string Audience, SymmetricSecurityKey SigningKey)
{
    // HMAC-SHA256 necesita al menos 256 bits de clave.
    const int MinKeyBytes = 32;

    public static JwtSettings FromConfiguration(IConfiguration config)
    {
        var key = config["Jwt:Key"];
        if (string.IsNullOrWhiteSpace(key))
            throw new InvalidOperationException("Falta Jwt:Key. Defínela con la variable de entorno Jwt__Key (o en appsettings.{Entorno}.local.json en desarrollo).");
        if (Encoding.UTF8.GetByteCount(key) < MinKeyBytes)
            throw new InvalidOperationException($"Jwt:Key es demasiado corta: se requieren al menos {MinKeyBytes} bytes.");
        if (key.Contains("change-me", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Jwt:Key usa un valor de ejemplo conocido. Genera una clave aleatoria.");
        return new JwtSettings(config["Jwt:Issuer"] ?? "Rtres.Api", config["Jwt:Audience"] ?? "Rtres.Web", new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)));
    }
}
ParseOptions.0.json�#
KC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Services\PayPalCheckoutService.cs�"using Microsoft.AspNetCore.Http;
using Rtres.Domain;

namespace Rtres.Api.Services;

public sealed class PayPalCheckoutService(IPayPalClient payPal, IConfiguration configuration)
{
    /// <summary>
    /// Inicia el pago en PayPal: orden (Único/Anual) o suscripción (Mensual, Bimestral, Trimestral, Semestral). <paramref name="request"/> es la petición
    /// del portal: PayPal vuelve al mismo origen desde el que se pagó (localhost en desarrollo), siempre que sea uno de
    /// los orígenes permitidos; si no, a <c>Frontend:PortalUrl</c>.
    /// </summary>
    /// <param name="igvRate">IGV a sumar (de <c>IgvRateForAsync</c>): el catálogo y los descuentos son sin IGV.</param>
    /// <param name="years">Años pagados por adelantado (solo Anual): una sola orden por el total.</param>
    public async Task<PayPalCheckout> StartAsync(ClientProduct item, Product product, HttpRequest? request, CancellationToken ct, decimal igvRate = 0m, int years = 1)
    {
        if (item.ValidateYears(years) is string yearsError) throw new InvalidOperationException(yearsError);
        var baseUrl = PortalBaseUrl(request, configuration);
        var returnUrl = $"{baseUrl}/billing/return?clientProductId={item.Id}";
        var cancelUrl = $"{baseUrl}/dashboard";
        var listPrice = ClientProductPricing.WithIgv(item.ListPrice(product) ?? throw new InvalidOperationException("El producto no tiene precio."), igvRate);
        var price = item.NextChargeTotal(igvRate, product)!.Value;
        if (price <= 0) throw new InvalidOperationException("Un producto con precio 0 no se puede cobrar por PayPal; asígnalo en modo Manual.");
        if (item.BillingCycle.SubscriptionMonths() is int months)
        {
            // Descuento sin usar: solo el primer periodo va rebajado, luego se cobra el precio de lista.
            item.PayPalPlanId = price != listPrice ? await payPal.CreatePlanAsync(product.Name, listPrice, product.Currency, months, price, ct) : await PlanAsync(product, item.BillingCycle, listPrice, ct);
            var subscription = await payPal.CreateSubscriptionAsync(item.PayPalPlanId, item.Id.ToString(), returnUrl, cancelUrl, ct);
            item.PayPalSubscriptionId = subscription.Id;
            return subscription;
        }
        var order = await payPal.CreateOrderAsync(item.ChargeTotal(igvRate, years, product)!.Value, product.Currency, item.Id.ToString(), returnUrl, cancelUrl, ct);
        item.PayPalOrderId = order.Id;
        item.PayPalOrderYears = years; // al capturar la orden (retorno o webhook) se extienden estos años
        return order;
    }

    /// <summary>
    /// Plan de PayPal para el precio y ciclo a cobrar. El del precio base y ciclo del catálogo se crea una vez y se guarda
    /// en el producto (se recrea si el precio base cambia); otro precio u otro ciclo usan un plan propio.
    /// </summary>
    private async Task<string> PlanAsync(Product product, BillingCycle cycle, decimal price, CancellationToken ct)
    {
        var months = cycle.SubscriptionMonths()!.Value;
        if (price != product.BasePrice || cycle != product.BillingCycle) return await payPal.CreatePlanAsync(product.Name, price, product.Currency, months, cancellationToken: ct);
        if (product.PayPalPlanId is null || product.PayPalPlanPrice != price)
        {
            product.PayPalPlanId = await payPal.CreatePlanAsync(product.Name, price, product.Currency, months, cancellationToken: ct);
            product.PayPalPlanPrice = price;
        }
        return product.PayPalPlanId;
    }

    public static string[] AllowedOrigins(IConfiguration configuration) =>
        [configuration["Frontend:PublicUrl"] ?? "https://rtres.net", configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net", "http://localhost:4200", "http://localhost:4201", "http://localhost:4000"];

    /// <summary>URL del portal desde el que se hizo la petición (si es un origen permitido), o <c>Frontend:PortalUrl</c>.</summary>
    public static string PortalBaseUrl(HttpRequest? request, IConfiguration configuration)
    {
        var origin = request?.Headers.Origin.ToString().TrimEnd('/');
        if (!string.IsNullOrEmpty(origin) && AllowedOrigins(configuration).Any(x => string.Equals(x.TrimEnd('/'), origin, StringComparison.OrdinalIgnoreCase))) return origin;
        return (configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net").TrimEnd('/');
    }
}
ParseOptions.0.json�A
JC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Services\PayPalPaymentService.cs�@using System.Globalization;
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
        transaction.InternalCode = await db.NextInternalCodeAsync(ct);
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

    /// <summary>
    /// Deshace <see cref="ExtendPeriod"/> al extornar un pago: Anual resta los años pagados; en suscripciones el próximo
    /// cobro solo vuelve atrás si este era el último pago (<paramref name="isLatestPayment"/>), porque cada pago lo fija de nuevo.
    /// </summary>
    public static void RollbackPeriod(ClientProduct item, int years, bool isLatestPayment)
    {
        switch (item.BillingCycle)
        {
            case BillingCycle.Anual:
                item.RenewsAt = item.RenewsAt?.AddYears(-years);
                break;
            case var cycle when cycle.SubscriptionMonths() is int months && isLatestPayment:
                item.NextChargeAt = item.NextChargeAt?.AddMonths(-months);
                break;
        }
    }

    /// <summary>Un cobro de PayPal extornado cuenta como existente: el webhook y la conciliación no deben volver a crearlo.</summary>
    private async Task<bool> PaymentExistsAsync(string transactionKey, CancellationToken ct) =>
        await db.PaymentTransactions.AnyAsync(x => x.PayPalOrderIdOrSubscriptionId == transactionKey, ct)
        || await db.PaymentReversals.AnyAsync(x => x.PaymentKey == transactionKey && x.Method == PaymentMethods.PayPal, ct);
}
ParseOptions.0.json�X
HC:\repo\rtres-net\Rtres\src\api\Rtres.Api\Services\TaxDocumentService.cs�Xusing Microsoft.EntityFrameworkCore;
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
ParseOptions.0.json�
WC:\repo\rtres-net\Rtres\src\api\Rtres.Api\obj\Debug\net10.0\Rtres.Api.GlobalUsings.g.cs�// <auto-generated/>
global using Microsoft.AspNetCore.Builder;
global using Microsoft.AspNetCore.Hosting;
global using Microsoft.AspNetCore.Http;
global using Microsoft.AspNetCore.Routing;
global using Microsoft.Extensions.Configuration;
global using Microsoft.Extensions.DependencyInjection;
global using Microsoft.Extensions.Hosting;
global using Microsoft.Extensions.Logging;
global using System;
global using System.Collections.Generic;
global using System.IO;
global using System.Linq;
global using System.Net.Http;
global using System.Net.Http.Json;
global using System.Threading;
global using System.Threading.Tasks;
ParseOptions.0.json�
kC:\repo\rtres-net\Rtres\src\api\Rtres.Api\obj\Debug\net10.0\.NETCoreApp,Version=v10.0.AssemblyAttributes.cs�// <autogenerated />
using System;
using System.Reflection;
[assembly: global::System.Runtime.Versioning.TargetFrameworkAttribute(".NETCoreApp,Version=v10.0", FrameworkDisplayName = ".NET 10.0")]
ParseOptions.0.json�	
UC:\repo\rtres-net\Rtres\src\api\Rtres.Api\obj\Debug\net10.0\Rtres.Api.AssemblyInfo.cs�//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Reflection;

[assembly: System.Reflection.AssemblyCompanyAttribute("Rtres.Api")]
[assembly: System.Reflection.AssemblyConfigurationAttribute("Debug")]
[assembly: System.Reflection.AssemblyFileVersionAttribute("1.0.0.0")]
[assembly: System.Reflection.AssemblyInformationalVersionAttribute("1.0.0+aaa6dd32d60330ac2233cef8fc8e5ea18d10aca9")]
[assembly: System.Reflection.AssemblyProductAttribute("Rtres.Api")]
[assembly: System.Reflection.AssemblyTitleAttribute("Rtres.Api")]
[assembly: System.Reflection.AssemblyVersionAttribute("1.0.0.0")]
[assembly: System.Runtime.CompilerServices.InternalsVisibleTo("Rtres.Api.Tests")]

// Generated by the MSBuild WriteCodeFragment class.

ParseOptions.0.json�
hC:\repo\rtres-net\Rtres\src\api\Rtres.Api\obj\Debug\net10.0\Rtres.Api.MvcApplicationPartsAssemblyInfo.cs�//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Reflection;

[assembly: Microsoft.AspNetCore.Mvc.ApplicationParts.ApplicationPartAttribute("Microsoft.AspNetCore.OpenApi")]

// Generated by the MSBuild WriteCodeFragment class.

ParseOptions.0.json��
�C:\repo\rtres-net\Rtres\src\api\Rtres.Api\obj\Debug\net10.0\Microsoft.AspNetCore.OpenApi.SourceGenerators\Microsoft.AspNetCore.OpenApi.SourceGenerators.XmlCommentGenerator\OpenApiXmlCommentSupport.generated.cs��//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------
#nullable enable
// Suppress warnings about obsolete types and members
// in generated code
#pragma warning disable CS0612, CS0618

namespace System.Runtime.CompilerServices
{
    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = true)]
    file sealed class InterceptsLocationAttribute : System.Attribute
    {
        public InterceptsLocationAttribute(int version, string data)
        {
        }
    }
}

namespace Microsoft.AspNetCore.OpenApi.Generated
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Linq;
    using System.Reflection;
    using System.Text;
    using System.Text.Json;
    using System.Text.Json.Nodes;
    using System.Threading;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.OpenApi;
    using Microsoft.AspNetCore.Mvc.Controllers;
    using Microsoft.AspNetCore.Mvc.ModelBinding.Metadata;
    using Microsoft.Extensions.DependencyInjection;
    using Microsoft.OpenApi;

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file record XmlComment(
        string? Summary,
        string? Description,
        string? Remarks,
        string? Returns,
        string? Value,
        bool Deprecated,
        List<string>? Examples,
        List<XmlParameterComment>? Parameters,
        List<XmlResponseComment>? Responses);

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file record XmlParameterComment(string? Name, string? Description, string? Example, bool Deprecated);

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file record XmlResponseComment(string Code, string? Description, string? Example);

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file static class XmlCommentCache
    {
        private static Dictionary<string, XmlComment>? _cache;
        public static Dictionary<string, XmlComment> Cache => _cache ??= GenerateCacheEntries();

        private static Dictionary<string, XmlComment> GenerateCacheEntries()
        {
            var cache = new Dictionary<string, XmlComment>();



            return cache;
        }
    }

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file static class DocumentationCommentIdHelper
    {
        /// <summary>
        /// Generates a documentation comment ID for a type.
        /// Example: T:Namespace.Outer+Inner`1 becomes T:Namespace.Outer.Inner`1
        /// </summary>
        public static string CreateDocumentationId(this Type type)
        {
            if (type == null)
            {
                throw new ArgumentNullException(nameof(type));
            }

            return "T:" + GetTypeDocId(type, includeGenericArguments: false, omitGenericArity: false);
        }

        /// <summary>
        /// Generates a documentation comment ID for a property.
        /// Example: P:Namespace.ContainingType.PropertyName or for an indexer P:Namespace.ContainingType.Item(System.Int32)
        /// </summary>
        public static string CreateDocumentationId(this PropertyInfo property)
        {
            if (property == null)
            {
                throw new ArgumentNullException(nameof(property));
            }

            var sb = new StringBuilder();
            sb.Append("P:");

            if (property.DeclaringType != null)
            {
                sb.Append(GetTypeDocId(property.DeclaringType, includeGenericArguments: false, omitGenericArity: false));
            }

            sb.Append('.');
            sb.Append(property.Name);

            // For indexers, include the parameter list.
            var indexParams = property.GetIndexParameters();
            if (indexParams.Length > 0)
            {
                sb.Append('(');
                for (int i = 0; i < indexParams.Length; i++)
                {
                    if (i > 0)
                    {
                        sb.Append(',');
                    }

                    sb.Append(GetTypeDocId(indexParams[i].ParameterType, includeGenericArguments: true, omitGenericArity: false));
                }
                sb.Append(')');
            }

            return sb.ToString();
        }

        /// <summary>
        /// Generates a documentation comment ID for a property given its container type and property name.
        /// Example: P:Namespace.ContainingType.PropertyName
        /// </summary>
        public static string CreateDocumentationId(Type containerType, string propertyName)
        {
            if (containerType == null)
            {
                throw new ArgumentNullException(nameof(containerType));
            }
            if (string.IsNullOrEmpty(propertyName))
            {
                throw new ArgumentException("Property name cannot be null or empty.", nameof(propertyName));
            }

            var sb = new StringBuilder();
            sb.Append("P:");
            sb.Append(GetTypeDocId(containerType, includeGenericArguments: false, omitGenericArity: false));
            sb.Append('.');
            sb.Append(propertyName);

            return sb.ToString();
        }

        /// <summary>
        /// Generates a documentation comment ID for a method (or constructor).
        /// For example:
        ///   M:Namespace.ContainingType.MethodName(ParamType1,ParamType2)~ReturnType
        ///   M:Namespace.ContainingType.#ctor(ParamType)
        /// </summary>
        public static string CreateDocumentationId(this MethodInfo method)
        {
            if (method == null)
            {
                throw new ArgumentNullException(nameof(method));
            }

            var sb = new StringBuilder();
            sb.Append("M:");

            // Append the fully qualified name of the declaring type.
            if (method.DeclaringType != null)
            {
                sb.Append(GetTypeDocId(method.DeclaringType, includeGenericArguments: false, omitGenericArity: false));
            }

            sb.Append('.');

            // Append the method name, handling constructors specially.
            if (method.IsConstructor)
            {
                sb.Append(method.IsStatic ? "#cctor" : "#ctor");
            }
            else
            {
                sb.Append(method.Name);
                if (method.IsGenericMethod)
                {
                    sb.Append("``");
                    sb.AppendFormat(CultureInfo.InvariantCulture, "{0}", method.GetGenericArguments().Length);
                }
            }

            // Append the parameter list, if any.
            var parameters = method.GetParameters();
            if (parameters.Length > 0)
            {
                sb.Append('(');
                for (int i = 0; i < parameters.Length; i++)
                {
                    if (i > 0)
                    {
                        sb.Append(',');
                    }

                    // Omit the generic arity for the parameter type.
                    sb.Append(GetTypeDocId(parameters[i].ParameterType, includeGenericArguments: true, omitGenericArity: true));
                }
                sb.Append(')');
            }

            // Append the return type after a '~' (if the method returns a value).
            if (method.ReturnType != typeof(void))
            {
                sb.Append('~');
                // Omit the generic arity for the return type.
                sb.Append(GetTypeDocId(method.ReturnType, includeGenericArguments: true, omitGenericArity: true));
            }

            return sb.ToString();
        }

        /// <summary>
        /// Generates a documentation ID string for a type.
        /// This method handles nested types (replacing '+' with '.'),
        /// generic types, arrays, pointers, by-ref types, and generic parameters.
        /// The <paramref name="includeGenericArguments"/> flag controls whether
        /// constructed generic type arguments are emitted, while <paramref name="omitGenericArity"/>
        /// controls whether the generic arity marker (e.g. "`1") is appended.
        /// </summary>
        private static string GetTypeDocId(Type type, bool includeGenericArguments, bool omitGenericArity)
        {
            if (type.IsGenericParameter)
            {
                // Use `` for method-level generic parameters and ` for type-level.
                if (type.DeclaringMethod != null)
                {
                    return "``" + type.GenericParameterPosition;
                }
                else if (type.DeclaringType != null)
                {
                    return "`" + type.GenericParameterPosition;
                }
                else
                {
                    return type.Name;
                }
            }

            if (type.IsGenericType)
            {
                Type genericDef = type.GetGenericTypeDefinition();
                string fullName = genericDef.FullName ?? genericDef.Name;

                var sb = new StringBuilder(fullName.Length);

                // Replace '+' with '.' for nested types
                for (var i = 0; i < fullName.Length; i++)
                {
                    char c = fullName[i];
                    if (c == '+')
                    {
                        sb.Append('.');
                    }
                    else if (c == '`')
                    {
                        break;
                    }
                    else
                    {
                        sb.Append(c);
                    }
                }

                if (!omitGenericArity)
                {
                    int arity = genericDef.GetGenericArguments().Length;
                    sb.Append('`');
                    sb.AppendFormat(CultureInfo.InvariantCulture, "{0}", arity);
                }

                if (includeGenericArguments && !type.IsGenericTypeDefinition)
                {
                    var typeArgs = type.GetGenericArguments();
                    sb.Append('{');

                    for (int i = 0; i < typeArgs.Length; i++)
                    {
                        if (i > 0)
                        {
                            sb.Append(',');
                        }

                        sb.Append(GetTypeDocId(typeArgs[i], includeGenericArguments, omitGenericArity));
                    }

                    sb.Append('}');
                }

                return sb.ToString();
            }

            // For non-generic types, use FullName (if available) and replace nested type separators.
            return (type.FullName ?? type.Name).Replace('+', '.');
        }

        /// <summary>
        /// Normalizes a documentation comment ID to match the compiler-style format.
        /// Strips the return type suffix for ordinary methods but retains it for conversion operators.
        /// </summary>
        /// <param name="docId">The documentation comment ID to normalize.</param>
        /// <returns>The normalized documentation comment ID.</returns>
        public static string NormalizeDocId(string docId)
        {
            // Find the tilde character that indicates the return type suffix
            var tildeIndex = docId.IndexOf('~');
            if (tildeIndex == -1)
            {
                // No return type suffix, return as-is
                return docId;
            }

            // Check if this is a conversion operator (op_Implicit or op_Explicit)
            // For these operators, we need to keep the return type suffix
            if (docId.Contains("op_Implicit") || docId.Contains("op_Explicit"))
            {
                return docId;
            }

            // For ordinary methods, strip the return type suffix
            return docId.Substring(0, tildeIndex);
        }
    }

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file class XmlCommentOperationTransformer : IOpenApiOperationTransformer
    {
        public Task TransformAsync(OpenApiOperation operation, OpenApiOperationTransformerContext context, CancellationToken cancellationToken)
        {
            var methodInfo = context.Description.ActionDescriptor is ControllerActionDescriptor controllerActionDescriptor
                ? controllerActionDescriptor.MethodInfo
                : context.Description.ActionDescriptor.EndpointMetadata.OfType<MethodInfo>().SingleOrDefault();

            if (methodInfo is null)
            {
                return Task.CompletedTask;
            }
            if (XmlCommentCache.Cache.TryGetValue(DocumentationCommentIdHelper.NormalizeDocId(methodInfo.CreateDocumentationId()), out var methodComment))
            {
                if (methodComment.Summary is { } summary)
                {
                    operation.Summary = summary;
                }
                if (methodComment.Description is { } description)
                {
                    operation.Description = description;
                }
                if (methodComment.Remarks is { } remarks)
                {
                    operation.Description = remarks;
                }
                if (methodComment.Parameters is { Count: > 0})
                {
                    foreach (var parameterComment in methodComment.Parameters)
                    {
                        var parameterInfo = methodInfo.GetParameters().SingleOrDefault(info => info.Name == parameterComment.Name);
                        var operationParameter = operation.Parameters?.SingleOrDefault(parameter => parameter.Name == parameterComment.Name);
                        if (operationParameter is not null)
                        {
                            var targetOperationParameter = UnwrapOpenApiParameter(operationParameter);
                            targetOperationParameter.Description = parameterComment.Description;
                            if (parameterComment.Example is { } jsonString)
                            {
                                targetOperationParameter.Example = jsonString.Parse();
                            }
                            targetOperationParameter.Deprecated = parameterComment.Deprecated;
                        }
                        else
                        {
                            var requestBody = operation.RequestBody;
                            if (requestBody is not null)
                            {
                                requestBody.Description = parameterComment.Description;
                                if (parameterComment.Example is { } jsonString)
                                {
                                    var content = requestBody?.Content?.Values;
                                    if (content is null)
                                    {
                                        continue;
                                    }
                                    foreach (var mediaType in content)
                                    {
                                        mediaType.Example = jsonString.Parse();
                                    }
                                }
                            }
                        }
                    }
                }
                // Applies `<returns>` on XML comments for operation with single response value.
                if (methodComment.Returns is { } returns && operation.Responses is { Count: 1 })
                {
                    var response = operation.Responses.First();
                    response.Value.Description = returns;
                }
                // Applies `<response>` on XML comments for operation with multiple response values.
                if (methodComment.Responses is { Count: > 0} && operation.Responses is { Count: > 0 })
                {
                    foreach (var response in operation.Responses)
                    {
                        var responseComment = methodComment.Responses.SingleOrDefault(xmlResponse => xmlResponse.Code == response.Key);
                        if (responseComment is not null)
                        {
                            response.Value.Description = responseComment.Description;
                        }
                    }
                }
            }
            foreach (var parameterDescription in context.Description.ParameterDescriptions)
            {
                var metadata = parameterDescription.ModelMetadata;
                if (metadata is not null
                    && metadata.MetadataKind == ModelMetadataKind.Property
                    && metadata.ContainerType is { } containerType
                    && metadata.PropertyName is { } propertyName)
                {
                    var propertyDocId = DocumentationCommentIdHelper.CreateDocumentationId(containerType, propertyName);
                    if (XmlCommentCache.Cache.TryGetValue(DocumentationCommentIdHelper.NormalizeDocId(propertyDocId), out var propertyComment))
                    {
                        var parameter = operation.Parameters?.SingleOrDefault(p => p.Name == metadata.Name);
                        var description = propertyComment.Summary;
                        if (!string.IsNullOrEmpty(description) && !string.IsNullOrEmpty(propertyComment.Value))
                        {
                            description = $"{description}\n{propertyComment.Value}";
                        }
                        else if (string.IsNullOrEmpty(description))
                        {
                            description = propertyComment.Value;
                        }
                        if (parameter is null)
                        {
                            if (operation.RequestBody is not null)
                            {
                                operation.RequestBody.Description = description;
                                if (propertyComment.Examples?.FirstOrDefault() is { } jsonString)
                                {
                                    var content = operation.RequestBody.Content?.Values;
                                    if (content is null)
                                    {
                                        continue;
                                    }
                                    var parsedExample = jsonString.Parse();
                                    foreach (var mediaType in content)
                                    {
                                        mediaType.Example = parsedExample;
                                    }
                                }
                            }
                            continue;
                        }
                        var targetOperationParameter = UnwrapOpenApiParameter(parameter);
                        if (targetOperationParameter is not null)
                        {
                            targetOperationParameter.Description = description;
                            if (propertyComment.Examples?.FirstOrDefault() is { } jsonString)
                            {
                                targetOperationParameter.Example = jsonString.Parse();
                            }
                        }
                    }
                }
            }

            return Task.CompletedTask;
        }

        private static OpenApiParameter UnwrapOpenApiParameter(IOpenApiParameter sourceParameter)
        {
            if (sourceParameter is OpenApiParameterReference parameterReference)
            {
                if (parameterReference.Target is OpenApiParameter target)
                {
                    return target;
                }
                else
                {
                    throw new InvalidOperationException($"The input schema must be an {nameof(OpenApiParameter)} or {nameof(OpenApiParameterReference)}.");
                }
            }
            else if (sourceParameter is OpenApiParameter directParameter)
            {
                return directParameter;
            }
            else
            {
                throw new InvalidOperationException($"The input schema must be an {nameof(OpenApiParameter)} or {nameof(OpenApiParameterReference)}.");
            }
        }
    }

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file class XmlCommentSchemaTransformer : IOpenApiSchemaTransformer
    {
        public Task TransformAsync(OpenApiSchema schema, OpenApiSchemaTransformerContext context, CancellationToken cancellationToken)
        {
            // Apply comments from the type
            if (XmlCommentCache.Cache.TryGetValue(DocumentationCommentIdHelper.NormalizeDocId(context.JsonTypeInfo.Type.CreateDocumentationId()), out var typeComment))
            {
                schema.Description = typeComment.Summary;
                if (typeComment.Examples?.FirstOrDefault() is { } jsonString)
                {
                    schema.Example = jsonString.Parse();
                }
            }

            if (context.JsonPropertyInfo is { AttributeProvider: PropertyInfo propertyInfo })
            {
                // Apply comments from the property
                if (XmlCommentCache.Cache.TryGetValue(DocumentationCommentIdHelper.NormalizeDocId(propertyInfo.CreateDocumentationId()), out var propertyComment))
                {
                    var description = propertyComment.Summary;
                    if (!string.IsNullOrEmpty(description) && !string.IsNullOrEmpty(propertyComment.Value))
                    {
                        description = $"{description}\n{propertyComment.Value}";
                    }
                    else if (string.IsNullOrEmpty(description))
                    {
                        description = propertyComment.Value;
                    }
                    if (schema.Metadata is null
                        || !schema.Metadata.TryGetValue("x-schema-id", out var schemaId)
                        || string.IsNullOrEmpty(schemaId as string))
                    {
                        // Inlined schema
                        schema.Description = description;
                        if (propertyComment.Examples?.FirstOrDefault() is { } jsonString)
                        {
                            schema.Example = jsonString.Parse();
                        }
                    }
                    else
                    {
                        // Schema Reference
                        if (!string.IsNullOrEmpty(description))
                        {
                            schema.Metadata["x-ref-description"] = description;
                        }
                        if (propertyComment.Examples?.FirstOrDefault() is { } jsonString)
                        {
                            schema.Metadata["x-ref-example"] = jsonString.Parse()!;
                        }
                    }
                }
            }
            return Task.CompletedTask;
        }
    }

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file static class JsonNodeExtensions
    {
        public static JsonNode? Parse(this string? json)
        {
            if (json is null)
            {
                return null;
            }

            try
            {
                return JsonNode.Parse(json);
            }
            catch (JsonException)
            {
                try
                {
                    // If parsing fails, try wrapping in quotes to make it a valid JSON string
                    return JsonNode.Parse($"\"{json.Replace("\"", "\\\"")}\"");
                }
                catch (JsonException)
                {
                    return null;
                }
            }
        }
    }

    [System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.AspNetCore.OpenApi.SourceGenerators, Version=10.0.8.0, Culture=neutral, PublicKeyToken=adb9793829ddae60", "10.0.8.0")]
    file static class GeneratedServiceCollectionExtensions
    {
        [global::System.Runtime.CompilerServices.InterceptsLocationAttribute(1, "K0e3l1JFnEGP6AT+I8IWsTUDAABQcm9ncmFtLmNz")]
        public static IServiceCollection AddOpenApi(this IServiceCollection services)
        {
            return services.AddOpenApi("v1", options =>
            {
                options.AddSchemaTransformer(new XmlCommentSchemaTransformer());
                options.AddOperationTransformer(new XmlCommentOperationTransformer());
            });
        }

    }
}
ParseOptions.0.json��
�C:\repo\rtres-net\Rtres\src\api\Rtres.Api\obj\Debug\net10.0\System.Text.RegularExpressions.Generator\System.Text.RegularExpressions.Generator.RegexGenerator\RegexGenerator.g.cs��// <auto-generated/>
#nullable enable
#pragma warning disable

namespace Rtres.Api.Controllers
{
    partial class AdminController
    {
        /// <remarks>
        /// Pattern:<br/>
        /// <code>^\\d{11}$</code><br/>
        /// Explanation:<br/>
        /// <code>
        /// ○ Match if at the beginning of the string.<br/>
        /// ○ Match a Unicode digit exactly 11 times.<br/>
        /// ○ Match if at the end of the string or if before an ending newline.<br/>
        /// </code>
        /// </remarks>
        [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Text.RegularExpressions.Generator", "10.0.15.2326")]
        private static partial global::System.Text.RegularExpressions.Regex RucRegex() => global::System.Text.RegularExpressions.Generated.RucRegex_0.Instance;
    }
}

namespace Rtres.Api.Controllers
{
    partial class BankTransfersController
    {
        /// <remarks>
        /// Pattern:<br/>
        /// <code>^\\d{20}$</code><br/>
        /// Explanation:<br/>
        /// <code>
        /// ○ Match if at the beginning of the string.<br/>
        /// ○ Match a Unicode digit exactly 20 times.<br/>
        /// ○ Match if at the end of the string or if before an ending newline.<br/>
        /// </code>
        /// </remarks>
        [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Text.RegularExpressions.Generator", "10.0.15.2326")]
        private static partial global::System.Text.RegularExpressions.Regex CciPattern() => global::System.Text.RegularExpressions.Generated.CciPattern_1.Instance;
    }
}

namespace Rtres.Api.Controllers
{
    partial class BankTransfersController
    {
        /// <remarks>
        /// Pattern:<br/>
        /// <code>\\s+</code><br/>
        /// Explanation:<br/>
        /// <code>
        /// ○ Match a whitespace character atomically at least once.<br/>
        /// </code>
        /// </remarks>
        [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Text.RegularExpressions.Generator", "10.0.15.2326")]
        private static partial global::System.Text.RegularExpressions.Regex WhitespacePattern() => global::System.Text.RegularExpressions.Generated.WhitespacePattern_2.Instance;
    }
}

namespace Rtres.Api.Controllers
{
    partial class LearningVideosController
    {
        /// <remarks>
        /// Pattern:<br/>
        /// <code>^[A-Za-z0-9_-]{11}$</code><br/>
        /// Explanation:<br/>
        /// <code>
        /// ○ Match if at the beginning of the string.<br/>
        /// ○ Match a character in the set [\-0-9A-Z_a-z] exactly 11 times.<br/>
        /// ○ Match if at the end of the string or if before an ending newline.<br/>
        /// </code>
        /// </remarks>
        [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Text.RegularExpressions.Generator", "10.0.15.2326")]
        private static partial global::System.Text.RegularExpressions.Regex YoutubeIdRegex() => global::System.Text.RegularExpressions.Generated.YoutubeIdRegex_3.Instance;
    }
}

namespace Rtres.Api.Controllers
{
    partial class LearningVideosController
    {
        /// <remarks>
        /// Pattern:<br/>
        /// <code>^(?:https?://)?(?:www\\.|m\\.|music\\.)?(?:youtube\\.com/(?:watch\\?(?:.*&amp;)?v=|embed/|shorts/|live/)|youtu\\.be/)(?&lt;id&gt;[A-Za-z0-9_-]{11})(?:[?&amp;#/].*)?$</code><br/>
        /// Options:<br/>
        /// <code>RegexOptions.IgnoreCase</code><br/>
        /// Explanation:<br/>
        /// <code>
        /// ○ Match if at the beginning of the string.<br/>
        /// ○ Optional (greedy).<br/>
        ///     ○ Match a character in the set [Hh].<br/>
        ///     ○ Match a character in the set [Tt] exactly 2 times.<br/>
        ///     ○ Match a character in the set [Pp].<br/>
        ///     ○ Match a character in the set [Ss] atomically, optionally.<br/>
        ///     ○ Match the string "://".<br/>
        /// ○ Optional (greedy).<br/>
        ///     ○ Match with 2 alternative expressions.<br/>
        ///         ○ Match a sequence of expressions.<br/>
        ///             ○ Match a character in the set [Ww] exactly 3 times.<br/>
        ///             ○ Match '.'.<br/>
        ///         ○ Match a sequence of expressions.<br/>
        ///             ○ Match a character in the set [Mm].<br/>
        ///             ○ Match with 2 alternative expressions.<br/>
        ///                 ○ Match '.'.<br/>
        ///                 ○ Match a sequence of expressions.<br/>
        ///                     ○ Match a character in the set [Uu].<br/>
        ///                     ○ Match a character in the set [Ss].<br/>
        ///                     ○ Match a character in the set [Ii].<br/>
        ///                     ○ Match a character in the set [Cc].<br/>
        ///                     ○ Match '.'.<br/>
        /// ○ Match a character in the set [Yy].<br/>
        /// ○ Match a character in the set [Oo].<br/>
        /// ○ Match a character in the set [Uu].<br/>
        /// ○ Match a character in the set [Tt].<br/>
        /// ○ Match a character in the set [Uu].<br/>
        /// ○ Match with 2 alternative expressions.<br/>
        ///     ○ Match a sequence of expressions.<br/>
        ///         ○ Match a character in the set [Bb].<br/>
        ///         ○ Match a character in the set [Ee].<br/>
        ///         ○ Match '.'.<br/>
        ///         ○ Match a character in the set [Cc].<br/>
        ///         ○ Match a character in the set [Oo].<br/>
        ///         ○ Match a character in the set [Mm].<br/>
        ///         ○ Match '/'.<br/>
        ///         ○ Match with 4 alternative expressions.<br/>
        ///             ○ Match a sequence of expressions.<br/>
        ///                 ○ Match a character in the set [Ww].<br/>
        ///                 ○ Match a character in the set [Aa].<br/>
        ///                 ○ Match a character in the set [Tt].<br/>
        ///                 ○ Match a character in the set [Cc].<br/>
        ///                 ○ Match a character in the set [Hh].<br/>
        ///                 ○ Match '?'.<br/>
        ///                 ○ Optional (greedy).<br/>
        ///                     ○ Match a character other than '\n' greedily any number of times.<br/>
        ///                     ○ Match '&amp;'.<br/>
        ///                 ○ Match a character in the set [Vv].<br/>
        ///                 ○ Match '='.<br/>
        ///             ○ Match a sequence of expressions.<br/>
        ///                 ○ Match a character in the set [Ee].<br/>
        ///                 ○ Match a character in the set [Mm].<br/>
        ///                 ○ Match a character in the set [Bb].<br/>
        ///                 ○ Match a character in the set [Ee].<br/>
        ///                 ○ Match a character in the set [Dd].<br/>
        ///                 ○ Match '/'.<br/>
        ///             ○ Match a sequence of expressions.<br/>
        ///                 ○ Match a character in the set [Ss].<br/>
        ///                 ○ Match a character in the set [Hh].<br/>
        ///                 ○ Match a character in the set [Oo].<br/>
        ///                 ○ Match a character in the set [Rr].<br/>
        ///                 ○ Match a character in the set [Tt].<br/>
        ///                 ○ Match a character in the set [Ss].<br/>
        ///                 ○ Match '/'.<br/>
        ///             ○ Match a sequence of expressions.<br/>
        ///                 ○ Match a character in the set [Ll].<br/>
        ///                 ○ Match a character in the set [Ii].<br/>
        ///                 ○ Match a character in the set [Vv].<br/>
        ///                 ○ Match a character in the set [Ee].<br/>
        ///                 ○ Match '/'.<br/>
        ///     ○ Match a sequence of expressions.<br/>
        ///         ○ Match '.'.<br/>
        ///         ○ Match a character in the set [Bb].<br/>
        ///         ○ Match a character in the set [Ee].<br/>
        ///         ○ Match '/'.<br/>
        /// ○ "id" capture group.<br/>
        ///     ○ Match a character in the set [\-0-9A-Z_a-z\u212A] exactly 11 times.<br/>
        /// ○ Optional (greedy).<br/>
        ///     ○ Match a character in the set [#&amp;/?].<br/>
        ///     ○ Match a character other than '\n' greedily any number of times.<br/>
        /// ○ Match if at the end of the string or if before an ending newline.<br/>
        /// </code>
        /// </remarks>
        [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Text.RegularExpressions.Generator", "10.0.15.2326")]
        private static partial global::System.Text.RegularExpressions.Regex YoutubeUrlRegex() => global::System.Text.RegularExpressions.Generated.YoutubeUrlRegex_4.Instance;
    }
}

namespace System.Text.RegularExpressions.Generated
{
    using System;
    using System.Buffers;
    using System.CodeDom.Compiler;
    using System.Collections;
    using System.ComponentModel;
    using System.Globalization;
    using System.Runtime.CompilerServices;
    using System.Text.RegularExpressions;
    using System.Threading;

    /// <summary>Custom <see cref="Regex"/>-derived type for the RucRegex method.</summary>
    [GeneratedCodeAttribute("System.Text.RegularExpressions.Generator", "10.0.15.2326")]
    file sealed class RucRegex_0 : Regex
    {
        /// <summary>Cached, thread-safe singleton instance.</summary>
        internal static readonly RucRegex_0 Instance = new();
    
        /// <summary>Initializes the instance.</summary>
        private RucRegex_0()
        {
            base.pattern = "^\\d{11}$";
            base.roptions = RegexOptions.None;
            ValidateMatchTimeout(Utilities.s_defaultTimeout);
            base.internalMatchTimeout = Utilities.s_defaultTimeout;
            base.factory = new RunnerFactory();
            base.capsize = 1;
        }
            
        /// <summary>Provides a factory for creating <see cref="RegexRunner"/> instances to be used by methods on <see cref="Regex"/>.</summary>
        private sealed class RunnerFactory : RegexRunnerFactory
        {
            /// <summary>Creates an instance of a <see cref="RegexRunner"/> used by methods on <see cref="Regex"/>.</summary>
            protected override RegexRunner CreateInstance() => new Runner();
        
            /// <summary>Provides the runner that contains the custom logic implementing the specified regular expression.</summary>
            private sealed class Runner : RegexRunner
            {
                /// <summary>Scan the <paramref name="inputSpan"/> starting from base.runtextstart for the next match.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                protected override void Scan(ReadOnlySpan<char> inputSpan)
                {
                    // The pattern is anchored.  Validate the current position and try to match at it only.
                    if (TryFindNextPossibleStartingPosition(inputSpan) && !TryMatchAtCurrentPosition(inputSpan))
                    {
                        base.runtextpos = inputSpan.Length;
                    }
                }
        
                /// <summary>Search <paramref name="inputSpan"/> starting from base.runtextpos for the next location a match could possibly start.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                /// <returns>true if a possible match was found; false if no more matches are possible.</returns>
                private bool TryFindNextPossibleStartingPosition(ReadOnlySpan<char> inputSpan)
                {
                    int pos = base.runtextpos;
                    
                    // Any possible match is at least 11 characters.
                    if (pos <= inputSpan.Length - 11)
                    {
                        // The pattern leads with a beginning (\A) anchor.
                        if (pos == 0)
                        {
                            return true;
                        }
                    }
                    
                    // No match found.
                    base.runtextpos = inputSpan.Length;
                    return false;
                }
        
                /// <summary>Determine whether <paramref name="inputSpan"/> at base.runtextpos is a match for the regular expression.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                /// <returns>true if the regular expression matches at the current position; otherwise, false.</returns>
                private bool TryMatchAtCurrentPosition(ReadOnlySpan<char> inputSpan)
                {
                    int pos = base.runtextpos;
                    int matchStart = pos;
                    ReadOnlySpan<char> slice = inputSpan.Slice(pos);
                    
                    // Match if at the beginning of the string.
                    if (pos != 0)
                    {
                        return false; // The input didn't match.
                    }
                    
                    // Match a Unicode digit exactly 11 times.
                    {
                        if ((uint)slice.Length < 11 ||
                            !char.IsDigit(slice[0]) ||
                            !char.IsDigit(slice[1]) ||
                            !char.IsDigit(slice[2]) ||
                            !char.IsDigit(slice[3]) ||
                            !char.IsDigit(slice[4]) ||
                            !char.IsDigit(slice[5]) ||
                            !char.IsDigit(slice[6]) ||
                            !char.IsDigit(slice[7]) ||
                            !char.IsDigit(slice[8]) ||
                            !char.IsDigit(slice[9]) ||
                            !char.IsDigit(slice[10]))
                        {
                            return false; // The input didn't match.
                        }
                    }
                    
                    // Match if at the end of the string or if before an ending newline.
                    if (12 < slice.Length || (11 < slice.Length && slice[11] != '\n'))
                    {
                        return false; // The input didn't match.
                    }
                    
                    // The input matched.
                    pos += 11;
                    base.runtextpos = pos;
                    base.Capture(0, matchStart, pos);
                    return true;
                }
            }
        }

    }
    
    /// <summary>Custom <see cref="Regex"/>-derived type for the CciPattern method.</summary>
    [GeneratedCodeAttribute("System.Text.RegularExpressions.Generator", "10.0.15.2326")]
    file sealed class CciPattern_1 : Regex
    {
        /// <summary>Cached, thread-safe singleton instance.</summary>
        internal static readonly CciPattern_1 Instance = new();
    
        /// <summary>Initializes the instance.</summary>
        private CciPattern_1()
        {
            base.pattern = "^\\d{20}$";
            base.roptions = RegexOptions.None;
            ValidateMatchTimeout(Utilities.s_defaultTimeout);
            base.internalMatchTimeout = Utilities.s_defaultTimeout;
            base.factory = new RunnerFactory();
            base.capsize = 1;
        }
            
        /// <summary>Provides a factory for creating <see cref="RegexRunner"/> instances to be used by methods on <see cref="Regex"/>.</summary>
        private sealed class RunnerFactory : RegexRunnerFactory
        {
            /// <summary>Creates an instance of a <see cref="RegexRunner"/> used by methods on <see cref="Regex"/>.</summary>
            protected override RegexRunner CreateInstance() => new Runner();
        
            /// <summary>Provides the runner that contains the custom logic implementing the specified regular expression.</summary>
            private sealed class Runner : RegexRunner
            {
                /// <summary>Scan the <paramref name="inputSpan"/> starting from base.runtextstart for the next match.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                protected override void Scan(ReadOnlySpan<char> inputSpan)
                {
                    // The pattern is anchored.  Validate the current position and try to match at it only.
                    if (TryFindNextPossibleStartingPosition(inputSpan) && !TryMatchAtCurrentPosition(inputSpan))
                    {
                        base.runtextpos = inputSpan.Length;
                    }
                }
        
                /// <summary>Search <paramref name="inputSpan"/> starting from base.runtextpos for the next location a match could possibly start.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                /// <returns>true if a possible match was found; false if no more matches are possible.</returns>
                private bool TryFindNextPossibleStartingPosition(ReadOnlySpan<char> inputSpan)
                {
                    int pos = base.runtextpos;
                    
                    // Any possible match is at least 20 characters.
                    if (pos <= inputSpan.Length - 20)
                    {
                        // The pattern leads with a beginning (\A) anchor.
                        if (pos == 0)
                        {
                            return true;
                        }
                    }
                    
                    // No match found.
                    base.runtextpos = inputSpan.Length;
                    return false;
                }
        
                /// <summary>Determine whether <paramref name="inputSpan"/> at base.runtextpos is a match for the regular expression.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                /// <returns>true if the regular expression matches at the current position; otherwise, false.</returns>
                private bool TryMatchAtCurrentPosition(ReadOnlySpan<char> inputSpan)
                {
                    int pos = base.runtextpos;
                    int matchStart = pos;
                    ReadOnlySpan<char> slice = inputSpan.Slice(pos);
                    
                    // Match if at the beginning of the string.
                    if (pos != 0)
                    {
                        return false; // The input didn't match.
                    }
                    
                    // Match a Unicode digit exactly 20 times.
                    {
                        if ((uint)slice.Length < 20)
                        {
                            return false; // The input didn't match.
                        }
                        
                        ReadOnlySpan<char> repeaterSlice = slice.Slice(0, 20);
                        for (int i = 0; i < repeaterSlice.Length; i++)
                        {
                            if (!char.IsDigit(repeaterSlice[i]))
                            {
                                return false; // The input didn't match.
                            }
                        }
                    }
                    
                    // Match if at the end of the string or if before an ending newline.
                    if (21 < slice.Length || (20 < slice.Length && slice[20] != '\n'))
                    {
                        return false; // The input didn't match.
                    }
                    
                    // The input matched.
                    pos += 20;
                    base.runtextpos = pos;
                    base.Capture(0, matchStart, pos);
                    return true;
                }
            }
        }

    }
    
    /// <summary>Custom <see cref="Regex"/>-derived type for the WhitespacePattern method.</summary>
    [GeneratedCodeAttribute("System.Text.RegularExpressions.Generator", "10.0.15.2326")]
    file sealed class WhitespacePattern_2 : Regex
    {
        /// <summary>Cached, thread-safe singleton instance.</summary>
        internal static readonly WhitespacePattern_2 Instance = new();
    
        /// <summary>Initializes the instance.</summary>
        private WhitespacePattern_2()
        {
            base.pattern = "\\s+";
            base.roptions = RegexOptions.None;
            ValidateMatchTimeout(Utilities.s_defaultTimeout);
            base.internalMatchTimeout = Utilities.s_defaultTimeout;
            base.factory = new RunnerFactory();
            base.capsize = 1;
        }
            
        /// <summary>Provides a factory for creating <see cref="RegexRunner"/> instances to be used by methods on <see cref="Regex"/>.</summary>
        private sealed class RunnerFactory : RegexRunnerFactory
        {
            /// <summary>Creates an instance of a <see cref="RegexRunner"/> used by methods on <see cref="Regex"/>.</summary>
            protected override RegexRunner CreateInstance() => new Runner();
        
            /// <summary>Provides the runner that contains the custom logic implementing the specified regular expression.</summary>
            private sealed class Runner : RegexRunner
            {
                /// <summary>Scan the <paramref name="inputSpan"/> starting from base.runtextstart for the next match.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                protected override void Scan(ReadOnlySpan<char> inputSpan)
                {
                    // Search until we can't find a valid starting position, we find a match, or we reach the end of the input.
                    while (TryFindNextPossibleStartingPosition(inputSpan) &&
                           !TryMatchAtCurrentPosition(inputSpan) &&
                           base.runtextpos != inputSpan.Length)
                    {
                        base.runtextpos++;
                        if (Utilities.s_hasTimeout)
                        {
                            base.CheckTimeout();
                        }
                    }
                }
        
                /// <summary>Search <paramref name="inputSpan"/> starting from base.runtextpos for the next location a match could possibly start.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                /// <returns>true if a possible match was found; false if no more matches are possible.</returns>
                private bool TryFindNextPossibleStartingPosition(ReadOnlySpan<char> inputSpan)
                {
                    int pos = base.runtextpos;
                    
                    // Empty matches aren't possible.
                    if ((uint)pos < (uint)inputSpan.Length)
                    {
                        // The pattern begins with a whitespace character.
                        // Find the next occurrence. If it can't be found, there's no match.
                        int i = inputSpan.Slice(pos).IndexOfAny(Utilities.s_whitespace);
                        if (i >= 0)
                        {
                            base.runtextpos = pos + i;
                            return true;
                        }
                    }
                    
                    // No match found.
                    base.runtextpos = inputSpan.Length;
                    return false;
                }
        
                /// <summary>Determine whether <paramref name="inputSpan"/> at base.runtextpos is a match for the regular expression.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                /// <returns>true if the regular expression matches at the current position; otherwise, false.</returns>
                private bool TryMatchAtCurrentPosition(ReadOnlySpan<char> inputSpan)
                {
                    int pos = base.runtextpos;
                    int matchStart = pos;
                    ReadOnlySpan<char> slice = inputSpan.Slice(pos);
                    
                    // Match a whitespace character atomically at least once.
                    {
                        int iteration = 0;
                        while ((uint)iteration < (uint)slice.Length && char.IsWhiteSpace(slice[iteration]))
                        {
                            iteration++;
                        }
                        
                        if (iteration == 0)
                        {
                            return false; // The input didn't match.
                        }
                        
                        slice = slice.Slice(iteration);
                        pos += iteration;
                    }
                    
                    // The input matched.
                    base.runtextpos = pos;
                    base.Capture(0, matchStart, pos);
                    return true;
                }
            }
        }

    }
    
    /// <summary>Custom <see cref="Regex"/>-derived type for the YoutubeIdRegex method.</summary>
    [GeneratedCodeAttribute("System.Text.RegularExpressions.Generator", "10.0.15.2326")]
    file sealed class YoutubeIdRegex_3 : Regex
    {
        /// <summary>Cached, thread-safe singleton instance.</summary>
        internal static readonly YoutubeIdRegex_3 Instance = new();
    
        /// <summary>Initializes the instance.</summary>
        private YoutubeIdRegex_3()
        {
            base.pattern = "^[A-Za-z0-9_-]{11}$";
            base.roptions = RegexOptions.None;
            ValidateMatchTimeout(Utilities.s_defaultTimeout);
            base.internalMatchTimeout = Utilities.s_defaultTimeout;
            base.factory = new RunnerFactory();
            base.capsize = 1;
        }
            
        /// <summary>Provides a factory for creating <see cref="RegexRunner"/> instances to be used by methods on <see cref="Regex"/>.</summary>
        private sealed class RunnerFactory : RegexRunnerFactory
        {
            /// <summary>Creates an instance of a <see cref="RegexRunner"/> used by methods on <see cref="Regex"/>.</summary>
            protected override RegexRunner CreateInstance() => new Runner();
        
            /// <summary>Provides the runner that contains the custom logic implementing the specified regular expression.</summary>
            private sealed class Runner : RegexRunner
            {
                /// <summary>Scan the <paramref name="inputSpan"/> starting from base.runtextstart for the next match.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                protected override void Scan(ReadOnlySpan<char> inputSpan)
                {
                    // The pattern is anchored.  Validate the current position and try to match at it only.
                    if (TryFindNextPossibleStartingPosition(inputSpan) && !TryMatchAtCurrentPosition(inputSpan))
                    {
                        base.runtextpos = inputSpan.Length;
                    }
                }
        
                /// <summary>Search <paramref name="inputSpan"/> starting from base.runtextpos for the next location a match could possibly start.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                /// <returns>true if a possible match was found; false if no more matches are possible.</returns>
                private bool TryFindNextPossibleStartingPosition(ReadOnlySpan<char> inputSpan)
                {
                    int pos = base.runtextpos;
                    
                    // Any possible match is at least 11 characters.
                    if (pos <= inputSpan.Length - 11)
                    {
                        // The pattern leads with a beginning (\A) anchor.
                        if (pos == 0)
                        {
                            return true;
                        }
                    }
                    
                    // No match found.
                    base.runtextpos = inputSpan.Length;
                    return false;
                }
        
                /// <summary>Determine whether <paramref name="inputSpan"/> at base.runtextpos is a match for the regular expression.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                /// <returns>true if the regular expression matches at the current position; otherwise, false.</returns>
                private bool TryMatchAtCurrentPosition(ReadOnlySpan<char> inputSpan)
                {
                    int pos = base.runtextpos;
                    int matchStart = pos;
                    char ch;
                    ReadOnlySpan<char> slice = inputSpan.Slice(pos);
                    
                    // Match if at the beginning of the string.
                    if (pos != 0)
                    {
                        return false; // The input didn't match.
                    }
                    
                    // Match a character in the set [\-0-9A-Z_a-z] exactly 11 times.
                    {
                        if ((uint)slice.Length < 11 ||
                            ((ch = slice[0]) >= '{' || ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0) ||
                            ((ch = slice[1]) >= '{' || ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0) ||
                            ((ch = slice[2]) >= '{' || ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0) ||
                            ((ch = slice[3]) >= '{' || ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0) ||
                            ((ch = slice[4]) >= '{' || ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0) ||
                            ((ch = slice[5]) >= '{' || ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0) ||
                            ((ch = slice[6]) >= '{' || ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0) ||
                            ((ch = slice[7]) >= '{' || ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0) ||
                            ((ch = slice[8]) >= '{' || ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0) ||
                            ((ch = slice[9]) >= '{' || ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0) ||
                            ((ch = slice[10]) >= '{' || ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0))
                        {
                            return false; // The input didn't match.
                        }
                    }
                    
                    // Match if at the end of the string or if before an ending newline.
                    if (12 < slice.Length || (11 < slice.Length && slice[11] != '\n'))
                    {
                        return false; // The input didn't match.
                    }
                    
                    // The input matched.
                    pos += 11;
                    base.runtextpos = pos;
                    base.Capture(0, matchStart, pos);
                    return true;
                }
            }
        }

    }
    
    /// <summary>Custom <see cref="Regex"/>-derived type for the YoutubeUrlRegex method.</summary>
    [GeneratedCodeAttribute("System.Text.RegularExpressions.Generator", "10.0.15.2326")]
    file sealed class YoutubeUrlRegex_4 : Regex
    {
        /// <summary>Cached, thread-safe singleton instance.</summary>
        internal static readonly YoutubeUrlRegex_4 Instance = new();
    
        /// <summary>Initializes the instance.</summary>
        private YoutubeUrlRegex_4()
        {
            base.pattern = "^(?:https?://)?(?:www\\.|m\\.|music\\.)?(?:youtube\\.com/(?:watch\\?(?:.*&)?v=|embed/|shorts/|live/)|youtu\\.be/)(?<id>[A-Za-z0-9_-]{11})(?:[?&#/].*)?$";
            base.roptions = RegexOptions.IgnoreCase;
            ValidateMatchTimeout(Utilities.s_defaultTimeout);
            base.internalMatchTimeout = Utilities.s_defaultTimeout;
            base.factory = new RunnerFactory();
            base.CapNames = new Hashtable { { "0", 0 } ,  { "id", 1 }  };
            base.capslist = new string[] {"0", "id" };
            base.capsize = 2;
        }
            
        /// <summary>Provides a factory for creating <see cref="RegexRunner"/> instances to be used by methods on <see cref="Regex"/>.</summary>
        private sealed class RunnerFactory : RegexRunnerFactory
        {
            /// <summary>Creates an instance of a <see cref="RegexRunner"/> used by methods on <see cref="Regex"/>.</summary>
            protected override RegexRunner CreateInstance() => new Runner();
        
            /// <summary>Provides the runner that contains the custom logic implementing the specified regular expression.</summary>
            private sealed class Runner : RegexRunner
            {
                /// <summary>Scan the <paramref name="inputSpan"/> starting from base.runtextstart for the next match.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                protected override void Scan(ReadOnlySpan<char> inputSpan)
                {
                    // The pattern is anchored.  Validate the current position and try to match at it only.
                    if (TryFindNextPossibleStartingPosition(inputSpan) && !TryMatchAtCurrentPosition(inputSpan))
                    {
                        base.runtextpos = inputSpan.Length;
                    }
                }
        
                /// <summary>Search <paramref name="inputSpan"/> starting from base.runtextpos for the next location a match could possibly start.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                /// <returns>true if a possible match was found; false if no more matches are possible.</returns>
                private bool TryFindNextPossibleStartingPosition(ReadOnlySpan<char> inputSpan)
                {
                    int pos = base.runtextpos;
                    
                    // Any possible match is at least 20 characters.
                    if (pos <= inputSpan.Length - 20)
                    {
                        // The pattern leads with a beginning (\A) anchor.
                        if (pos == 0)
                        {
                            return true;
                        }
                    }
                    
                    // No match found.
                    base.runtextpos = inputSpan.Length;
                    return false;
                }
        
                /// <summary>Determine whether <paramref name="inputSpan"/> at base.runtextpos is a match for the regular expression.</summary>
                /// <param name="inputSpan">The text being scanned by the regular expression.</param>
                /// <returns>true if the regular expression matches at the current position; otherwise, false.</returns>
                private bool TryMatchAtCurrentPosition(ReadOnlySpan<char> inputSpan)
                {
                    int pos = base.runtextpos;
                    int matchStart = pos;
                    char ch;
                    int alternation_branch = 0;
                    int alternation_branch1 = 0;
                    int alternation_starting_capturepos1 = 0;
                    int alternation_starting_capturepos2 = 0;
                    int alternation_starting_pos1 = 0;
                    int alternation_starting_pos2 = 0;
                    int capture_starting_pos = 0;
                    int charloop_starting_pos = 0, charloop_ending_pos = 0;
                    int charloop_starting_pos1 = 0, charloop_ending_pos1 = 0;
                    int loop_iteration = 0;
                    int loop_iteration1 = 0;
                    int loop_iteration2 = 0;
                    int loop_iteration3 = 0;
                    int stackpos = 0;
                    uint charMinusLowUInt32;
                    ReadOnlySpan<char> slice = inputSpan.Slice(pos);
                    
                    // Match if at the beginning of the string.
                    if (pos != 0)
                    {
                        UncaptureUntil(0);
                        return false; // The input didn't match.
                    }
                    
                    // Optional (greedy).
                    //{
                        loop_iteration = 0;
                        
                        LoopBody:
                        Utilities.StackPush(ref base.runstack!, ref stackpos, base.Crawlpos(), pos);
                        
                        loop_iteration++;
                        
                        if ((uint)slice.Length < 4 ||
                            !slice.StartsWith("http", StringComparison.OrdinalIgnoreCase)) // Match the string "http" (ordinal case-insensitive)
                        {
                            goto LoopIterationNoMatch;
                        }
                        
                        // Match a character in the set [Ss] atomically, optionally.
                        {
                            if ((uint)slice.Length > (uint)4 && ((slice[4] | 0x20) == 's'))
                            {
                                slice = slice.Slice(1);
                                pos++;
                            }
                        }
                        
                        // Match the string "://".
                        if (!slice.Slice(4).StartsWith("://"))
                        {
                            goto LoopIterationNoMatch;
                        }
                        
                        pos += 7;
                        slice = inputSpan.Slice(pos);
                        
                        // The loop has an upper bound of 1. Continue iterating greedily if it hasn't yet been reached.
                        if (loop_iteration == 0)
                        {
                            goto LoopBody;
                        }
                        goto LoopEnd;
                        
                        // The loop iteration failed. Put state back to the way it was before the iteration.
                        LoopIterationNoMatch:
                        if (--loop_iteration < 0)
                        {
                            // Unable to match the remainder of the expression after exhausting the loop.
                            UncaptureUntil(0);
                            return false; // The input didn't match.
                        }
                        pos = base.runstack![--stackpos];
                        UncaptureUntil(base.runstack![--stackpos]);
                        slice = inputSpan.Slice(pos);
                        LoopEnd:;
                    //}
                    
                    // Optional (greedy).
                    //{
                        loop_iteration1 = 0;
                        
                        LoopBody1:
                        Utilities.StackPush(ref base.runstack!, ref stackpos, base.Crawlpos(), pos);
                        
                        loop_iteration1++;
                        
                        // Match with 2 alternative expressions.
                        //{
                            int alternation_starting_pos = pos;
                            int alternation_starting_capturepos = base.Crawlpos();
                            
                            // Branch 0
                            //{
                                if ((uint)slice.Length < 4 ||
                                    !slice.StartsWith("www.", StringComparison.OrdinalIgnoreCase)) // Match the string "www." (ordinal case-insensitive)
                                {
                                    goto AlternationBranch;
                                }
                                
                                Utilities.StackPush(ref base.runstack!, ref stackpos, 0, alternation_starting_pos, alternation_starting_capturepos);
                                pos += 4;
                                slice = inputSpan.Slice(pos);
                                goto AlternationMatch;
                                
                                AlternationBranch:
                                pos = alternation_starting_pos;
                                slice = inputSpan.Slice(pos);
                                UncaptureUntil(alternation_starting_capturepos);
                            //}
                            
                            // Branch 1
                            //{
                                // Match a character in the set [Mm].
                                if (slice.IsEmpty || ((slice[0] | 0x20) != 'm'))
                                {
                                    goto LoopIterationNoMatch1;
                                }
                                
                                // Match with 2 alternative expressions.
                                //{
                                    if ((uint)slice.Length < 2)
                                    {
                                        goto LoopIterationNoMatch1;
                                    }
                                    
                                    switch (slice[1])
                                    {
                                        case '.':
                                            pos += 2;
                                            slice = inputSpan.Slice(pos);
                                            break;
                                            
                                        case 'U' or 'u':
                                            
                                            if ((uint)slice.Length < 6 ||
                                                !slice.Slice(2).StartsWith("sic.", StringComparison.OrdinalIgnoreCase)) // Match the string "sic." (ordinal case-insensitive)
                                            {
                                                goto LoopIterationNoMatch1;
                                            }
                                            
                                            pos += 6;
                                            slice = inputSpan.Slice(pos);
                                            break;
                                            
                                        default:
                                            goto LoopIterationNoMatch1;
                                    }
                                //}
                                
                                Utilities.StackPush(ref base.runstack!, ref stackpos, 1, alternation_starting_pos, alternation_starting_capturepos);
                                goto AlternationMatch;
                            //}
                            
                            AlternationBacktrack:
                            if (Utilities.s_hasTimeout)
                            {
                                base.CheckTimeout();
                            }
                            
                            Utilities.StackPop(base.runstack!, ref stackpos, out alternation_starting_capturepos, out alternation_starting_pos);
                            switch (base.runstack![--stackpos])
                            {
                                case 0:
                                    goto AlternationBranch;
                                case 1:
                                    goto LoopIterationNoMatch1;
                            }
                            
                            AlternationMatch:;
                        //}
                        
                        
                        // The loop has an upper bound of 1. Continue iterating greedily if it hasn't yet been reached.
                        if (loop_iteration1 == 0)
                        {
                            goto LoopBody1;
                        }
                        goto LoopEnd1;
                        
                        // The loop iteration failed. Put state back to the way it was before the iteration.
                        LoopIterationNoMatch1:
                        if (--loop_iteration1 < 0)
                        {
                            // Unable to match the remainder of the expression after exhausting the loop.
                            goto LoopIterationNoMatch;
                        }
                        pos = base.runstack![--stackpos];
                        UncaptureUntil(base.runstack![--stackpos]);
                        slice = inputSpan.Slice(pos);
                        goto LoopEnd1;
                        
                        LoopBacktrack:
                        if (Utilities.s_hasTimeout)
                        {
                            base.CheckTimeout();
                        }
                        
                        if (loop_iteration1 == 0)
                        {
                            // No iterations of the loop remain to backtrack into. Fail the loop.
                            goto LoopIterationNoMatch;
                        }
                        goto AlternationBacktrack;
                        LoopEnd1:;
                    //}
                    
                    if ((uint)slice.Length < 5 ||
                        !slice.StartsWith("youtu", StringComparison.OrdinalIgnoreCase)) // Match the string "youtu" (ordinal case-insensitive)
                    {
                        goto LoopBacktrack;
                    }
                    
                    // Match with 2 alternative expressions.
                    //{
                        alternation_starting_pos1 = pos;
                        alternation_starting_capturepos1 = base.Crawlpos();
                        
                        // Branch 0
                        //{
                            if ((uint)slice.Length < 12 ||
                                !slice.Slice(5).StartsWith("be.com/", StringComparison.OrdinalIgnoreCase)) // Match the string "be.com/" (ordinal case-insensitive)
                            {
                                goto AlternationBranch1;
                            }
                            
                            // Match with 4 alternative expressions.
                            //{
                                alternation_starting_pos2 = pos;
                                alternation_starting_capturepos2 = base.Crawlpos();
                                
                                // Branch 0
                                //{
                                    if ((uint)slice.Length < 18 ||
                                        !slice.Slice(12).StartsWith("watch?", StringComparison.OrdinalIgnoreCase)) // Match the string "watch?" (ordinal case-insensitive)
                                    {
                                        goto AlternationBranch2;
                                    }
                                    
                                    // Optional (greedy).
                                    //{
                                        pos += 18;
                                        slice = inputSpan.Slice(pos);
                                        loop_iteration2 = 0;
                                        
                                        LoopBody2:
                                        Utilities.StackPush(ref base.runstack!, ref stackpos, base.Crawlpos(), pos);
                                        
                                        loop_iteration2++;
                                        
                                        // Match a character other than '\n' greedily any number of times.
                                        //{
                                            charloop_starting_pos = pos;
                                            
                                            int iteration = slice.IndexOf('\n');
                                            if (iteration < 0)
                                            {
                                                iteration = slice.Length;
                                            }
                                            
                                            slice = slice.Slice(iteration);
                                            pos += iteration;
                                            
                                            charloop_ending_pos = pos;
                                            goto CharLoopEnd;
                                            
                                            CharLoopBacktrack:
                                            UncaptureUntil(base.runstack![--stackpos]);
                                            Utilities.StackPop(base.runstack!, ref stackpos, out charloop_ending_pos, out charloop_starting_pos);
                                            
                                            if (Utilities.s_hasTimeout)
                                            {
                                                base.CheckTimeout();
                                            }
                                            
                                            if (charloop_starting_pos >= charloop_ending_pos ||
                                                (charloop_ending_pos = inputSpan.Slice(charloop_starting_pos, charloop_ending_pos - charloop_starting_pos).LastIndexOf('&')) < 0)
                                            {
                                                goto LoopIterationNoMatch2;
                                            }
                                            charloop_ending_pos += charloop_starting_pos;
                                            pos = charloop_ending_pos;
                                            slice = inputSpan.Slice(pos);
                                            
                                            CharLoopEnd:
                                            Utilities.StackPush(ref base.runstack!, ref stackpos, charloop_starting_pos, charloop_ending_pos, base.Crawlpos());
                                        //}
                                        
                                        // Match '&'.
                                        if (slice.IsEmpty || slice[0] != '&')
                                        {
                                            goto CharLoopBacktrack;
                                        }
                                        
                                        pos++;
                                        slice = inputSpan.Slice(pos);
                                        
                                        // The loop has an upper bound of 1. Continue iterating greedily if it hasn't yet been reached.
                                        if (loop_iteration2 == 0)
                                        {
                                            goto LoopBody2;
                                        }
                                        goto LoopEnd2;
                                        
                                        // The loop iteration failed. Put state back to the way it was before the iteration.
                                        LoopIterationNoMatch2:
                                        if (--loop_iteration2 < 0)
                                        {
                                            // Unable to match the remainder of the expression after exhausting the loop.
                                            goto AlternationBranch2;
                                        }
                                        pos = base.runstack![--stackpos];
                                        UncaptureUntil(base.runstack![--stackpos]);
                                        slice = inputSpan.Slice(pos);
                                        goto LoopEnd2;
                                        
                                        LoopBacktrack1:
                                        if (Utilities.s_hasTimeout)
                                        {
                                            base.CheckTimeout();
                                        }
                                        
                                        if (loop_iteration2 == 0)
                                        {
                                            // No iterations of the loop remain to backtrack into. Fail the loop.
                                            goto AlternationBranch2;
                                        }
                                        goto CharLoopBacktrack;
                                        LoopEnd2:;
                                    //}
                                    
                                    if ((uint)slice.Length < 2 ||
                                        ((slice[0] | 0x20) != 'v') || // Match a character in the set [Vv].
                                        slice[1] != '=') // Match '='.
                                    {
                                        goto LoopBacktrack1;
                                    }
                                    
                                    alternation_branch1 = 0;
                                    pos += 2;
                                    slice = inputSpan.Slice(pos);
                                    goto AlternationMatch2;
                                    
                                    AlternationBranch2:
                                    pos = alternation_starting_pos2;
                                    slice = inputSpan.Slice(pos);
                                    UncaptureUntil(alternation_starting_capturepos2);
                                //}
                                
                                // Branch 1
                                //{
                                    if ((uint)slice.Length < 18 ||
                                        !slice.Slice(12).StartsWith("embed/", StringComparison.OrdinalIgnoreCase)) // Match the string "embed/" (ordinal case-insensitive)
                                    {
                                        goto AlternationBranch3;
                                    }
                                    
                                    alternation_branch1 = 1;
                                    pos += 18;
                                    slice = inputSpan.Slice(pos);
                                    goto AlternationMatch2;
                                    
                                    AlternationBranch3:
                                    pos = alternation_starting_pos2;
                                    slice = inputSpan.Slice(pos);
                                    UncaptureUntil(alternation_starting_capturepos2);
                                //}
                                
                                // Branch 2
                                //{
                                    if ((uint)slice.Length < 19 ||
                                        !slice.Slice(12).StartsWith("shorts/", StringComparison.OrdinalIgnoreCase)) // Match the string "shorts/" (ordinal case-insensitive)
                                    {
                                        goto AlternationBranch4;
                                    }
                                    
                                    alternation_branch1 = 2;
                                    pos += 19;
                                    slice = inputSpan.Slice(pos);
                                    goto AlternationMatch2;
                                    
                                    AlternationBranch4:
                                    pos = alternation_starting_pos2;
                                    slice = inputSpan.Slice(pos);
                                    UncaptureUntil(alternation_starting_capturepos2);
                                //}
                                
                                // Branch 3
                                //{
                                    if ((uint)slice.Length < 17 ||
                                        !slice.Slice(12).StartsWith("live/", StringComparison.OrdinalIgnoreCase)) // Match the string "live/" (ordinal case-insensitive)
                                    {
                                        goto AlternationBranch1;
                                    }
                                    
                                    alternation_branch1 = 3;
                                    pos += 17;
                                    slice = inputSpan.Slice(pos);
                                    goto AlternationMatch2;
                                //}
                                
                                AlternationBacktrack2:
                                if (Utilities.s_hasTimeout)
                                {
                                    base.CheckTimeout();
                                }
                                
                                switch (alternation_branch1)
                                {
                                    case 0:
                                        goto LoopBacktrack1;
                                    case 1:
                                        goto AlternationBranch3;
                                    case 2:
                                        goto AlternationBranch4;
                                    case 3:
                                        goto AlternationBranch1;
                                }
                                
                                AlternationMatch2:;
                            //}
                            
                            alternation_branch = 0;
                            goto AlternationMatch1;
                            
                            AlternationBranch1:
                            pos = alternation_starting_pos1;
                            slice = inputSpan.Slice(pos);
                            UncaptureUntil(alternation_starting_capturepos1);
                        //}
                        
                        // Branch 1
                        //{
                            if ((uint)slice.Length < 9 ||
                                !slice.Slice(5).StartsWith(".be/", StringComparison.OrdinalIgnoreCase)) // Match the string ".be/" (ordinal case-insensitive)
                            {
                                goto LoopBacktrack;
                            }
                            
                            alternation_branch = 1;
                            pos += 9;
                            slice = inputSpan.Slice(pos);
                            goto AlternationMatch1;
                        //}
                        
                        AlternationBacktrack1:
                        if (Utilities.s_hasTimeout)
                        {
                            base.CheckTimeout();
                        }
                        
                        switch (alternation_branch)
                        {
                            case 0:
                                goto AlternationBacktrack2;
                            case 1:
                                goto LoopBacktrack;
                        }
                        
                        AlternationMatch1:;
                    //}
                    
                    // "id" capture group.
                    {
                        capture_starting_pos = pos;
                        
                        // Match a character in the set [\-0-9A-Z_a-z\u212A] exactly 11 times.
                        {
                            if ((uint)slice.Length < 11 ||
                                ((ch = slice[0]) < 128 ? ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0 : !RegexRunner.CharInClass((char)ch, "\0\f\0-.0:A[_`a{KÅ")) ||
                                ((ch = slice[1]) < 128 ? ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0 : !RegexRunner.CharInClass((char)ch, "\0\f\0-.0:A[_`a{KÅ")) ||
                                ((ch = slice[2]) < 128 ? ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0 : !RegexRunner.CharInClass((char)ch, "\0\f\0-.0:A[_`a{KÅ")) ||
                                ((ch = slice[3]) < 128 ? ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0 : !RegexRunner.CharInClass((char)ch, "\0\f\0-.0:A[_`a{KÅ")) ||
                                ((ch = slice[4]) < 128 ? ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0 : !RegexRunner.CharInClass((char)ch, "\0\f\0-.0:A[_`a{KÅ")) ||
                                ((ch = slice[5]) < 128 ? ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0 : !RegexRunner.CharInClass((char)ch, "\0\f\0-.0:A[_`a{KÅ")) ||
                                ((ch = slice[6]) < 128 ? ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0 : !RegexRunner.CharInClass((char)ch, "\0\f\0-.0:A[_`a{KÅ")) ||
                                ((ch = slice[7]) < 128 ? ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0 : !RegexRunner.CharInClass((char)ch, "\0\f\0-.0:A[_`a{KÅ")) ||
                                ((ch = slice[8]) < 128 ? ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0 : !RegexRunner.CharInClass((char)ch, "\0\f\0-.0:A[_`a{KÅ")) ||
                                ((ch = slice[9]) < 128 ? ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0 : !RegexRunner.CharInClass((char)ch, "\0\f\0-.0:A[_`a{KÅ")) ||
                                ((ch = slice[10]) < 128 ? ("\0\0 Ͽ\ufffe蟿\ufffe߿"[ch >> 4] & (1 << (ch & 0xF))) == 0 : !RegexRunner.CharInClass((char)ch, "\0\f\0-.0:A[_`a{KÅ")))
                            {
                                goto AlternationBacktrack1;
                            }
                        }
                        
                        pos += 11;
                        slice = inputSpan.Slice(pos);
                        base.Capture(1, capture_starting_pos, pos);
                    }
                    
                    // Optional (greedy).
                    //{
                        loop_iteration3 = 0;
                        
                        LoopBody3:
                        Utilities.StackPush(ref base.runstack!, ref stackpos, base.Crawlpos(), pos);
                        
                        loop_iteration3++;
                        
                        // Match a character in the set [#&/?].
                        if (slice.IsEmpty || ((int)((0x90080008U << (short)(charMinusLowUInt32 = (ushort)(slice[0] - '#'))) & (charMinusLowUInt32 - 32)) >= 0))
                        {
                            goto LoopIterationNoMatch3;
                        }
                        
                        // Match a character other than '\n' greedily any number of times.
                        //{
                            pos++;
                            slice = inputSpan.Slice(pos);
                            charloop_starting_pos1 = pos;
                            
                            int iteration1 = slice.IndexOf('\n');
                            if (iteration1 < 0)
                            {
                                iteration1 = slice.Length;
                            }
                            
                            slice = slice.Slice(iteration1);
                            pos += iteration1;
                            
                            charloop_ending_pos1 = pos;
                            goto CharLoopEnd1;
                            
                            CharLoopBacktrack1:
                            UncaptureUntil(base.runstack![--stackpos]);
                            Utilities.StackPop(base.runstack!, ref stackpos, out charloop_ending_pos1, out charloop_starting_pos1);
                            
                            if (Utilities.s_hasTimeout)
                            {
                                base.CheckTimeout();
                            }
                            
                            if (charloop_starting_pos1 >= charloop_ending_pos1)
                            {
                                goto LoopIterationNoMatch3;
                            }
                            pos = --charloop_ending_pos1;
                            slice = inputSpan.Slice(pos);
                            
                            CharLoopEnd1:
                            Utilities.StackPush(ref base.runstack!, ref stackpos, charloop_starting_pos1, charloop_ending_pos1, base.Crawlpos());
                        //}
                        
                        
                        // The loop has an upper bound of 1. Continue iterating greedily if it hasn't yet been reached.
                        if (loop_iteration3 == 0)
                        {
                            goto LoopBody3;
                        }
                        goto LoopEnd3;
                        
                        // The loop iteration failed. Put state back to the way it was before the iteration.
                        LoopIterationNoMatch3:
                        if (--loop_iteration3 < 0)
                        {
                            // Unable to match the remainder of the expression after exhausting the loop.
                            goto AlternationBacktrack1;
                        }
                        pos = base.runstack![--stackpos];
                        UncaptureUntil(base.runstack![--stackpos]);
                        slice = inputSpan.Slice(pos);
                        goto LoopEnd3;
                        
                        LoopBacktrack2:
                        if (Utilities.s_hasTimeout)
                        {
                            base.CheckTimeout();
                        }
                        
                        if (loop_iteration3 == 0)
                        {
                            // No iterations of the loop remain to backtrack into. Fail the loop.
                            goto AlternationBacktrack1;
                        }
                        goto CharLoopBacktrack1;
                        LoopEnd3:;
                    //}
                    
                    // Match if at the end of the string or if before an ending newline.
                    if (pos < inputSpan.Length - 1 || ((uint)pos < (uint)inputSpan.Length && inputSpan[pos] != '\n'))
                    {
                        goto LoopBacktrack2;
                    }
                    
                    // The input matched.
                    base.runtextpos = pos;
                    base.Capture(0, matchStart, pos);
                    return true;
                    
                    // <summary>Undo captures until it reaches the specified capture position.</summary>
                    [MethodImpl(MethodImplOptions.AggressiveInlining)]
                    void UncaptureUntil(int capturePosition)
                    {
                        while (base.Crawlpos() > capturePosition)
                        {
                            base.Uncapture();
                        }
                    }
                }
            }
        }

    }
    
    /// <summary>Helper methods used by generated <see cref="Regex"/>-derived implementations.</summary>
    [GeneratedCodeAttribute("System.Text.RegularExpressions.Generator", "10.0.15.2326")]
    file static class Utilities
    {
        /// <summary>Default timeout value set in <see cref="AppContext"/>, or <see cref="Regex.InfiniteMatchTimeout"/> if none was set.</summary>
        internal static readonly TimeSpan s_defaultTimeout = AppContext.GetData("REGEX_DEFAULT_MATCH_TIMEOUT") is TimeSpan timeout ? timeout : Regex.InfiniteMatchTimeout;
        
        /// <summary>Whether <see cref="s_defaultTimeout"/> is non-infinite.</summary>
        internal static readonly bool s_hasTimeout = s_defaultTimeout != Regex.InfiniteMatchTimeout;
        
        /// <summary>Pops 2 values from the backtracking stack.</summary>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        internal static void StackPop(int[] stack, ref int pos, out int arg0, out int arg1)
        {
            arg0 = stack[--pos];
            arg1 = stack[--pos];
        }
        
        /// <summary>Pushes 2 values onto the backtracking stack.</summary>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        internal static void StackPush(ref int[] stack, ref int pos, int arg0, int arg1)
        {
            // If there's space available for all 2 values, store them.
            int[] s = stack;
            int p = pos;
            if ((uint)(p + 1) < (uint)s.Length)
            {
                s[p] = arg0;
                s[p + 1] = arg1;
                pos += 2;
                return;
            }
        
            // Otherwise, resize the stack to make room and try again.
            WithResize(ref stack, ref pos, arg0, arg1);
        
            // <summary>Resize the backtracking stack array and push 2 values onto the stack.</summary>
            [MethodImpl(MethodImplOptions.NoInlining)]
            static void WithResize(ref int[] stack, ref int pos, int arg0, int arg1)
            {
                Array.Resize(ref stack, (pos + 1) * 2);
                StackPush(ref stack, ref pos, arg0, arg1);
            }
        }
        
        /// <summary>Pushes 3 values onto the backtracking stack.</summary>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        internal static void StackPush(ref int[] stack, ref int pos, int arg0, int arg1, int arg2)
        {
            // If there's space available for all 3 values, store them.
            int[] s = stack;
            int p = pos;
            if ((uint)(p + 2) < (uint)s.Length)
            {
                s[p] = arg0;
                s[p + 1] = arg1;
                s[p + 2] = arg2;
                pos += 3;
                return;
            }
        
            // Otherwise, resize the stack to make room and try again.
            WithResize(ref stack, ref pos, arg0, arg1, arg2);
        
            // <summary>Resize the backtracking stack array and push 3 values onto the stack.</summary>
            [MethodImpl(MethodImplOptions.NoInlining)]
            static void WithResize(ref int[] stack, ref int pos, int arg0, int arg1, int arg2)
            {
                Array.Resize(ref stack, (pos + 2) * 2);
                StackPush(ref stack, ref pos, arg0, arg1, arg2);
            }
        }
        
        /// <summary>Supports searching for characters in or not in "\t\n\v\f\r \u0085             \u2028\u2029  　".</summary>
        internal static readonly SearchValues<char> s_whitespace = SearchValues.Create("\t\n\v\f\r \u0085             \u2028\u2029  　");
    }
}
ParseOptions.0.json