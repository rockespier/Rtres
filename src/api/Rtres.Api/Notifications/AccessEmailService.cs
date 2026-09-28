using Rtres.Api.Services;
using Rtres.Domain;

namespace Rtres.Api.Notifications;

/// <summary>
/// Envía por email el acceso (usuario + contraseña temporal) a un usuario nuevo o con la contraseña restablecida.
/// Se envía en el momento, sin pasar por la cola de Hangfire: sus argumentos se guardan en la base de datos y la
/// contraseña quedaría ahí en texto plano. Si el envío falla, el portal muestra la contraseña para entregarla a mano.
/// </summary>
public sealed class AccessEmailService(NotificationJob job, IConfiguration configuration, ILogger<AccessEmailService> logger)
{
    public async Task<bool> SendAsync(Client client, string name, string email, string temporaryPassword, HttpRequest? request, CancellationToken ct)
    {
        var notification = new Notification(NotificationType.AccountAccess, new()
        {
            ["name"] = name,
            ["company"] = client.CompanyName,
            ["email"] = email,
            ["password"] = temporaryPassword,
            ["portalUrl"] = PayPalCheckoutService.PortalBaseUrl(request, configuration),
        }, To: email);
        try
        {
            return await job.SendAsync(client.Id, notification, ct);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "No se pudo enviar el email de acceso a {Email}", email);
            return false;
        }
    }
}
