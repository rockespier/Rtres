using System.Globalization;
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
    public async Task<GitHubIssue> CreateIssueAsync(Rtres.Domain.Project project, Ticket ticket, CancellationToken cancellationToken = default)
    {
        var newIssue = new NewIssue(BuildTitle(ticket)) { Body = BuildBody(ticket) };
        foreach (var label in BuildLabels(project, ticket)) newIssue.Labels.Add(label);
        var issue = await Client().Issue.Create(project.GithubRepoOwner, project.GithubRepoName, newIssue);
        return new GitHubIssue(issue.Number, issue.HtmlUrl);
    }

    public async Task<long> CreateCommentAsync(Rtres.Domain.Project project, int issueNumber, string body, CancellationToken cancellationToken = default)
        => (await Client().Issue.Comment.Create(project.GithubRepoOwner, project.GithubRepoName, issueNumber, body)).Id;

    public static string BuildCommentBody(TicketComment comment, string authorName) =>
        $"**{authorName}** (vía portal de clientes):\n\n{comment.Body.Trim()}\n\n{GitHubLabels.PortalCommentMarker}{comment.Id} -->";

    private GitHubClient Client()
    {
        var token = configuration["GitHub:Token"];
        if (string.IsNullOrWhiteSpace(token)) throw new InvalidOperationException("GitHub:Token no está configurado.");
        return new GitHubClient(new Octokit.ProductHeaderValue("rtres-portal")) { Credentials = new Credentials(token) };
    }

    public static string BuildTitle(Ticket ticket) => $"[{ticket.Code}] {ticket.Title}";

    public static IReadOnlyList<string> BuildLabels(Rtres.Domain.Project project, Ticket ticket) =>
        [GitHubLabels.ForType(ticket.Type), GitHubLabels.ForStatus(ticket.Status), GitHubLabels.ForProject(project.Slug)];

    public static string BuildBody(Ticket ticket)
    {
        var body = new StringBuilder();
        body.Append("> Ticket **").Append(ticket.Code).Append("** creado desde el portal de clientes (")
            .Append(ticket.Type switch { TicketType.Bug => "bug", TicketType.Funcionalidad => "funcionalidad", _ => "requerimiento" }).AppendLine(").");
        Section(body, "Descripción", ticket.Description);
        Section(body, "Comportamiento actual", ticket.CurrentBehavior);
        Section(body, "Comportamiento esperado", ticket.ExpectedBehavior);
        Section(body, "Pasos para reproducir", ticket.StepsToReproduce);
        Section(body, "Entorno", ticket.Environment);
        Section(body, "Criterios de aceptación", ticket.AcceptanceCriteria);
        if (ticket.Type != TicketType.Bug) Section(body, "Impacto estimado", ticket.EstimatedImpact);
        return body.ToString();
    }

    private static void Section(StringBuilder body, string heading, string? content)
    {
        if (string.IsNullOrWhiteSpace(content)) return;
        body.AppendLine().Append("## ").AppendLine(heading).AppendLine(content.Trim());
    }
}

/// <summary>USD: TXT público de SUNAT (fecha|compra|venta). EUR: API pública del BCRP, serie PD04648PD (TC Euro venta) — ver T7.0 en el PLAN.</summary>
public sealed class ExchangeRateClient(HttpClient httpClient) : IExchangeRateClient
{
    private static readonly Dictionary<string, int> SpanishMonths = new(StringComparer.OrdinalIgnoreCase)
    { ["Ene"] = 1, ["Feb"] = 2, ["Mar"] = 3, ["Abr"] = 4, ["May"] = 5, ["Jun"] = 6, ["Jul"] = 7, ["Ago"] = 8, ["Set"] = 9, ["Oct"] = 10, ["Nov"] = 11, ["Dic"] = 12 };

    public async Task<ExchangeRateQuote?> GetUsdAsync(CancellationToken cancellationToken = default)
    {
        var text = await httpClient.GetStringAsync("https://www.sunat.gob.pe/a/txt/tipoCambio.txt", cancellationToken);
        var fields = text.Trim().Split('|', StringSplitOptions.RemoveEmptyEntries);
        if (fields.Length < 3 || !DateOnly.TryParseExact(fields[0], "dd/MM/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out var date)
            || !decimal.TryParse(fields[2], NumberStyles.Number, CultureInfo.InvariantCulture, out var venta)) return null;
        return new ExchangeRateQuote(date, venta, "SUNAT");
    }

    public async Task<ExchangeRateQuote?> GetEurAsync(CancellationToken cancellationToken = default)
    {
        var end = DateOnly.FromDateTime(DateTime.UtcNow);
        var start = end.AddDays(-10);
        var url = $"https://estadisticas.bcrp.gob.pe/estadisticas/series/api/PD04648PD/json/{start:yyyy-MM-dd}/{end:yyyy-MM-dd}";
        using var response = await httpClient.GetAsync(url, cancellationToken);
        if (!response.IsSuccessStatusCode) return null;
        // El WAF del BCRP (Imperva) a veces inyecta HTML extra tras el JSON válido; nos quedamos solo con el objeto balanceado.
        using var json = JsonDocument.Parse(ExtractJsonObject(await response.Content.ReadAsStringAsync(cancellationToken)));
        if (!json.RootElement.TryGetProperty("periods", out var periods)) return null;
        foreach (var period in periods.EnumerateArray().Reverse())
        {
            var value = period.GetProperty("values")[0].GetString();
            if (string.IsNullOrWhiteSpace(value) || value == "n.d." || !decimal.TryParse(value, NumberStyles.Number, CultureInfo.InvariantCulture, out var rate)) continue;
            var parts = (period.GetProperty("name").GetString() ?? "").Split('.');
            if (parts.Length != 3 || !int.TryParse(parts[0], out var day) || !SpanishMonths.TryGetValue(parts[1], out var month) || !int.TryParse(parts[2], out var yy)) continue;
            return new ExchangeRateQuote(new DateOnly(2000 + yy, month, day), rate, "BCRP");
        }
        return null;
    }

    private static string ExtractJsonObject(string body)
    {
        var start = body.IndexOf('{');
        if (start < 0) return body;
        var depth = 0;
        for (var i = start; i < body.Length; i++)
        {
            if (body[i] == '{') depth++;
            else if (body[i] == '}' && --depth == 0) return body[start..(i + 1)];
        }
        return body[start..];
    }
}
