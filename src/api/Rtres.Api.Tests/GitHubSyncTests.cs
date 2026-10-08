using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Hangfire;
using Hangfire.Common;
using Hangfire.States;
using Microsoft.AspNetCore.Authorization;
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
    [InlineData("closed", "completed", new[] { "bug", "estado:abierto" }, TicketStatus.Resuelto)] // label con el que nace todo issue
    [InlineData("closed", "not_planned", new[] { "estado:en-progreso" }, TicketStatus.Cerrado)]
    [InlineData("closed", "completed", new[] { "estado:en-progreso", "estado:resuelto" }, TicketStatus.Resuelto)]
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
    public void Token_per_owner_falls_back_to_default()
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["GitHub:Token"] = "personal",
            ["GitHub:Tokens:Mi-Org"] = "org",
        }).Build();

        Assert.Equal("org", GitHubIssuesClient.TokenFor(config, "mi-org"));
        Assert.Equal("personal", GitHubIssuesClient.TokenFor(config, "rockespier"));
        Assert.Throws<InvalidOperationException>(() => GitHubIssuesClient.TokenFor(new ConfigurationBuilder().Build(), "rockespier"));
    }

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
        TestData.RemoveRepos(db);
        var github = new FakeGitHub();
        await new GitHubIssueSyncJob(db, github, NullLogger<GitHubIssueSyncJob>.Instance).CreateIssueAsync(seed.Ticket.Id, CancellationToken.None);
        Assert.Equal(0, github.Calls);
    }
}

public class MultiRepoProjectTests
{
    [Fact]
    public async Task Ticket_goes_to_the_chosen_repo_and_its_webhook_finds_it()
    {
        using var db = TestData.Db(out var seed);
        var api = new ProjectRepository { ProjectId = seed.Project.Id, Owner = "rtres", Name = "cabalgatas-andinas-api", Label = "API" };
        db.ProjectRepositories.Add(api); await db.SaveChangesAsync();
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test");
        var portal = new PortalController(db, new FakeJobs(), new FakeNotifications(), new ConfigurationBuilder().Build(), NullLogger<PortalController>.Instance) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };

        Assert.IsType<BadRequestObjectResult>(await portal.CreateTicket(new CreateTicketRequest(seed.Project.Id, TicketType.Bug, "X", "Y", null, null, null, null, null, null, Guid.NewGuid()), null, CancellationToken.None));
        var created = Assert.IsType<CreatedResult>(await portal.CreateTicket(new CreateTicketRequest(seed.Project.Id, TicketType.Bug, "Falla el API", "500", null, null, null, null, null, null, api.Id), null, CancellationToken.None));
        var ticket = Assert.IsType<Ticket>(created.Value);

        var github = new FakeGitHub();
        var job = new GitHubIssueSyncJob(db, github, NullLogger<GitHubIssueSyncJob>.Instance);
        await job.CreateIssueAsync(ticket.Id, CancellationToken.None);
        await job.CreateIssueAsync(seed.Ticket.Id, CancellationToken.None); // sin repositorio indicado: va al principal
        Assert.Equal(["rtres/cabalgatas-andinas-api", "rtres/cabalgatas-andinas-web"], github.Repos);
        Assert.Equal(api.Id, (await db.Tickets.SingleAsync(x => x.Id == ticket.Id)).RepositoryId);

        // Mismo número de issue en ambos repos: el webhook distingue el ticket por repositorio.
        await new GitHubWebhookProcessor(db, new FakeNotifications(), NullLogger<GitHubWebhookProcessor>.Instance)
            .ProcessAsync("issues", TestData.IssueEvent("closed", 42, state: "closed", repo: "cabalgatas-andinas-api"), CancellationToken.None);
        Assert.Equal(TicketStatus.Resuelto, (await db.Tickets.SingleAsync(x => x.Id == ticket.Id)).Status);
        Assert.Equal(TicketStatus.Abierto, (await db.Tickets.SingleAsync(x => x.Id == seed.Ticket.Id)).Status);
    }
}

public class GitHubProjectStatusTests
{
    [Theory]
    [InlineData("Recibido", TicketStatus.Abierto)]
    [InlineData("En Progreso", TicketStatus.EnProgreso)]
    [InlineData("In progress", TicketStatus.EnProgreso)]
    [InlineData("Resuelto", TicketStatus.Resuelto)]
    [InlineData("Done", TicketStatus.Resuelto)]
    [InlineData("PUBLICADO", TicketStatus.Publicado)]
    [InlineData("En progresó", TicketStatus.EnProgreso)]
    [InlineData("Revisión", null)]
    [InlineData(null, null)]
    public void Columns_map_to_ticket_status(string? column, TicketStatus? expected) => Assert.Equal(expected, GitHubProjectStatus.Map(column));

    [Fact]
    public void Closed_issue_ignores_a_work_in_progress_column()
    {
        Assert.Null(GitHubProjectStatus.Resolve(new GitHubIssueState(true, "En Progreso")));
        Assert.Equal(TicketStatus.Publicado, GitHubProjectStatus.Resolve(new GitHubIssueState(true, "Publicado")));
    }

    [Fact]
    public void GraphQL_response_is_parsed_and_partial_errors_are_tolerated()
    {
        var json = JsonDocument.Parse("""
            {"data":{"repository":{
              "i1":{"state":"OPEN","projectItems":{"nodes":[{"fieldValueByName":null},{"fieldValueByName":{"name":"En Progreso"}}]}},
              "i2":{"state":"CLOSED","projectItems":null},
              "i3":null}},
             "errors":[{"message":"Could not resolve to an Issue with the number of 3."}]}
            """).RootElement;
        var states = GitHubIssuesClient.ParseStates(json).ToDictionary(x => x.Number, x => x.State);
        Assert.Equal(new GitHubIssueState(false, "En Progreso"), states[1]);
        Assert.Equal(new GitHubIssueState(true, null), states[2]);
        Assert.False(states.ContainsKey(3));
        Assert.Contains("i1:issue(number:1)", GitHubIssuesClient.BuildStatesQuery([1, 2]));
    }

    [Fact]
    public async Task Job_applies_the_column_only_when_it_changes()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        seed.Ticket.RepositoryId = (await db.ProjectRepositories.FirstAsync()).Id; await db.SaveChangesAsync();
        var github = new FakeGitHub(); var notifications = new FakeNotifications();
        var job = new GitHubProjectStatusSyncJob(db, github, notifications, NullLogger<GitHubProjectStatusSyncJob>.Instance);

        github.States[7] = new GitHubIssueState(false, "En Progreso");
        await job.SyncAsync(CancellationToken.None);
        var ticket = await db.Tickets.SingleAsync();
        Assert.Equal((TicketStatus.EnProgreso, "En Progreso"), (ticket.Status, ticket.GithubProjectStatus));
        Assert.Equal("EnProgreso", Assert.Single(notifications.Sent).Data["status"]);

        // Un label estado:resuelto lo cambia por webhook; la columna no se movió, así que el job no lo pisa.
        ticket.Status = TicketStatus.Resuelto; await db.SaveChangesAsync();
        await job.SyncAsync(CancellationToken.None);
        Assert.Equal(TicketStatus.Resuelto, (await db.Tickets.SingleAsync()).Status);

        github.States[7] = new GitHubIssueState(false, "Publicado");
        await job.SyncAsync(CancellationToken.None);
        Assert.Equal(TicketStatus.Publicado, (await db.Tickets.SingleAsync()).Status);
        Assert.Equal(2, notifications.Sent.Count);
    }

    [Fact]
    public async Task Webhook_ignores_events_that_do_not_change_status()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        seed.Ticket.Status = TicketStatus.EnProgreso; await db.SaveChangesAsync(); // movido de columna; el issue aún tiene estado:abierto
        var processor = new GitHubWebhookProcessor(db, new FakeNotifications(), NullLogger<GitHubWebhookProcessor>.Instance);
        await processor.ProcessAsync("issues", TestData.IssueEvent("edited", 7, labels: ["estado:abierto"]), CancellationToken.None);
        var labeledBug = JsonSerializer.SerializeToElement(new { action = "labeled", label = new { name = "bug" }, issue = new { number = 7, state = "open", labels = new[] { new { name = "estado:abierto" }, new { name = "bug" } } }, repository = new { name = "cabalgatas-andinas-web", owner = new { login = "rtres" } } });
        await processor.ProcessAsync("issues", labeledBug, CancellationToken.None);
        Assert.Equal(TicketStatus.EnProgreso, (await db.Tickets.SingleAsync()).Status);
    }
}

public class TicketAttachmentTests
{
    [Fact]
    public async Task Attachments_are_uploaded_to_the_repo_once_and_linked_in_the_issue()
    {
        using var db = TestData.Db(out var seed);
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test");
        var portal = new PortalController(db, new FakeJobs(), new FakeNotifications(), new ConfigurationBuilder().Build(), NullLogger<PortalController>.Instance) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };
        static IFormFile File(string name, string type, int size) => new FormFile(new MemoryStream(new byte[size]), 0, size, "files", name) { Headers = new HeaderDictionary(), ContentType = type };
        var request = new CreateTicketRequest(seed.Project.Id, TicketType.Requerimiento, "Beneficios en el PDF", "Letras más pequeñas", null, "2 por fila", null, null, "Se ve como la imagen", null);

        Assert.IsType<BadRequestObjectResult>(await portal.CreateTicket(request, null, CancellationToken.None, [File("vacio.png", "image/png", 0)]));
        var created = Assert.IsType<CreatedResult>(await portal.CreateTicket(request, null, CancellationToken.None, [File("diseño final.png", "image/png", 10), File("log.txt", "text/plain", 5)]));
        var ticket = Assert.IsType<Ticket>(created.Value);

        var github = new FakeGitHub();
        var job = new GitHubIssueSyncJob(db, github, NullLogger<GitHubIssueSyncJob>.Instance);
        await job.CreateIssueAsync(ticket.Id, CancellationToken.None);
        await job.CreateIssueAsync(ticket.Id, CancellationToken.None); // reintento: no vuelve a subir
        Assert.Equal(2, github.Uploads.Count);
        Assert.All(github.Uploads, x => Assert.StartsWith($".rtres/attachments/{ticket.Code}/", x));
        Assert.EndsWith("-dise-o-final.png", github.Uploads[0]);
        Assert.Contains("![diseño final.png](https://github.com/", github.LastBody);
        Assert.Contains("- [log.txt](https://github.com/", github.LastBody);
    }
}

public class TicketFromProductTests
{
    [Fact]
    public async Task Ticket_can_come_from_a_product_only_if_the_product_allows_tickets()
    {
        using var db = TestData.Db(out var seed);
        var support = new Product { Name = "Soporte", AllowsTickets = true }; var hosting = new Product { Name = "Hosting" };
        var withTickets = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = support.Id };
        var withoutTickets = new ClientProduct { ClientId = seed.Client.Id, ProjectId = seed.Project.Id, ProductId = hosting.Id };
        db.AddRange(support, hosting, withTickets, withoutTickets); await db.SaveChangesAsync();
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test");
        var portal = new PortalController(db, new FakeJobs(), new FakeNotifications(), new ConfigurationBuilder().Build(), NullLogger<PortalController>.Instance) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };

        Assert.IsType<BadRequestObjectResult>(await portal.CreateTicket(new CreateTicketRequest(seed.Project.Id, TicketType.Bug, "Caído", "No carga", null, null, null, null, null, null, ClientProductId: withoutTickets.Id), null, CancellationToken.None));
        var created = Assert.IsType<CreatedResult>(await portal.CreateTicket(new CreateTicketRequest(seed.Project.Id, TicketType.Bug, "Caído", "No carga", null, null, null, null, null, null, ClientProductId: withTickets.Id), null, CancellationToken.None));
        Assert.Equal(withTickets.Id, Assert.IsType<Ticket>(created.Value).ClientProductId);
    }
}

public class GitHubWebhookProcessorTests
{
    [Fact]
    public async Task Status_change_updates_ticket_and_notifies()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        var notifications = new FakeNotifications();
        await Processor(db, notifications).ProcessAsync("issues", TestData.IssueEvent("labeled", 7, labels: ["estado:en-progreso"]), CancellationToken.None);
        Assert.Equal(TicketStatus.EnProgreso, (await db.Tickets.SingleAsync()).Status);
        var sent = Assert.Single(notifications.Sent);
        Assert.Equal(NotificationType.TicketStatusChanged, sent.Type);
        Assert.Equal("EnProgreso", sent.Data["status"]); Assert.Equal("RT-108", sent.Data["code"]); Assert.Equal(seed.Ticket.Id.ToString(), sent.Data["ticketId"]);

        // Mismo estado otra vez: no se notifica de nuevo.
        await Processor(db, notifications).ProcessAsync("issues", TestData.IssueEvent("edited", 7, labels: ["estado:en-progreso"]), CancellationToken.None);
        Assert.Single(notifications.Sent);

        // Cerrar el issue sin quitar los labels de trabajo en curso también cambia el estado y avisa.
        await Processor(db, notifications).ProcessAsync("issues", TestData.IssueEvent("closed", 7, state: "closed", labels: ["estado:abierto", "estado:en-progreso"]), CancellationToken.None);
        Assert.Equal(TicketStatus.Resuelto, (await db.Tickets.SingleAsync()).Status);
        Assert.Equal(2, notifications.Sent.Count);
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
        var notifications = new FakeNotifications();
        var processor = Processor(db, notifications);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 900, "Lo estamos revisando"), CancellationToken.None);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 900, "Lo estamos revisando"), CancellationToken.None);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 901, "ci", userType: "Bot"), CancellationToken.None);
        await processor.ProcessAsync("issue_comment", TestData.CommentEvent("created", 7, 902, "**Ana** (vía portal):\n\nHola\n\n" + GitHubLabels.PortalCommentMarker + Guid.NewGuid() + " -->"), CancellationToken.None);
        var comment = await db.TicketComments.SingleAsync();
        Assert.True(comment.FromGithub); Assert.Equal("dev", comment.GithubAuthorLogin);
        // Solo el comentario humano nuevo avisa al cliente (ni el duplicado, ni el bot, ni el eco del portal).
        var reply = Assert.Single(notifications.Sent);
        Assert.Equal(NotificationType.TicketReply, reply.Type); Assert.Equal("ticket-reply:900", reply.DedupeKey); Assert.Equal("dev", reply.Data["author"]);

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
        var controller = new PortalController(db, jobs, new FakeNotifications(), new ConfigurationBuilder().Build(), NullLogger<PortalController>.Instance) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };

        Assert.IsType<BadRequestObjectResult>(await controller.AddComment(seed.Ticket.Id, new CreateTicketCommentRequest("  "), CancellationToken.None));
        Assert.IsType<NotFoundResult>(await controller.AddComment(Guid.NewGuid(), new CreateTicketCommentRequest("Hola"), CancellationToken.None));

        var result = Assert.IsType<OkObjectResult>(await controller.AddComment(seed.Ticket.Id, new CreateTicketCommentRequest(" Hola "), CancellationToken.None));
        var dto = Assert.IsType<TicketCommentDto>(result.Value);
        Assert.Equal("Hola", dto.Body); Assert.Equal("Roberto Ramos", dto.AuthorName); Assert.False(dto.FromGithub);
        var job = Assert.Single(jobs.Created);
        Assert.Equal(nameof(GitHubIssueSyncJob.PostCommentAsync), job.Method.Name);
    }
}

public class AdminTicketEndpointTests
{
    [Fact]
    public async Task Updates_portal_ticket_notifies_client_and_rejects_github_ticket()
    {
        using var db = TestData.Db(out var seed);
        var jobs = new FakeJobs(); var notifications = new FakeNotifications();
        var controller = Admin(db, seed.User, jobs, notifications);
        TestData.RemoveRepos(db);

        var ok = Assert.IsType<OkObjectResult>(await controller.UpdateTicket(seed.Ticket.Id, new UpdateTicketStatusRequest(TicketStatus.EnProgreso), CancellationToken.None));
        Assert.Equal(TicketStatus.EnProgreso, (await db.Tickets.SingleAsync()).Status);
        var notification = Assert.Single(notifications.Sent); Assert.Equal(NotificationType.TicketStatusChanged, notification.Type); Assert.NotNull(notification.DedupeKey);

        db.ProjectRepositories.Add(new ProjectRepository { ProjectId = seed.Project.Id, Owner = "rtres", Name = "repo", IsDefault = true }); await db.SaveChangesAsync();
        var conflict = Assert.IsType<ConflictObjectResult>(await controller.UpdateTicket(seed.Ticket.Id, new UpdateTicketStatusRequest(TicketStatus.Resuelto), CancellationToken.None));
        Assert.Equal("El estado de este ticket se gestiona en GitHub", ((dynamic)conflict.Value!).message);
    }

    [Fact]
    public async Task Admin_comment_on_github_ticket_is_queued_and_client_cannot_use_admin_controller()
    {
        using var db = TestData.Db(out var seed, issueNumber: 7);
        var jobs = new FakeJobs(); var notifications = new FakeNotifications();
        var admin = Admin(db, seed.User, jobs, notifications);
        var result = Assert.IsType<OkObjectResult>(await admin.AddTicketComment(seed.Ticket.Id, new CreateTicketCommentRequest("Lo revisamos"), CancellationToken.None));
        var comment = Assert.IsType<TicketCommentDto>(result.Value); Assert.Equal("Lo revisamos", comment.Body); Assert.Equal("Rtres", comment.AuthorName);
        Assert.Equal(nameof(GitHubIssueSyncJob.PostCommentAsync), Assert.Single(jobs.Created).Method.Name);
        Assert.Equal(NotificationType.TicketReply, Assert.Single(notifications.Sent).Type);

        var authorization = Assert.Single(typeof(AdminController).GetCustomAttributes(typeof(AuthorizeAttribute), true).Cast<AuthorizeAttribute>());
        Assert.Equal(nameof(UserRole.SuperAdmin), authorization.Roles); // El pipeline devuelve 403 al cliente antes de ejecutar estos endpoints.
    }

    [Fact]
    public async Task New_ticket_without_repo_notifies_rtres()
    {
        using var db = TestData.Db(out var seed);
        TestData.RemoveRepos(db);
        var notifications = new FakeNotifications(); var jobs = new FakeJobs();
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Cliente")], "test");
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Notifications:StaffEmail"] = "equipo@rtres.net" }).Build();
        var portal = new PortalController(db, jobs, notifications, config, NullLogger<PortalController>.Instance) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };

        await portal.CreateTicket(new CreateTicketRequest(seed.Project.Id, TicketType.Bug, "Sin repo", "Necesito ayuda", null, null, null, null, null, null), null, CancellationToken.None);

        var notification = Assert.Single(notifications.Sent); Assert.Equal(NotificationType.TicketCreated, notification.Type); Assert.Equal("equipo@rtres.net", notification.To); Assert.NotNull(notification.DedupeKey);
    }

    private static AdminController Admin(RtresDbContext db, UserAccount user, IBackgroundJobClient jobs, INotificationSender notifications)
    {
        user.Role = UserRole.SuperAdmin; db.SaveChanges();
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()), new Claim(ClaimTypes.Role, nameof(UserRole.SuperAdmin))], "test");
        return new AdminController(db, null!, null!, null!, null!, jobs, notifications) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } } };
    }
}

public class SqlServerTranslationTests
{
    // La base en memoria de los demás tests acepta consultas que SQL Server no puede traducir; esto valida la traducción real.
    [Fact]
    public void Comment_queries_translate_to_sql_server()
    {
        using var db = new RtresDbContext(new DbContextOptionsBuilder<RtresDbContext>().UseSqlServer("Server=none;Database=x;User Id=a;Password=b").Options);
        var id = Guid.NewGuid();
        Assert.Contains("SELECT", PortalController.ToCommentDtos(db, db.TicketComments.Where(x => x.TicketId == id).OrderBy(x => x.CreatedAt)).ToQueryString());
        Assert.Contains("SELECT", PortalController.ToCommentDtos(db, db.TicketComments.Where(x => x.Id == id)).ToQueryString());
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
        db.Database.EnsureCreated(); // siembra las categorías de gasto de sistema (HasData)
        var client = new Client { CompanyName = "Cabalgatas Andinas", Email = "c@example.com" };
        var project = new Project { ClientId = client.Id, Name = "Web", Slug = "cabalgatas-andinas-web" };
        var repository = new ProjectRepository { ProjectId = project.Id, Owner = "rtres", Name = "cabalgatas-andinas-web", IsDefault = true };
        project.Repositories.Add(repository);
        var user = new UserAccount { ClientId = client.Id, Email = "roberto@example.com", Name = "Roberto Ramos" };
        var ticket = new Ticket { Code = "RT-108", ClientId = client.Id, ProjectId = project.Id, Title = "Botón", Description = "No responde", GithubIssueNumber = issueNumber, RepositoryId = issueNumber is null ? null : repository.Id };
        db.AddRange(client, project, user, ticket); db.SaveChanges();
        seed = new Seed(client, project, ticket, user);
        return db;
    }

    public static void RemoveRepos(RtresDbContext db) { db.ProjectRepositories.RemoveRange(db.ProjectRepositories); db.SaveChanges(); }

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
    public List<string> Repos { get; } = [];
    public Task<long> CreateCommentAsync(ProjectRepository repository, int issueNumber, string body, CancellationToken cancellationToken = default)
    {
        Comments.Add((issueNumber, body));
        return Task.FromResult(5000L);
    }
    public Dictionary<int, GitHubIssueState> States { get; } = [];
    public Task<IReadOnlyDictionary<int, GitHubIssueState>> GetIssueStatesAsync(ProjectRepository repository, IReadOnlyCollection<int> issueNumbers, CancellationToken cancellationToken = default)
        => Task.FromResult<IReadOnlyDictionary<int, GitHubIssueState>>(States.Where(x => issueNumbers.Contains(x.Key)).ToDictionary());
    public List<string> Uploads { get; } = [];
    public string? LastBody { get; private set; }
    public Task<string> UploadFileAsync(ProjectRepository repository, string path, byte[] content, string message, CancellationToken cancellationToken = default)
    {
        Uploads.Add(path);
        return Task.FromResult($"https://github.com/{repository.Owner}/{repository.Name}/blob/main/{path}?raw=true");
    }
    public Task<GitHubIssue> CreateIssueAsync(Project project, ProjectRepository repository, Ticket ticket, IReadOnlyList<TicketAttachment> attachments, CancellationToken cancellationToken = default)
    {
        Calls++; Repos.Add($"{repository.Owner}/{repository.Name}"); LastBody = GitHubIssuesClient.BuildBody(ticket, attachments);
        return Task.FromResult(new GitHubIssue(42, $"https://github.com/{repository.Owner}/{repository.Name}/issues/42"));
    }
}

internal sealed class FakeNotifications : INotificationSender
{
    public List<Notification> Sent { get; } = [];
    public Task SendAsync(Client client, Notification notification, CancellationToken cancellationToken = default) { Sent.Add(notification); return Task.CompletedTask; }
}
