using System.Security.Cryptography;
using System.Text;

namespace Rtres.Domain;

/// <summary>Convención de labels entre el portal y los repos de GitHub de cada proyecto.</summary>
public static class GitHubLabels
{
    public const string StatusPrefix = "estado:";
    public const string ProjectPrefix = "proyecto:";

    private static readonly (TicketStatus Status, string Label)[] StatusLabels =
    [
        (TicketStatus.Abierto, "estado:abierto"),
        (TicketStatus.EnProgreso, "estado:en-progreso"),
        (TicketStatus.Resuelto, "estado:resuelto"),
        (TicketStatus.Publicado, "estado:publicado"),
        (TicketStatus.Cerrado, "estado:cerrado"),
    ];

    /// <summary>Marca oculta que llevan los comentarios publicados desde el portal, para no reimportarlos por el webhook.</summary>
    public const string PortalCommentMarker = "<!-- rtres-portal-comment:";

    public static string ForType(TicketType type) => type switch
    {
        TicketType.Bug => "bug",
        TicketType.Funcionalidad => "enhancement",
        _ => "requirement",
    };
    public static string ForStatus(TicketStatus status) => StatusLabels.First(x => x.Status == status).Label;
    public static string ForProject(string projectSlug) => ProjectPrefix + projectSlug;

    /// <summary>
    /// Resuelve el estado del ticket a partir del estado del issue. En un issue abierto manda el label <c>estado:*</c>
    /// más avanzado (sin label → Abierto). En un issue cerrado solo cuentan los labels de cierre (resuelto/publicado/
    /// cerrado): los de trabajo en curso (abierto/en-progreso) quedan obsoletos al cerrar — todo issue nace con
    /// <c>estado:abierto</c> y no se puede exigir quitarlo a mano. Sin label de cierre, "not_planned" → Cerrado y
    /// cualquier otro cierre → Resuelto.
    /// </summary>
    public static TicketStatus ResolveStatus(string issueState, string? stateReason, IEnumerable<string> labels)
    {
        var set = labels.Select(x => x.Trim().ToLowerInvariant()).ToHashSet();
        var closed = string.Equals(issueState, "closed", StringComparison.OrdinalIgnoreCase);
        // Si hay varios labels de estado, gana el más avanzado.
        foreach (var (status, label) in StatusLabels.Reverse())
            if (set.Contains(label) && (!closed || status >= TicketStatus.Resuelto)) return status;
        if (!closed) return TicketStatus.Abierto;
        return string.Equals(stateReason, "not_planned", StringComparison.OrdinalIgnoreCase) ? TicketStatus.Cerrado : TicketStatus.Resuelto;
    }
}

public static class GitHubWebhookSignature
{
    /// <summary>Valida el header <c>X-Hub-Signature-256</c> (HMAC-SHA256 del body con el secreto del webhook).</summary>
    public static bool IsValid(string secret, byte[] body, string? signatureHeader)
    {
        const string prefix = "sha256=";
        if (string.IsNullOrEmpty(secret) || string.IsNullOrEmpty(signatureHeader) || !signatureHeader.StartsWith(prefix, StringComparison.Ordinal)) return false;
        byte[] expected;
        try { expected = Convert.FromHexString(signatureHeader[prefix.Length..]); }
        catch (FormatException) { return false; }
        var actual = HMACSHA256.HashData(Encoding.UTF8.GetBytes(secret), body);
        return CryptographicOperations.FixedTimeEquals(actual, expected);
    }
}
