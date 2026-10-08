using System.Security.Claims;
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
        if (request.IgvRate is decimal igvRate) settings.IgvRate = igvRate;
        if (request.RentaRate is decimal rentaRate) settings.RentaRate = rentaRate;
        (settings.FacturaSeries, settings.FacturaNextNumber, settings.ReciboSeries, settings.ReciboNextNumber) = (facturaSeries, facturaNext, reciboSeries, reciboNext);
        settings.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return Ok(TaxSettingsDto(settings));
    }

    private Task<int?> LastNumberAsync(TaxDocumentType type, string series, CancellationToken ct) => db.TaxDocuments.Where(x => x.Type == type && x.Series == series).MaxAsync(x => (int?)x.Number, ct);
    private static object TaxSettingsDto(TaxSettings x) => new { igvRate = x.IgvRate, rentaRate = x.RentaRate, facturaSeries = x.FacturaSeries, facturaNextNumber = x.FacturaNextNumber, reciboSeries = x.ReciboSeries, reciboNextNumber = x.ReciboNextNumber, ruc = x.Ruc, isGoodTaxpayer = x.IsGoodTaxpayer };

    private async Task<TaxSettings> TaxSettingsRow(CancellationToken ct)
    {
        var settings = await db.TaxSettings.FirstOrDefaultAsync(ct);
        if (settings is not null) return settings;
        settings = new TaxSettings(); db.TaxSettings.Add(settings); await db.SaveChangesAsync(ct); return settings;
    }

    [HttpGet("tax-documents")]
    public async Task<ActionResult> TaxDocuments(Guid? clientId, int? month, int? year, CancellationToken ct) => Ok(await db.TaxDocuments
        .Where(x => (clientId == null || x.ClientId == clientId) && (month == null || x.IssueDate.Month == month) && (year == null || x.IssueDate.Year == year))
        .OrderByDescending(x => x.IssueDate).ThenByDescending(x => x.Number).Select(x => TaxDocumentDto(x)).ToListAsync(ct));

    /// <summary>Emisión manual (cobros fuera de PayPal): el tipo sale del producto y la serie/correlativo se asignan solos.</summary>
    [HttpPost("tax-documents")]
    public async Task<ActionResult> CreateTaxDocument(TaxDocumentRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Currency) || request.TotalAmount <= 0) return BadRequest(new { message = "Moneda y un total mayor a 0 son obligatorios." });
        var item = await db.ClientProducts.Include(x => x.Product).SingleOrDefaultAsync(x => x.Id == request.ClientProductId, ct);
        if (item?.Product is null) return NotFound(new { message = "Producto del cliente no encontrado." });
        var client = await db.Clients.FindAsync([item.ClientId], ct);
        if (client is null || !client.RequiresTaxDocument) return BadRequest(new { message = "Este cliente no requiere comprobante tributario (solo se emite a clientes en Perú)." });
        if (request.RetentionAmount is < 0 || request.RetentionAmount > request.TotalAmount) return BadRequest(new { message = "La retención debe estar entre 0 y el total." });
        // El comprobante manual es de un cobro fuera del portal: se registra el cobro para que cuente una sola vez en los reportes.
        var currency = request.Currency.Trim().ToUpperInvariant();
        var payment = new PaymentTransaction { ClientId = client.Id, ClientProductId = item.Id, Amount = request.TotalAmount, Currency = currency, Status = "COMPLETED", Method = PaymentMethods.Transferencia, CreatedAt = request.IssueDate.ToDateTime(new TimeOnly(12, 0), DateTimeKind.Utc), Notes = EmptyToNull(request.Notes) };
        payment.PayPalOrderIdOrSubscriptionId = $"MANUAL-{payment.Id:N}";
        payment.InternalCode = $"RT-INT-{1 + await db.PaymentTransactions.CountAsync(ct):000000}";
        payment.AmountPen = payment.Amount * await db.RateToPenAsync(currency, request.IssueDate, ct);
        db.PaymentTransactions.Add(payment); await db.SaveChangesAsync(ct);
        var document = await taxDocuments.IssueAsync(client.Id, item.Product.TaxDocumentType, request.IssueDate, currency, request.TotalAmount, EmptyToNull(request.Notes), payment.Id, ct);
        if (request.RetentionAmount > 0) { document.RetentionAmount = request.RetentionAmount; await db.SaveChangesAsync(ct); }
        return Created($"/api/admin/tax-documents/{document.Id}", TaxDocumentDto(document));
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
        var expense = new Expense { Description = request.Description.Trim(), CategoryId = request.CategoryId, Type = request.Type, Amount = request.Amount, Currency = request.Currency.Trim().ToUpperInvariant(), Date = request.Date, Recurring = request.Recurring, RecurrenceCycle = request.RecurrenceCycle };
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

    private sealed record Sale(Guid ClientId, DateOnly Date, decimal BasePen, decimal IgvPen, bool Gravada, decimal RetentionPen);

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
            return new Sale(x.ClientId, DateOnly.FromDateTime(x.CreatedAt), basePen, x.AmountPen - basePen, isFactura, retentionPen);
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
        // La Renta se estima sobre todas las ventas sin IGV (gravadas y no gravadas).
        return Ok(new
        {
            ventasGravadasPen = Math.Round(gravadasPen, 2), ventasNoGravadasPen = Math.Round(basePen - gravadasPen, 2), igvEstimado = Math.Round(sales.Sum(x => x.IgvPen), 2), rentaEstimada = Math.Round(basePen * settings.RentaRate, 2), tasa = new { igvRate = settings.IgvRate, rentaRate = settings.RentaRate }, disclaimer = TaxDisclaimer,
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
        var months = new List<IgvMonth>(); var carry = 0m;
        for (var month = start; month <= end; month = month.AddMonths(1))
        {
            var monthEnd = month.AddMonths(1).AddDays(-1);
            var debito = sales.Where(x => x.Date >= month && x.Date <= monthEnd).Sum(x => x.IgvPen);
            var credito = purchases.Where(x => x.Period == month).Sum(x => x.TaxCreditPen);
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
        var impuestos = ventas * rentaRate;
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
            return Conflict(new { message = $"«{project.Name}» tiene {Count(products, "producto", "productos")}{(products > 0 && tickets > 0 ? " y " : "")}{Count(tickets, "ticket", "tickets")}: muévelos o elimínalos antes de borrar el proyecto." });
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
        await db.SaveChangesAsync(ct); return Ok(await ClientProductDtoAsync(item, ct));
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
    private static object TaxDocumentDto(TaxDocument x) => new { id = x.Id, paymentTransactionId = x.PaymentTransactionId, clientId = x.ClientId, type = x.Type.ToString(), series = x.Series, number = x.Number, issueDate = x.IssueDate, currency = x.Currency, baseAmount = x.BaseAmount, igvAmount = x.IgvAmount, totalAmount = x.TotalAmount, notes = x.Notes, retentionAmount = x.RetentionAmount };
    private static object ExpenseDto(Expense x) => new { id = x.Id, description = x.Description, categoryId = x.CategoryId, categoryName = x.Category?.Name ?? "", type = x.Type.ToString(), amount = x.Amount, currency = x.Currency, amountPen = x.AmountPen, date = x.Date, recurring = x.Recurring, recurrenceCycle = x.RecurrenceCycle?.ToString(), recurrenceEndsAt = x.RecurrenceEndsAt };
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
public sealed record ClientProductPatchRequest(decimal? Price, ClientProductStatus? Status, BillingCycle? BillingCycle, bool? IsManualBilling, string? DomainName, string? PriceLabelOverride, decimal? Discount = null);
public sealed record ImportError(int Row, string Reason);
/// <summary>Columna de una plantilla de importación: <paramref name="Options"/> genera una lista desplegable en Excel.</summary>
public sealed record TemplateColumn(string Name, bool Required, string Accepted, string[]? Options = null);
public sealed record ClientAccess(string ClientName, string Email, string TemporaryPassword, bool EmailSent = false);
public sealed record ProjectRequest(string? Name, string? Slug, string? GithubRepoOwner, string? GithubRepoName);
public sealed record RepositoryRequest(string? Owner, string? Name, string? Label = null, bool? IsDefault = null);
public sealed record TaxSettingsRequest(decimal? IgvRate, decimal? RentaRate, string? FacturaSeries = null, int? FacturaNextNumber = null, string? ReciboSeries = null, int? ReciboNextNumber = null, string? Ruc = null, bool? IsGoodTaxpayer = null);
public sealed record TaxDocumentRequest(Guid ClientProductId, DateOnly IssueDate, string Currency, decimal TotalAmount, string? Notes, decimal? RetentionAmount = null);
public sealed record ExpenseRequest(string Description, Guid CategoryId, ExpenseType Type, decimal Amount, string Currency, DateOnly Date, bool Recurring, BillingCycle? RecurrenceCycle);
public sealed record EndRecurrenceRequest(DateOnly EndsAt);
public sealed record ExpensePatchRequest(string? Description, Guid? CategoryId, ExpenseType? Type, decimal? Amount, string? Currency, DateOnly? Date, bool? Recurring, BillingCycle? RecurrenceCycle);
