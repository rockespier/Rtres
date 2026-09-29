using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace Rtres.Api.Services;

/// <summary>Configuración JWT validada al arrancar: sin una Jwt:Key real la API no inicia.</summary>
public sealed record JwtSettings(string Issuer, string Audience, SymmetricSecurityKey SigningKey)
{
    // HMAC-SHA256 necesita al menos 256 bits de clave.
    const int MinKeyBytes = 32;

    public static JwtSettings FromConfiguration(IConfiguration config)
    {
        var key = config["Jwt:Key"];
        if (string.IsNullOrWhiteSpace(key))
            throw new InvalidOperationException("Falta Jwt:Key. Defínela con la variable de entorno Jwt__Key (o en appsettings.{Entorno}.local.json en desarrollo).");
        if (Encoding.UTF8.GetByteCount(key) < MinKeyBytes)
            throw new InvalidOperationException($"Jwt:Key es demasiado corta: se requieren al menos {MinKeyBytes} bytes.");
        if (key.Contains("change-me", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Jwt:Key usa un valor de ejemplo conocido. Genera una clave aleatoria.");
        return new JwtSettings(config["Jwt:Issuer"] ?? "Rtres.Api", config["Jwt:Audience"] ?? "Rtres.Web", new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)));
    }
}
