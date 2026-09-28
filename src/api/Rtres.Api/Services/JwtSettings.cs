using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace Rtres.Api.Services;

/// <summary>
/// Emisor, audiencia y clave de los tokens del portal. Fuera de Development la API no arranca sin una clave propia
/// (<c>Jwt:Key</c>, 32+ caracteres): con la clave de ejemplo, cualquiera podría firmar un token de SuperAdmin.
/// </summary>
public sealed record JwtSettings(string Issuer, string Audience, string Key)
{
    public const string DevelopmentKey = "development-only-change-me-development-only-change-me";
    public const int MinKeyLength = 32;

    public SymmetricSecurityKey SigningKey => new(Encoding.UTF8.GetBytes(Key));

    public static JwtSettings From(IConfiguration configuration, bool isDevelopment)
    {
        var key = configuration["Jwt:Key"];
        if (string.IsNullOrWhiteSpace(key) || key == DevelopmentKey)
        {
            if (!isDevelopment) throw new InvalidOperationException("Falta Jwt:Key: configura una clave propia de 32+ caracteres (variable de entorno Jwt__Key o appsettings.Production.local.json).");
            key = DevelopmentKey;
        }
        if (key.Length < MinKeyLength) throw new InvalidOperationException($"Jwt:Key debe tener al menos {MinKeyLength} caracteres.");
        return new(configuration["Jwt:Issuer"] ?? "Rtres.Api", configuration["Jwt:Audience"] ?? "Rtres.Web", key);
    }
}
