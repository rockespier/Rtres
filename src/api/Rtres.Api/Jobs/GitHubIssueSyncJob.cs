using Hangfire;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>Crea el issue de GitHub de un ticket. Se encola al crear el ticket; Hangfire reintenta si GitHub falla.</summary>
public sealed class GitHubIssueSyncJob(RtresDbContext db, IGitHubIssuesClient github, ILogger<GitHubIssueSyncJob> logger)
{
    [AutomaticRetry(Attempts = 5)]
    public async Task CreateIssueAsync(Guid ticketId, CancellationToken cancellationToken)
    {
        var ticket = await db.Tickets.SingleOrDefaultAsync(x => x.Id == ticketId, cancellationToken);
        if (ticket is null) { logger.LogWarning("Ticket {TicketId} no existe; no se crea issue", ticketId); return; }
        if (ticket.GithubIssueNumber is not null) return; // idempotente ante reintentos
        var project = await db.Projects.SingleAsync(x => x.Id == ticket.ProjectId, cancellationToken);
        if (string.IsNullOrWhiteSpace(project.GithubRepoOwner) || string.IsNullOrWhiteSpace(project.GithubRepoName))
        {
            logger.LogWarning("Proyecto {Project} no tiene repo de GitHub configurado; ticket {Code} queda sin issue", project.Slug, ticket.Code);
            return;
        }
        var issue = await github.CreateIssueAsync(project, ticket, cancellationToken);
        ticket.GithubIssueNumber = issue.Number; ticket.GithubIssueUrl = issue.Url; ticket.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        logger.LogInformation("Ticket {Code} sincronizado con {Owner}/{Repo}#{Number}", ticket.Code, project.GithubRepoOwner, project.GithubRepoName, issue.Number);
    }
}
