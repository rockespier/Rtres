using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.GitHub;

/// <summary>Aplica los eventos <c>issues</c> e <c>issue_comment</c> de GitHub sobre los tickets del portal.</summary>
public sealed class GitHubWebhookProcessor(RtresDbContext db, INotificationSender notifications, ILogger<GitHubWebhookProcessor> logger)
{
    public const string StatusChangedTemplate = "ticket-status-changed";

    public async Task ProcessAsync(string eventName, JsonElement payload, CancellationToken ct)
    {
        if (eventName is not ("issues" or "issue_comment")) return;
        if (!payload.TryGetProperty("issue", out var issue) || !payload.TryGetProperty("repository", out var repo)) return;
        if (issue.TryGetProperty("pull_request", out _)) return; // comentarios en PRs no son tickets

        var owner = repo.GetProperty("owner").GetProperty("login").GetString();
        var name = repo.GetProperty("name").GetString();
        var number = issue.GetProperty("number").GetInt32();
        var ticket = await db.Tickets
            .Join(db.Projects, t => t.ProjectId, p => p.Id, (t, p) => new { t, p })
            .Where(x => x.t.GithubIssueNumber == number && x.p.GithubRepoOwner == owner && x.p.GithubRepoName == name)
            .Select(x => x.t).SingleOrDefaultAsync(ct);
        if (ticket is null) { logger.LogDebug("Issue {Owner}/{Repo}#{Number} no corresponde a ningún ticket", owner, name, number); return; }

        var action = payload.GetProperty("action").GetString();
        if (eventName == "issues") await ApplyIssueAsync(ticket, issue, ct);
        else await ApplyCommentAsync(ticket, action, payload.GetProperty("comment"), ct);
        await db.SaveChangesAsync(ct);
    }

    private async Task ApplyIssueAsync(Ticket ticket, JsonElement issue, CancellationToken ct)
    {
        var labels = issue.TryGetProperty("labels", out var l) && l.ValueKind == JsonValueKind.Array
            ? l.EnumerateArray().Select(x => x.GetProperty("name").GetString() ?? string.Empty)
            : [];
        var stateReason = issue.TryGetProperty("state_reason", out var r) && r.ValueKind == JsonValueKind.String ? r.GetString() : null;
        var newStatus = GitHubLabels.ResolveStatus(issue.GetProperty("state").GetString() ?? "open", stateReason, labels);
        if (newStatus == ticket.Status) return;

        var previous = ticket.Status;
        ticket.Status = newStatus; ticket.UpdatedAt = DateTime.UtcNow;
        var client = await db.Clients.FindAsync([ticket.ClientId], ct);
        if (client is null) return;
        var success = true;
        try { await notifications.SendAsync(client, StatusChangedTemplate, new { ticket.Code, ticket.Title, PreviousStatus = previous, Status = newStatus, ticket.GithubIssueUrl }, ct); }
        catch (Exception ex) { success = false; logger.LogError(ex, "No se pudo notificar el cambio de estado del ticket {Code}", ticket.Code); }
        db.NotificationLogs.Add(new NotificationLog { ClientId = client.Id, Type = "TicketStatusChange", Channel = "email", Success = success });
    }

    private async Task ApplyCommentAsync(Ticket ticket, string? action, JsonElement comment, CancellationToken ct)
    {
        var commentId = comment.GetProperty("id").GetInt64();
        var user = comment.GetProperty("user");
        if (user.GetProperty("type").GetString() == "Bot") return;
        var existing = await db.TicketComments.SingleOrDefaultAsync(x => x.TicketId == ticket.Id && x.GithubCommentId == commentId, ct);
        var body = comment.GetProperty("body").GetString() ?? string.Empty;
        switch (action)
        {
            case "created" when existing is null:
                db.TicketComments.Add(new TicketComment { TicketId = ticket.Id, Body = body, FromGithub = true, GithubCommentId = commentId, GithubAuthorLogin = user.GetProperty("login").GetString() });
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
