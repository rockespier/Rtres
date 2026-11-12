using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;

namespace Rtres.Api.Services;

/// <summary>Resultado de un ID token de Firebase válido: el correo y si Google lo verificó.</summary>
public sealed record FirebaseIdentity(string Email, bool EmailVerified);

/// <summary>Verifica ID tokens de Firebase Authentication. Devuelve null si el token no es válido.</summary>
public interface IFirebaseTokenVerifier
{
    Task<FirebaseIdentity?> VerifyAsync(string idToken, CancellationToken ct);
}

/// <summary>
/// Valida el ID token contra los metadatos OpenID que publica Firebase (firma, emisor, audiencia y vigencia),
/// sin Firebase Admin SDK ni credenciales de cuenta de servicio. Sin Firebase:ProjectId rechaza todo sin ir a la red.
/// </summary>
public sealed class FirebaseTokenVerifier : IFirebaseTokenVerifier
{
    readonly string? projectId;
    readonly ConfigurationManager<OpenIdConnectConfiguration>? metadata;

    public FirebaseTokenVerifier(IConfiguration config)
    {
        projectId = config["Firebase:ProjectId"]?.Trim();
        if (string.IsNullOrEmpty(projectId)) return;
        // ConfigurationManager cachea y refresca las claves de firma de Google.
        metadata = new ConfigurationManager<OpenIdConnectConfiguration>(
            $"https://securetoken.google.com/{projectId}/.well-known/openid-configuration",
            new OpenIdConnectConfigurationRetriever(), new HttpDocumentRetriever { RequireHttps = true });
    }

    public async Task<FirebaseIdentity?> VerifyAsync(string idToken, CancellationToken ct)
    {
        if (metadata is null || string.IsNullOrWhiteSpace(idToken)) return null;
        try
        {
            var oidc = await metadata.GetConfigurationAsync(ct);
            var result = await new JsonWebTokenHandler().ValidateTokenAsync(idToken, new TokenValidationParameters
            {
                ValidateIssuer = true, ValidateAudience = true, ValidateLifetime = true, ValidateIssuerSigningKey = true,
                ValidIssuer = $"https://securetoken.google.com/{projectId}", ValidAudience = projectId,
                IssuerSigningKeys = oidc.SigningKeys, ClockSkew = TimeSpan.FromMinutes(1)
            });
            if (!result.IsValid) return null;
            var email = result.Claims.TryGetValue("email", out var e) ? e as string : null;
            if (string.IsNullOrWhiteSpace(email)) return null;
            var verified = result.Claims.TryGetValue("email_verified", out var v) && v is true or "true";
            return new FirebaseIdentity(email, verified);
        }
        catch (Exception)
        {
            return null;
        }
    }
}
