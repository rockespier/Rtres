using System.Reflection;
using ClosedXML.Excel;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Notifications;
using Rtres.Api.Services;
using System.Security.Claims;
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
        string[][] rows = [["CompanyName", "ContactName", "Email", "Phone", "PreferredLanguage", "RequiresTaxDocument"], ["Uno", "Ana", "ana@uno.pe", "", "es", "SI"], ["Dos", "Bea", seed.User.Email, "", "es", ""], ["Tres", "Caro", "caro@tres.it", "", "it", ""], ["Cuatro", "Dani", "dani@cuatro.pe", "", "es", "quizás"]];
        for (var r = 0; r < rows.Length; r++) for (var c = 0; c < rows[r].Length; c++) sheet.Cell(r + 1, c + 1).Value = rows[r][c];
        using var stream = new MemoryStream(); book.SaveAs(stream); stream.Position = 0;

        var ok = Assert.IsType<OkObjectResult>(await Admin(db).ImportClients(new FormFile(stream, 0, stream.Length, "file", "clientes.xlsx"), CancellationToken.None));
        Assert.Equal(2, Prop<int>(ok.Value!, "created"));
        Assert.Equal(["ana@uno.pe", "caro@tres.it"], Prop<List<ClientAccess>>(ok.Value!, "accesses").Select(x => x.Email));
        Assert.Equal(2, await db.UserAccounts.CountAsync(x => x.Email == "ana@uno.pe" || x.Email == "caro@tres.it"));
        // Solo el cliente peruano marcado emite comprobante; un valor que no es SI/NO rechaza la fila.
        Assert.Equal(["Uno"], await db.Clients.Where(x => x.RequiresTaxDocument).Select(x => x.CompanyName).ToListAsync());
        Assert.False(await db.Clients.AnyAsync(x => x.CompanyName == "Cuatro"));
    }

    [Fact]
    public async Task Projects_are_created_with_a_unique_slug_and_can_have_several_repos()
    {
        using var db = TestData.Db(out var seed);
        var admin = Admin(db);
        var created = Assert.IsType<CreatedResult>(await admin.CreateProject(seed.Client.Id, new ProjectRequest("Tienda Ñandú Online", null, "rockespier", "tienda"), CancellationToken.None));
        var project = await db.Projects.Include(x => x.Repositories).SingleAsync(x => x.Name == "Tienda Ñandú Online");
        var main = Assert.Single(project.Repositories);
        Assert.Equal(("tienda-nandu-online", "rockespier", "tienda", true), (project.Slug, main.Owner, main.Name, main.IsDefault));
        Assert.IsType<ConflictObjectResult>(await admin.CreateProject(seed.Client.Id, new ProjectRequest("Tienda ñandú online", null, null, null), CancellationToken.None));
        Assert.IsType<NotFoundResult>(await admin.CreateProject(Guid.NewGuid(), new ProjectRequest("X", null, null, null), CancellationToken.None));

        Assert.IsType<OkObjectResult>(await admin.AddRepository(project.Id, new RepositoryRequest("rockespier", "tienda-api", "API", IsDefault: true), CancellationToken.None));
        Assert.IsType<ConflictObjectResult>(await admin.AddRepository(project.Id, new RepositoryRequest("rockespier", "tienda"), CancellationToken.None)); // un repo, un proyecto
        var api = await db.ProjectRepositories.SingleAsync(x => x.Name == "tienda-api");
        Assert.Equal(("API", true, false), (api.Label, api.IsDefault, main.IsDefault)); // solo un principal

        Assert.IsType<OkObjectResult>(await admin.UpdateRepository(main.Id, new RepositoryRequest(null, "tienda-v2", "Web", IsDefault: true), CancellationToken.None));
        Assert.Equal(("tienda-v2", "Web", true, false), (main.Name, main.Label, main.IsDefault, api.IsDefault));

        db.Tickets.Add(new Ticket { Code = "RT-900", ClientId = seed.Client.Id, ProjectId = project.Id, RepositoryId = api.Id, GithubIssueNumber = 3 }); await db.SaveChangesAsync();
        Assert.IsType<ConflictObjectResult>(await admin.UpdateRepository(api.Id, new RepositoryRequest(null, "otro"), CancellationToken.None)); // ya tiene issues
        Assert.IsType<ConflictObjectResult>(await admin.DeleteRepository(api.Id, CancellationToken.None));
        Assert.IsType<OkObjectResult>(await admin.DeleteRepository(main.Id, CancellationToken.None));
        Assert.True((await db.ProjectRepositories.SingleAsync(x => x.ProjectId == project.Id)).IsDefault); // el que queda pasa a ser el principal
    }

    [Fact]
    public async Task Projects_are_deleted_only_without_products_or_tickets()
    {
        using var db = TestData.Db(out var seed);
        var admin = Admin(db);
        await admin.CreateProject(seed.Client.Id, new ProjectRequest("Landing", null, "rockespier", "landing"), CancellationToken.None);
        var project = await db.Projects.SingleAsync(x => x.Name == "Landing");
        var ticket = new Ticket { Code = "RT-901", ClientId = seed.Client.Id, ProjectId = project.Id };
        db.Tickets.Add(ticket); await db.SaveChangesAsync();

        Assert.IsType<ConflictObjectResult>(await admin.DeleteProject(project.Id, CancellationToken.None));
        db.Tickets.Remove(ticket); await db.SaveChangesAsync();
        Assert.IsType<NoContentResult>(await admin.DeleteProject(project.Id, CancellationToken.None));
        Assert.False(await db.Projects.AnyAsync(x => x.Id == project.Id));
        Assert.False(await db.ProjectRepositories.AnyAsync(x => x.Name == "landing"));
        Assert.IsType<NotFoundResult>(await admin.DeleteProject(project.Id, CancellationToken.None));
    }

    [Fact]
    public async Task New_client_receives_the_access_by_email_in_its_language()
    {
        using var db = TestData.Db(out _);
        var email = new FakeEmail();
        var result = Assert.IsType<CreatedResult>(await Admin(db, email).CreateClient(new ClientRequest("Andes Tours", "Ana Quispe", "ana@andes.pe", null, "it"), CancellationToken.None));
        var access = Prop<ClientAccess>(result.Value!, "access");

        Assert.True(access.EmailSent);
        var message = Assert.Single(email.Sent);
        Assert.Equal("ana@andes.pe", message.To);
        Assert.Equal("Il tuo accesso al portale clienti di Rtres (Andes Tours)", message.Subject);
        Assert.Contains(access.TemporaryPassword, message.Text);
        Assert.Contains("/login", message.Html);
        var log = await db.NotificationLogs.SingleAsync();
        Assert.Equal(("AccountAccess", "ana@andes.pe", true), (log.Type, log.Recipient, log.Success));
    }

    [Fact]
    public async Task If_the_email_fails_the_access_is_still_created_and_flagged_as_not_sent()
    {
        using var db = TestData.Db(out _);
        var result = Assert.IsType<CreatedResult>(await Admin(db, new FakeEmail { Fail = true }).CreateClient(new ClientRequest("Andes Tours", "Ana", "ana@andes.pe", null, "es"), CancellationToken.None));
        var access = Prop<ClientAccess>(result.Value!, "access");
        Assert.False(access.EmailSent);
        Assert.IsType<OkObjectResult>(await Login(db, "ana@andes.pe", access.TemporaryPassword));
    }

    [Fact]
    public async Task Team_invitation_is_emailed_to_the_invited_person_not_to_the_client_contact()
    {
        using var db = TestData.Db(out var seed);
        var email = new FakeEmail();
        var controller = new AccountController(db, AccessEmail(db, email))
        {
            ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, "Admin")], "test")) } },
        };
        var result = Assert.IsType<CreatedResult>(await controller.Invite(new InviteRequest("Pedro", "pedro@cabalgatas.pe"), CancellationToken.None));

        Assert.True(Prop<bool>(result.Value!, "emailSent"));
        var message = Assert.Single(email.Sent);
        Assert.Equal("pedro@cabalgatas.pe", message.To);
        Assert.Contains(Prop<string>(result.Value!, "temporaryPassword"), message.Text);
        Assert.Contains("Hola Pedro", message.Text);
    }

    [Fact]
    public async Task Admin_sets_the_dates_of_a_manual_product_and_its_status_follows()
    {
        using var db = TestData.Db(out var seed);
        var product = new Product { Name = "Hosting", Type = ProductType.Hosting, BillingCycle = BillingCycle.Anual, BasePrice = 120 };
        db.Products.Add(product); db.SaveChanges();
        var admin = Admin(db);
        var soon = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(10));

        var created = Assert.IsType<CreatedResult>(await admin.AssignProduct(seed.Client.Id, new AssignProductRequest(product.Id, seed.Project.Id, BillingCycle.Anual, "Manual", null, null, null, soon), CancellationToken.None));
        var item = await db.ClientProducts.SingleAsync(x => x.ProductId == product.Id);
        Assert.Equal((new DateTime(soon, new TimeOnly(12, 0), DateTimeKind.Utc), ClientProductStatus.PorVencer), (item.RenewsAt!.Value, item.Status));

        var past = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-2));
        Assert.IsType<OkObjectResult>(await admin.UpdateClientProductDates(item.Id, new ClientProductDatesRequest(past, null), CancellationToken.None));
        Assert.Equal(ClientProductStatus.Vencido, item.Status);

        var renewed = DateOnly.FromDateTime(DateTime.UtcNow.AddYears(1));
        Assert.IsType<OkObjectResult>(await admin.UpdateClientProductDates(item.Id, new ClientProductDatesRequest(renewed, null), CancellationToken.None));
        Assert.Equal(ClientProductStatus.Activo, item.Status);
        Assert.IsType<NotFoundResult>(await admin.UpdateClientProductDates(Guid.NewGuid(), new ClientProductDatesRequest(null, null), CancellationToken.None));
    }

    private static AdminController Admin(RtresDbContext db, FakeEmail? email = null) =>
        new(db, null!, null!, AccessEmail(db, email ?? new FakeEmail()), PayPalPaymentTests.TaxDocuments(db), null!, new FakeNotifications()) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };

    internal static AccessEmailService AccessEmail(RtresDbContext db, IEmailSender email) =>
        new(NotificationJobTests.Job(db, email), new ConfigurationBuilder().Build(), NullLogger<AccessEmailService>.Instance);

    private static Task<ActionResult> Login(RtresDbContext db, string email, string password, IMemoryCache? cache = null) =>
        new AuthController(db, TestJwt, cache ?? new MemoryCache(new MemoryCacheOptions())).Login(new LoginRequest(email, password), CancellationToken.None);

    internal static readonly JwtSettings TestJwt = JwtSettings.FromConfiguration(
        new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Jwt:Key"] = new string('k', 48) }).Build());

    private static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name, BindingFlags.Public | BindingFlags.Instance)!.GetValue(value)!;
}
