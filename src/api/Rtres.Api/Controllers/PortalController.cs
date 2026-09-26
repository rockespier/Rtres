using System.Security.Claims;
using Hangfire;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Jobs;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

[ApiController, Authorize, Route("api")]
public sealed class PortalController(RtresDbContext db, IBackgroundJobClient jobs) : ControllerBase
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
        return Ok(new { activeProducts = await p.CountAsync(x => x.Status == ClientProductStatus.Activo, ct), expiringSoon = await p.CountAsync(x => x.Status == ClientProductStatus.PorVencer, ct), openTickets = await db.Tickets.CountAsync(x => x.ClientId == id && (x.Status == TicketStatus.Abierto || x.Status == TicketStatus.EnProgreso), ct), nextPaymentAmount = await p.Where(x => x.NextChargeAt != null).OrderBy(x => x.NextChargeAt).Select(x => x.Price).FirstOrDefaultAsync(ct) });
    }
    [HttpGet("client-products")] public async Task<IActionResult> Products(Guid? clientId, CancellationToken ct) { var error = ResolveClientId(clientId, out var id); if (error is not null) return error; return Ok(await db.ClientProducts.Include(x => x.Product).Include(x => x.Project).Where(x => x.ClientId == id).ToListAsync(ct)); }
    [HttpGet("projects")] public async Task<IActionResult> Projects(Guid? clientId, CancellationToken ct) { var error = ResolveClientId(clientId, out var id); if (error is not null) return error; return Ok(await db.Projects.Where(x => x.ClientId == id).ToListAsync(ct)); }
    [HttpGet("tickets")] public async Task<IActionResult> Tickets(Guid? clientId, TicketStatus? status = null, TicketType? type = null, int page = 1, CancellationToken ct = default) { var error = ResolveClientId(clientId, out var id); if (error is not null) return error; page = Math.Max(page, 1); var q = db.Tickets.Where(x => x.ClientId == id && (status == null || x.Status == status) && (type == null || x.Type == type)).OrderByDescending(x => x.UpdatedAt); var n = await q.CountAsync(ct); return Ok(new { items = await q.Skip((page - 1) * 20).Take(20).ToListAsync(ct), page, totalPages = (int)Math.Ceiling(n / 20d) }); }
    [HttpGet("tickets/{id:guid}")] public async Task<IActionResult> Ticket(Guid id, Guid? clientId, CancellationToken ct) { var error = ResolveClientId(clientId, out var client); if (error is not null) return error; var t = await db.Tickets.SingleOrDefaultAsync(x => x.Id == id && x.ClientId == client, ct); return t is null ? NotFound() : Ok(new { ticket = t, comments = await ToCommentDtos(db, db.TicketComments.Where(x => x.TicketId == id).OrderBy(x => x.CreatedAt)).ToListAsync(ct) }); }
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
        .Select(x => new TicketCommentDto(x.Id, x.Body, x.FromGithub, x.FromGithub ? x.GithubAuthorLogin : db.UserAccounts.Where(u => u.Id == x.AuthorUserId).Select(u => u.Name == "" ? u.Email : u.Name).FirstOrDefault(), x.CreatedAt));
    [HttpPost("tickets")] public async Task<IActionResult> CreateTicket(CreateTicketRequest r, Guid? clientId, CancellationToken ct) { var error = ResolveClientId(clientId, out var client); if (error is not null) return error; if (!await db.Projects.AnyAsync(x => x.Id == r.ProjectId && x.ClientId == client, ct)) return NotFound(); var t = new Ticket { Code = $"RT-{101 + await db.Tickets.CountAsync(ct)}", ClientId = client, ProjectId = r.ProjectId, CreatedByUserId = UserId, Type = r.Type, Title = r.Title, Description = r.Description, CurrentBehavior = r.CurrentBehavior, ExpectedBehavior = r.ExpectedBehavior, StepsToReproduce = r.StepsToReproduce, Environment = r.Environment, AcceptanceCriteria = r.AcceptanceCriteria, EstimatedImpact = r.EstimatedImpact }; db.Tickets.Add(t); await db.SaveChangesAsync(ct); jobs.Enqueue<GitHubIssueSyncJob>(j => j.CreateIssueAsync(t.Id, CancellationToken.None)); return Created($"/api/tickets/{t.Id}", t); }
    [HttpPost("tickets/{id:guid}/attachments")] public async Task<IActionResult> Attachment(Guid id, IFormFile file, Guid? clientId, CancellationToken ct) { var error = ResolveClientId(clientId, out var client); if (error is not null) return error; if (!await db.Tickets.AnyAsync(x => x.Id == id && x.ClientId == client, ct)) return NotFound(); var a = new TicketAttachment { TicketId = id, FileName = file.FileName, Url = $"/uploads/{id}/{file.FileName}", SizeBytes = file.Length }; db.TicketAttachments.Add(a); await db.SaveChangesAsync(ct); return Ok(a); }
}
