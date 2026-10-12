using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;
using Rtres.Domain;

namespace Rtres.Api.Tests;

public class ContactTests
{
    [Fact]
    public async Task Valid_contact_is_saved_and_staff_is_notified_in_background()
    {
        using var db = TestData.Db(out _);
        var jobs = new FakeJobs();
        var result = await Controller(db, jobs).Submit(new ContactRequest(" Ana Pérez ", "ana@empresa.pe", "+51 999 111 222", "Empresa SAC", "software-a-medida", "Necesitamos un sistema de ventas con comisiones.", "es", "/es/servicios/software-a-medida"), CancellationToken.None);

        Assert.IsType<AcceptedResult>(result);
        var lead = await db.ContactLeads.SingleAsync();
        Assert.Equal(("Ana Pérez", "software-a-medida", "/es/servicios/software-a-medida", ContactLeadStatus.Nuevo), (lead.Name, lead.Service, lead.SourcePage, lead.Status));
        Assert.Single(jobs.Created); // el email al equipo va por Hangfire: un SMTP lento no frena el formulario
    }

    [Fact]
    public async Task Honeypot_is_accepted_silently_without_saving()
    {
        using var db = TestData.Db(out _);
        var jobs = new FakeJobs();
        Assert.IsType<AcceptedResult>(await Controller(db, jobs).Submit(new ContactRequest("Bot", "bot@spam.com", null, null, null, "Compre seguidores baratos ahora mismo", "es", null, Website: "http://spam.example"), CancellationToken.None));
        Assert.False(await db.ContactLeads.AnyAsync());
        Assert.Empty(jobs.Created);
    }

    [Theory]
    [InlineData("", "ana@empresa.pe", "Mensaje suficientemente largo", "name")]
    [InlineData("Ana", "no-es-un-email", "Mensaje suficientemente largo", "email")]
    [InlineData("Ana", "ana@empresa.pe", "Hola", "message")]
    public async Task Invalid_contact_is_rejected(string name, string email, string message, string field)
    {
        using var db = TestData.Db(out _);
        var bad = Assert.IsType<BadRequestObjectResult>(await Controller(db, new FakeJobs()).Submit(new ContactRequest(name, email, null, null, null, message, "it", null), CancellationToken.None));
        Assert.Equal(field, bad.Value!.GetType().GetProperty("field")!.GetValue(bad.Value));
    }

    [Fact]
    public void Lead_email_lists_who_and_what_for_the_team()
    {
        var (subject, _, text) = Rtres.Infrastructure.Notifications.EmailTemplates.Render(new Notification(NotificationType.ContactLead, new() { ["name"] = "Ana", ["email"] = "ana@empresa.pe", ["company"] = "Empresa SAC", ["service"] = "apis", ["message"] = "Hola, quiero la API de RUC", ["locale"] = "es", ["page"] = "/es/" }), "en", "https://portal.rtres.net");
        Assert.Equal("Nuevo contacto desde la web: Ana (Empresa SAC)", subject); // siempre en español: es para el equipo
        Assert.Contains("ana@empresa.pe", text);
        Assert.Contains("https://portal.rtres.net/admin/leads", text);
    }

    private static ContactController Controller(Rtres.Infrastructure.Persistence.RtresDbContext db, FakeJobs jobs) =>
        new(db, jobs) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } };
}
