using System.Buffers.Text;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Rtres.Api.Notifications;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Notifications;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>
/// Login sin contraseña: el usuario pide un enlace de un solo uso a su correo y el portal lo canjea por la misma sesión
/// que el login normal. Solo para usuarios activos ya existentes; nunca crea ni vincula cuentas.
/// </summary>
[ApiController, Route("api/auth/login-link")]
public sealed class LoginLinkController(RtresDbContext db, JwtSettings jwt, IMemoryCache cache, ILoginLinkMailer mailer, IConfiguration configuration) : ControllerBase
{
    public static readonly TimeSpan Lifetime = TimeSpan.FromMinutes(15);
    // Por correo y además del límite por IP: evita usar el endpoint para llenar de correos el buzón de alguien.
    const int MaxLinksPerWindow = 3;
    public const string Sent = "Si tu correo está registrado, te llegará un enlace para entrar en unos minutos.";
    public const string Invalid = "El enlace no es válido, ya se usó o venció. Pide uno nuevo desde el inicio de sesión.";
    sealed class SentLinks { public int Count; }

    /// <summary>Responde siempre 202 con el mismo mensaje: no revela si el correo existe.</summary>
    [HttpPost, EnableRateLimiting(AuthController.LoginRateLimitPolicy)]
    public async Task<ActionResult> Send(LoginLinkRequest request, CancellationToken ct)
    {
        var email = request.Email?.Trim().ToLowerInvariant();
        if (string.IsNullOrEmpty(email) || !email.Contains('@')) return BadRequest(new { message = "Ingresa un correo válido." });
        var u = await db.UserAccounts.AsNoTracking().FirstOrDefaultAsync(x => x.IsActive && x.Email.Trim().ToLower() == email, ct);
        var c = u?.ClientId is Guid clientId ? await db.Clients.AsNoTracking().FirstOrDefaultAsync(x => x.Id == clientId, ct) : null;
        if (u is null || c is { IsActive: false } || !WithinLimit(email)) return Accepted(new { message = Sent });

        var now = DateTime.UtcNow;
        var token = Base64Url.EncodeToString(RandomNumberGenerator.GetBytes(32));
        // Limpia de paso los enlaces vencidos de este usuario.
        db.LoginLinks.RemoveRange(await db.LoginLinks.Where(x => x.UserAccountId == u.Id && x.ExpiresAt < now).ToListAsync(ct));
        db.LoginLinks.Add(new LoginLink { UserAccountId = u.Id, TokenHash = Hash(token), CreatedAt = now, ExpiresAt = now + Lifetime });
        await db.SaveChangesAsync(ct);

        var notification = new Notification(NotificationType.LoginLink, new()
        {
            ["name"] = u.Name.Split(' ', StringSplitOptions.RemoveEmptyEntries).FirstOrDefault() ?? u.Name,
            ["token"] = token,
            ["minutes"] = ((int)Lifetime.TotalMinutes).ToString(CultureInfo.InvariantCulture),
        }, To: u.Email);
        var (subject, html, text) = EmailTemplates.Render(notification, c?.PreferredLanguage, PayPalCheckoutService.PortalBaseUrl(Request, configuration));
        mailer.Send(new EmailMessage(u.Email, subject, html, text));
        return Accepted(new { message = Sent });
    }

    /// <summary>Canjea el enlace (una sola vez) por la sesión del portal. Es POST para que los antivirus de correo que abren los enlaces no lo gasten.</summary>
    [HttpPost("verify"), EnableRateLimiting(AuthController.LoginRateLimitPolicy)]
    public async Task<ActionResult> Verify(LoginLinkVerifyRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Token)) return Unauthorized(new { message = Invalid });
        var hash = Hash(request.Token.Trim());
        var now = DateTime.UtcNow;
        var link = await db.LoginLinks.FirstOrDefaultAsync(x => x.TokenHash == hash, ct);
        if (link is null || link.UsedAt is not null || link.ExpiresAt <= now) return Unauthorized(new { message = Invalid });
        link.UsedAt = now;
        try { await db.SaveChangesAsync(ct); }
        catch (DbUpdateConcurrencyException) { return Unauthorized(new { message = Invalid }); } // otra petición lo canjeó antes

        var u = await db.UserAccounts.AsNoTracking().FirstOrDefaultAsync(x => x.Id == link.UserAccountId && x.IsActive, ct);
        if (u is null) return Unauthorized(new { message = Invalid });
        var c = u.ClientId is Guid clientId ? await db.Clients.AsNoTracking().FirstOrDefaultAsync(x => x.Id == clientId, ct) : null;
        if (c is not null && !c.IsActive) return StatusCode(403, new { message = "Este cliente está dado de baja. Contacta a Rtres." });
        return AuthController.SessionFor(jwt, u, c);
    }

    bool WithinLimit(string email)
    {
        var sent = cache.GetOrCreate("login-link:" + email, e => { e.AbsoluteExpirationRelativeToNow = Lifetime; return new SentLinks(); })!;
        return Interlocked.Increment(ref sent.Count) <= MaxLinksPerWindow;
    }

    static string Hash(string token) => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token)));
}
