using Hangfire;
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
        var project = await db.Projects.SingleAsync(x => x.Id == ticket.ProjectId, cancellationToken);
        if (!HasRepo(project))
        {
            logger.LogWarning("Proyecto {Project} no tiene repo de GitHub configurado; ticket {Code} queda sin issue", project.Slug, ticket.Code);
            return;
        }
        if (ticket.GithubIssueNumber is null)
        {
            var issue = await github.CreateIssueAsync(project, ticket, cancellationToken);
            ticket.GithubIssueNumber = issue.Number; ticket.GithubIssueUrl = issue.Url; ticket.UpdatedAt = DateTime.UtcNow;
            await db.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Ticket {Code} sincronizado con {Owner}/{Repo}#{Number}", ticket.Code, project.GithubRepoOwner, project.GithubRepoName, issue.Number);
        }

        // Comentarios hechos en el portal antes de que existiera el issue.
        var pending = await db.TicketComments.Where(x => x.TicketId == ticket.Id && !x.FromGithub && x.GithubCommentId == null).OrderBy(x => x.CreatedAt).ToListAsync(cancellationToken);
        foreach (var comment in pending) await PublishAsync(project, ticket, comment, cancellationToken);
    }

    [AutomaticRetry(Attempts = 5)]
    public async Task PostCommentAsync(Guid commentId, CancellationToken cancellationToken)
    {
        var comment = await db.TicketComments.SingleOrDefaultAsync(x => x.Id == commentId, cancellationToken);
        if (comment is null || comment.FromGithub || comment.GithubCommentId is not null) return;
        var ticket = await db.Tickets.SingleAsync(x => x.Id == comment.TicketId, cancellationToken);
        if (ticket.GithubIssueNumber is null) return; // CreateIssueAsync lo publica al crear el issue
        var project = await db.Projects.SingleAsync(x => x.Id == ticket.ProjectId, cancellationToken);
        if (!HasRepo(project)) return;
        await PublishAsync(project, ticket, comment, cancellationToken);
    }

    private async Task PublishAsync(Project project, Ticket ticket, TicketComment comment, CancellationToken cancellationToken)
    {
        var author = await db.UserAccounts.Where(x => x.Id == comment.AuthorUserId).Select(x => x.Name == "" ? x.Email : x.Name).SingleOrDefaultAsync(cancellationToken) ?? "Cliente";
        comment.GithubCommentId = await github.CreateCommentAsync(project, ticket.GithubIssueNumber!.Value, GitHubIssuesClient.BuildCommentBody(comment, author), cancellationToken);
        await db.SaveChangesAsync(cancellationToken);
    }

    private static bool HasRepo(Project project) => !string.IsNullOrWhiteSpace(project.GithubRepoOwner) && !string.IsNullOrWhiteSpace(project.GithubRepoName);
}
