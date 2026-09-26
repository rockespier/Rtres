using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
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
        var ticket = new Ticket { Code = "RT-110", Type = TicketType.Soporte, Title = "Botón roto", Description = "No responde", Environment = "  ", EstimatedImpact = "Alto" };
        var body = GitHubIssuesClient.BuildBody(ticket);
        Assert.Contains("## Descripción\nNo responde", body.ReplaceLineEndings("\n"));
        Assert.DoesNotContain("## Entorno", body);
        Assert.DoesNotContain("Impacto", body);
        ticket.Type = TicketType.Cambio;
        Assert.Contains("## Impacto estimado", GitHubIssuesClient.BuildBody(ticket));
        Assert.Equal("[RT-110] Botón roto", GitHubIssuesClient.BuildTitle(ticket));
        Assert.Equal(["tipo:cambio", "estado:abierto", "proyecto:web"], GitHubIssuesClient.BuildLabels(new Project { Slug = "web" }, ticket));
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

internal sealed record Seed(Client Client, Project Project, Ticket Ticket);

internal static class TestData
{
    public static RtresDbContext Db(out Seed seed, int? issueNumber = null)
    {
        var db = new RtresDbContext(new DbContextOptionsBuilder<RtresDbContext>().UseInMemoryDatabase(Guid.NewGuid().ToString()).Options);
        var client = new Client { CompanyName = "Cabalgatas Andinas", Email = "c@example.com" };
        var project = new Project { ClientId = client.Id, Name = "Web", Slug = "cabalgatas-andinas-web", GithubRepoOwner = "rtres", GithubRepoName = "cabalgatas-andinas-web" };
        var ticket = new Ticket { Code = "RT-108", ClientId = client.Id, ProjectId = project.Id, Title = "Botón", Description = "No responde", GithubIssueNumber = issueNumber };
        db.AddRange(client, project, ticket); db.SaveChanges();
        seed = new Seed(client, project, ticket);
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
