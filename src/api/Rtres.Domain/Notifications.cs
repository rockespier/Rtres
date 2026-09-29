namespace Rtres.Domain;

/// <summary><see cref="TransferRequested"/> es un aviso interno para Rtres (no para el cliente).</summary>
public enum NotificationType { RenewalReminder, TicketStatusChanged, TicketReply, PaymentReceived, PaymentFailed, AccountAccess, TransferRequested }

/// <summary>
/// Aviso para un cliente. <see cref="Data"/> lleva los valores que usa la plantilla (ver <c>EmailTemplates</c>);
/// <see cref="DedupeKey"/> evita enviar dos veces el mismo aviso (p. ej. el recordatorio de 7 días de un producto).
/// <see cref="To"/> reemplaza al destinatario por defecto (el email del cliente), p. ej. para el acceso de un usuario invitado.
/// </summary>
public sealed record Notification(NotificationType Type, Dictionary<string, string> Data, string? DedupeKey = null, string? To = null);

public sealed record EmailMessage(string To, string Subject, string Html, string Text);

public interface IEmailSender
{
    Task SendAsync(EmailMessage message, CancellationToken cancellationToken = default);
}
