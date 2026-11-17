namespace Rtres.Api.Controllers;

/// <summary>
/// Perfiles dentro de la empresa cliente: el Admin ve todo (inicio, servicios, contratación, facturación y equipo);
/// el rol Cliente (miembro del equipo) solo sus tickets y su cuenta. El portal oculta lo mismo (core/nav.ts).
/// </summary>
public static class ClientRoles
{
    /// <summary>Ver servicios, pagos y medios de pago del cliente: su Admin y Rtres (SuperAdmin viendo como el cliente).</summary>
    public const string Billing = "Admin,SuperAdmin";
    /// <summary>Contratar, renovar, cancelar o reportar pagos: solo el Admin del cliente.</summary>
    public const string Purchase = "Admin";
}
