�
=C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\BankTransfers.cs�namespace Rtres.Domain;

public enum BankAccountType { Ahorros, Corriente }

/// <summary>Cuenta de Rtres donde los clientes pagan por transferencia. Inactiva = no se muestra a los clientes.</summary>
public sealed class BankAccount
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string BankName { get; set; } = string.Empty;
    /// <summary>Titular que verá el cliente (razón social o nombre).</summary>
    public string Holder { get; set; } = string.Empty;
    /// <summary>PEN, USD o EUR.</summary>
    public string Currency { get; set; } = "PEN";
    public BankAccountType Type { get; set; }
    public string AccountNumber { get; set; } = string.Empty;
    /// <summary>Código de cuenta interbancario (CCI, 20 dígitos en Perú). Opcional: las cuentas del exterior no lo tienen.</summary>
    public string? Cci { get; set; }
    public bool IsActive { get; set; } = true;
    public int SortOrder { get; set; }
}

/// <summary>Fila única (singleton): qué medios de pago puede usar el cliente en el portal.</summary>
public sealed class PaymentSettings
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public bool PayPalEnabled { get; set; } = true;
    public bool BankTransferEnabled { get; set; } = true;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public enum TransferReportStatus { Pendiente, Aprobado, Rechazado }

/// <summary>
/// Pago por transferencia que reporta el cliente (N° de operación y/o foto de la constancia). Rtres lo revisa: al aprobarlo
/// se registra el cobro (<see cref="PaymentTransaction"/>) y se activa o renueva el producto; al rechazarlo se avisa el motivo.
/// </summary>
public sealed class TransferReport
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ClientId { get; set; }
    public Guid ClientProductId { get; set; }
    public Guid? BankAccountId { get; set; }
    public decimal Amount { get; set; }
    /// <summary>Moneda de lo transferido (la de la cuenta de destino).</summary>
    public string Currency { get; set; } = "PEN";
    public DateOnly PaidAt { get; set; }
    public string? OperationNumber { get; set; }
    public int Years { get; set; } = 1;
    public string? ReceiptFileName { get; set; }
    public string? ReceiptContentType { get; set; }
    public byte[]? ReceiptContent { get; set; }
    public TransferReportStatus Status { get; set; }
    public string? RejectionReason { get; set; }
    public Guid? ReportedByUserId { get; set; }
    public Guid? ReviewedByUserId { get; set; }
    public DateTime? ReviewedAt { get; set; }
    public Guid? PaymentTransactionId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

/// <summary>Último reporte de transferencia de un producto, para la tarjeta de "Mis servicios".</summary>
public sealed record TransferReportSummary(Guid Id, TransferReportStatus Status, DateTime CreatedAt, string? RejectionReason);
ParseOptions.0.json�9
DC:\repo\rtres-net\Rtres\src\api\Rtres.Domain\ClientProductPricing.cs�9namespace Rtres.Domain;

/// <summary>
/// Precio de un producto de cliente. El precio de lista es el del catálogo (así se estandariza); un cliente con un
/// precio menor lleva un descuento de monto fijo que cubre un solo periodo: al renovar se cobra el precio del catálogo.
/// <see cref="ClientProduct.DiscountEndsAt"/> en null = el descuento aún no se usó (se aplica al próximo cobro);
/// con fecha = cubre el periodo pagado que termina en esa fecha, y el próximo cobro ya es la renovación sin descuento.
/// Un <see cref="ClientProduct.Discount"/> negativo es un recargo: sube el precio con el mismo ciclo de vida, pero siempre
/// entra en el próximo cobro (un periodo ya pagado no se puede encarecer).
/// </summary>
public static class ClientProductPricing
{
    /// <summary>Periodo sin fecha de fin (pago único sin vencimiento o manual sin fecha): el descuento no expira por tiempo.</summary>
    public static readonly DateTime NoEnd = new(9999, 12, 31, 0, 0, 0, DateTimeKind.Utc);

    /// <summary>Precio del catálogo; el precio propio del cliente solo cuenta si el producto no tiene precio de catálogo.</summary>
    public static decimal? ListPrice(this ClientProduct item, Product? product = null) => (product ?? item.Product)?.BasePrice ?? item.Price;

    private static bool HasAdjustment(this ClientProduct item) => item.Discount is not (null or 0m);

    public static bool DiscountPendingUse(this ClientProduct item) => item.HasAdjustment() && item.DiscountEndsAt is null;

    /// <summary>Lo que se cobrará en el próximo pago: con descuento solo si todavía no se usó; si no, precio de lista.</summary>
    public static decimal? NextChargePrice(this ClientProduct item, Product? product = null) =>
        item.ListPrice(product) is decimal list ? list - (item.DiscountPendingUse() ? item.Discount!.Value : 0m) : null;

    /// <summary>
    /// IGV que se suma al cobro. Los precios del catálogo y los descuentos son sin IGV: solo se agrega cuando el producto
    /// emite Factura y el cliente requiere comprobante (Perú). Exterior (exportación de servicios) y Recibo por honorarios: 0.
    /// </summary>
    public static decimal IgvRateFor(Client client, Product product, decimal igvRate) =>
        client.RequiresTaxDocument && product.TaxDocumentType == TaxDocumentType.Factura ? igvRate : 0m;

    public static decimal WithIgv(decimal net, decimal igvRate) => Math.Round(net * (1 + igvRate), 2);

    /// <summary>Monto a cobrar en el próximo pago, con IGV si corresponde (<paramref name="igvRate"/> de <see cref="IgvRateFor"/>).</summary>
    public static decimal? NextChargeTotal(this ClientProduct item, decimal igvRate, Product? product = null) =>
        item.NextChargePrice(product) is decimal net ? WithIgv(net, igvRate) : null;

    public const int MaxPrepaidYears = 5;

    /// <summary>
    /// Monto a cobrar por <paramref name="years"/> años de un producto anual pagados de una vez: el descuento (si aún no
    /// se usó) solo rebaja el primer año, los siguientes van a precio de catálogo; el IGV se aplica al total.
    /// </summary>
    public static decimal? ChargeTotal(this ClientProduct item, decimal igvRate, int years, Product? product = null) =>
        item.NextChargePrice(product) is decimal first && item.ListPrice(product) is decimal list ? WithIgv(first + (years - 1) * list, igvRate) : null;

    /// <summary>Error si no se pueden pagar <paramref name="years"/> años de una vez (solo productos anuales, hasta <see cref="MaxPrepaidYears"/>).</summary>
    public static string? ValidateYears(this ClientProduct item, int years) =>
        years < 1 || years > MaxPrepaidYears ? $"Se pueden pagar de 1 a {MaxPrepaidYears} años."
        : years > 1 && item.BillingCycle != BillingCycle.Anual ? "Solo los productos anuales se pueden pagar por varios años." : null;

    /// <summary>Precio vigente del periodo actual (lo que muestra el portal).</summary>
    public static decimal? CurrentPrice(this ClientProduct item, DateTime now, Product? product = null) =>
        item.ListPrice(product) is decimal list ? list - (item.HasAdjustment() && (item.DiscountEndsAt is null || now < item.DiscountEndsAt) ? item.Discount!.Value : 0m) : null;

    /// <summary>
    /// Fija (o quita, con null/0) el descuento. Si el producto ya tiene un periodo pagado (no está Pendiente), el
    /// descuento cubre ese periodo y termina con él; si está Pendiente, se aplica al primer cobro. Un valor negativo es un
    /// recargo: siempre queda para el próximo cobro. Devuelve el error de validación.
    /// </summary>
    public static string? SetDiscount(this ClientProduct item, decimal? discount, Product? product = null)
    {
        if (discount is null or 0) { item.Discount = null; item.DiscountEndsAt = null; return null; }
        if (item.ListPrice(product) is not decimal list) return "El producto no tiene precio: no se le puede aplicar un descuento ni un recargo.";
        if (discount > list) return $"El descuento no puede superar el precio del catálogo ({list:0.00}).";
        // PayPal cobra solo el precio del plan: en una suscripción en curso el recargo nunca llegaría al cobro.
        if (discount < 0 && !string.IsNullOrWhiteSpace(item.PayPalSubscriptionId) && item.Status is not (ClientProductStatus.Pendiente or ClientProductStatus.Cancelado))
            return "El producto tiene una suscripción de PayPal en curso: su precio no se puede subir con un recargo.";
        item.Discount = Math.Round(discount.Value, 2);
        item.DiscountEndsAt = discount < 0 || item.Status == ClientProductStatus.Pendiente ? null : item.PeriodEnd() ?? NoEnd;
        return null;
    }

    /// <summary>
    /// Tras aplicar un pago (con la vigencia ya extendida): si el descuento estaba pendiente, ese pago lo usó y cubre el
    /// periodo recién pagado; si ya se había usado, este pago es la renovación a precio de lista y el descuento se quita.
    /// </summary>
    public static void OnPaymentApplied(this ClientProduct item)
    {
        if (!item.HasAdjustment()) return;
        if (item.DiscountEndsAt is null) item.DiscountEndsAt = item.PeriodEnd() ?? NoEnd;
        else { item.Discount = null; item.DiscountEndsAt = null; }
    }

    /// <summary>
    /// Deshace <see cref="OnPaymentApplied"/> al extornar un pago: si ese pago usó el descuento (terminaba con el periodo
    /// pagado, <paramref name="paidPeriodEnd"/>), vuelve a quedar pendiente de uso. Si el pago lo había quitado no se repone:
    /// ya estaba usado y el próximo cobro es a precio de lista de todos modos.
    /// </summary>
    public static void OnPaymentReversed(this ClientProduct item, DateTime? paidPeriodEnd)
    {
        if (item.HasAdjustment() && (item.DiscountEndsAt == NoEnd || item.DiscountEndsAt == paidPeriodEnd)) item.DiscountEndsAt = null;
    }

    /// <summary>Si el descuento cubría un periodo sin fecha y ahora se le pone una, termina con esa fecha.</summary>
    public static void OnDatesChanged(this ClientProduct item)
    {
        if (item.DiscountEndsAt == NoEnd && item.PeriodEnd() is DateTime end) item.DiscountEndsAt = end;
    }

    private static DateTime? PeriodEnd(this ClientProduct item) => item.BillingCycle.IsSubscription() ? item.NextChargeAt : item.RenewsAt;
}
ParseOptions.0.json�
<C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\ContactLeads.cs�namespace Rtres.Domain;

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
ParseOptions.0.json�+
9C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\Contracts.cs�+namespace Rtres.Domain;

public record WordPressPage(string Locale, string Slug, string Title, string Html, DateTimeOffset UpdatedAt);
public record WordPressProject(string Name, string Category, string? PhotoUrl);
public record WordPressReview(string Author, string Quote);
/// <summary>Artículo del blog. <c>Html</c> es el contenido de WordPress sin sanear: el sitio lo sanea al mostrarlo.</summary>
public record WordPressBlogPost(string Slug, string Title, string Excerpt, string Html, string? Tag, DateTimeOffset PublishedAt, DateTimeOffset UpdatedAt, int ReadingMinutes, string? CoverUrl, string? CoverAlt);
public record PayPalCheckout(string Id, string ApprovalUrl);
/// <summary>Resultado de capturar una orden aprobada. <c>Status</c> es el de la captura: COMPLETED, PENDING, DECLINED…</summary>
public record PayPalCapture(string OrderId, string Status, decimal? Amount, string? Currency);
public record PayPalSubscriptionPayment(string Id, decimal Amount, string Currency);
/// <summary>Estado de una suscripción (ACTIVE, APPROVAL_PENDING, CANCELLED…) y sus cobros completados.</summary>
public record PayPalSubscriptionInfo(string Id, string Status, DateTime? NextBillingTime, IReadOnlyList<PayPalSubscriptionPayment> Payments);
public record GitHubIssue(int Number, string Url);
/// <summary>Estado de un issue y la columna "Status" de los GitHub Projects donde está (null si no está en ninguno o el token no puede leerlos).</summary>
public record GitHubIssueState(bool Closed, string? ProjectStatus);
public record ExchangeRateQuote(DateOnly Date, decimal RateToPen, string Source);

public interface IWordPressContentClient
{
    Task<WordPressPage?> GetPageAsync(string locale, string slug, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<WordPressProject>> GetProjectsAsync(string locale, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<WordPressReview>> GetReviewsAsync(string locale, CancellationToken cancellationToken = default);
    /// <summary>Artículos publicados del idioma, del más reciente al más antiguo. Lanza <see cref="HttpRequestException"/> si WordPress falla y no hay una copia anterior.</summary>
    Task<IReadOnlyList<WordPressBlogPost>> GetBlogPostsAsync(string locale, CancellationToken cancellationToken = default);
    Task<string?> GetHeroPhotoUrlAsync(CancellationToken cancellationToken = default);
}

public interface IPayPalClient
{
    Task<PayPalCheckout> CreateOrderAsync(decimal amount, string currency, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default);
    Task<PayPalCheckout> CreateSubscriptionAsync(string planId, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default);
    Task<PayPalCapture> CaptureOrderAsync(string orderId, CancellationToken cancellationToken = default);
    /// <summary>Crea en PayPal un producto de catálogo y un plan de cobro mensual a precio fijo; devuelve el id del plan.</summary>
    /// <summary>Plan mensual; con <paramref name="firstCyclePrice"/> el primer mes se cobra a ese precio y los siguientes a <paramref name="price"/>.</summary>
    /// <summary>Plan de suscripción que cobra cada <paramref name="intervalMonths"/> meses; con <paramref name="firstCyclePrice"/>, el primer cobro va a ese precio.</summary>
    Task<string> CreatePlanAsync(string name, decimal price, string currency, int intervalMonths, decimal? firstCyclePrice = null, CancellationToken cancellationToken = default);
    Task<PayPalSubscriptionInfo> GetSubscriptionAsync(string subscriptionId, CancellationToken cancellationToken = default);
    Task CancelSubscriptionAsync(string subscriptionId, string reason, CancellationToken cancellationToken = default);
    Task<bool> VerifyWebhookAsync(string payload, IReadOnlyDictionary<string, string> headers, CancellationToken cancellationToken = default);
}

public interface IGitHubIssuesClient
{
    Task<GitHubIssue> CreateIssueAsync(Project project, ProjectRepository repository, Ticket ticket, IReadOnlyList<TicketAttachment> attachments, CancellationToken cancellationToken = default);
    /// <summary>Sube un archivo al repo (rama por defecto) y devuelve una URL que GitHub muestra a quien tenga acceso al repo.</summary>
    /// <summary>Lee en bloque (GraphQL) el estado y la columna del proyecto de los issues indicados; los que no existen no aparecen.</summary>
    Task<IReadOnlyDictionary<int, GitHubIssueState>> GetIssueStatesAsync(ProjectRepository repository, IReadOnlyCollection<int> issueNumbers, CancellationToken cancellationToken = default);
    Task<string> UploadFileAsync(ProjectRepository repository, string path, byte[] content, string message, CancellationToken cancellationToken = default);
    Task<long> CreateCommentAsync(ProjectRepository repository, int issueNumber, string body, CancellationToken cancellationToken = default);
}

/// <summary>USD desde el tipo de cambio oficial de SUNAT, EUR desde el BCRP — ver T7.0 en el PLAN para el detalle de cada fuente.</summary>
public interface IExchangeRateClient
{
    Task<ExchangeRateQuote?> GetUsdAsync(CancellationToken cancellationToken = default);
    Task<ExchangeRateQuote?> GetEurAsync(CancellationToken cancellationToken = default);
}

public interface INotificationSender
{
    Task SendAsync(Client client, Notification notification, CancellationToken cancellationToken = default);
}
ParseOptions.0.json��
8C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\Entities.cs��namespace Rtres.Domain;

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
 public bool IsIncomeTax { get; set; } public int SortOrder { get; set; }
    /// <summary>Se resta de la utilidad en la Renta anual. Las de <see cref="IsIncomeTax"/> nunca lo son.</summary>
    public bool IsDeductible { get; set; } = true; }

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
    public decimal? AppliedIgvRate { get; set; }
    /// <summary>No se guarda: último pago por transferencia reportado por el cliente (en revisión o rechazado), para la tarjeta.</summary>
    public TransferReportSummary? TransferReport { get; set; } }
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

/// <summary>
/// Constancia de un extorno: un pago y/o comprobante registrados por error se eliminan y aquí queda qué se borró, por qué y
/// quién lo hizo. Además evita que PayPal (webhook o conciliación) vuelva a crear un cobro extornado: ver <see cref="PaymentKey"/>.
/// </summary>
public sealed class PaymentReversal { public Guid Id { get; set; } = Guid.NewGuid(); public Guid ClientId { get; set; } public Guid? ClientProductId { get; set; } /// <summary>Identificador del cobro eliminado; null si el comprobante no tenía cobro.</summary>
    public string? PaymentKey { get; set; } public string? Method { get; set; } public string? InternalCode { get; set; } public decimal Amount { get; set; } public string Currency { get; set; } = "PEN"; public decimal? AmountPen { get; set; } public DateTime? PaidAt { get; set; }
    public TaxDocumentType DocumentType { get; set; } public string Series { get; set; } = string.Empty; public int Number { get; set; } public DateOnly IssueDate { get; set; }
    public string Reason { get; set; } = string.Empty; /// <summary>El usuario indicó que el comprobante no llegó a emitirse en SUNAT.</summary>
    public bool NotIssued { get; set; } public bool NumberReleased { get; set; } public Guid? ReversedByUserId { get; set; } public DateTime ReversedAt { get; set; } = DateTime.UtcNow; }

/// <summary>Producto del cliente incluido en un comprobante. <see cref="Amount"/> es lo cobrado por esa línea en la moneda del documento (con IGV en facturas).</summary>
public sealed class TaxDocumentLine { public Guid Id { get; set; } = Guid.NewGuid(); public Guid TaxDocumentId { get; set; } public Guid? ClientProductId { get; set; } public string Description { get; set; } = string.Empty; public decimal Amount { get; set; } public int Order { get; set; } }

public sealed class Expense { public Guid Id { get; set; } = Guid.NewGuid(); public string Description { get; set; } = string.Empty; public Guid CategoryId { get; set; } public ExpenseCategory? Category { get; set; } public ExpenseType Type { get; set; } public decimal Amount { get; set; } public string Currency { get; set; } = "PEN"; public decimal AmountPen { get; set; } public DateOnly Date { get; set; } public bool Recurring { get; set; } public BillingCycle? RecurrenceCycle { get; set; } /// <summary>Último pago de un gasto recurrente que se dio de baja; null = sigue vigente.</summary>
 public DateOnly? RecurrenceEndsAt { get; set; }
    /// <summary>No se resta en la Renta anual aunque su categoría sea deducible (p. ej. cuotas de deuda con SUNAT o un préstamo).</summary>
    public bool IsNonDeductible { get; set; }
    /// <summary>Servicio de un proveedor no domiciliado (OpenAI, Anthropic, Google…): su IGV se paga con el Formulario 1662 (tributo 1041).</summary>
    public bool IsNonDomiciledService { get; set; } public string? ForeignSupplierName { get; set; } public string? ForeignSupplierCountry { get; set; }
    /// <summary>Fecha y N° de orden del Formulario 1662 pagado; null = aún no se pagó.</summary>
    public DateOnly? Form1662PaidAt { get; set; } public string? Form1662Number { get; set; } }

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
    /// <summary>Suma el IGV pagado con el Formulario 1662 al crédito fiscal del mes en que se pagó. Apagado mientras no se declare el 1662.</summary>
    public bool Use1662AsCredit { get; set; }
}

/// <summary>
/// Parámetros de la Renta anual del Régimen MYPE Tributario para un ejercicio: UIT del año y tasas por tramo (10 % hasta
/// 15 UIT de renta neta, 29.5 % por el exceso). Los ingresa el usuario: el sistema no asume valores oficiales.
/// </summary>
public sealed class AnnualTaxSettings
{
    public Guid Id { get; set; } = Guid.NewGuid(); public int Year { get; set; } public decimal Uit { get; set; }
    public decimal ThresholdUits { get; set; } = 15m; public decimal LowRate { get; set; } = 0.10m; public decimal HighRate { get; set; } = 0.295m;
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
    /// <summary>Lo realmente pagado al presentar (en soles); null = no se registró y los reportes usan el estimado.</summary>
    public decimal? IgvPaid { get; set; } public decimal? RentaPaid { get; set; }

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
ParseOptions.0.json�)
:C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\GitHubSync.cs�(using System.Security.Cryptography;
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

/// <summary>Columnas del campo "Status" de un GitHub Project → estado del ticket. Acepta los nombres en español del tablero y los por defecto de GitHub.</summary>
public static class GitHubProjectStatus
{
    private static readonly Dictionary<string, TicketStatus> Columns = new()
    {
        ["recibido"] = TicketStatus.Abierto, ["abierto"] = TicketStatus.Abierto, ["todo"] = TicketStatus.Abierto, ["to do"] = TicketStatus.Abierto, ["backlog"] = TicketStatus.Abierto,
        ["en progreso"] = TicketStatus.EnProgreso, ["in progress"] = TicketStatus.EnProgreso,
        ["resuelto"] = TicketStatus.Resuelto, ["done"] = TicketStatus.Resuelto,
        ["publicado"] = TicketStatus.Publicado, ["published"] = TicketStatus.Publicado,
        ["cerrado"] = TicketStatus.Cerrado, ["closed"] = TicketStatus.Cerrado,
    };

    /// <summary>Sin distinguir mayúsculas ni tildes; columnas desconocidas → null (no cambian el ticket).</summary>
    public static TicketStatus? Map(string? column)
    {
        if (string.IsNullOrWhiteSpace(column)) return null;
        var plain = new string(column.Trim().ToLowerInvariant().Normalize(System.Text.NormalizationForm.FormD)
            .Where(c => System.Globalization.CharUnicodeInfo.GetUnicodeCategory(c) != System.Globalization.UnicodeCategory.NonSpacingMark).ToArray());
        return Columns.TryGetValue(plain, out var status) ? status : null;
    }

    /// <summary>
    /// Estado a aplicar cuando la columna cambió. Un issue cerrado no vuelve a un estado de trabajo en curso por una columna
    /// atrasada: el cierre ya lo aplicó el webhook.
    /// </summary>
    public static TicketStatus? Resolve(GitHubIssueState state) =>
        Map(state.ProjectStatus) is { } status && (!state.Closed || status >= TicketStatus.Resuelto) ? status : null;
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
ParseOptions.0.json�
9C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\IncomeTax.cs�namespace Rtres.Domain;

/// <summary>Impuesto a la Renta anual del Régimen MYPE Tributario, por tramos de la renta neta imponible.</summary>
public sealed record MypeIncomeTax(decimal Limit, decimal LowBase, decimal LowTax, decimal HighBase, decimal HighTax)
{
    public decimal Total => LowTax + HighTax;

    /// <summary>
    /// Tramo 1: la renta neta hasta <see cref="AnnualTaxSettings.ThresholdUits"/> UIT paga <see cref="AnnualTaxSettings.LowRate"/>;
    /// tramo 2: solo el exceso paga <see cref="AnnualTaxSettings.HighRate"/>. Sin utilidad (o con pérdida) no hay impuesto.
    /// </summary>
    public static MypeIncomeTax Compute(decimal netIncome, AnnualTaxSettings settings)
    {
        var limit = settings.ThresholdUits * settings.Uit;
        var taxable = Math.Max(netIncome, 0m);
        var low = Math.Min(taxable, limit); var high = Math.Max(taxable - limit, 0m);
        return new MypeIncomeTax(limit, low, Math.Round(low * settings.LowRate, 2), high, Math.Round(high * settings.HighRate, 2));
    }
}

public static class Form1662
{
    /// <summary>
    /// IGV por utilización de servicios de no domiciliados: la tasa del IGV sobre el monto en soles. El monto en soles del
    /// gasto ya usa el tipo de cambio venta de SUNAT de la fecha del pago (el más cercano si ese día no hay).
    /// </summary>
    public static decimal Igv(Expense expense, decimal igvRate) => Math.Round(expense.AmountPen * igvRate, 2);
}
ParseOptions.0.json�	
=C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\Notifications.cs�namespace Rtres.Domain;

/// <summary><see cref="TransferRequested"/> es un aviso interno para Rtres (no para el cliente).</summary>
public enum NotificationType { RenewalReminder, TicketStatusChanged, TicketReply, PaymentReceived, PaymentFailed, AccountAccess, TransferRequested, TicketCreated, TaxDueReminder, TransferReported, TransferRejected, ContactLead }

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
ParseOptions.0.json�
]C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\obj\Debug\net10.0\Rtres.Domain.GlobalUsings.g.cs�// <auto-generated/>
global using System;
global using System.Collections.Generic;
global using System.IO;
global using System.Linq;
global using System.Net.Http;
global using System.Threading;
global using System.Threading.Tasks;
ParseOptions.0.json�
nC:\repo\rtres-net\Rtres\src\api\Rtres.Domain\obj\Debug\net10.0\.NETCoreApp,Version=v10.0.AssemblyAttributes.cs�// <autogenerated />
using System;
using System.Reflection;
[assembly: global::System.Runtime.Versioning.TargetFrameworkAttribute(".NETCoreApp,Version=v10.0", FrameworkDisplayName = ".NET 10.0")]
ParseOptions.0.json�
[C:\repo\rtres-net\Rtres\src\api\Rtres.Domain\obj\Debug\net10.0\Rtres.Domain.AssemblyInfo.cs�//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Reflection;

[assembly: System.Reflection.AssemblyCompanyAttribute("Rtres.Domain")]
[assembly: System.Reflection.AssemblyConfigurationAttribute("Debug")]
[assembly: System.Reflection.AssemblyFileVersionAttribute("1.0.0.0")]
[assembly: System.Reflection.AssemblyInformationalVersionAttribute("1.0.0+aaa6dd32d60330ac2233cef8fc8e5ea18d10aca9")]
[assembly: System.Reflection.AssemblyProductAttribute("Rtres.Domain")]
[assembly: System.Reflection.AssemblyTitleAttribute("Rtres.Domain")]
[assembly: System.Reflection.AssemblyVersionAttribute("1.0.0.0")]

// Generated by the MSBuild WriteCodeFragment class.

ParseOptions.0.json