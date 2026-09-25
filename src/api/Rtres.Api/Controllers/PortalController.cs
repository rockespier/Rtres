using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;
namespace Rtres.Api.Controllers;
[ApiController,Authorize,Route("api")]
public sealed class PortalController(RtresDbContext db):ControllerBase
{
 Guid ClientId=>Guid.Parse(User.FindFirstValue("client_id")!); Guid UserId=>Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
 [HttpGet("dashboard/summary")] public async Task<ActionResult> Summary(CancellationToken ct){var p=db.ClientProducts.Where(x=>x.ClientId==ClientId);return Ok(new{activeProducts=await p.CountAsync(x=>x.Status==ClientProductStatus.Activo,ct),expiringSoon=await p.CountAsync(x=>x.Status==ClientProductStatus.PorVencer,ct),openTickets=await db.Tickets.CountAsync(x=>x.ClientId==ClientId&&(x.Status==TicketStatus.Abierto||x.Status==TicketStatus.EnProgreso),ct),nextPaymentAmount=await p.OrderBy(x=>x.NextChargeAt).Select(x=>x.Price).FirstOrDefaultAsync(ct)});}
 [HttpGet("client-products")] public async Task<ActionResult> Products(CancellationToken ct)=>Ok(await db.ClientProducts.Include(x=>x.Product).Include(x=>x.Project).Where(x=>x.ClientId==ClientId).ToListAsync(ct));
 [HttpGet("projects")] public async Task<ActionResult> Projects(CancellationToken ct)=>Ok(await db.Projects.Where(x=>x.ClientId==ClientId).ToListAsync(ct));
 [HttpGet("tickets")] public async Task<ActionResult> Tickets(int page=1,CancellationToken ct=default){var q=db.Tickets.Where(x=>x.ClientId==ClientId).OrderByDescending(x=>x.UpdatedAt);var n=await q.CountAsync(ct);return Ok(new{items=await q.Skip((page-1)*20).Take(20).ToListAsync(ct),page,totalPages=(int)Math.Ceiling(n/20d)});}
 [HttpGet("tickets/{id:guid}")] public async Task<ActionResult> Ticket(Guid id,CancellationToken ct){var t=await db.Tickets.SingleOrDefaultAsync(x=>x.Id==id&&x.ClientId==ClientId,ct);return t is null?NotFound():Ok(new{ticket=t,comments=await db.TicketComments.Where(x=>x.TicketId==id).ToListAsync(ct)});}
 [HttpPost("tickets")] public async Task<ActionResult> CreateTicket(CreateTicketRequest r,CancellationToken ct){if(!await db.Projects.AnyAsync(x=>x.Id==r.ProjectId&&x.ClientId==ClientId,ct))return NotFound();var t=new Ticket{Code=$"RT-{101+await db.Tickets.CountAsync(ct)}",ClientId=ClientId,ProjectId=r.ProjectId,CreatedByUserId=UserId,Type=r.Type,Title=r.Title,Description=r.Description,CurrentBehavior=r.CurrentBehavior,ExpectedBehavior=r.ExpectedBehavior,StepsToReproduce=r.StepsToReproduce,Environment=r.Environment,AcceptanceCriteria=r.AcceptanceCriteria,EstimatedImpact=r.EstimatedImpact};db.Tickets.Add(t);await db.SaveChangesAsync(ct);return Created($"/api/tickets/{t.Id}",t);}
 [HttpPost("tickets/{id:guid}/attachments")] public async Task<ActionResult> Attachment(Guid id,IFormFile file,CancellationToken ct){if(!await db.Tickets.AnyAsync(x=>x.Id==id&&x.ClientId==ClientId,ct))return NotFound();var a=new TicketAttachment{TicketId=id,FileName=file.FileName,Url=$"/uploads/{id}/{file.FileName}",SizeBytes=file.Length};db.TicketAttachments.Add(a);await db.SaveChangesAsync(ct);return Ok(a);}
}
