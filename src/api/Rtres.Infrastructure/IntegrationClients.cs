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

    /// <summary>
    /// Captura (cobra) una orden que el cliente ya aprobó en PayPal. Es idempotente: se envía con
    /// <c>PayPal-Request-Id</c> fijo por orden, y si la orden ya estaba capturada se lee su captura existente.
    /// </summary>
    public async Task<PayPalCapture> CaptureOrderAsync(string orderId, CancellationToken cancellationToken = default)
    {
        var path = $"v2/checkout/orders/{Uri.EscapeDataString(orderId)}";
        using var request = new HttpRequestMessage(HttpMethod.Post, $"{path}/capture") { Content = new StringContent("{}", Encoding.UTF8, "application/json") };
        request.Headers.Add("PayPal-Request-Id", $"capture-{orderId}");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", await AccessTokenAsync(cancellationToken));
        using var response = await httpClient.SendAsync(request, cancellationToken);
        var body = await response.Content.ReadAsStringAsync(cancellationToken);
        if ((int)response.StatusCode == 422 && body.Contains("ORDER_ALREADY_CAPTURED", StringComparison.Ordinal))
        {
            using var existing = await SendAsync(new HttpRequestMessage(HttpMethod.Get, path), cancellationToken);
            body = await existing.Content.ReadAsStringAsync(cancellationToken);
        }
        else if (!response.IsSuccessStatusCode) throw new HttpRequestException($"PayPal no pudo capturar la orden {orderId}: {(int)response.StatusCode} {body}");
        return ParseCapture(orderId, body);
    }

    public static PayPalCapture ParseCapture(string orderId, string json)
    {
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;
        var status = root.TryGetProperty("status", out var orderStatus) ? orderStatus.GetString() ?? "" : "";
        if (root.TryGetProperty("purchase_units", out var units) && units.ValueKind == JsonValueKind.Array && units.GetArrayLength() > 0
            && units[0].TryGetProperty("payments", out var payments) && payments.TryGetProperty("captures", out var captures)
            && captures.ValueKind == JsonValueKind.Array && captures.GetArrayLength() > 0)
        {
            var capture = captures[0];
            decimal? amount = null; string? currency = null;
            if (capture.TryGetProperty("amount", out var value))
            {
                if (decimal.TryParse(value.GetProperty("value").GetString(), System.Globalization.NumberStyles.Number, System.Globalization.CultureInfo.InvariantCulture, out var parsed)) amount = parsed;
                currency = value.TryGetProperty("currency_code", out var code) ? code.GetString() : null;
            }
            return new PayPalCapture(orderId, capture.TryGetProperty("status", out var captureStatus) ? captureStatus.GetString() ?? status : status, amount, currency);
        }
        return new PayPalCapture(orderId, status, null, null);
    }

    public async Task<string> CreatePlanAsync(string name, decimal price, string currency, int intervalMonths, decimal? firstCyclePrice = null, CancellationToken cancellationToken = default)
    {
        using var productResponse = await SendAsync(new HttpRequestMessage(HttpMethod.Post, "v1/catalogs/products") { Content = JsonContent(new { name, type = "SERVICE" }) }, cancellationToken);
        using var product = JsonDocument.Parse(await productResponse.Content.ReadAsStringAsync(cancellationToken));
        var plan = new
        {
            product_id = product.RootElement.GetProperty("id").GetString(),
            name = intervalMonths == 1 ? $"{name} — mensual" : $"{name} — cada {intervalMonths} meses",
            // Con descuento, un ciclo TRIAL (un periodo) al precio rebajado y luego el precio regular.
            billing_cycles = firstCyclePrice is decimal first
                ? new[] { Cycle("TRIAL", 1, 1, first, currency, intervalMonths), Cycle("REGULAR", 2, 0, price, currency, intervalMonths) }
                : new[] { Cycle("REGULAR", 1, 0, price, currency, intervalMonths) },
            payment_preferences = new { auto_bill_outstanding = true, payment_failure_threshold = 3 },
        };
        using var planResponse = await SendAsync(new HttpRequestMessage(HttpMethod.Post, "v1/billing/plans") { Content = JsonContent(plan) }, cancellationToken);
        using var created = JsonDocument.Parse(await planResponse.Content.ReadAsStringAsync(cancellationToken));
        return created.RootElement.GetProperty("id").GetString()!;
    }

    private static object Cycle(string tenure, int sequence, int totalCycles, decimal price, string currency, int intervalMonths) =>
        new { frequency = new { interval_unit = "MONTH", interval_count = intervalMonths }, tenure_type = tenure, sequence, total_cycles = totalCycles, pricing_scheme = new { fixed_price = new { value = price.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture), currency_code = currency } } };

    public async Task<PayPalSubscriptionInfo> GetSubscriptionAsync(string subscriptionId, CancellationToken cancellationToken = default)
    {
        var path = $"v1/billing/subscriptions/{Uri.EscapeDataString(subscriptionId)}";
        using var response = await SendAsync(new HttpRequestMessage(HttpMethod.Get, path), cancellationToken);
        var subscriptionJson = await response.Content.ReadAsStringAsync(cancellationToken);
        var now = DateTime.UtcNow;
        var range = $"start_time={now.AddDays(-40):yyyy-MM-ddTHH:mm:ssZ}&end_time={now.AddMinutes(5):yyyy-MM-ddTHH:mm:ssZ}";
        using var transactions = await SendAsync(new HttpRequestMessage(HttpMethod.Get, $"{path}/transactions?{range}"), cancellationToken);
        return ParseSubscription(subscriptionJson, await transactions.Content.ReadAsStringAsync(cancellationToken));
    }

    public static PayPalSubscriptionInfo ParseSubscription(string subscriptionJson, string transactionsJson)
    {
        using var subscription = JsonDocument.Parse(subscriptionJson);
        var root = subscription.RootElement;
        DateTime? next = root.TryGetProperty("billing_info", out var billing) && billing.TryGetProperty("next_billing_time", out var time)
            && DateTime.TryParse(time.GetString(), System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.AdjustToUniversal, out var parsed) ? parsed : null;
        var payments = new List<PayPalSubscriptionPayment>();
        using var transactions = JsonDocument.Parse(transactionsJson);
        if (transactions.RootElement.TryGetProperty("transactions", out var list) && list.ValueKind == JsonValueKind.Array)
            foreach (var tx in list.EnumerateArray())
            {
                if (tx.TryGetProperty("status", out var status) && status.GetString() != "COMPLETED") continue;
                if (!tx.TryGetProperty("amount_with_breakdown", out var breakdown) || !breakdown.TryGetProperty("gross_amount", out var gross)) continue;
                if (!decimal.TryParse(gross.GetProperty("value").GetString(), System.Globalization.NumberStyles.Number, System.Globalization.CultureInfo.InvariantCulture, out var amount)) continue;
                payments.Add(new PayPalSubscriptionPayment(tx.GetProperty("id").GetString()!, amount, gross.GetProperty("currency_code").GetString() ?? "USD"));
            }
        return new PayPalSubscriptionInfo(root.GetProperty("id").GetString()!, root.GetProperty("status").GetString() ?? "", next, payments);
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

public sealed class GitHubIssuesClient(IConfiguration configuration, HttpClient http) : IGitHubIssuesClient
{
    private const int GraphQlBatch = 50;

    public async Task<IReadOnlyDictionary<int, GitHubIssueState>> GetIssueStatesAsync(ProjectRepository repository, IReadOnlyCollection<int> issueNumbers, CancellationToken cancellationToken = default)
    {
        var result = new Dictionary<int, GitHubIssueState>();
        foreach (var batch in issueNumbers.Distinct().Chunk(GraphQlBatch))
        {
            using var request = new HttpRequestMessage(HttpMethod.Post, "https://api.github.com/graphql") { Content = JsonContent(new { query = BuildStatesQuery(batch), variables = new { owner = repository.Owner, name = repository.Name } }) };
            request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", TokenFor(configuration, repository.Owner));
            request.Headers.UserAgent.ParseAdd("rtres-portal");
            using var response = await http.SendAsync(request, cancellationToken);
            response.EnsureSuccessStatusCode();
            using var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync(cancellationToken));
            foreach (var (number, state) in ParseStates(json.RootElement)) result[number] = state;
        }
        return result;
    }

    private static StringContent JsonContent<T>(T value) => new(JsonSerializer.Serialize(value), Encoding.UTF8, "application/json");

    /// <summary>Un alias por issue (<c>i{número}</c>) para leer hasta 50 en una sola consulta.</summary>
    public static string BuildStatesQuery(IEnumerable<int> numbers) =>
        "query($owner:String!,$name:String!){repository(owner:$owner,name:$name){" +
        string.Concat(numbers.Select(n => $"i{n}:issue(number:{n}){{state projectItems(first:10){{nodes{{fieldValueByName(name:\"Status\"){{... on ProjectV2ItemFieldSingleSelectValue{{name}}}}}}}}}}")) + "}}";

    /// <summary>
    /// Toma la primera columna "Status" que corresponda a un estado conocido. Los errores parciales de GraphQL (issue
    /// borrado, token sin permiso de Projects) dejan ese dato en null en vez de fallar todo el lote.
    /// </summary>
    public static IEnumerable<(int Number, GitHubIssueState State)> ParseStates(JsonElement root)
    {
        if (!root.TryGetProperty("data", out var data) || data.ValueKind != JsonValueKind.Object || !data.TryGetProperty("repository", out var repo) || repo.ValueKind != JsonValueKind.Object) yield break;
        foreach (var issue in repo.EnumerateObject())
        {
            if (issue.Value.ValueKind != JsonValueKind.Object || !int.TryParse(issue.Name.AsSpan(1), out var number)) continue;
            var closed = issue.Value.TryGetProperty("state", out var st) && st.GetString() == "CLOSED";
            var columns = issue.Value.TryGetProperty("projectItems", out var items) && items.ValueKind == JsonValueKind.Object
                ? items.GetProperty("nodes").EnumerateArray()
                    .Select(n => n.TryGetProperty("fieldValueByName", out var v) && v.ValueKind == JsonValueKind.Object && v.TryGetProperty("name", out var c) ? c.GetString() : null)
                    .Where(c => c is not null).ToList()
                : [];
            yield return (number, new GitHubIssueState(closed, columns.FirstOrDefault(c => GitHubProjectStatus.Map(c) is not null) ?? columns.FirstOrDefault()));
        }
    }

    public async Task<GitHubIssue> CreateIssueAsync(Rtres.Domain.Project project, ProjectRepository repository, Ticket ticket, IReadOnlyList<TicketAttachment> attachments, CancellationToken cancellationToken = default)
    {
        var newIssue = new NewIssue(BuildTitle(ticket)) { Body = BuildBody(ticket, attachments) };
        foreach (var label in BuildLabels(project, ticket)) newIssue.Labels.Add(label);
        var issue = await Client(repository.Owner).Issue.Create(repository.Owner, repository.Name, newIssue);
        return new GitHubIssue(issue.Number, issue.HtmlUrl);
    }

    public async Task<long> CreateCommentAsync(ProjectRepository repository, int issueNumber, string body, CancellationToken cancellationToken = default)
        => (await Client(repository.Owner).Issue.Comment.Create(repository.Owner, repository.Name, issueNumber, body)).Id;

    public async Task<string> UploadFileAsync(ProjectRepository repository, string path, byte[] content, string message, CancellationToken cancellationToken = default)
    {
        var result = await Client(repository.Owner).Repository.Content.CreateFile(repository.Owner, repository.Name, path, new CreateFileRequest(message, Convert.ToBase64String(content), convertContentToBase64: false));
        // ?raw=true: el issue muestra la imagen incluso en repos privados (GitHub la sirve con la sesión del lector).
        return result.Content.HtmlUrl + "?raw=true";
    }

    /// <summary>Ruta del adjunto en el repo: carpeta por ticket y el id delante para que dos archivos con el mismo nombre no choquen.</summary>
    public static string AttachmentPath(Ticket ticket, TicketAttachment attachment)
    {
        var name = string.Concat(attachment.FileName.Select(c => char.IsAsciiLetterOrDigit(c) || c is '.' or '-' or '_' ? c : '-')).Trim('-');
        return $".rtres/attachments/{ticket.Code}/{attachment.Id.ToString("N")[..8]}-{(name.Length == 0 ? "archivo" : name)}";
    }

    public static string BuildCommentBody(TicketComment comment, string authorName) =>
        $"**{authorName}** (vía portal de clientes):\n\n{comment.Body.Trim()}\n\n{GitHubLabels.PortalCommentMarker}{comment.Id} -->";

    private GitHubClient Client(string owner) =>
        new(new Octokit.ProductHeaderValue("rtres-portal")) { Credentials = new Credentials(TokenFor(configuration, owner)) };

    /// <summary>
    /// Un token fine-grained solo cubre un resource owner (usuario u organización): se busca en <c>GitHub:Tokens:{owner}</c>
    /// y, si no hay, se usa <c>GitHub:Token</c>. Las claves de configuración no distinguen mayúsculas, igual que GitHub.
    /// </summary>
    public static string TokenFor(IConfiguration configuration, string owner)
    {
        var token = configuration[$"GitHub:Tokens:{owner}"];
        if (string.IsNullOrWhiteSpace(token)) token = configuration["GitHub:Token"];
        if (string.IsNullOrWhiteSpace(token)) throw new InvalidOperationException($"No hay token de GitHub para '{owner}': configura GitHub:Tokens:{owner} o GitHub:Token.");
        return token;
    }

    public static string BuildTitle(Ticket ticket) => $"[{ticket.Code}] {ticket.Title}";

    public static IReadOnlyList<string> BuildLabels(Rtres.Domain.Project project, Ticket ticket) =>
        [GitHubLabels.ForType(ticket.Type), GitHubLabels.ForStatus(ticket.Status), GitHubLabels.ForProject(project.Slug)];

    public static string BuildBody(Ticket ticket, IReadOnlyList<TicketAttachment>? attachments = null)
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
        var uploaded = (attachments ?? []).Where(x => x.Url.Length > 0).ToList();
        if (uploaded.Count > 0)
        {
            body.AppendLine().AppendLine("### Adjuntos");
            foreach (var a in uploaded) body.AppendLine().AppendLine(a.IsImage ? $"![{a.FileName}]({a.Url})" : $"- [{a.FileName}]({a.Url})");
        }
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
