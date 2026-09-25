using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Octokit;
using Rtres.Domain;

namespace Rtres.Infrastructure;

public sealed class WordPressContentClient(HttpClient httpClient) : IWordPressContentClient
{
    public async Task<WordPressPage?> GetPageAsync(string locale, string slug, CancellationToken cancellationToken = default)
    {
        var response = await httpClient.GetAsync($"wp-json/wp/v2/pages?slug={Uri.EscapeDataString(slug)}&lang={locale}", cancellationToken);
        if (!response.IsSuccessStatusCode) return null;
        using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync(cancellationToken));
        var page = json.RootElement.EnumerateArray().FirstOrDefault();
        if (page.ValueKind == JsonValueKind.Undefined) return null;
        return new WordPressPage(locale, slug, page.GetProperty("title").GetProperty("rendered").GetString() ?? slug,
            page.GetProperty("content").GetProperty("rendered").GetString() ?? string.Empty, DateTimeOffset.UtcNow);
    }
}

public sealed class PayPalClient(HttpClient httpClient, IConfiguration configuration) : IPayPalClient
{
    public async Task<PayPalCheckout> CreateOrderAsync(decimal amountUsd, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default)
    {
        var body = JsonSerializer.Serialize(new { intent = "CAPTURE", purchase_units = new[] { new { amount = new { currency_code = "USD", value = amountUsd.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture) } } }, application_context = new { return_url = returnUrl, cancel_url = cancelUrl } });
        return await CreateAsync("v2/checkout/orders", body, cancellationToken);
    }

    public async Task<PayPalCheckout> CreateSubscriptionAsync(string planId, string returnUrl, string cancelUrl, CancellationToken cancellationToken = default)
    {
        var body = JsonSerializer.Serialize(new { plan_id = planId, application_context = new { return_url = returnUrl, cancel_url = cancelUrl } });
        return await CreateAsync("v1/billing/subscriptions", body, cancellationToken);
    }

    public Task<bool> VerifyWebhookAsync(string payload, IReadOnlyDictionary<string, string> headers, CancellationToken cancellationToken = default)
        => Task.FromResult(headers.ContainsKey("paypal-transmission-id"));

    private async Task<PayPalCheckout> CreateAsync(string path, string body, CancellationToken cancellationToken)
    {
        using var request = new HttpRequestMessage(HttpMethod.Post, path) { Content = new StringContent(body, Encoding.UTF8, "application/json") };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", configuration["PayPal:AccessToken"]);
        using var response = await httpClient.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();
        using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync(cancellationToken));
        var approval = json.RootElement.GetProperty("links").EnumerateArray().First(x => x.GetProperty("rel").GetString() == "approve").GetProperty("href").GetString()!;
        return new PayPalCheckout(json.RootElement.GetProperty("id").GetString()!, approval);
    }
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
