namespace Rtres.Domain;

public record WordPressPage(string Locale, string Slug, string Title, string Html, DateTimeOffset UpdatedAt);
public record WordPressProject(string Name, string Category, string? PhotoUrl);
public record WordPressReview(string Author, string Quote);
public record PayPalCheckout(string Id, string ApprovalUrl);
public record GitHubIssue(int Number, string Url);
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
    Task CancelSubscriptionAsync(string subscriptionId, string reason, CancellationToken cancellationToken = default);
    Task<bool> VerifyWebhookAsync(string payload, IReadOnlyDictionary<string, string> headers, CancellationToken cancellationToken = default);
}

public interface IGitHubIssuesClient
{
    Task<GitHubIssue> CreateIssueAsync(Project project, Ticket ticket, CancellationToken cancellationToken = default);
    Task<long> CreateCommentAsync(Project project, int issueNumber, string body, CancellationToken cancellationToken = default);
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
