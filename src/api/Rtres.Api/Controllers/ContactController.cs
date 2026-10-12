using System.Net.Mail;
using Hangfire;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Notifications;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>
/// Formulario de contacto del sitio público: guarda el lead y avisa al equipo (email y campana) en segundo plano. Contra
/// bots: límite de envíos por IP y un campo trampa (<see cref="ContactRequest.Website"/>) que una persona no ve.
/// </summary>
[ApiController]
public sealed class ContactController(RtresDbContext db, IBackgroundJobClient jobs) : ControllerBase
{
    public const string RateLimitPolicy = "contact";
    public static readonly string[] Locales = ["es", "en", "it"];

    [HttpPost("api/public/contact"), EnableRateLimiting(RateLimitPolicy)]
    public async Task<ActionResult> Submit(ContactRequest request, CancellationToken ct)
    {
        // Un bot llena el campo oculto: se responde igual que a una persona, sin guardar ni avisar.
        if (!string.IsNullOrWhiteSpace(request.Website)) return Accepted();
        var name = request.Name?.Trim(); var email = request.Email?.Trim(); var message = request.Message?.Trim();
        if (string.IsNullOrEmpty(name) || name.Length > 150) return BadRequest(new { field = "name", message = "Indica tu nombre." });
        if (string.IsNullOrEmpty(email) || email.Length > 200 || !MailAddress.TryCreate(email, out _)) return BadRequest(new { field = "email", message = "Indica un email válido." });
        if (string.IsNullOrEmpty(message) || message.Length < 10 || message.Length > 4000) return BadRequest(new { field = "message", message = "Cuéntanos en unas líneas qué necesitas (10 a 4000 caracteres)." });
        var lead = new ContactLead
        {
            Name = name, Email = email, Message = message,
            Phone = Clip(request.Phone, 40), Company = Clip(request.Company, 150), Service = Clip(request.Service, 60),
            Locale = Locales.Contains(request.Locale) ? request.Locale! : "es", SourcePage = Clip(request.Page, 200),
        };
        db.ContactLeads.Add(lead); await db.SaveChangesAsync(ct);
        var data = new Dictionary<string, string> { ["leadId"] = lead.Id.ToString(), ["name"] = lead.Name, ["email"] = lead.Email, ["message"] = lead.Message, ["locale"] = lead.Locale };
        if (lead.Phone is not null) data["phone"] = lead.Phone;
        if (lead.Company is not null) data["company"] = lead.Company;
        if (lead.Service is not null) data["service"] = lead.Service;
        if (lead.SourcePage is not null) data["page"] = lead.SourcePage;
        jobs.Enqueue<StaffNotifier>(x => x.SendAsync(new Notification(NotificationType.ContactLead, data, $"contact-lead:{lead.Id}", null), CancellationToken.None));
        return Accepted();
    }

    [HttpGet("api/admin/leads"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Leads(ContactLeadStatus? status, CancellationToken ct) =>
        Ok(await db.ContactLeads.Where(x => status == null || x.Status == status).OrderByDescending(x => x.CreatedAt).Take(300).ToListAsync(ct));

    [HttpPatch("api/admin/leads/{id:guid}"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> UpdateLead(Guid id, ContactLeadPatch request, CancellationToken ct)
    {
        var lead = await db.ContactLeads.FindAsync([id], ct); if (lead is null) return NotFound();
        if (request.Status is ContactLeadStatus status) lead.Status = status;
        if (request.Notes is not null) lead.Notes = Clip(request.Notes, 1000);
        await db.SaveChangesAsync(ct); return Ok(lead);
    }

    private static string? Clip(string? value, int max) => string.IsNullOrWhiteSpace(value) ? null : value.Trim() is var v && v.Length > max ? v[..max] : value.Trim();
}

/// <summary><see cref="Website"/>: campo trampa oculto; si llega con valor, es un bot.</summary>
public sealed record ContactRequest(string? Name, string? Email, string? Phone, string? Company, string? Service, string? Message, string? Locale, string? Page, string? Website = null);
public sealed record ContactLeadPatch(ContactLeadStatus? Status, string? Notes);
