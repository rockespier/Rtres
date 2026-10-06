using System.Text.Json;
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
