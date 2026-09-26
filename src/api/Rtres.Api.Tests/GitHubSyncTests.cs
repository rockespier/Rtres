using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Hangfire;
using Hangfire.Common;
using Hangfire.States;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.GitHub;
using Rtres.Api.Jobs;
using Rtres.Domain;
using Rtres.Infrastructure;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class GitHubLabelsTests
{
    [Theory]
    [InlineData("open", null, new string[0], TicketStatus.Abierto)]
    [InlineData("open", null, new[] { "tipo:soporte", "estado:en-progreso" }, TicketStatus.EnProgreso)]
    [InlineData("open", null, new[] { "estado:en-progreso", "estado:resuelto" }, TicketStatus.Resuelto)]
    [InlineData("closed", "completed", new string[0], TicketStatus.Resuelto)]
    [InlineData("closed", "not_planned", new string[0], TicketStatus.Cerrado)]
    [InlineData("closed", "completed", new[] { "Estado:Publicado" }, TicketStatus.Publicado)]
    public void ResolveStatus_maps_issue_state_and_labels(string state, string? reason, string[] labels, TicketStatus expected)
        => Assert.Equal(expected, GitHubLabels.ResolveStatus(state, reason, labels));

    [Fact]
    public void Status_labels_round_trip()
    {
        foreach (var status in Enum.GetValues<TicketStatus>())
            Assert.Equal(status, GitHubLabels.ResolveStatus("open", null, [GitHubLabels.ForStatus(status)]));
    }
}

public class GitHubWebhookSignatureTests
{
    [Fact]
    public void Accepts_valid_and_rejects_tampered_signatures()
    {
        var body = Encoding.UTF8.GetBytes("{\"a\":1}");
        var header = TestData.Sign("s3cret", body);
        Assert.True(GitHubWebhookSignature.IsValid("s3cret", body, header));
        Assert.False(GitHubWebhookSignature.IsValid("otro", body, header));
        Assert.False(GitHubWebhookSignature.IsValid("s3cret", Encoding.UTF8.GetBytes("{\"a\":2}"), header));
        Assert.False(GitHubWebhookSignature.IsValid("s3cret", body, null));
        Assert.False(GitHubWebhookSignature.IsValid("s3cret", body, "sha256=zz"));
        Assert.False(GitHubWebhookSignature.IsValid("", body, header));
    }
}

public class GitHubIssuesClientTests
{
    [Fact]
    public void Body_skips_empty_sections_and_impact_only_for_changes()
    {
        var ticket = new Ticket { Code = "RT-110", Type = TicketType.Bug, Title = "Botón roto", Description = "No responde", Environment = "  ", EstimatedImpact = "Alto" };
        var body = GitHubIssuesClient.BuildBody(ticket);
        Assert.Contains("## Descripción\nNo responde", body.ReplaceLineEndings("\n"));
        Assert.DoesNotContain("## Entorno", body);
        Assert.DoesNotContain("Impacto", body);
        ticket.Type = TicketType.Requerimiento;
        Assert.Contains("## Impacto estimado", GitHubIssuesClient.BuildBody(ticket));
        Assert.Equal("[RT-110] Botón roto", GitHubIssuesClient.BuildTitle(ticket));
        Assert.Equal(["requirement", "estado:abierto", "proyecto:web"], GitHubIssuesClient.BuildLabels(new Project { Slug = "web" }, ticket));
    }

    [Theory]
    [InlineData(TicketType.Bug, "bug")]
    [InlineData(TicketType.Funcionalidad, "enhancement")]
    [InlineData(TicketType.Requerimiento, "requirement")]
    public void Type_labels_follow_github_conventions(TicketType type, string label) => Assert.Equal(label, GitHubLabels.ForType(type));

    [Fact]
    public void Portal_comment_body_carries_marker()
    {
        var comment = new TicketComment { Body = " Gracias " };
        var body = GitHubIssuesClient.BuildCommentBody(comment, "Roberto");
        Assert.StartsWith("**Roberto** (vía portal de clientes):", body);
        Assert.Contains(GitHubLabels.PortalCommentMarker + comment.Id, body);
    }
}

public class GitHubIssueSyncJobTests
{
    [Fact]
    public async Task Creates_issue_once_and_stores_number()
    {
        using var db = TestData.Db(out var seed);
        var github = new FakeGitHub();
        var job = new GitHubIssueSyncJob(db, github, NullLogger<GitHubIssueSyncJob>.Instance);
        await job.CreateIssueAsync(seed.Ticket.Id, CancellationToken.None);
        await job.CreateIssueAsync(seed.Ticket.Id, CancellationToken.None);
        Assert.Equal(1, github.Calls);
        var ticket = await db.Tickets.SingleAsync(x => x.Id == seed.Ticket.Id);
        Assert.Equal(42, ticket.GithubIssueNumber);
        Assert.Equal("https://github.com/rtres/cabalgatas-andinas-web/issues/42", ticket.GithubIssueUrl);
    }

    [Fact]
    public async Task Portal_comments_are_published_once_issue_exists()
    {
        using var db = TestData.Db(out var seed);
        var comment = new TicketComment { TicketId = seed.Ticket.Id, AuthorUserId = seed.User.Id, Body = "¿Novedades?" };
        db.TicketComments.Add(comment); await db.SaveChangesAsync();
        var github = new FakeGitHub();
        var job = new GitHubIssueSyncJob(db, github, NullLogger<GitHubIssueSyncJob>.Instance);

        await job.PostCommentAsync(comment.Id, CancellationToken.None); // sin issue todavía: no publica
        Assert.Empty(github.Comments);

        await job.CreateIssueAsync(seed.Ticket.Id, CancellationToken.None); // publica los pendientes
        await job.PostCommentAsync(comment.Id, CancellationToken.None); // ya publicado: no duplica
        var (issue, body) = Assert.Single(github.Comments);
        Assert.Equal(42, issue);
        Assert.StartsWith("**Roberto Ramos**", body);
        Assert.Equal(5000, (await db.TicketComments.SingleAsync()).GithubCommentId);
    }

    [Fact]
    public async Task Skips_projects_without_repo()
    {
        using var db = TestData.Db(out var seed);
        seed.Project.GithubRepoName = ""; await db.SaveChangesAsync();
        var github = new FakeGitHub();
        await new GitHubIssueSyncJob(db, github, NullLogger<GitHubIssueSyncJob>.Instance).CreateIssueAsync(seed.Ticket.Id, CancellationToken.None);
        Assert.Equal(0, github.Calls);
    }
}

public class GitHubWebhookProcessorTests
{
    [Fact]
    public async Task Status_change_updates_ticket_notifies_and_logs()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        var notifications = new FakeNotifications();
        await Processor(db, notifications).ProcessAsync("issues", TestData.IssueEvent("labeled", 7, labels: ["estado:en-progreso"]), CancellationToken.None);
        Assert.Equal(TicketStatus.EnProgreso, (await db.Tickets.SingleAsync()).Status);
        Assert.Equal([GitHubWebhookProcessor.StatusChangedTemplate], notifications.Templates);
        Assert.True((await db.NotificationLogs.SingleAsync()).Success);

        // Mismo estado otra vez: no se notifica de nuevo.
        await Processor(db, notifications).ProcessAsync("issues", TestData.IssueEvent("edited", 7, labels: ["estado:en-progreso"]), CancellationToken.None);
        Assert.Single(notifications.Templates);
    }

    [Fact]
    public async Task Issue_from_other_repo_is_ignored()
    {
        using var db = TestData.Db(out _, issueNumber: 7);
        await Processor(db, new FakeNotifications()).ProcessAsync("issues", TestData.IssueEvent("closed", 7, state: "closed", repo: "otro-repo"), CancellationToken.None);
        Assert.Equal(TicketStatus.Abierto, (await db.Tickets.SingleAsync()).Status);
    }

    [Fact]
    public async Task Comments_are_created_edited_deleted_and_bots_ignored()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        var processor = Processor(db, new FakeNotifications());
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 900, "Lo estamos revisando"), CancellationToken.None);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 900, "Lo estamos revisando"), CancellationToken.None);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 901, "ci", userType: "Bot"), CancellationToken.None);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 902, "**Ana** (vía portal):\n\nHola\n\n" + GitHubLabels.PortalCommentMarker + Guid.NewGuid() + " -->"), CancellationToken.None);
        var comment = await db.TicketComments.SingleAsync();
        Assert.True(comment.FromGithub); Assert.Equal("dev", comment.GithubAuthorLogin);

        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("edited", 7, 900, "Corregido"), CancellationToken.None);
        Assert.Equal("Corregido", (await db.TicketComments.SingleAsync()).Body);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("deleted", 7, 900, "Corregido"), CancellationToken.None);
        Assert.Empty(db.TicketComments);
    }

    private static GitHubWebhookProcessor Processor(RtresDbContext db, INotificationSender n) => new(db, n, NullLogger<GitHubWebhookProcessor>.Instance);
}

public class GitHubWebhookControllerTests
{
    [Theory]
    [InlineData("s3cret", true)]
    [InlineData("otro", false)]
    public async Task Verifies_signature_before_processing(string signingSecret, bool accepted)
    {
        using var db = TestData.Db(out _, issueNumber: 7);
        var body = Encoding.UTF8.GetBytes(TestData.IssueEvent("closed", 7, state: "closed").GetRawText());
        var context = new DefaultHttpContext();
        context.Request.Body = new MemoryStream(body);
        context.Request.Headers["X-GitHub-Event"] = "issues";
        context.Request.Headers["X-Hub-Signature-256"] = TestData.Sign(signingSecret, body);
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["GitHub:WebhookSecret"] = "s3cret" }).Build();
        var controller = new GitHubWebhookController(new GitHubWebhookProcessor(db, new FakeNotifications(), NullLogger<GitHubWebhookProcessor>.Instance), config, NullLogger<GitHubWebhookController>.Instance)
            { ControllerContext = new ControllerContext { HttpContext = context } };

        var result = await controller.Receive(CancellationToken.None);

        Assert.Equal(accepted ? typeof(OkResult) : typeof(UnauthorizedResult), result.GetType());
        Assert.Equal(accepted ? TicketStatus.Resuelto : TicketStatus.Abierto, (await db.Tickets.SingleAsync()).Status);
    }
}

public class TicketCommentsEndpointTests
{
    [Fact]
    public async Task Portal_comment_is_saved_with_author_and_queued_for_github()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        var jobs = new FakeJobs();
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test");
        var controller = new PortalController(db, jobs) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };

        Assert.IsType<BadRequestObjectResult>(await controller.AddComment(seed.Ticket.Id, new CreateTicketCommentRequest("  "), CancellationToken.None));
        Assert.IsType<NotFoundResult>(await controller.AddComment(Guid.NewGuid(), new CreateTicketCommentRequest("Hola"), CancellationToken.None));

        var result = Assert.IsType<OkObjectResult>(await controller.AddComment(seed.Ticket.Id, new CreateTicketCommentRequest(" Hola "), CancellationToken.None));
        var dto = Assert.IsType<TicketCommentDto>(result.Value);
        Assert.Equal("Hola", dto.Body); Assert.Equal("Roberto Ramos", dto.AuthorName); Assert.False(dto.FromGithub);
        var job = Assert.Single(jobs.Created);
        Assert.Equal(nameof(GitHubIssueSyncJob.PostCommentAsync), job.Method.Name);
    }
}

internal sealed class FakeJobs : IBackgroundJobClient
{
    public List<Job> Created { get; } = [];
    public string Create(Job job, IState state) { Created.Add(job); return Created.Count.ToString(); }
    public bool ChangeState(string jobId, IState state, string expectedState) => true;
}

internal sealed record Seed(Client Client, Project Project, Ticket Ticket, UserAccount User);

internal static class TestData
{
    public static RtresDbContext Db(out Seed seed, int? issueNumber = null)
    {
        var db = new RtresDbContext(new DbContextOptionsBuilder<RtresDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString()).Options);
        var client = new Client { CompanyName = "Cabalgatas Andinas", Email = "c@example.com" };
        var project = new Project { ClientId = client.Id, Name = "Web", Slug = "cabalgatas-andinas-web", GithubRepoOwner = "rtres", GithubRepoName = "cabalgatas-andinas-web" };
        var user = new UserAccount { ClientId = client.Id, Email = "roberto@example.com", Name = "Roberto Ramos" };
        var ticket = new Ticket { Code = "RT-108", ClientId = client.Id, ProjectId = project.Id, Title = "Botón", Description = "No responde", GithubIssueNumber = issueNumber };
        db.AddRange(client, project, user, ticket); db.SaveChanges();
        seed = new Seed(client, project, ticket, user);
        return db;
    }

    public static string Sign(string secret, byte[] body) => "sha256=" + Convert.ToHexStringLower(HMACSHA256.HashData(Encoding.UTF8.GetBytes(secret), body));

    public static JsonElement IssueEvent(string action, int number, string state = "open", string[]? labels = null, string repo = "cabalgatas-andinas-web")
        => Json(new { action, issue = new { number, state, state_reason = (string?)null, labels = (labels ?? []).Select(name => new { name }) }, repository = Repo(repo) });

    public static JsonElement CommentEvent(string action, int number, long commentId, string body, string userType = "User")
        => Json(new { action, issue = new { number, state = "open" }, comment = new { id = commentId, body, user = new { login = "dev", type = userType } }, repository = Repo("cabalgatas-andinas-web") });

    private static object Repo(string name) => new { name, owner = new { login = "rtres" } };
    private static JsonElement Json(object value) => JsonSerializer.SerializeToElement(value);
}

internal sealed class FakeGitHub : IGitHubIssuesClient
{
    public int Calls { get; private set; }
    public List<(int Issue, string Body)> Comments { get; } = [];
    public Task<long> CreateCommentAsync(Project project, int issueNumber, string body, CancellationToken cancellationToken = default)
    {
        Comments.Add((issueNumber, body));
        return Task.FromResult(5000L);
    }
    public Task<GitHubIssue> CreateIssueAsync(Project project, Ticket ticket, CancellationToken cancellationToken = default)
    {
        Calls++;
        return Task.FromResult(new GitHubIssue(42, $"https://github.com/{project.GithubRepoOwner}/{project.GithubRepoName}/issues/42"));
    }
}

internal sealed class FakeNotifications : INotificationSender
{
    public List<string> Templates { get; } = [];
    public Task SendAsync(Client client, string template, object model, CancellationToken cancellationToken = default) { Templates.Add(template); return Task.CompletedTask; }
}
