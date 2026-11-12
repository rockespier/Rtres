using Rtres.Domain;

namespace Rtres.Api.Notifications;

/// <summary>Envía el email del enlace de acceso sin hacer esperar la respuesta.</summary>
public interface ILoginLinkMailer
{
    void Send(EmailMessage message);
}

/// <summary>
/// Envía en segundo plano y con su propio scope: la respuesta de la API tarda lo mismo exista o no el correo (no revela
/// cuentas) y un SMTP lento no la frena. No pasa por Hangfire: sus argumentos se guardarían en la BD con el token en claro.
/// </summary>
public sealed class BackgroundLoginLinkMailer(IServiceScopeFactory scopes, ILogger<BackgroundLoginLinkMailer> logger) : ILoginLinkMailer
{
    public void Send(EmailMessage message) => _ = Task.Run(async () =>
    {
        try
        {
            using var scope = scopes.CreateScope();
            await scope.ServiceProvider.GetRequiredService<IEmailSender>().SendAsync(message);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "No se pudo enviar el enlace de acceso a {Email}", message.To);
        }
    });
}
