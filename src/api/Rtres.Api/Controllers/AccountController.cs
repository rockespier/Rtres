using System.Security.Claims;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ClosedXML.Excel;
using Rtres.Api.Jobs;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

[ApiController, Authorize, Route("api")]
public sealed class AccountController(RtresDbContext db) : ControllerBase
{
    private Guid UserId => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    private bool TryGetClientId(out Guid clientId) => Guid.TryParse(User.FindFirstValue("client_id"), out clientId);
    private static readonly PasswordHasher<UserAccount> Hasher = new();

    [HttpGet("profile")]
    public async Task<ActionResult> Profile(CancellationToken ct) { var user = await db.UserAccounts.FindAsync([UserId], ct); return user is null ? NotFound() : Ok(new { name = user.Name, email = user.Email }); }
    [HttpPatch("profile")]
    public async Task<ActionResult> UpdateProfile(ProfileRequest request, CancellationToken ct) { if (string.IsNullOrWhiteSpace(request.Name)) return BadRequest(new { message = "El nombre es obligatorio." }); var user = await db.UserAccounts.FindAsync([UserId], ct); if (user is null) return NotFound(); user.Name = request.Name.Trim(); await db.SaveChangesAsync(ct); return Ok(); }
    [HttpPost("profile/change-password")]
    public async Task<ActionResult> ChangePassword(ChangePasswordRequest request, CancellationToken ct) { var user = await db.UserAccounts.FindAsync([UserId], ct); if (user is null) return NotFound(); if (Hasher.VerifyHashedPassword(user, user.PasswordHash, request.CurrentPassword) == PasswordVerificationResult.Failed) return BadRequest(new { message = "La contraseña actual no coincide." }); if (string.IsNullOrWhiteSpace(request.NewPassword)) return BadRequest(new { message = "La nueva contraseña es obligatoria." }); user.PasswordHash = Hasher.HashPassword(user, request.NewPassword); await db.SaveChangesAsync(ct); return Ok(); }
    [HttpGet("billing/transactions")]
    public async Task<ActionResult> Transactions(CancellationToken ct) { if (!TryGetClientId(out var clientId)) return Ok(Array.Empty<object>()); return Ok(await (from transaction in db.PaymentTransactions join clientProduct in db.ClientProducts.Include(x => x.Product) on transaction.ClientProductId equals clientProduct.Id where clientProduct.ClientId == clientId orderby transaction.CreatedAt descending select new { id = transaction.Id, createdAt = transaction.CreatedAt, product = clientProduct.Product!.Name, amount = transaction.Amount, currency = transaction.Currency, status = transaction.Status }).ToListAsync(ct)); }
    [HttpGet("team/users"), Authorize(Roles = "Admin")]
    public async Task<ActionResult> Team(CancellationToken ct) { if (!TryGetClientId(out var clientId)) return Forbid(); return Ok(await db.UserAccounts.Where(x => x.ClientId == clientId).OrderBy(x => x.Name).Select(x => new { id = x.Id, name = x.Name, email = x.Email, role = x.Role.ToString(), isActive = x.IsActive }).ToListAsync(ct)); }
    [HttpPost("team/users"), Authorize(Roles = "Admin")]
    public async Task<ActionResult> Invite(InviteRequest request, CancellationToken ct) { if (!TryGetClientId(out var clientId)) return Forbid(); if (string.IsNullOrWhiteSpace(request.Name) || string.IsNullOrWhiteSpace(request.Email)) return BadRequest(new { message = "Nombre y email son obligatorios." }); if (await db.UserAccounts.AnyAsync(x => x.Email == request.Email, ct)) return Conflict(new { message = "El email ya está registrado." }); var temporaryPassword = Convert.ToBase64String(RandomNumberGenerator.GetBytes(12)).Replace("+", "A").Replace("/", "B"); var user = new UserAccount { ClientId = clientId, Name = request.Name.Trim(), Email = request.Email.Trim(), Role = UserRole.Cliente }; user.PasswordHash = Hasher.HashPassword(user, temporaryPassword); db.UserAccounts.Add(user); await db.SaveChangesAsync(ct); return Created($"/api/team/users/{user.Id}", new { id = user.Id, temporaryPassword }); }
    [HttpPatch("team/users/{id:guid}"), Authorize(Roles = "Admin")]
    public async Task<ActionResult> UpdateTeam(Guid id, UpdateTeamRequest request, CancellationToken ct) { if (!TryGetClientId(out var clientId)) return Forbid(); var user = await db.UserAccounts.SingleOrDefaultAsync(x => x.Id == id && x.ClientId == clientId, ct); if (user is null) return NotFound(); if (id == UserId && ((request.Role is UserRole.Cliente) || request.IsActive is false)) return BadRequest(new { message = "No puedes bajar tu rol ni desactivarte." }); if (request.Role is UserRole role && role is not (UserRole.Cliente or UserRole.Admin)) return BadRequest(); if (request.Role is UserRole validRole) user.Role = validRole; if (request.IsActive is bool active) user.IsActive = active; await db.SaveChangesAsync(ct); return Ok(); }
}

[ApiController, Authorize(Roles = "SuperAdmin"), Route("api/admin")]
public sealed class AdminController(RtresDbContext db, PayPalCheckoutService checkoutService, ExchangeRateSyncJob exchangeRateSync) : ControllerBase
{
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
    public async Task<ActionResult> TaxSettings(CancellationToken ct) { var settings = await TaxSettingsRow(ct); return Ok(new { igvRate = settings.IgvRate, rentaRate = settings.RentaRate }); }

    [HttpPatch("tax-settings")]
    public async Task<ActionResult> UpdateTaxSettings(TaxSettingsRequest request, CancellationToken ct)
    {
        if (request.IgvRate is decimal igv && (igv < 0 || igv > 1) || request.RentaRate is decimal renta0 && (renta0 < 0 || renta0 > 1)) return BadRequest(new { message = "Las tasas deben estar entre 0 y 1 (ej. 0.18 para 18%)." });
        var settings = await TaxSettingsRow(ct);
        if (request.IgvRate is decimal igvRate) settings.IgvRate = igvRate;
        if (request.RentaRate is decimal rentaRate) settings.RentaRate = rentaRate;
        settings.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return Ok(new { igvRate = settings.IgvRate, rentaRate = settings.RentaRate });
    }

    private async Task<TaxSettings> TaxSettingsRow(CancellationToken ct)
    {
        var settings = await db.TaxSettings.FirstOrDefaultAsync(ct);
        if (settings is not null) return settings;
        settings = new TaxSettings(); db.TaxSettings.Add(settings); await db.SaveChangesAsync(ct); return settings;
    }

    [HttpGet("tax-documents")]
    public async Task<ActionResult> TaxDocuments(Guid? clientId, int? month, int? year, CancellationToken ct) => Ok(await db.TaxDocuments
        .Where(x => (clientId == null || x.ClientId == clientId) && (month == null || x.IssueDate.Month == month) && (year == null || x.IssueDate.Year == year))
        .OrderByDescending(x => x.IssueDate).Select(x => TaxDocumentDto(x)).ToListAsync(ct));

    [HttpPost("tax-documents")]
    public async Task<ActionResult> CreateTaxDocument(TaxDocumentRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Series) || request.Number <= 0 || string.IsNullOrWhiteSpace(request.Currency)) return BadRequest(new { message = "Serie, correlativo y moneda son obligatorios." });
        if (!await db.Clients.AnyAsync(x => x.Id == request.ClientId, ct)) return NotFound(new { message = "Cliente no encontrado." });
        if (request.PaymentTransactionId is Guid txId && !await db.PaymentTransactions.AnyAsync(x => x.Id == txId, ct)) return NotFound(new { message = "Transacción de pago no encontrada." });
        if (await db.TaxDocuments.AnyAsync(x => x.Series == request.Series.Trim() && x.Number == request.Number, ct)) return Conflict(new { message = "Ya existe un documento con esa serie y correlativo." });
        var document = new TaxDocument { PaymentTransactionId = request.PaymentTransactionId, ClientId = request.ClientId, Type = request.Type, Series = request.Series.Trim(), Number = request.Number, IssueDate = request.IssueDate, Currency = request.Currency.Trim().ToUpperInvariant(), BaseAmount = request.BaseAmount, IgvAmount = request.IgvAmount, TotalAmount = request.TotalAmount, Notes = EmptyToNull(request.Notes) };
        db.TaxDocuments.Add(document); await db.SaveChangesAsync(ct);
        return Created($"/api/admin/tax-documents/{document.Id}", TaxDocumentDto(document));
    }

    [HttpGet("expenses")]
    public async Task<ActionResult> Expenses(int? month, int? year, ExpenseCategory? category, CancellationToken ct) => Ok(await db.Expenses
        .Where(x => (month == null || x.Date.Month == month) && (year == null || x.Date.Year == year) && (category == null || x.Category == category))
        .OrderByDescending(x => x.Date).Select(x => ExpenseDto(x)).ToListAsync(ct));

    [HttpPost("expenses")]
    public async Task<ActionResult> CreateExpense(ExpenseRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Description) || string.IsNullOrWhiteSpace(request.Currency) || request.Amount <= 0) return BadRequest(new { message = "Descripción, moneda y un monto mayor a 0 son obligatorios." });
        var expense = new Expense { Description = request.Description.Trim(), Category = request.Category, Type = request.Type, Amount = request.Amount, Currency = request.Currency.Trim().ToUpperInvariant(), Date = request.Date, Recurring = request.Recurring, RecurrenceCycle = request.RecurrenceCycle };
        expense.AmountPen = expense.Amount * await db.RateToPenAsync(expense.Currency, expense.Date, ct);
        db.Expenses.Add(expense); await db.SaveChangesAsync(ct);
        return Created($"/api/admin/expenses/{expense.Id}", ExpenseDto(expense));
    }

    [HttpPatch("expenses/{id:guid}")]
    public async Task<ActionResult> UpdateExpense(Guid id, ExpensePatchRequest request, CancellationToken ct)
    {
        var expense = await db.Expenses.FindAsync([id], ct); if (expense is null) return NotFound();
        if (request.Description is not null) expense.Description = request.Description.Trim();
        if (request.Category is ExpenseCategory category) expense.Category = category;
        if (request.Type is ExpenseType type) expense.Type = type;
        if (request.Amount is decimal amount) expense.Amount = amount;
        if (request.Currency is not null) expense.Currency = request.Currency.Trim().ToUpperInvariant();
        if (request.Date is DateOnly date) expense.Date = date;
        if (request.Recurring is bool recurring) expense.Recurring = recurring;
        if (request.RecurrenceCycle is BillingCycle cycle) expense.RecurrenceCycle = cycle;
        if (string.IsNullOrWhiteSpace(expense.Description) || string.IsNullOrWhiteSpace(expense.Currency) || expense.Amount <= 0) return BadRequest(new { message = "Descripción, moneda y un monto mayor a 0 son obligatorios." });
        expense.AmountPen = expense.Amount * await db.RateToPenAsync(expense.Currency, expense.Date, ct);
        await db.SaveChangesAsync(ct); return Ok(ExpenseDto(expense));
    }

    private const string TaxDisclaimer = "Estimación calculada con las tasas configuradas por el usuario en Configuración de tasas — no es una liquidación oficial ante SUNAT. El régimen tributario real (RER/MYPE/General) puede calcular la Renta sobre una base distinta (utilidad neta, no ventas brutas); confirma con tu contador antes de declarar.";

    [HttpGet("reports/sales")]
    public async Task<ActionResult> SalesReport(int month, int year, string currency, CancellationToken ct)
    {
        if (currency is not ("PEN" or "USD" or "EUR")) return BadRequest(new { message = "Moneda inválida." });
        var settings = await TaxSettingsRow(ct);
        var basePen = await db.PaymentTransactions.Where(x => x.CreatedAt.Month == month && x.CreatedAt.Year == year).SumAsync(x => (decimal?)x.AmountPen, ct) ?? 0m;
        var igvPen = basePen * settings.IgvRate;
        var rate = currency == "PEN" ? 1m : await db.RateToPenAsync(currency, new DateOnly(year, month, DateTime.DaysInMonth(year, month)), ct);
        return Ok(new { baseImponible = Math.Round(basePen / rate, 2), igv = Math.Round(igvPen / rate, 2), total = Math.Round((basePen + igvPen) / rate, 2) });
    }

    [HttpGet("reports/tax-summary")]
    public async Task<ActionResult> TaxSummaryReport(int month, int year, CancellationToken ct)
    {
        var settings = await TaxSettingsRow(ct);
        var ventasGravadasPen = await db.PaymentTransactions.Where(x => x.CreatedAt.Month == month && x.CreatedAt.Year == year).SumAsync(x => (decimal?)x.AmountPen, ct) ?? 0m;
        return Ok(new { ventasGravadasPen = Math.Round(ventasGravadasPen, 2), igvEstimado = Math.Round(ventasGravadasPen * settings.IgvRate, 2), rentaEstimada = Math.Round(ventasGravadasPen * settings.RentaRate, 2), tasa = new { igvRate = settings.IgvRate, rentaRate = settings.RentaRate }, disclaimer = TaxDisclaimer });
    }

    [HttpGet("reports/expenses")]
    public async Task<ActionResult> ExpensesReport(int month, int year, CancellationToken ct)
    {
        var expenses = await db.Expenses.Where(x => x.Date.Month == month && x.Date.Year == year).ToListAsync(ct);
        return Ok(new { total = Math.Round(expenses.Sum(x => x.AmountPen), 2), porCategoria = expenses.GroupBy(x => x.Category).Select(g => new { categoria = g.Key.ToString(), monto = Math.Round(g.Sum(x => x.AmountPen), 2) }) });
    }

    [HttpGet("reports/net")]
    public async Task<ActionResult> NetReport(int month, int year, CancellationToken ct)
    {
        var settings = await TaxSettingsRow(ct);
        var ventasPen = await db.PaymentTransactions.Where(x => x.CreatedAt.Month == month && x.CreatedAt.Year == year).SumAsync(x => (decimal?)x.AmountPen, ct) ?? 0m;
        var gastosPen = await db.Expenses.Where(x => x.Date.Month == month && x.Date.Year == year).SumAsync(x => (decimal?)x.AmountPen, ct) ?? 0m;
        // El IGV no es costo de la empresa (se cobra aparte y se traslada a SUNAT): solo la Renta reduce la utilidad.
        var impuestosEstimadosPen = ventasPen * settings.RentaRate;
        return Ok(new { ventasPen = Math.Round(ventasPen, 2), gastosPen = Math.Round(gastosPen, 2), impuestosEstimadosPen = Math.Round(impuestosEstimadosPen, 2), netoEstimadoPen = Math.Round(ventasPen - gastosPen - impuestosEstimadosPen, 2) });
    }

    [HttpGet("clients")]
    public async Task<ActionResult> Clients(CancellationToken ct) => Ok(await db.Clients.OrderBy(x => x.CompanyName).Select(x => new { id = x.Id, companyName = x.CompanyName, isActive = x.IsActive, activeProducts = db.ClientProducts.Count(p => p.ClientId == x.Id && p.Status == ClientProductStatus.Activo), openTickets = db.Tickets.Count(t => t.ClientId == x.Id && (t.Status == TicketStatus.Abierto || t.Status == TicketStatus.EnProgreso)) }).ToListAsync(ct));

    [HttpGet("clients/{id:guid}")]
    public async Task<ActionResult> Client(Guid id, CancellationToken ct)
    {
        var client = await db.Clients.FindAsync([id], ct);
        if (client is null) return NotFound();
        var products = await db.ClientProducts.Include(x => x.Product).Include(x => x.Project).Where(x => x.ClientId == id).ToListAsync(ct);
        return Ok(new { client = ClientDto(client), products = products.Select(ClientProductDto) });
    }

    [HttpPost("clients")]
    public async Task<ActionResult> CreateClient(ClientRequest request, CancellationToken ct)
    {
        var error = ValidateClient(request); if (error is not null) return BadRequest(new { message = error });
        if (await db.Clients.AnyAsync(x => x.Email == request.Email.Trim(), ct)) return Conflict(new { message = "El email ya está registrado." });
        var client = new Client { CompanyName = request.CompanyName.Trim(), ContactName = request.ContactName.Trim(), Email = request.Email.Trim(), Phone = EmptyToNull(request.Phone), PreferredLanguage = request.PreferredLanguage.Trim().ToLowerInvariant() };
        db.Clients.Add(client); await db.SaveChangesAsync(ct); return Created($"/api/admin/clients/{client.Id}", ClientDto(client));
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
        await db.SaveChangesAsync(ct); return Ok(ClientDto(client));
    }

    [HttpGet("clients/import/template")]
    public IActionResult ClientTemplate() => File(CreateWorkbook(["CompanyName", "ContactName", "Email", "Phone", "PreferredLanguage"]), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "clientes-plantilla.xlsx");

    [HttpPost("clients/import")]
    public async Task<ActionResult> ImportClients(IFormFile file, CancellationToken ct) => await Import(file, "clientes", async (row, rowNumber, errors) =>
    {
        var request = new ClientRequest(Cell(row, 1), Cell(row, 2), Cell(row, 3), Cell(row, 4), Cell(row, 5)); var error = ValidateClient(request);
        if (error is not null || await db.Clients.AnyAsync(x => x.Email == request.Email.Trim(), ct)) { errors.Add(new(rowNumber, error ?? "El email ya está registrado.")); return false; }
        db.Clients.Add(new Client { CompanyName = request.CompanyName.Trim(), ContactName = request.ContactName.Trim(), Email = request.Email.Trim(), Phone = EmptyToNull(request.Phone), PreferredLanguage = request.PreferredLanguage.Trim().ToLowerInvariant() }); return true;
    }, ct);

    [HttpGet("products")]
    public async Task<ActionResult> Products(CancellationToken ct) => Ok((await db.Products.OrderBy(x => x.Name).ToListAsync(ct)).Select(ProductDto));

    [HttpPost("products")]
    public async Task<ActionResult> CreateProduct(ProductRequest request, CancellationToken ct)
    {
        var error = ValidateProduct(request); if (error is not null) return BadRequest(new { message = error });
        var product = ToProduct(request); db.Products.Add(product); await db.SaveChangesAsync(ct); return Created($"/api/admin/products/{product.Id}", ProductDto(product));
    }

    [HttpPatch("products/{id:guid}")]
    public async Task<ActionResult> UpdateProduct(Guid id, ProductPatchRequest request, CancellationToken ct)
    {
        var product = await db.Products.FindAsync([id], ct); if (product is null) return NotFound();
        if (request.Type is ProductType type) product.Type = type; if (request.Name is not null) product.Name = request.Name.Trim(); if (request.BillingCycle is BillingCycle cycle) product.BillingCycle = cycle; if (request.BasePrice is not null) product.BasePrice = request.BasePrice; if (request.Currency is not null) product.Currency = request.Currency.Trim().ToUpperInvariant(); if (request.Description is not null) product.Description = EmptyToNull(request.Description); if (request.IsActive is bool active) product.IsActive = active;
        if (string.IsNullOrWhiteSpace(product.Name) || string.IsNullOrWhiteSpace(product.Currency)) return BadRequest(new { message = "Nombre y moneda son obligatorios." });
        await db.SaveChangesAsync(ct); return Ok(ProductDto(product));
    }

    [HttpGet("products/import/template")]
    public IActionResult ProductTemplate() => File(CreateWorkbook(["Type", "Name", "BillingCycle", "BasePrice", "Currency", "Description", "IsActive"]), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "productos-plantilla.xlsx");

    [HttpPost("products/import")]
    public async Task<ActionResult> ImportProducts(IFormFile file, CancellationToken ct) => await Import(file, "productos", (row, rowNumber, errors) =>
    {
        if (!Enum.TryParse<ProductType>(Cell(row, 1), true, out var type) || !Enum.TryParse<BillingCycle>(Cell(row, 3), true, out var cycle) || !decimal.TryParse(Cell(row, 4), out var price) || !bool.TryParse(Cell(row, 7), out var active) || string.IsNullOrWhiteSpace(Cell(row, 2)) || string.IsNullOrWhiteSpace(Cell(row, 5))) { errors.Add(new(rowNumber, "Fila inválida: revisa tipo, ciclo, precio, moneda y activo.")); return Task.FromResult(false); }
        db.Products.Add(new Product { Type = type, Name = Cell(row, 2).Trim(), BillingCycle = cycle, BasePrice = price, Currency = Cell(row, 5).Trim().ToUpperInvariant(), Description = EmptyToNull(Cell(row, 6)), IsActive = active }); return Task.FromResult(true);
    }, ct);

    [HttpPost("clients/{clientId:guid}/products")]
    public async Task<ActionResult> AssignProduct(Guid clientId, AssignProductRequest request, CancellationToken ct)
    {
        if (!await db.Clients.AnyAsync(x => x.Id == clientId, ct) || !await db.Projects.AnyAsync(x => x.Id == request.ProjectId && x.ClientId == clientId, ct)) return NotFound();
        var product = await db.Products.FindAsync([request.ProductId], ct); if (product is null) return NotFound();
        if (request.BillingMode is not ("Manual" or "PayPal")) return BadRequest(new { message = "Modo de facturación inválido." });
        var item = new ClientProduct { ClientId = clientId, ProjectId = request.ProjectId, ProductId = product.Id, BillingCycle = request.BillingCycle, IsManualBilling = request.BillingMode == "Manual", Status = request.BillingMode == "Manual" ? ClientProductStatus.Activo : ClientProductStatus.Pendiente, Price = request.Price ?? product.BasePrice, DomainName = EmptyToNull(request.DomainName), PriceLabelOverride = EmptyToNull(request.PriceLabelOverride), Product = product };
        db.ClientProducts.Add(item);
        if (request.BillingMode == "PayPal")
        {
            try
            {
                var checkout = await checkoutService.StartAsync(item, product, ct);
                await db.SaveChangesAsync(ct);
                return Created($"/api/admin/client-products/{item.Id}", new { clientProduct = ClientProductDto(item), approvalUrl = checkout.ApprovalUrl });
            }
            catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
        }
        await db.SaveChangesAsync(ct); return Created($"/api/admin/client-products/{item.Id}", new { clientProduct = ClientProductDto(item), approvalUrl = (string?)null });
    }

    [HttpPatch("client-products/{id:guid}")]
    public async Task<ActionResult> UpdateClientProduct(Guid id, ClientProductPatchRequest request, CancellationToken ct)
    {
        var item = await db.ClientProducts.Include(x => x.Product).Include(x => x.Project).SingleOrDefaultAsync(x => x.Id == id, ct); if (item is null) return NotFound();
        if (request.Price is not null) item.Price = request.Price; if (request.Status is ClientProductStatus status) item.Status = status; if (request.BillingCycle is BillingCycle cycle) item.BillingCycle = cycle; if (request.DomainName is not null) item.DomainName = EmptyToNull(request.DomainName); if (request.PriceLabelOverride is not null) item.PriceLabelOverride = EmptyToNull(request.PriceLabelOverride); if (request.IsManualBilling is bool manual) item.IsManualBilling = manual;
        await db.SaveChangesAsync(ct); return Ok(ClientProductDto(item));
    }

    private async Task<ActionResult> Import(IFormFile file, string kind, Func<IXLRow, int, List<ImportError>, Task<bool>> addRow, CancellationToken ct)
    {
        if (file is null || file.Length == 0) return BadRequest(new { message = "Selecciona un archivo .xlsx." });
        var errors = new List<ImportError>(); var created = 0;
        try { using var stream = file.OpenReadStream(); using var book = new XLWorkbook(stream); var sheet = book.Worksheets.First(); foreach (var row in sheet.RowsUsed().Skip(1)) if (await addRow(row, row.RowNumber(), errors)) { await db.SaveChangesAsync(ct); created++; } }
        catch (Exception ex) when (ex is not DbUpdateException) { return BadRequest(new { message = $"No se pudo leer la plantilla de {kind}." }); }
        return Ok(new { created, skipped = errors.Count, errors });
    }
    private static string Cell(IXLRow row, int col) => row.Cell(col).GetString();
    private static byte[] CreateWorkbook(string[] headers) { using var book = new XLWorkbook(); var sheet = book.AddWorksheet("Plantilla"); for (var i = 0; i < headers.Length; i++) sheet.Cell(1, i + 1).Value = headers[i]; sheet.Row(1).Style.Font.Bold = true; sheet.Columns().AdjustToContents(); using var stream = new MemoryStream(); book.SaveAs(stream); return stream.ToArray(); }
    private static string? EmptyToNull(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
    private static string? ValidateClient(ClientRequest request) => string.IsNullOrWhiteSpace(request.CompanyName) || string.IsNullOrWhiteSpace(request.ContactName) || string.IsNullOrWhiteSpace(request.Email) || !request.Email.Contains('@') ? "Empresa, contacto y email válido son obligatorios." : request.PreferredLanguage.Trim().ToLowerInvariant() is not ("es" or "en" or "it") ? "Idioma inválido." : null;
    private static string? ValidateProduct(ProductRequest request) => string.IsNullOrWhiteSpace(request.Name) || string.IsNullOrWhiteSpace(request.Currency) ? "Nombre y moneda son obligatorios." : null;
    private static Product ToProduct(ProductRequest r) => new() { Type = r.Type, Name = r.Name.Trim(), BillingCycle = r.BillingCycle, BasePrice = r.BasePrice, Currency = r.Currency.Trim().ToUpperInvariant(), Description = EmptyToNull(r.Description), IsActive = r.IsActive };
    private static object ClientDto(Client x) => new { id = x.Id, companyName = x.CompanyName, contactName = x.ContactName, email = x.Email, phone = x.Phone, preferredLanguage = x.PreferredLanguage, isActive = x.IsActive };
    private static object ProductDto(Product x) => new { id = x.Id, type = x.Type.ToString(), name = x.Name, billingCycle = x.BillingCycle.ToString(), basePrice = x.BasePrice, currency = x.Currency, description = x.Description, isActive = x.IsActive };
    private static object ClientProductDto(ClientProduct x) => new { id = x.Id, clientId = x.ClientId, projectId = x.ProjectId, projectName = x.Project?.Name, productId = x.ProductId, productName = x.Product?.Name, productType = x.Product?.Type.ToString(), billingCycle = x.BillingCycle.ToString(), isManualBilling = x.IsManualBilling, status = x.Status.ToString(), price = x.Price, domainName = x.DomainName, priceLabelOverride = x.PriceLabelOverride };
    private static object TaxDocumentDto(TaxDocument x) => new { id = x.Id, paymentTransactionId = x.PaymentTransactionId, clientId = x.ClientId, type = x.Type.ToString(), series = x.Series, number = x.Number, issueDate = x.IssueDate, currency = x.Currency, baseAmount = x.BaseAmount, igvAmount = x.IgvAmount, totalAmount = x.TotalAmount, notes = x.Notes };
    private static object ExpenseDto(Expense x) => new { id = x.Id, description = x.Description, category = x.Category.ToString(), type = x.Type.ToString(), amount = x.Amount, currency = x.Currency, amountPen = x.AmountPen, date = x.Date, recurring = x.Recurring, recurrenceCycle = x.RecurrenceCycle?.ToString() };
}

public sealed record ProfileRequest(string Name);
public sealed record ChangePasswordRequest(string CurrentPassword, string NewPassword);
public sealed record InviteRequest(string Name, string Email);
public sealed record UpdateTeamRequest(UserRole? Role, bool? IsActive);
public sealed record ClientRequest(string CompanyName, string ContactName, string Email, string? Phone, string PreferredLanguage);
public sealed record ClientPatchRequest(string? CompanyName, string? ContactName, string? Email, string? Phone, string? PreferredLanguage, bool? IsActive);
public sealed record ProductRequest(ProductType Type, string Name, BillingCycle BillingCycle, decimal? BasePrice, string Currency, string? Description, bool IsActive);
public sealed record ProductPatchRequest(ProductType? Type, string? Name, BillingCycle? BillingCycle, decimal? BasePrice, string? Currency, string? Description, bool? IsActive);
public sealed record AssignProductRequest(Guid ProductId, Guid ProjectId, BillingCycle BillingCycle, string BillingMode, decimal? Price, string? DomainName, string? PriceLabelOverride);
public sealed record ClientProductPatchRequest(decimal? Price, ClientProductStatus? Status, BillingCycle? BillingCycle, bool? IsManualBilling, string? DomainName, string? PriceLabelOverride);
public sealed record ImportError(int Row, string Reason);
public sealed record TaxSettingsRequest(decimal? IgvRate, decimal? RentaRate);
public sealed record TaxDocumentRequest(Guid? PaymentTransactionId, Guid ClientId, TaxDocumentType Type, string Series, int Number, DateOnly IssueDate, string Currency, decimal BaseAmount, decimal IgvAmount, decimal TotalAmount, string? Notes);
public sealed record ExpenseRequest(string Description, ExpenseCategory Category, ExpenseType Type, decimal Amount, string Currency, DateOnly Date, bool Recurring, BillingCycle? RecurrenceCycle);
public sealed record ExpensePatchRequest(string? Description, ExpenseCategory? Category, ExpenseType? Type, decimal? Amount, string? Currency, DateOnly? Date, bool? Recurring, BillingCycle? RecurrenceCycle);
