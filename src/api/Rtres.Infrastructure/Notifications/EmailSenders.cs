using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MimeKit;
using Rtres.Domain;

namespace Rtres.Infrastructure.Notifications;

/// <summary>Envía por el SMTP configurado en <c>Smtp:*</c> (cuenta de correo del hosting).</summary>
public sealed class SmtpEmailSender(IConfiguration configuration) : IEmailSender
{
    public async Task SendAsync(EmailMessage message, CancellationToken cancellationToken = default)
    {
        var smtp = configuration.GetSection("Smtp");
        var mime = new MimeMessage();
        mime.From.Add(new MailboxAddress(smtp["FromName"] ?? "Rtres Web Solutions", smtp["From"] ?? smtp["User"]));
        mime.To.Add(MailboxAddress.Parse(message.To));
        mime.Subject = message.Subject;
        mime.Body = new BodyBuilder { HtmlBody = message.Html, TextBody = message.Text }.ToMessageBody();

        using var client = new SmtpClient { CheckCertificateRevocation = false };
        var security = Enum.TryParse<SecureSocketOptions>(smtp["Security"], true, out var parsed) ? parsed : SecureSocketOptions.Auto;
        await client.ConnectAsync(smtp["Host"], int.TryParse(smtp["Port"], out var port) ? port : 587, security, cancellationToken);
        if (!string.IsNullOrEmpty(smtp["User"])) await client.AuthenticateAsync(smtp["User"], smtp["Password"], cancellationToken);
        await client.SendAsync(mime, cancellationToken);
        await client.DisconnectAsync(true, cancellationToken);
    }
}

/// <summary>Se usa cuando <c>Smtp:Host</c> no está configurado (desarrollo): solo escribe el email en el log.</summary>
public sealed class LoggingEmailSender(ILogger<LoggingEmailSender> logger) : IEmailSender
{
    public Task SendAsync(EmailMessage message, CancellationToken cancellationToken = default)
    {
        logger.LogInformation("Email (SMTP sin configurar) para {To}: {Subject}\n{Text}", message.To, message.Subject, message.Text);
        return Task.CompletedTask;
    }
}
