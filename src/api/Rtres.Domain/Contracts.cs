namespace Rtres.Domain;

public record WordPressPage(string Locale, string Slug, string Title, string Html, DateTimeOffset UpdatedAt);
public record WordPressProject(string Name, string Category, string? PhotoUrl);
public record WordPressReview(string Author, string Quote);
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
