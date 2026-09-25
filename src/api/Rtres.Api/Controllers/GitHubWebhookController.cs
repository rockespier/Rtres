using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

[ApiController, Route("api/webhooks/github")]
public sealed class GitHubWebhookController(RtresDbContext db, INotificationSender notifications) : ControllerBase
{
    [HttpPost]
    public async Task<ActionResult> Receive([FromBody] GitHubIssueWebhook payload, CancellationToken ct)
    {
        if (Request.Headers["X-GitHub-Event"] != "issues") return Ok();
        var ticket = await db.Tickets.SingleOrDefaultAsync(x => x.GithubIssueNumber == payload.Issue.Number, ct);
        if (ticket is null) return Ok();
        ticket.Status = payload.Issue.State == "closed" ? TicketStatus.Cerrado : TicketStatus.EnProgreso; ticket.UpdatedAt = DateTime.UtcNow;
        var client = await db.Clients.FindAsync([ticket.ClientId], ct);
        if (client is not null) await notifications.SendAsync(client, ticket.Status == TicketStatus.Cerrado ? "ticket-closed" : "ticket-updated", ticket, ct);
        await db.SaveChangesAsync(ct); return Ok();
    }
}

public record GitHubIssueWebhook(string Action, GitHubWebhookIssue Issue);
public record GitHubWebhookIssue(int Number, string State);
