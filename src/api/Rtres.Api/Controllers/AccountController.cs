using System.Security.Claims;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ClosedXML.Excel;
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
public sealed class AdminController(RtresDbContext db, PayPalCheckoutService checkoutService) : ControllerBase
{
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
