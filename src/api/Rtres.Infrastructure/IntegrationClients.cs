using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Octokit;
using Rtres.Domain;

namespace Rtres.Infrastructure;

public sealed class WordPressContentClient(HttpClient httpClient, IMemoryCache cache) : IWordPressContentClient
{
    private static readonly TimeSpan CacheTtl = TimeSpan.FromMinutes(5);

    public async Task<WordPressPage?> GetPageAsync(string locale, string slug, CancellationToken cancellationToken = default)
    {
        return await cache.GetOrCreateAsync($"wp:page:{locale}:{slug}", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheTtl;
            var response = await httpClient.GetAsync($"wp-json/wp/v2/pages?slug={Uri.EscapeDataString(slug)}&lang={locale}", cancellationToken);
            if (!response.IsSuccessStatusCode) return null;
            using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync(cancellationToken));
            var page = json.RootElement.EnumerateArray().FirstOrDefault();
            if (page.ValueKind == JsonValueKind.Undefined) return null;
            return new WordPressPage(locale, slug, page.GetProperty("title").GetProperty("rendered").GetString() ?? slug,
                page.GetProperty("content").GetProperty("rendered").GetString() ?? string.Empty, DateTimeOffset.UtcNow);
        });
    }

    public async Task<IReadOnlyList<WordPressProject>> GetProjectsAsync(string locale, CancellationToken cancellationToken = default)
    {
        return await cache.GetOrCreateAsync($"wp:projects:{locale}", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheTtl;
            var posts = await GetPostsByCategorySlugAsync($"proyectos-{locale}", cancellationToken);
            return (IReadOnlyList<WordPressProject>)posts.Select(p => new WordPressProject(p.Title, p.Text, p.PhotoUrl)).ToList();
        }) ?? [];
    }

    public async Task<IReadOnlyList<WordPressReview>> GetReviewsAsync(string locale, CancellationToken cancellationToken = default)
    {
        return await cache.GetOrCreateAsync($"wp:reviews:{locale}", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheTtl;
            var posts = await GetPostsByCategorySlugAsync($"resenas-{locale}", cancellationToken, useContentAsText: true);
            return (IReadOnlyList<WordPressReview>)posts.Select(p => new WordPressReview(p.Title, p.Text)).ToList();
        }) ?? [];
    }

    public async Task<string?> GetHeroPhotoUrlAsync(CancellationToken cancellationToken = default)
    {
        return await cache.GetOrCreateAsync("wp:hero-photo", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = CacheTtl;
            return await FetchHeroPhotoUrlAsync(cancellationToken);
        });
    }

    private async Task<string?> FetchHeroPhotoUrlAsync(CancellationToken cancellationToken)
    {
        var response = await httpClient.GetAsync("wp-json/wp/v2/pages?slug=hero&_embed", cancellationToken);
        if (!response.IsSuccessStatusCode) return null;
        using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync(cancellationToken));
        var page = json.RootElement.EnumerateArray().FirstOrDefault();
        if (page.ValueKind == JsonValueKind.Undefined) return null;
        return ExtractFeaturedMediaUrl(page);
    }

    private async Task<List<(string Title, string Text, string? PhotoUrl)>> GetPostsByCategorySlugAsync(string categorySlug, CancellationToken cancellationToken, bool useContentAsText = false)
    {
        var catResponse = await httpClient.GetAsync($"wp-json/wp/v2/categories?slug={Uri.EscapeDataString(categorySlug)}", cancellationToken);
        var catBody = await catResponse.Content.ReadAsStringAsync(cancellationToken);
        if (!catResponse.IsSuccessStatusCode) return [];
        using var catJson = JsonDocument.Parse(catBody);
        var category = catJson.RootElement.EnumerateArray().FirstOrDefault();
        if (category.ValueKind == JsonValueKind.Undefined) return [];
        var categoryId = category.GetProperty("id").GetInt32();

        var postsResponse = await httpClient.GetAsync($"wp-json/wp/v2/posts?categories={categoryId}&_embed&per_page=50&orderby=date&order=asc", cancellationToken);
        if (!postsResponse.IsSuccessStatusCode) return [];
        using var postsJson = JsonDocument.Parse(await postsResponse.Content.ReadAsStringAsync(cancellationToken));

        var result = new List<(string, string, string?)>();
        foreach (var post in postsJson.RootElement.EnumerateArray())
        {
            var title = post.GetProperty("title").GetProperty("rendered").GetString() ?? "";
            var text = useContentAsText
                ? StripHtml(post.GetProperty("content").GetProperty("rendered").GetString() ?? "")
                : StripHtml(post.GetProperty("excerpt").GetProperty("rendered").GetString() ?? "");
            result.Add((title, text, ExtractFeaturedMediaUrl(post)));
        }
        return result;
    }

    private static string? ExtractFeaturedMediaUrl(JsonElement post)
    {
        if (!post.TryGetProperty("_embedded", out var embedded)) return null;
        if (!embedded.TryGetProperty("wp:featuredmedia", out var media)) return null;
        var first = media.EnumerateArray().FirstOrDefault();
        if (first.ValueKind == JsonValueKind.Undefined) return null;
        return first.TryGetProperty("source_url", out var url) ? url.GetString() : null;
    }

    private static string StripHtml(string html) => System.Text.RegularExpressions.Regex.Replace(html, "<.*?>", "").Trim();
}

public sealed class PayPalClient(HttpClient httpClient, IConfiguration configuration) : IPayPalClient
{
    public async Task<PayPalCheckout> CreateOrderAsync(decimal amount, string currency, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default)
    {
        var body = JsonSerializer.Serialize(new { intent = "CAPTURE", purchase_units = new[] { new { custom_id = customId, amount = new { currency_code = currency, value = amount.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture) } } }, application_context = new { return_url = returnUrl, cancel_url = cancelUrl, user_action = "PAY_NOW" } });
        return await CreateAsync("v2/checkout/orders", body, cancellationToken);
    }

    public async Task<PayPalCheckout> CreateSubscriptionAsync(string planId, string customId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default)
    {
        var body = JsonSerializer.Serialize(new { plan_id = planId, custom_id = customId, application_context = new { return_url = returnUrl, cancel_url = cancelUrl, user_action = "SUBSCRIBE_NOW" } });
        return await CreateAsync("v1/billing/subscriptions", body, cancellationToken);
    }

    public async Task CancelSubscriptionAsync(string subscriptionId, string reason, CancellationToken cancellationToken = default)
    {
        await SendAsync(new HttpRequestMessage(HttpMethod.Post, $"v1/billing/subscriptions/{Uri.EscapeDataString(subscriptionId)}/cancel") { Content = JsonContent(new { reason }) }, cancellationToken);
    }

    public async Task<bool> VerifyWebhookAsync(string payload, IReadOnlyDictionary<string, string> headers, CancellationToken cancellationToken = default)
    {
        var required = new[] { "paypal-auth-algo", "paypal-cert-url", "paypal-transmission-id", "paypal-transmission-sig", "paypal-transmission-time" };
        if (required.Any(key => !headers.ContainsKey(key)) || string.IsNullOrWhiteSpace(configuration["PayPal:WebhookId"])) return false;
        using var request = new HttpRequestMessage(HttpMethod.Post, "v1/notifications/verify-webhook-signature") { Content = JsonContent(new { auth_algo = headers["paypal-auth-algo"], cert_url = headers["paypal-cert-url"], transmission_id = headers["paypal-transmission-id"], transmission_sig = headers["paypal-transmission-sig"], transmission_time = headers["paypal-transmission-time"], webhook_id = configuration["PayPal:WebhookId"], webhook_event = JsonDocument.Parse(payload).RootElement }) };
        using var response = await SendAsync(request, cancellationToken);
        using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync(cancellationToken));
        return json.RootElement.TryGetProperty("verification_status", out var status) && status.GetString() == "SUCCESS";
    }

    private async Task<PayPalCheckout> CreateAsync(string path, string body, CancellationToken cancellationToken)
    {
        using var request = new HttpRequestMessage(HttpMethod.Post, path) { Content = new StringContent(body, Encoding.UTF8, "application/json") };
        using var response = await SendAsync(request, cancellationToken);
        using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync(cancellationToken));
        var approval = json.RootElement.GetProperty("links").EnumerateArray().First(x => x.GetProperty("rel").GetString() == "approve").GetProperty("href").GetString()!;
        return new PayPalCheckout(json.RootElement.GetProperty("id").GetString()!, approval);
    }

    private async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", await AccessTokenAsync(cancellationToken));
        var response = await httpClient.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();
        return response;
    }

    private async Task<string> AccessTokenAsync(CancellationToken cancellationToken)
    {
        var clientId = configuration["PayPal:ClientId"];
        var secret = configuration["PayPal:Secret"];
        if (string.IsNullOrWhiteSpace(clientId) || string.IsNullOrWhiteSpace(secret)) throw new InvalidOperationException("PayPal:ClientId y PayPal:Secret son obligatorios.");
        using var request = new HttpRequestMessage(HttpMethod.Post, "v1/oauth2/token") { Content = new FormUrlEncodedContent(new[] { new KeyValuePair<string, string>("grant_type", "client_credentials") }) };
        request.Headers.Authorization = new AuthenticationHeaderValue("Basic", Convert.ToBase64String(Encoding.UTF8.GetBytes($"{clientId}:{secret}")));
        using var response = await httpClient.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();
        using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync(cancellationToken));
        return json.RootElement.GetProperty("access_token").GetString()!;
    }

    private static StringContent JsonContent<T>(T value) => new(JsonSerializer.Serialize(value), Encoding.UTF8, "application/json");
}

public sealed class GitHubIssuesClient(IConfiguration configuration) : IGitHubIssuesClient
{
    public async Task<GitHubIssue> CreateIssueAsync(Rtres.Domain.Project project, Ticket ticket, string clientSlug, CancellationToken cancellationToken = default)
    {
        var client = new GitHubClient(new Octokit.ProductHeaderValue("rtres-portal")) { Credentials = new Credentials(configuration["GitHub:Token"]) };
        var body = $"## Descripción\n{ticket.Description}\n\n## Comportamiento actual\n{ticket.CurrentBehavior}\n\n## Comportamiento esperado\n{ticket.ExpectedBehavior}\n\n## Pasos para reproducir\n{ticket.StepsToReproduce}\n\n## Entorno\n{ticket.Environment}\n\n## Criterios de aceptación\n{ticket.AcceptanceCriteria}\n\n## Impacto estimado\n{ticket.EstimatedImpact ?? "No aplica"}";
        var issue = await client.Issue.Create(project.GithubRepoOwner, project.GithubRepoName, new NewIssue(ticket.Title) { Body = body, Labels = { ticket.Type == TicketType.Soporte ? "ticket-soporte" : "ticket-cambio", $"cliente:{clientSlug}" } });
        return new GitHubIssue(issue.Number, issue.HtmlUrl);
    }
}

public sealed class LoggingNotificationSender(ILogger<LoggingNotificationSender> logger) : INotificationSender
{
    public Task SendAsync(Client client, string template, object model, CancellationToken cancellationToken = default)
    {
        logger.LogInformation("Notification {Template} queued for {Email} ({Language})", template, client.Email, client.PreferredLanguage);
        return Task.CompletedTask;
    }
}
