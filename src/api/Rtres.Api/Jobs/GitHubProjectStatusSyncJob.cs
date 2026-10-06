using Hangfire;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.GitHub;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Jobs;

/// <summary>
/// Copia al ticket la columna "Status" del GitHub Project donde está su issue (Recibido, En progreso, Resuelto, Publicado).
/// GitHub no avisa por webhook de los movimientos en proyectos de usuario, así que se consulta cada pocos minutos.
/// Solo se aplica cuando la columna cambia respecto a la última vista: así no pisa estados puestos por label o al cerrar.
/// </summary>
public sealed class GitHubProjectStatusSyncJob(RtresDbContext db, IGitHubIssuesClient github, INotificationSender notifications, ILogger<GitHubProjectStatusSyncJob> logger)
{
    [AutomaticRetry(Attempts = 0), DisableConcurrentExecution(timeoutInSeconds: 300)]
    public async Task SyncAsync(CancellationToken cancellationToken)
    {
        var tickets = await db.Tickets.Where(x => x.GithubIssueNumber != null && x.RepositoryId != null && x.Status != TicketStatus.Cerrado).ToListAsync(cancellationToken);
        var repositoryIds = tickets.Select(x => x.RepositoryId!.Value).Distinct().ToList();
        var repositories = await db.ProjectRepositories.Where(x => repositoryIds.Contains(x.Id)).ToListAsync(cancellationToken);

        foreach (var repository in repositories)
        {
            var group = tickets.Where(x => x.RepositoryId == repository.Id).ToList();
            IReadOnlyDictionary<int, GitHubIssueState> states;
            try { states = await github.GetIssueStatesAsync(repository, group.Select(x => x.GithubIssueNumber!.Value).ToList(), cancellationToken); }
            catch (Exception ex) when (ex is HttpRequestException or InvalidOperationException)
            {
                // Un repo sin token o sin permiso no frena al resto.
                logger.LogWarning(ex, "No se pudo leer el estado de los issues de {Owner}/{Repo}", repository.Owner, repository.Name);
                continue;
            }

            foreach (var ticket in group)
            {
                if (!states.TryGetValue(ticket.GithubIssueNumber!.Value, out var state) || state.ProjectStatus is null || state.ProjectStatus == ticket.GithubProjectStatus) continue;
                ticket.GithubProjectStatus = state.ProjectStatus;
                if (GitHubProjectStatus.Resolve(state) is { } status && status != ticket.Status)
                {
                    ticket.Status = status; ticket.UpdatedAt = DateTime.UtcNow;
                    await GitHubWebhookProcessor.NotifyTicketAsync(db, notifications, ticket, NotificationType.TicketStatusChanged, new() { ["status"] = status.ToString() }, null, cancellationToken);
                    logger.LogInformation("Ticket {Code} → {Status} (columna «{Column}» en GitHub)", ticket.Code, status, state.ProjectStatus);
                }
            }
            await db.SaveChangesAsync(cancellationToken);
        }
    }
}
