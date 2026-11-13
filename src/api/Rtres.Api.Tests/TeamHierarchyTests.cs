using System.Reflection;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Notifications;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

/// <summary>Área, cargo y jefe inmediato de los usuarios del portal, y el aviso al jefe cuando su equipo registra un ticket.</summary>
public class TeamHierarchyTests
{
    [Fact]
    public async Task Admin_saves_area_job_title_and_manager_and_can_clear_them()
    {
        using var db = TestData.Db(out var seed);
        var manager = AddUser(db, seed.Client.Id, "jefa@cabalgatas.pe", "Lucía");
        var analyst = AddUser(db, seed.Client.Id, "ana@cabalgatas.pe", "Ana");
        var controller = Team(db, seed);

        Assert.IsType<OkResult>(await controller.UpdateTeam(analyst.Id, new UpdateTeamRequest(null, null, "  Ventas ", "Analista", manager.Id), CancellationToken.None));
        var row = await Row(controller, analyst.Id);
        Assert.Equal("Ventas", Prop<string?>(row, "area")); Assert.Equal("Analista", Prop<string?>(row, "jobTitle")); Assert.Equal(manager.Id, Prop<Guid?>(row, "managerId"));

        Assert.IsType<OkResult>(await controller.UpdateTeam(analyst.Id, new UpdateTeamRequest(null, null, "", null, Guid.Empty), CancellationToken.None));
        row = await Row(controller, analyst.Id);
        Assert.Null(Prop<string?>(row, "area")); Assert.Equal("Analista", Prop<string?>(row, "jobTitle")); Assert.Null(Prop<Guid?>(row, "managerId"));
    }

    [Fact]
    public async Task Area_longer_than_100_characters_is_rejected()
    {
        using var db = TestData.Db(out var seed);
        var analyst = AddUser(db, seed.Client.Id, "ana@cabalgatas.pe", "Ana");

        Assert.IsType<BadRequestObjectResult>(await Team(db, seed).UpdateTeam(analyst.Id, new UpdateTeamRequest(null, null, new string('a', 101), null, null), CancellationToken.None));
        Assert.Null((await db.UserAccounts.AsNoTracking().SingleAsync(x => x.Id == analyst.Id)).Area);
    }

    public static TheoryData<string> InvalidManagers() => ["other-client", "self", "inactive", "cycle"];

    [Theory, MemberData(nameof(InvalidManagers))]
    public async Task Invalid_manager_is_rejected_and_nothing_is_saved(string kind)
    {
        using var db = TestData.Db(out var seed);
        var current = AddUser(db, seed.Client.Id, "jefa@cabalgatas.pe", "Lucía");
        var analyst = AddUser(db, seed.Client.Id, "ana@cabalgatas.pe", "Ana", managerId: current.Id);
        var other = new Client { CompanyName = "Otra", Email = "otra@example.com" }; db.Clients.Add(other); db.SaveChanges();
        var managerId = kind switch
        {
            "other-client" => AddUser(db, other.Id, "x@otra.pe", "Externo").Id,
            "self" => analyst.Id,
            "inactive" => AddUser(db, seed.Client.Id, "baja@cabalgatas.pe", "Baja", active: false).Id,
            _ => AddUser(db, seed.Client.Id, "pedro@cabalgatas.pe", "Pedro", managerId: analyst.Id).Id, // Pedro → Ana: Ana → Pedro cerraría el ciclo
        };

        var result = await Team(db, seed).UpdateTeam(analyst.Id, new UpdateTeamRequest(null, null, "Ventas", null, managerId), CancellationToken.None);

        Assert.IsType<BadRequestObjectResult>(result);
        var saved = await db.UserAccounts.AsNoTracking().SingleAsync(x => x.Id == analyst.Id);
        Assert.Equal(current.Id, saved.ManagerId); Assert.Null(saved.Area);
    }

    [Theory]
    [InlineData(true)]
    [InlineData(false)]
    public async Task Ticket_notifies_the_creators_active_manager_once(bool withRepositories)
    {
        using var db = TestData.Db(out var seed);
        if (!withRepositories) TestData.RemoveRepos(db);
        var manager = AddUser(db, seed.Client.Id, "jefa@cabalgatas.pe", "Lucía");
        SetManager(db, seed.User, manager.Id, "Ventas");
        var notifications = new FakeNotifications();

        var ticketId = await CreateTicket(db, seed, notifications);

        var sent = Assert.Single(notifications.Sent, x => x.Type == NotificationType.TicketCreatedForManager);
        Assert.Equal("jefa@cabalgatas.pe", sent.To); Assert.Equal($"ticket-manager:{ticketId}", sent.DedupeKey);
        Assert.Equal("Roberto Ramos", sent.Data["creator"]); Assert.Equal("Ventas", sent.Data["area"]);
        Assert.Equal(withRepositories ? 0 : 1, notifications.Sent.Count(x => x.Type == NotificationType.TicketCreated));
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task Ticket_without_an_active_manager_sends_no_manager_notification(bool inactiveManager)
    {
        using var db = TestData.Db(out var seed);
        if (inactiveManager) SetManager(db, seed.User, AddUser(db, seed.Client.Id, "baja@cabalgatas.pe", "Baja", active: false).Id, null);
        var notifications = new FakeNotifications();

        await CreateTicket(db, seed, notifications);

        Assert.DoesNotContain(notifications.Sent, x => x.Type == NotificationType.TicketCreatedForManager);
    }

    [Theory]
    [InlineData("es")]
    [InlineData("en")]
    [InlineData("it")]
    public void Manager_email_names_ticket_project_creator_and_area(string lang)
    {
        var sample = EmailTemplatesTests.Sample(NotificationType.TicketCreatedForManager);
        var (subject, html, text) = EmailTemplates.Render(sample, lang, "https://portal.rtres.net");

        Assert.Contains("Ana Pérez", subject); Assert.Contains("RT-108", subject);
        foreach (var value in new[] { "RT-108", "Botón", "Web", "Ana Pérez", "(Ventas)" }) Assert.Contains(value, text);
        Assert.Contains("https://portal.rtres.net/tickets/t-1", html);
        Assert.Contains("https://portal.rtres.net/tickets/t-1", text);

        sample.Data.Remove("area");
        var withoutArea = EmailTemplates.Render(sample, lang, "https://portal.rtres.net").Text;
        Assert.DoesNotContain("Ventas", withoutArea); Assert.DoesNotContain("()", withoutArea);
    }

    [Fact]
    public async Task Manager_email_creates_no_bell_entry()
    {
        using var db = TestData.Db(out var seed);
        var email = new FakeEmail();
        var notification = EmailTemplatesTests.Sample(NotificationType.TicketCreatedForManager) with { DedupeKey = "ticket-manager:t-1", To = "jefa@cabalgatas.pe" };

        await NotificationJobTests.Job(db, email).SendAsync(seed.Client.Id, notification, CancellationToken.None);

        Assert.Equal("jefa@cabalgatas.pe", Assert.Single(email.Sent).To);
        Assert.Empty(db.PortalNotifications);
    }

    private static UserAccount AddUser(RtresDbContext db, Guid clientId, string email, string name, bool active = true, Guid? managerId = null)
    {
        var user = new UserAccount { ClientId = clientId, Email = email, Name = name, IsActive = active, ManagerId = managerId };
        db.UserAccounts.Add(user); db.SaveChanges();
        return user;
    }

    private static void SetManager(RtresDbContext db, UserAccount user, Guid managerId, string? area) { user.ManagerId = managerId; user.Area = area; db.SaveChanges(); }

    private static ClaimsPrincipal Principal(Seed seed, string role) =>
        new(new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, role)], "test"));

    private static AccountController Team(RtresDbContext db, Seed seed) =>
        new(db, ClientOnboardingTests.AccessEmail(db, new FakeEmail())) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = Principal(seed, "Admin") } } };

    private static async Task<object> Row(AccountController controller, Guid userId)
    {
        var rows = Assert.IsAssignableFrom<System.Collections.IEnumerable>(Assert.IsType<OkObjectResult>(await controller.Team(CancellationToken.None)).Value).Cast<object>();
        return rows.Single(x => Prop<Guid>(x, "id") == userId);
    }

    private static async Task<Guid> CreateTicket(RtresDbContext db, Seed seed, FakeNotifications notifications)
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Notifications:StaffEmail"] = "equipo@rtres.net" }).Build();
        var portal = new PortalController(db, new FakeJobs(), notifications, config, NullLogger<PortalController>.Instance, new BankTransferService(db, new ConfigurationBuilder().Build())) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = Principal(seed, "Cliente") } } };
        var result = Assert.IsType<CreatedResult>(await portal.CreateTicket(new CreateTicketRequest(seed.Project.Id, TicketType.Bug, "Botón roto", "No responde", null, null, null, null, null, null), null, CancellationToken.None));
        return Assert.IsType<Ticket>(result.Value).Id;
    }

    private static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name, BindingFlags.Public | BindingFlags.Instance)!.GetValue(value)!;
}
