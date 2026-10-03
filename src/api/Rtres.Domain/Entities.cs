namespace Rtres.Domain;

public enum UserRole { Admin, Cliente, SuperAdmin }
public enum ProductType { Hosting, Dominio, Ssl, BackupBd, SoporteMensual, DesarrolloWeb }
// Valores nuevos al final: la BD guarda el número (Unico=0, Mensual=1, Anual=2).
public enum BillingCycle { Unico, Mensual, Anual, Bimestral, Trimestral, Semestral }
public static class BillingCycles
{
    /// <summary>Meses entre cobros de los ciclos por suscripción (PayPal cobra solo; se controla con NextChargeAt); null en Único y Anual (pago por periodo con RenewsAt).</summary>
    public static int? SubscriptionMonths(this BillingCycle cycle) => cycle switch { BillingCycle.Mensual => 1, BillingCycle.Bimestral => 2, BillingCycle.Trimestral => 3, BillingCycle.Semestral => 6, _ => null };
    public static bool IsSubscription(this BillingCycle cycle) => cycle.SubscriptionMonths() is not null;
}
public enum ClientProductStatus { Activo, PorVencer, Vencido, Cancelado, Pendiente }
public enum TicketType { Bug, Funcionalidad, Requerimiento } // mismos valores 0/1 que los antiguos Soporte/Cambio
public enum TicketStatus { Abierto, EnProgreso, Resuelto, Publicado, Cerrado }
public enum TaxDocumentType { Factura, ReciboPorHonorarios }
public static class PaymentMethods { public const string PayPal = "PayPal"; public const string Transferencia = "Transferencia"; /// <summary>Transferencia del exterior (remesa); no lleva comprobante peruano.</summary>
    public const string Remesa = "Remesa"; }
public enum ExpenseType { Fijo, Variable }
public enum ExpenseCategory { Hosting, Dominios, SuscripcionesIA, ApisPorUso, Sueldos, Otros, /// <summary>Pagos de Impuesto a la Renta a SUNAT (pagos a cuenta y regularización): en los reportes se restan como impuestos, no como gasto operativo. El IGV pagado no se registra: se cobra al cliente y no es costo.</summary>
    ImpuestoRenta, /// <summary>Comisiones de PayPal, bancos y remesadoras.</summary>
    Comisiones }

public sealed class Client { public Guid Id { get; set; } = Guid.NewGuid(); public string CompanyName { get; set; } = string.Empty; public string ContactName { get; set; } = string.Empty; public string Email { get; set; } = string.Empty; public string? Phone { get; set; } public string PreferredLanguage { get; set; } = "es"; public bool IsActive { get; set; } = true; /// <summary>Solo clientes en Perú: se les emite Factura/Recibo por honorarios por cada pago.</summary>
    public bool RequiresTaxDocument { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; }
public sealed class UserAccount { public Guid Id { get; set; } = Guid.NewGuid(); public Guid? ClientId { get; set; } public string Email { get; set; } = string.Empty; public string PasswordHash { get; set; } = string.Empty; public string Name { get; set; } = string.Empty; public UserRole Role { get; set; } = UserRole.Cliente; public bool IsActive { get; set; } = true; /// <summary>Última vez que abrió la campana: lo posterior cuenta como no leído.</summary>
    public DateTime? NotificationsSeenAt { get; set; } }
/// <summary>Un proyecto puede tener varios repositorios de GitHub (ej. web y API); sin repositorios sus tickets no se sincronizan.</summary>
public sealed class Project { public Guid Id { get; set; } = Guid.NewGuid(); public Guid ClientId { get; set; } public string Name { get; set; } = string.Empty; public string Slug { get; set; } = string.Empty; public List<ProjectRepository> Repositories { get; set; } = []; }
/// <summary>Repositorio de GitHub de un proyecto. <see cref="Label"/> es el nombre que ve el cliente al elegir dónde va su ticket; el principal (<see cref="IsDefault"/>) recibe los tickets que no indican repositorio.</summary>
public sealed class ProjectRepository { public Guid Id { get; set; } = Guid.NewGuid(); public Guid ProjectId { get; set; } public string Owner { get; set; } = string.Empty; public string Name { get; set; } = string.Empty; public string? Label { get; set; } public bool IsDefault { get; set; } }
public static class ProjectExtensions
{
    /// <summary>Repositorio del ticket: el indicado, o el principal del proyecto (el primero si ninguno está marcado).</summary>
    public static ProjectRepository? RepositoryFor(this IReadOnlyCollection<ProjectRepository> repositories, Guid? repositoryId) =>
        repositoryId is Guid id ? repositories.FirstOrDefault(x => x.Id == id) : repositories.OrderByDescending(x => x.IsDefault).FirstOrDefault();
}
public sealed class Product { public Guid Id { get; set; } = Guid.NewGuid(); public ProductType Type { get; set; } public string Name { get; set; } = string.Empty; public BillingCycle BillingCycle { get; set; } public decimal? BasePrice { get; set; } public string Currency { get; set; } = "USD"; public string? Description { get; set; } public bool IsActive { get; set; } = true; public string? PayPalPlanId { get; set; } public decimal? PayPalPlanPrice { get; set; } public TaxDocumentType TaxDocumentType { get; set; } = TaxDocumentType.Factura;
    /// <summary>Agrupa el catálogo (ej. "Sitios web", "Infraestructura"); texto libre.</summary>
    public string? Category { get; set; }
    /// <summary>Palabras separadas por coma con las que el buscador del catálogo encuentra el producto (ej. "web, página, tienda online").</summary>
    public string? Tags { get; set; }
    /// <summary>El cliente puede registrar tickets desde la tarjeta de este producto.</summary>
    public bool AllowsTickets { get; set; } }
public sealed class ClientProduct { public Guid Id { get; set; } = Guid.NewGuid(); public Guid ClientId { get; set; } public Guid ProjectId { get; set; } public Guid ProductId { get; set; } public ClientProductStatus Status { get; set; } public BillingCycle BillingCycle { get; set; } public bool IsManualBilling { get; set; } public DateTime? RenewsAt { get; set; } public DateTime? NextChargeAt { get; set; } public DateTime? LastBackupAt { get; set; } public decimal? Price { get; set; } public string? PriceLabelOverride { get; set; } public string? PayPalOrderId { get; set; } public string? PayPalSubscriptionId { get; set; } public string? PayPalPlanId { get; set; } public string? DomainName { get; set; } /// <summary>Descuento de monto fijo sobre el precio del catálogo; ver <see cref="ClientProductPricing"/>.</summary>
    public decimal? Discount { get; set; } public DateTime? DiscountEndsAt { get; set; } public Product? Product { get; set; } public Project? Project { get; set; }
    /// <summary>Años que cubre la orden de PayPal pendiente (<see cref="PayPalOrderId"/>): al capturarla se extiende esa cantidad.</summary>
    public int? PayPalOrderYears { get; set; }
    /// <summary>No se guarda: IGV que se suma a este producto para su cliente; lo llena el API para que el portal muestre "+ IGV".</summary>
    public decimal? AppliedIgvRate { get; set; } }
public sealed class Ticket { public Guid Id { get; set; } = Guid.NewGuid(); public string Code { get; set; } = string.Empty; public Guid ClientId { get; set; } public Guid ProjectId { get; set; } public Guid CreatedByUserId { get; set; } public TicketType Type { get; set; } public TicketStatus Status { get; set; } = TicketStatus.Abierto; public string Title { get; set; } = string.Empty; public string Description { get; set; } = string.Empty; public string? CurrentBehavior { get; set; } public string? ExpectedBehavior { get; set; } public string? StepsToReproduce { get; set; } public string? Environment { get; set; } public string? AcceptanceCriteria { get; set; } public string? EstimatedImpact { get; set; } /// <summary>Repositorio donde se crea el issue; null = el principal del proyecto (se fija al crear el issue).</summary>
    public Guid? RepositoryId { get; set; } /// <summary>Producto desde el que se registró el ticket (opcional).</summary>
    public Guid? ClientProductId { get; set; } public int? GithubIssueNumber { get; set; } public string? GithubIssueUrl { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; public DateTime UpdatedAt { get; set; } = DateTime.UtcNow; }
public sealed class TicketAttachment { public Guid Id { get; set; } = Guid.NewGuid(); public Guid TicketId { get; set; } public string FileName { get; set; } = string.Empty; public string Url { get; set; } = string.Empty; public long SizeBytes { get; set; } }
public sealed class TicketComment { public Guid Id { get; set; } = Guid.NewGuid(); public Guid TicketId { get; set; } public Guid? AuthorUserId { get; set; } public string Body { get; set; } = string.Empty; public bool FromGithub { get; set; } public long? GithubCommentId { get; set; } public string? GithubAuthorLogin { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; }
/// <summary>Un cobro = un ingreso. <see cref="CreatedAt"/> es la fecha del cobro; su comprobante (si lo hay) es un <see cref="TaxDocument"/> enlazado.</summary>
public sealed class PaymentTransaction { public Guid Id { get; set; } = Guid.NewGuid(); public Guid ClientId { get; set; } /// <summary>Opcional: un cobro puede no corresponder a un producto (ej. remesa por un desarrollo).</summary>
    public Guid? ClientProductId { get; set; } public string PayPalOrderIdOrSubscriptionId { get; set; } = string.Empty; public decimal Amount { get; set; } public string Currency { get; set; } = "USD"; public string Status { get; set; } = string.Empty; /// <summary>PayPal o Transferencia (pago bancario registrado por Rtres).</summary>
    public string Method { get; set; } = PaymentMethods.PayPal; /// <summary>Años que cubre el pago (productos anuales pagados por adelantado); 1 en el resto.</summary>
    public int Years { get; set; } = 1; public decimal AmountPen { get; set; } public string? InternalCode { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; public string? Notes { get; set; } }
public sealed class NotificationLog { public Guid Id { get; set; } = Guid.NewGuid(); public Guid ClientId { get; set; } public string Type { get; set; } = string.Empty; public string Channel { get; set; } = string.Empty; public DateTime SentAt { get; set; } = DateTime.UtcNow; public bool Success { get; set; } public string? Recipient { get; set; } public string? DedupeKey { get; set; } public string? Error { get; set; } }

/// <summary>Tipo de cambio del día hacia PEN (moneda de referencia contable de Rtres). USD viene de SUNAT, EUR del BCRP.</summary>
public sealed class ExchangeRate { public Guid Id { get; set; } = Guid.NewGuid(); public DateOnly Date { get; set; } public string CurrencyCode { get; set; } = string.Empty; public decimal RateToPen { get; set; } public string Source { get; set; } = string.Empty; }

/// <summary>Registro de una Factura/Recibo por Honorarios ya emitido con el facturador externo — Rtres no emite ni timbra nada ante SUNAT.</summary>
public sealed class TaxDocument { public Guid Id { get; set; } = Guid.NewGuid(); public Guid? PaymentTransactionId { get; set; } public Guid ClientId { get; set; } public TaxDocumentType Type { get; set; } public string Series { get; set; } = string.Empty; public int Number { get; set; } public DateOnly IssueDate { get; set; } public string Currency { get; set; } = "PEN"; public decimal BaseAmount { get; set; } public decimal IgvAmount { get; set; } public decimal TotalAmount { get; set; } public string? Notes { get; set; } /// <summary>Retención de Renta que hizo el cliente (Recibo por honorarios, 8 %): impuesto ya pagado, en la moneda del documento.</summary>
    public decimal? RetentionAmount { get; set; } }

public sealed class Expense { public Guid Id { get; set; } = Guid.NewGuid(); public string Description { get; set; } = string.Empty; public ExpenseCategory Category { get; set; } public ExpenseType Type { get; set; } public decimal Amount { get; set; } public string Currency { get; set; } = "PEN"; public decimal AmountPen { get; set; } public DateOnly Date { get; set; } public bool Recurring { get; set; } public BillingCycle? RecurrenceCycle { get; set; } }

/// <summary>Fila única (singleton): tasas de IGV/Renta configurables — el sistema no valida el régimen tributario real, solo aplica la tasa configurada.</summary>
public sealed class TaxSettings
{
    public Guid Id { get; set; } = Guid.NewGuid(); public decimal IgvRate { get; set; } = 0.18m; public decimal RentaRate { get; set; } = 0.10m; public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    // SUNAT numera cada tipo de comprobante por separado: una serie y su próximo correlativo por tipo. Factura y recibo
    // pueden compartir serie (E001 al emitir desde SUNAT SOL) sin que sus correlativos se mezclen.
    public string FacturaSeries { get; set; } = "F001"; public int FacturaNextNumber { get; set; } = 1;
    public string ReciboSeries { get; set; } = "E001"; public int ReciboNextNumber { get; set; } = 1;
}

/// <summary>
/// Aviso de la campana del portal: uno por notificación (no por canal), con los mismos datos que el email.
/// <see cref="ForStaff"/>: avisos internos para Rtres (ticket nuevo, pedido por transferencia), no los ve el cliente.
/// </summary>
public sealed class PortalNotification { public Guid Id { get; set; } = Guid.NewGuid(); public Guid ClientId { get; set; } public string Type { get; set; } = string.Empty; public bool ForStaff { get; set; } public string DataJson { get; set; } = "{}"; public string? DedupeKey { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; }
