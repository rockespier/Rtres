namespace Rtres.Domain;

public enum ContactLeadStatus { Nuevo, Contactado, Cliente, Descartado }

/// <summary>Contacto que llega desde el formulario del sitio público (rtres.net/contacto).</summary>
public sealed class ContactLead
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Company { get; set; }
    /// <summary>Servicio de interés elegido en el formulario (slug del servicio, "apis" u "otro").</summary>
    public string? Service { get; set; }
    public string Message { get; set; } = string.Empty;
    /// <summary>Idioma del sitio (es, en, it) y página desde la que llegó: para medir qué contenido convierte.</summary>
    public string Locale { get; set; } = "es";
    public string? SourcePage { get; set; }
    public ContactLeadStatus Status { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
