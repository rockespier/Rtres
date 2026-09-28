using System.Reflection;
using ClosedXML.Excel;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class ClientOnboardingTests
{
    [Fact]
    public async Task New_client_gets_an_admin_user_that_can_log_in()
    {
        using var db = TestData.Db(out _);
        var result = Assert.IsType<CreatedResult>(await Admin(db).CreateClient(new ClientRequest("Andes Tours", "Ana Quispe", "ana@andes.pe", null, "es"), CancellationToken.None));
        var access = Prop<ClientAccess>(result.Value!, "access");
        Assert.Equal(("Andes Tours", "ana@andes.pe"), (access.ClientName, access.Email));

        var user = await db.UserAccounts.SingleAsync(x => x.Email == "ana@andes.pe");
        Assert.Equal((UserRole.Admin, "Ana Quispe"), (user.Role, user.Name));
        Assert.IsType<OkObjectResult>(await Login(db, "ana@andes.pe", access.TemporaryPassword));
    }

    [Fact]
    public async Task Client_email_already_used_by_a_user_is_rejected()
    {
        using var db = TestData.Db(out var seed); // roberto@example.com ya es usuario
        Assert.IsType<ConflictObjectResult>(await Admin(db).CreateClient(new ClientRequest("Otra", "X", seed.User.Email, null, "es"), CancellationToken.None));
        Assert.Single(db.Clients);
    }

    [Fact]
    public async Task Generate_access_creates_the_missing_user_or_resets_the_password()
    {
        using var db = TestData.Db(out var seed);
        var legacy = new Client { CompanyName = "Legacy", ContactName = "Luis", Email = "luis@legacy.pe" }; // creado antes de esta versión, sin usuario
        db.Clients.Add(legacy); db.SaveChanges();
        var admin = Admin(db);

        var first = Assert.IsType<OkObjectResult>(await admin.ClientAccess(legacy.Id, CancellationToken.None)).Value as ClientAccess;
        Assert.IsType<OkObjectResult>(await Login(db, "luis@legacy.pe", first!.TemporaryPassword));

        var second = Assert.IsType<OkObjectResult>(await admin.ClientAccess(legacy.Id, CancellationToken.None)).Value as ClientAccess;
        Assert.Single(db.UserAccounts.Where(x => x.Email == "luis@legacy.pe"));
        Assert.IsType<UnauthorizedObjectResult>(await Login(db, "luis@legacy.pe", first.TemporaryPassword)); // la anterior deja de servir
        Assert.IsType<OkObjectResult>(await Login(db, "luis@legacy.pe", second!.TemporaryPassword));
    }

    [Fact]
    public async Task Import_creates_users_and_returns_their_accesses()
    {
        using var db = TestData.Db(out var seed);
        using var book = new XLWorkbook();
        var sheet = book.AddWorksheet("Plantilla");
        string[][] rows = [["CompanyName", "ContactName", "Email", "Phone", "PreferredLanguage"], ["Uno", "Ana", "ana@uno.pe", "", "es"], ["Dos", "Bea", seed.User.Email, "", "es"], ["Tres", "Caro", "caro@tres.it", "", "it"]];
        for (var r = 0; r < rows.Length; r++) for (var c = 0; c < rows[r].Length; c++) sheet.Cell(r + 1, c + 1).Value = rows[r][c];
        using var stream = new MemoryStream(); book.SaveAs(stream); stream.Position = 0;

        var ok = Assert.IsType<OkObjectResult>(await Admin(db).ImportClients(new FormFile(stream, 0, stream.Length, "file", "clientes.xlsx"), CancellationToken.None));
        Assert.Equal(2, Prop<int>(ok.Value!, "created"));
        Assert.Equal(["ana@uno.pe", "caro@tres.it"], Prop<List<ClientAccess>>(ok.Value!, "accesses").Select(x => x.Email));
        Assert.Equal(2, await db.UserAccounts.CountAsync(x => x.Email == "ana@uno.pe" || x.Email == "caro@tres.it"));
    }

    [Fact]
    public async Task Projects_are_created_with_a_unique_slug_and_their_repo_can_be_edited()
    {
        using var db = TestData.Db(out var seed);
        var admin = Admin(db);
        var created = Assert.IsType<CreatedResult>(await admin.CreateProject(seed.Client.Id, new ProjectRequest("Tienda Ñandú Online", null, "rockespier", "tienda"), CancellationToken.None));
        var project = await db.Projects.SingleAsync(x => x.Name == "Tienda Ñandú Online");
        Assert.Equal(("tienda-nandu-online", "rockespier", "tienda"), (project.Slug, project.GithubRepoOwner, project.GithubRepoName));
        Assert.IsType<ConflictObjectResult>(await admin.CreateProject(seed.Client.Id, new ProjectRequest("Tienda ñandú online", null, null, null), CancellationToken.None));
        Assert.IsType<NotFoundResult>(await admin.CreateProject(Guid.NewGuid(), new ProjectRequest("X", null, null, null), CancellationToken.None));

        Assert.IsType<OkObjectResult>(await admin.UpdateProject(project.Id, new ProjectRequest(null, null, "rtres-web", "tienda-v2"), CancellationToken.None));
        Assert.Equal(("rtres-web", "tienda-v2"), (project.GithubRepoOwner, project.GithubRepoName));
    }

    private static AdminController Admin(RtresDbContext db) => new(db, null!, null!);

    private static Task<ActionResult> Login(RtresDbContext db, string email, string password) =>
        new AuthController(db, new ConfigurationBuilder().Build()).Login(new LoginRequest(email, password), CancellationToken.None);

    private static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name, BindingFlags.Public | BindingFlags.Instance)!.GetValue(value)!;
}
