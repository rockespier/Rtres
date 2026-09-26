namespace Rtres.Domain;

public record WordPressPage(string Locale, string Slug, string Title, string Html, DateTimeOffset UpdatedAt);
public record WordPressProject(string Name, string Category, string? PhotoUrl);
public record WordPressReview(string Author, string Quote);
public record PayPalCheckout(string Id, string ApprovalUrl);
public record GitHubIssue(int Number, string Url);

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
    Task<GitHubIssue> CreateIssueAsync(Project project, Ticket ticket, string clientSlug, CancellationToken cancellationToken = default);
}

public interface INotificationSender
{
    Task SendAsync(Client client, string template, object model, CancellationToken cancellationToken = default);
}
