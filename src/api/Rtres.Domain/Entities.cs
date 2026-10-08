namespace Rtres.Domain;

public enum UserRole { Admin, Cliente, SuperAdmin }
public enum ProductType { Hosting, Dominio, Ssl, BackupBd, SoporteMensual, DesarrolloWeb }
// Valores nuevos al final: la BD guarda el número (Unico=0, Mensual=1, Anual=2).
public enum BillingCycle { Unico, Mensual, Anual, Bimestral, Trimestral, Semestral }
public static class BillingCycles
{
    /// <summary>Meses entre cobros de los ciclos por suscripción (PayPal cobra solo; se controla con NextChargeAt); null en Único y Anual (pago por periodo con RenewsAt).</summary>
    /// <summary>Meses entre pagos de cualquier ciclo con repetición (Anual = 12); Único no se repite.</summary>
    public static int Months(this BillingCycle cycle) => cycle == BillingCycle.Anual ? 12 : cycle.SubscriptionMonths() ?? throw new ArgumentOutOfRangeException(nameof(cycle), "Un pago único no se repite.");
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
/// <summary>Categoría de gasto administrable desde Configuración. Las de sistema (con <see cref="Code"/>) no se borran.</summary>
public sealed class ExpenseCategory { public Guid Id { get; set; } = Guid.NewGuid(); public string Name { get; set; } = string.Empty; /// <summary>Nombre fijo de las categorías de sistema (los del antiguo enum): lo aceptan la importación de Excel y los scripts.</summary>
 public string? Code { get; set; } /// <summary>Pagos de Impuesto a la Renta a SUNAT: en los reportes se restan como impuestos, no como gasto operativo. El IGV pagado no se registra: se cobra al cliente y no es costo.</summary>
 public bool IsIncomeTax { get; set; } public int SortOrder { get; set; } }

/// <summary>Ids fijos de las categorías de sistema (sembradas por migración con los valores del antiguo enum).</summary>
public static class ExpenseCategoryIds
{
    public static readonly Guid Hosting = new("e0000000-0000-0000-0000-000000000000");
    public static readonly Guid Dominios = new("e0000000-0000-0000-0000-000000000001");
    public static readonly Guid SuscripcionesIA = new("e0000000-0000-0000-0000-000000000002");
    public static readonly Guid ApisPorUso = new("e0000000-0000-0000-0000-000000000003");
    public static readonly Guid Sueldos = new("e0000000-0000-0000-0000-000000000004");
    public static readonly Guid Otros = new("e0000000-0000-0000-0000-000000000005");
    public static readonly Guid ImpuestoRenta = new("e0000000-0000-0000-0000-000000000006");
    public static readonly Guid Comisiones = new("e0000000-0000-0000-0000-000000000007");

    public static IReadOnlyList<ExpenseCategory> Seed =>
    [
        new() { Id = Hosting, Code = "Hosting", Name = "Hosting", SortOrder = 0 },
        new() { Id = Dominios, Code = "Dominios", Name = "Dominios", SortOrder = 1 },
        new() { Id = SuscripcionesIA, Code = "SuscripcionesIA", Name = "Suscripciones IA", SortOrder = 2 },
        new() { Id = ApisPorUso, Code = "ApisPorUso", Name = "APIs por uso", SortOrder = 3 },
        new() { Id = Sueldos, Code = "Sueldos", Name = "Sueldos", SortOrder = 4 },
        new() { Id = Otros, Code = "Otros", Name = "Otros", SortOrder = 5 },
        new() { Id = ImpuestoRenta, Code = "ImpuestoRenta", Name = "Impuesto a la Renta", IsIncomeTax = true, SortOrder = 6 },
        new() { Id = Comisiones, Code = "Comisiones", Name = "Comisiones", SortOrder = 7 },
    ];
}

public enum PurchaseDocumentType { Factura, NotaCredito, NotaDebito, Boleta, ReciboPorHonorarios, Extranjero, Otro }

/// <summary>
/// Compra con comprobante (Registro de Compras). Si el comprobante discrimina IGV (factura, nota de débito/crédito) y la
/// compra se destina a operaciones gravadas, su IGV es crédito fiscal del periodo de anotación. Una nota de crédito resta.
/// Montos en la moneda del comprobante y su equivalente en PEN al tipo de cambio de la fecha de emisión.
/// </summary>
public sealed class Purchase
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateOnly IssueDate { get; set; }
    /// <summary>Primer día del mes en que se anota en el Registro de Compras (por defecto, el de emisión).</summary>
    public DateOnly Period { get; set; }
    public PurchaseDocumentType DocumentType { get; set; }
    public string Series { get; set; } = string.Empty;
    public string Number { get; set; } = string.Empty;
    public string SupplierTaxId { get; set; } = string.Empty;
    public string SupplierName { get; set; } = string.Empty;
    public string Currency { get; set; } = "PEN";
    public decimal TaxBase { get; set; }
    public decimal Igv { get; set; }
    /// <summary>Parte inafecta o exonerada del comprobante.</summary>
    public decimal NonTaxable { get; set; }
    public decimal Total { get; set; }
    public decimal ExchangeRate { get; set; } = 1m;
    public decimal BasePen { get; set; }
    public decimal IgvPen { get; set; }
    public decimal TotalPen { get; set; }
    public bool GivesTaxCredit { get; set; }
    /// <summary>Gasto creado junto con la compra, para no registrarla dos veces.</summary>
    public Guid? ExpenseId { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public static bool AllowsTaxCredit(PurchaseDocumentType type) => type is PurchaseDocumentType.Factura or PurchaseDocumentType.NotaCredito or PurchaseDocumentType.NotaDebito;
    /// <summary>Crédito fiscal en PEN con signo: la nota de crédito lo reduce.</summary>
    public decimal TaxCreditPen => GivesTaxCredit ? (DocumentType == PurchaseDocumentType.NotaCredito ? -IgvPen : IgvPen) : 0m;
}

/// <summary>Video de YouTube que se muestra en la página Recursos del sitio. Se administra desde el portal.</summary>
public sealed class LearningVideo { public Guid Id { get; set; } = Guid.NewGuid(); public string Title { get; set; } = string.Empty; public string YoutubeId { get; set; } = string.Empty; public string Category { get; set; } = string.Empty; /// <summary>es, en o it; null = se muestra en los tres idiomas del sitio.</summary>
 public string? Language { get; set; } public string? Description { get; set; } public int SortOrder { get; set; } public bool IsPublished { get; set; } = true; public DateTime CreatedAt { get; set; } = DateTime.UtcNow; }

/// <summary>Categoría del catálogo de productos. El producto guarda el nombre (lo usan la web y el catálogo); renombrarla actualiza sus productos.</summary>
public sealed class ProductCategory { public Guid Id { get; set; } = Guid.NewGuid(); public string Name { get; set; } = string.Empty; public int SortOrder { get; set; } }

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
    public Guid? ClientProductId { get; set; } public int? GithubIssueNumber { get; set; } public string? GithubIssueUrl { get; set; } /// <summary>Última columna "Status" vista en el GitHub Project del issue: el estado solo se aplica cuando esa columna cambia.</summary>
 public string? GithubProjectStatus { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; public DateTime UpdatedAt { get; set; } = DateTime.UtcNow; }
/// <summary>Archivo adjunto al crear el ticket. El contenido vive en la BD hasta subirse al repo del ticket; <see cref="Url"/> es su enlace en GitHub (vacío mientras no se sube).</summary>
public sealed class TicketAttachment { public Guid Id { get; set; } = Guid.NewGuid(); public Guid TicketId { get; set; } public string FileName { get; set; } = string.Empty; public string Url { get; set; } = string.Empty; public long SizeBytes { get; set; } public string ContentType { get; set; } = "application/octet-stream"; public byte[] Content { get; set; } = []; public DateTime CreatedAt { get; set; } = DateTime.UtcNow; public bool IsImage => ContentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase); }
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

public sealed class Expense { public Guid Id { get; set; } = Guid.NewGuid(); public string Description { get; set; } = string.Empty; public Guid CategoryId { get; set; } public ExpenseCategory? Category { get; set; } public ExpenseType Type { get; set; } public decimal Amount { get; set; } public string Currency { get; set; } = "PEN"; public decimal AmountPen { get; set; } public DateOnly Date { get; set; } public bool Recurring { get; set; } public BillingCycle? RecurrenceCycle { get; set; } /// <summary>Último pago de un gasto recurrente que se dio de baja; null = sigue vigente.</summary>
 public DateOnly? RecurrenceEndsAt { get; set; } }

/// <summary>Fila única (singleton): tasas de IGV/Renta configurables — el sistema no valida el régimen tributario real, solo aplica la tasa configurada.</summary>
public sealed class TaxSettings
{
    public Guid Id { get; set; } = Guid.NewGuid(); public decimal IgvRate { get; set; } = 0.18m; public decimal RentaRate { get; set; } = 0.10m; public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    // SUNAT numera cada tipo de comprobante por separado: una serie y su próximo correlativo por tipo. Factura y recibo
    // pueden compartir serie (E001 al emitir desde SUNAT SOL) sin que sus correlativos se mezclen.
    public string FacturaSeries { get; set; } = "F001"; public int FacturaNextNumber { get; set; } = 1;
    public string ReciboSeries { get; set; } = "E001"; public int ReciboNextNumber { get; set; } = 1;
    /// <summary>RUC de Rtres: su último dígito elige la columna del cronograma de vencimientos (<see cref="TaxDueDate"/>).</summary>
    public string? Ruc { get; set; } public bool IsGoodTaxpayer { get; set; }
}

/// <summary>
/// Fila del cronograma de obligaciones mensuales de SUNAT (IGV-Renta, PDT 621): un periodo tributario y su fecha de
/// vencimiento por último dígito del RUC, tal como la publica SUNAT cada diciembre. <see cref="FiledAt"/> marca que Rtres ya
/// declaró ese periodo y apaga los recordatorios.
/// </summary>
public sealed class TaxDueDate
{
    public Guid Id { get; set; } = Guid.NewGuid();
    /// <summary>Primer día del mes del periodo tributario (ej. 2026-09-01 = setiembre 2026).</summary>
    public DateOnly Period { get; set; }
    public DateOnly Digit0 { get; set; } public DateOnly Digit1 { get; set; } public DateOnly Digit2And3 { get; set; } public DateOnly Digit4And5 { get; set; } public DateOnly Digit6And7 { get; set; } public DateOnly Digit8And9 { get; set; }
    /// <summary>Buenos contribuyentes y UESP.</summary>
    public DateOnly GoodTaxpayer { get; set; }
    public DateTime? FiledAt { get; set; }

    /// <summary>Vencimiento que aplica a un RUC (por su último dígito) o a un buen contribuyente; null si el RUC no es válido.</summary>
    public DateOnly? DueFor(string? ruc, bool goodTaxpayer)
    {
        if (goodTaxpayer) return GoodTaxpayer;
        if (string.IsNullOrWhiteSpace(ruc) || !char.IsAsciiDigit(ruc.Trim()[^1])) return null;
        return (ruc.Trim()[^1] - '0') switch { 0 => Digit0, 1 => Digit1, 2 or 3 => Digit2And3, 4 or 5 => Digit4And5, 6 or 7 => Digit6And7, _ => Digit8And9 };
    }
}

/// <summary>
/// Cronograma 2026 de obligaciones mensuales (Anexo I de la R.S. N.º 000281-2022/SUNAT). Se siembra con la migración; los
/// años siguientes se cargan desde el portal cuando SUNAT los publique.
/// </summary>
public static class TaxDueDateSeed
{
    public static TaxDueDate[] Rows2026 => Rows(2026,
    [
        ("2026-02-16", "2026-02-17", "2026-02-18", "2026-02-19", "2026-02-20", "2026-02-23", "2026-02-24"),
        ("2026-03-16", "2026-03-17", "2026-03-18", "2026-03-19", "2026-03-20", "2026-03-23", "2026-03-24"),
        ("2026-04-17", "2026-04-20", "2026-04-21", "2026-04-22", "2026-04-23", "2026-04-24", "2026-04-27"),
        ("2026-05-18", "2026-05-19", "2026-05-20", "2026-05-21", "2026-05-22", "2026-05-25", "2026-05-26"),
        ("2026-06-15", "2026-06-16", "2026-06-17", "2026-06-18", "2026-06-19", "2026-06-22", "2026-06-23"),
        ("2026-07-15", "2026-07-16", "2026-07-17", "2026-07-20", "2026-07-21", "2026-07-22", "2026-07-24"),
        ("2026-08-18", "2026-08-19", "2026-08-20", "2026-08-21", "2026-08-24", "2026-08-25", "2026-08-26"),
        ("2026-09-15", "2026-09-16", "2026-09-17", "2026-09-18", "2026-09-21", "2026-09-22", "2026-09-23"),
        ("2026-10-16", "2026-10-19", "2026-10-20", "2026-10-21", "2026-10-22", "2026-10-23", "2026-10-26"),
        ("2026-11-16", "2026-11-17", "2026-11-18", "2026-11-19", "2026-11-20", "2026-11-23", "2026-11-24"),
        ("2026-12-17", "2026-12-18", "2026-12-21", "2026-12-22", "2026-12-23", "2026-12-24", "2026-12-28"),
        ("2027-01-18", "2027-01-19", "2027-01-20", "2027-01-21", "2027-01-22", "2027-01-25", "2027-01-26"),
    ]);

    private static TaxDueDate[] Rows(int year, (string, string, string, string, string, string, string)[] months) => months.Select((m, i) => new TaxDueDate
    {
        // Ids fijos: HasData los necesita estables entre migraciones.
        Id = new Guid($"7d000000-0000-0000-0000-{year:D4}{i + 1:D8}"), Period = new DateOnly(year, i + 1, 1),
        Digit0 = DateOnly.Parse(m.Item1), Digit1 = DateOnly.Parse(m.Item2), Digit2And3 = DateOnly.Parse(m.Item3), Digit4And5 = DateOnly.Parse(m.Item4),
        Digit6And7 = DateOnly.Parse(m.Item5), Digit8And9 = DateOnly.Parse(m.Item6), GoodTaxpayer = DateOnly.Parse(m.Item7),
    }).ToArray();
}

/// <summary>
/// Aviso de la campana del portal: uno por notificación (no por canal), con los mismos datos que el email.
/// <see cref="ForStaff"/>: avisos internos para Rtres (ticket nuevo, pedido por transferencia), no los ve el cliente.
/// </summary>
public sealed class PortalNotification { public Guid Id { get; set; } = Guid.NewGuid(); public Guid ClientId { get; set; } public string Type { get; set; } = string.Empty; public bool ForStaff { get; set; } public string DataJson { get; set; } = "{}"; public string? DedupeKey { get; set; } public DateTime CreatedAt { get; set; } = DateTime.UtcNow; }
