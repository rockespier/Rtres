using System.Reflection;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;

namespace Rtres.Api.Tests;

/// <summary>Perfiles del equipo del cliente: el Admin ve todo; el miembro (rol Cliente), solo tickets y su cuenta.</summary>
public class ClientRolesTests
{
    public static TheoryData<Type, string> BillingEndpoints => new()
    {
        { typeof(PortalController), nameof(PortalController.Summary) },
        { typeof(PortalController), nameof(PortalController.Products) },
        { typeof(AccountController), nameof(AccountController.Transactions) },
        { typeof(PaymentsController), nameof(PaymentsController.Catalog) },
        { typeof(PaymentsController), "Subscribe" },
        { typeof(PaymentsController), "Renew" },
        { typeof(PaymentsController), "Cancel" },
        { typeof(PaymentsController), "Capture" },
        { typeof(PaymentsController), "BankTransfer" },
        { typeof(PaymentsController), "ClientProduct" },
        { typeof(BankTransfersController), nameof(BankTransfersController.EnabledPaymentMethods) },
        { typeof(BankTransfersController), "Report" },
        { typeof(BankTransfersController), nameof(BankTransfersController.Receipt) },
    };

    [Theory, MemberData(nameof(BillingEndpoints))]
    public void Team_members_cannot_call_billing_endpoints(Type controller, string action)
    {
        var method = controller.GetMethod(action, BindingFlags.Public | BindingFlags.Instance) ?? throw new InvalidOperationException($"{controller.Name}.{action} no existe");
        var roles = method.GetCustomAttributes<AuthorizeAttribute>().Select(a => a.Roles).OfType<string>().ToList();
        Assert.NotEmpty(roles);
        Assert.All(roles, r => Assert.DoesNotContain("Cliente", r.Split(',')));
        Assert.Contains(roles, r => r.Split(',').Contains("Admin"));
    }

    [Fact]
    public async Task Team_members_only_see_ticket_notifications()
    {
        using var db = TestData.Db(out var seed);
        db.PortalNotifications.AddRange(
            new PortalNotification { ClientId = seed.Client.Id, Type = nameof(NotificationType.TicketReply) },
            new PortalNotification { ClientId = seed.Client.Id, Type = nameof(NotificationType.PaymentReceived) },
            new PortalNotification { ClientId = seed.Client.Id, Type = nameof(NotificationType.RenewalReminder) });
        db.SaveChanges();

        Assert.Equal([nameof(NotificationType.TicketReply)], await Types(Portal(db, seed, "Cliente")));
        Assert.Equal(3, (await Types(Portal(db, seed, "Admin"))).Count);
    }

    private static PortalController Portal(Rtres.Infrastructure.Persistence.RtresDbContext db, Seed seed, string role)
    {
        var config = new ConfigurationBuilder().Build();
        var identity = new ClaimsIdentity([new Claim(ClaimTypes.NameIdentifier, seed.User.Id.ToString()), new Claim("client_id", seed.Client.Id.ToString()), new Claim(ClaimTypes.Role, role)], "test");
        return new PortalController(db, new FakeJobs(), new FakeNotifications(), config, NullLogger<PortalController>.Instance, new BankTransferService(db, config))
        {
            ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext { User = new ClaimsPrincipal(identity) } },
        };
    }

    private static async Task<List<string>> Types(PortalController portal)
    {
        var ok = Assert.IsType<OkObjectResult>(await portal.Notifications(null, CancellationToken.None));
        using var json = JsonDocument.Parse(JsonSerializer.Serialize(ok.Value));
        return json.RootElement.GetProperty("items").EnumerateArray().Select(x => x.GetProperty("type").GetString()!).ToList();
    }
}
