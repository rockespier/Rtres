using System.Globalization;
using System.Net;
using System.Text;
using Rtres.Domain;

namespace Rtres.Infrastructure.Notifications;

/// <summary>
/// Plantillas de email ES/EN/IT. Cada tipo de aviso espera estas claves en <see cref="Notification.Data"/>:
/// <list type="bullet">
/// <item><c>RenewalReminder</c>: product, renewsAt (ISO), days, autoRenew ("true"/"false"), domain?, amount?, currency?</item>
/// <item><c>TicketStatusChanged</c>: ticketId, code, title, status (nombre de <see cref="TicketStatus"/>)</item>
/// <item><c>TicketReply</c>: ticketId, code, title, author, body</item>
/// <item><c>PaymentReceived</c>: product, amount, currency</item>
/// <item><c>PaymentFailed</c>: product</item>
/// <item><c>AccountAccess</c>: name, company, email, password (se envía en el momento, nunca por la cola de Hangfire)</item>
/// <item><c>TransferRequested</c>: clientId, company, product, project, amount?, currency — aviso interno para Rtres, siempre en español</item>
/// <item><c>TicketCreated</c>: ticketId, code, title, company, project, body — aviso interno para Rtres, siempre en español</item>
/// <item><c>TaxDueReminder</c>: period (yyyy-MM), dueDate (yyyy-MM-dd), days — aviso interno para Rtres, siempre en español</item>
/// </list>
/// </summary>
public static class EmailTemplates
{
    public static readonly string[] Languages = ["es", "en", "it"];

    public static (string Subject, string Html, string Text) Render(Notification notification, string? language, string portalUrl)
    {
        // Los avisos internos van al equipo de Rtres: el idioma del cliente no aplica.
        var lang = notification.Type is NotificationType.TransferRequested or NotificationType.TicketCreated or NotificationType.TaxDueReminder ? "es" : Languages.Contains(language) ? language! : "es";
        var d = notification.Data;
        var t = Texts[lang];
        var portal = portalUrl.TrimEnd('/');
        string V(string key) => d.TryGetValue(key, out var value) ? value : string.Empty;

        var (subject, paragraphs, cta, link) = notification.Type switch
        {
            NotificationType.RenewalReminder => RenewalReminder(t, lang, V, portal),
            NotificationType.TicketStatusChanged => (
                string.Format(t["status.subject"], V("code"), StatusLabel(lang, V("status"))),
                new[] { string.Format(t["status.body"], V("code"), V("title"), StatusLabel(lang, V("status"))) },
                t["cta.ticket"], $"{portal}/tickets/{V("ticketId")}"),
            NotificationType.TicketReply => (
                string.Format(t["reply.subject"], V("code")),
                new[] { string.Format(t["reply.body"], V("author"), V("code"), V("title")), Quote(V("body")) },
                t["cta.reply"], $"{portal}/tickets/{V("ticketId")}"),
            NotificationType.PaymentReceived => (
                string.Format(t["paid.subject"], V("product")),
                new[] { string.Format(t["paid.body"], Money(lang, V("amount"), V("currency")), V("product")) },
                t["cta.billing"], $"{portal}/billing"),
            NotificationType.AccountAccess => (
                string.Format(t["access.subject"], V("company")),
                new[] { string.Format(t["access.body"], V("name"), V("company")), string.Format(t["access.credentials"], V("email"), V("password")), t["access.change"] },
                t["cta.login"], $"{portal}/login"),
            NotificationType.PaymentFailed => (
                string.Format(t["failed.subject"], V("product")),
                new[] { string.Format(t["failed.body"], V("product")) },
                t["cta.dashboard"], $"{portal}/dashboard"),
            NotificationType.TransferRequested => (
                string.Format(t["transfer.subject"], V("company"), V("product")),
                string.IsNullOrWhiteSpace(V("amount"))
                    ? new[] { string.Format(t["transfer.body"], V("company"), V("product"), V("project")), t["transfer.next"] }
                    : new[] { string.Format(t["transfer.body"], V("company"), V("product"), V("project")), string.Format(t["transfer.amount"], Money(lang, V("amount"), V("currency"))), t["transfer.next"] },
                t["cta.client"], $"{portal}/admin/clients/{V("clientId")}"),
            NotificationType.TicketCreated => (
                string.Format(t["ticket-created.subject"], V("code"), V("company")),
                new[] { string.Format(t["ticket-created.body"], V("company"), V("project"), V("title")), Quote(V("body")) },
                t["cta.ticket"], $"{portal}/admin/tickets?ticketId={V("ticketId")}"),
            NotificationType.TaxDueReminder => TaxDueReminder(t, V, portal),
            _ => throw new ArgumentOutOfRangeException(nameof(notification), notification.Type, null),
        };
        var footer = notification.Type is NotificationType.TransferRequested or NotificationType.TicketCreated or NotificationType.TaxDueReminder ? t["footer.staff"] : t["footer"];
        return (subject, Html(footer, paragraphs, cta, link), Text(footer, paragraphs, cta, link));
    }

    private static (string, string[], string, string) TaxDueReminder(Dictionary<string, string> t, Func<string, string> v, string portal)
    {
        var es = Culture("es");
        var period = DateTime.TryParseExact(v("period"), "yyyy-MM", CultureInfo.InvariantCulture, DateTimeStyles.None, out var p) ? p.ToString("MMMM yyyy", es).ToLower(es) : v("period");
        var due = DateTime.TryParseExact(v("dueDate"), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out var d) ? d.ToString("dddd d 'de' MMMM", es) : v("dueDate");
        var days = int.TryParse(v("days"), out var n) ? n : 0;
        var when = days <= 0 ? t["tax-due.today"] : days == 1 ? t["renewal.tomorrow"] : string.Format(t["renewal.inDays"], days);
        return (string.Format(t["tax-due.subject"], period, when), new[] { string.Format(t["tax-due.body"], period, due, when), t["tax-due.next"] }, t["cta.tax-due"], $"{portal}/admin/tax-calendar");
    }

    private static (string, string[], string, string) RenewalReminder(Dictionary<string, string> t, string lang, Func<string, string> v, string portal)
    {
        var product = string.IsNullOrWhiteSpace(v("domain")) ? v("product") : $"{v("product")} ({v("domain")})";
        var date = DateTime.TryParse(v("renewsAt"), CultureInfo.InvariantCulture, DateTimeStyles.RoundtripKind, out var parsed)
            ? parsed.ToString(lang switch { "en" => "MMMM d, yyyy", "es" => "d 'de' MMMM 'de' yyyy", _ => "d MMMM yyyy" }, Culture(lang)) : v("renewsAt");
        var days = int.TryParse(v("days"), out var n) ? n : 0;
        var when = days <= 1 ? t["renewal.tomorrow"] : string.Format(t["renewal.inDays"], days);
        var paragraphs = new List<string> { string.Format(t["renewal.body"], product, date, when) };
        if (!string.IsNullOrWhiteSpace(v("amount"))) paragraphs.Add(string.Format(t["renewal.amount"], Money(lang, v("amount"), v("currency"))));
        paragraphs.Add(v("autoRenew") == "true" ? t["renewal.auto"] : t["renewal.manual"]);
        return (string.Format(t["renewal.subject"], product, when), paragraphs.ToArray(), t["cta.dashboard"], $"{portal}/dashboard");
    }

    private static string StatusLabel(string lang, string status) =>
        StatusLabels[lang].TryGetValue(status, out var label) ? label : status;

    private static string Money(string lang, string amount, string currency) =>
        decimal.TryParse(amount, NumberStyles.Number, CultureInfo.InvariantCulture, out var value)
            ? $"{(string.IsNullOrWhiteSpace(currency) ? "USD" : currency)} {value.ToString("N2", Culture(lang))}"
            : $"{currency} {amount}".Trim();

    private static CultureInfo Culture(string lang) => CultureInfo.GetCultureInfo(lang switch { "en" => "en-US", "it" => "it-IT", _ => "es-PE" });

    private static string Quote(string body) => body.Length > 600 ? body[..600].TrimEnd() + "…" : body;

    private static string Html(string footer, IEnumerable<string> paragraphs, string cta, string link)
    {
        var html = new StringBuilder();
        html.Append("<!doctype html><html><body style=\"margin:0;background:#f5f5f0;font-family:Arial,Helvetica,sans-serif;color:#1a1a1a\">")
            .Append("<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\"><tr><td align=\"center\" style=\"padding:32px 16px\">")
            .Append("<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"max-width:560px;background:#ffffff;border-radius:12px;padding:32px\">")
            .Append("<tr><td style=\"font-size:18px;font-weight:bold;padding-bottom:20px\">Rtres Web Solutions</td></tr>");
        foreach (var p in paragraphs)
            html.Append("<tr><td style=\"font-size:15px;line-height:1.6;padding-bottom:14px;white-space:pre-line\">").Append(WebUtility.HtmlEncode(p)).Append("</td></tr>");
        html.Append("<tr><td style=\"padding:12px 0 24px\"><a href=\"").Append(WebUtility.HtmlEncode(link))
            .Append("\" style=\"display:inline-block;background:#5b7a2a;color:#ffffff;text-decoration:none;font-weight:bold;padding:12px 22px;border-radius:8px\">")
            .Append(WebUtility.HtmlEncode(cta)).Append("</a></td></tr>")
            .Append("<tr><td style=\"font-size:12px;color:#777777;border-top:1px solid #eeeeee;padding-top:16px\">").Append(WebUtility.HtmlEncode(footer)).Append("</td></tr>")
            .Append("</table></td></tr></table></body></html>");
        return html.ToString();
    }

    private static string Text(string footer, IEnumerable<string> paragraphs, string cta, string link) =>
        $"{string.Join("\n\n", paragraphs)}\n\n{cta}: {link}\n\n--\n{footer}";

    private static readonly Dictionary<string, Dictionary<string, string>> StatusLabels = new()
    {
        ["es"] = new() { ["Abierto"] = "Abierto", ["EnProgreso"] = "En progreso", ["Resuelto"] = "Resuelto", ["Publicado"] = "Publicado", ["Cerrado"] = "Cerrado" },
        ["en"] = new() { ["Abierto"] = "Open", ["EnProgreso"] = "In progress", ["Resuelto"] = "Resolved", ["Publicado"] = "Released", ["Cerrado"] = "Closed" },
        ["it"] = new() { ["Abierto"] = "Aperto", ["EnProgreso"] = "In corso", ["Resuelto"] = "Risolto", ["Publicado"] = "Pubblicato", ["Cerrado"] = "Chiuso" },
    };

    private static readonly Dictionary<string, Dictionary<string, string>> Texts = new()
    {
        ["es"] = new()
        {
            ["renewal.subject"] = "{0} vence {1}",
            ["renewal.body"] = "Tu servicio {0} vence el {1} ({2}).",
            ["renewal.inDays"] = "en {0} días",
            ["renewal.tomorrow"] = "mañana",
            ["renewal.amount"] = "Importe de la renovación: {0}.",
            ["renewal.auto"] = "Tienes la renovación automática activa: se cobrará a tu método de pago en PayPal sin que tengas que hacer nada.",
            ["renewal.manual"] = "Para evitar interrupciones, renuévalo desde el portal de clientes antes de esa fecha.",
            ["status.subject"] = "Ticket {0}: {1}",
            ["status.body"] = "Tu ticket {0} «{1}» cambió de estado a: {2}.",
            ["reply.subject"] = "Nueva respuesta en tu ticket {0}",
            ["reply.body"] = "{0} respondió en tu ticket {1} «{2}»:",
            ["paid.subject"] = "Pago recibido: {0}",
            ["paid.body"] = "Recibimos tu pago de {0} por {1}. ¡Gracias!",
            ["failed.subject"] = "No se pudo procesar el pago de {0}",
            ["failed.body"] = "PayPal no pudo completar el pago de {0}. Revisa tu método de pago en PayPal o renueva el servicio desde el portal para evitar que se suspenda.",
            ["access.subject"] = "Tu acceso al portal de clientes de Rtres ({0})",
            ["access.body"] = "Hola {0}: te dimos acceso al portal de clientes de Rtres Web Solutions para {1}, donde puedes ver tus productos, pagos y tickets de soporte.",
            ["access.credentials"] = "Usuario: {0}\nContraseña temporal: {1}",
            ["access.change"] = "Por seguridad, cámbiala en Perfil después de tu primer ingreso. Si no esperabas este correo, avísanos respondiendo a este mensaje.",
            ["cta.login"] = "Entrar al portal",
            ["cta.dashboard"] = "Ver mis productos",
            ["cta.ticket"] = "Ver ticket",
            ["cta.reply"] = "Ver y responder",
            ["cta.billing"] = "Ver facturación",
            ["footer"] = "Recibes este correo porque tienes servicios contratados con Rtres Web Solutions.",
            ["transfer.subject"] = "Pedido por transferencia: {0} — {1}",
            ["transfer.body"] = "{0} agregó {1} (proyecto {2}) desde el catálogo y eligió pagar por transferencia bancaria.",
            ["transfer.amount"] = "Monto a recibir: {0}.",
            ["transfer.next"] = "El producto queda Pendiente. Cuando llegue la transferencia, regístrala en el detalle del cliente con \"Registrar pago\" para activarlo.",
            ["ticket-created.subject"] = "Nuevo ticket sin GitHub: {0} — {1}",
            ["ticket-created.body"] = "{0} abrió el ticket «{2}» para el proyecto {1}. Atiéndelo desde el portal de administración:",
            ["cta.client"] = "Ver cliente",
            ["footer.staff"] = "Aviso interno del portal de clientes de Rtres.",
            ["tax-due.subject"] = "SUNAT: la declaración de {0} vence {1}",
            ["tax-due.body"] = "La declaración mensual de IGV-Renta del periodo {0} vence el {1} ({2}).",
            ["tax-due.next"] = "Revisa el IGV y la Renta estimados en Reportes y, cuando presentes la declaración, márcala como presentada en el calendario para no recibir más avisos.",
            ["tax-due.today"] = "hoy",
            ["cta.tax-due"] = "Ver calendario",
        },
        ["en"] = new()
        {
            ["renewal.subject"] = "{0} expires {1}",
            ["renewal.body"] = "Your service {0} expires on {1} ({2}).",
            ["renewal.inDays"] = "in {0} days",
            ["renewal.tomorrow"] = "tomorrow",
            ["renewal.amount"] = "Renewal amount: {0}.",
            ["renewal.auto"] = "Automatic renewal is on: your PayPal payment method will be charged, no action needed.",
            ["renewal.manual"] = "To avoid any interruption, renew it from the client portal before that date.",
            ["status.subject"] = "Ticket {0}: {1}",
            ["status.body"] = "Your ticket {0} \"{1}\" is now: {2}.",
            ["reply.subject"] = "New reply on your ticket {0}",
            ["reply.body"] = "{0} replied on your ticket {1} \"{2}\":",
            ["paid.subject"] = "Payment received: {0}",
            ["paid.body"] = "We received your payment of {0} for {1}. Thank you!",
            ["failed.subject"] = "Payment for {0} could not be processed",
            ["failed.body"] = "PayPal could not complete the payment for {0}. Please check your PayPal payment method or renew the service from the portal to avoid suspension.",
            ["access.subject"] = "Your access to the Rtres client portal ({0})",
            ["access.body"] = "Hi {0}: you now have access to the Rtres Web Solutions client portal for {1}, where you can see your products, payments and support tickets.",
            ["access.credentials"] = "User: {0}\nTemporary password: {1}",
            ["access.change"] = "For security, change it in Profile after your first sign-in. If you weren't expecting this email, let us know by replying to it.",
            ["cta.login"] = "Sign in to the portal",
            ["cta.dashboard"] = "View my products",
            ["cta.ticket"] = "View ticket",
            ["cta.reply"] = "View and reply",
            ["cta.billing"] = "View billing",
            ["footer"] = "You are receiving this email because you have active services with Rtres Web Solutions.",
        },
        ["it"] = new()
        {
            ["renewal.subject"] = "{0} scade {1}",
            ["renewal.body"] = "Il tuo servizio {0} scade il {1} ({2}).",
            ["renewal.inDays"] = "tra {0} giorni",
            ["renewal.tomorrow"] = "domani",
            ["renewal.amount"] = "Importo del rinnovo: {0}.",
            ["renewal.auto"] = "Il rinnovo automatico è attivo: l'importo verrà addebitato sul tuo metodo di pagamento PayPal, senza bisogno di fare nulla.",
            ["renewal.manual"] = "Per evitare interruzioni, rinnovalo dal portale clienti prima di tale data.",
            ["status.subject"] = "Ticket {0}: {1}",
            ["status.body"] = "Il tuo ticket {0} «{1}» è ora: {2}.",
            ["reply.subject"] = "Nuova risposta al tuo ticket {0}",
            ["reply.body"] = "{0} ha risposto al tuo ticket {1} «{2}»:",
            ["paid.subject"] = "Pagamento ricevuto: {0}",
            ["paid.body"] = "Abbiamo ricevuto il tuo pagamento di {0} per {1}. Grazie!",
            ["failed.subject"] = "Impossibile elaborare il pagamento di {0}",
            ["failed.body"] = "PayPal non è riuscito a completare il pagamento di {0}. Controlla il tuo metodo di pagamento su PayPal o rinnova il servizio dal portale per evitarne la sospensione.",
            ["access.subject"] = "Il tuo accesso al portale clienti di Rtres ({0})",
            ["access.body"] = "Ciao {0}: ora hai accesso al portale clienti di Rtres Web Solutions per {1}, dove puoi vedere i tuoi prodotti, pagamenti e ticket di assistenza.",
            ["access.credentials"] = "Utente: {0}\nPassword temporanea: {1}",
            ["access.change"] = "Per sicurezza, cambiala in Profilo dopo il primo accesso. Se non ti aspettavi questa email, faccelo sapere rispondendo a questo messaggio.",
            ["cta.login"] = "Accedi al portale",
            ["cta.dashboard"] = "Vedi i miei prodotti",
            ["cta.ticket"] = "Vedi ticket",
            ["cta.reply"] = "Vedi e rispondi",
            ["cta.billing"] = "Vedi fatturazione",
            ["footer"] = "Ricevi questa email perché hai servizi attivi con Rtres Web Solutions.",
        },
    };
}
