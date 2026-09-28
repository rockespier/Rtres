using System.Collections.Concurrent;

namespace Rtres.Api.Services;

/// <summary>
/// Frena la adivinación de contraseñas: tras <see cref="MaxFailures"/> intentos fallidos para un mismo correo dentro de
/// <see cref="Window"/>, el login de ese correo queda bloqueado hasta que pase la ventana. Un login correcto lo reinicia.
/// Se cuenta por correo (no por IP) porque detrás del proxy todas las peticiones llegan con la misma IP.
/// </summary>
public sealed class LoginThrottle(TimeProvider clock)
{
    public const int MaxFailures = 5;
    public static readonly TimeSpan Window = TimeSpan.FromMinutes(15);

    private readonly ConcurrentDictionary<string, (int Count, DateTimeOffset Since)> failures = new(StringComparer.OrdinalIgnoreCase);

    /// <summary>Tiempo que falta para poder volver a intentar, o null si el correo no está bloqueado.</summary>
    public TimeSpan? RetryAfter(string email)
    {
        if (!failures.TryGetValue(Key(email), out var entry)) return null;
        var left = entry.Since + Window - clock.GetUtcNow();
        if (left <= TimeSpan.Zero) { failures.TryRemove(Key(email), out _); return null; }
        return entry.Count >= MaxFailures ? left : null;
    }

    public void Failed(string email)
    {
        var now = clock.GetUtcNow();
        failures.AddOrUpdate(Key(email), _ => (1, now), (_, e) => e.Since + Window <= now ? (1, now) : (e.Count + 1, e.Since));
        if (failures.Count > 10_000) foreach (var (k, e) in failures) if (e.Since + Window <= now) failures.TryRemove(k, out _);
    }

    public void Succeeded(string email) => failures.TryRemove(Key(email), out _);

    private static string Key(string email) => email.Trim();
}
