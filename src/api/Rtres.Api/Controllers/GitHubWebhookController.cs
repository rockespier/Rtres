using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Rtres.Api.GitHub;
using Rtres.Domain;

namespace Rtres.Api.Controllers;

[ApiController, Route("api/webhooks/github")]
public sealed class GitHubWebhookController(GitHubWebhookProcessor processor, IConfiguration configuration, ILogger<GitHubWebhookController> logger) : ControllerBase
{
    [HttpPost]
    public async Task<ActionResult> Receive([FromHeader(Name = "X-GitHub-Event")] string? eventName, [FromHeader(Name = "X-Hub-Signature-256")] string? signature, CancellationToken ct)
    {
        using var buffer = new MemoryStream();
        await Request.Body.CopyToAsync(buffer, ct);
        var body = buffer.ToArray();
        var secret = configuration["GitHub:WebhookSecret"] ?? string.Empty;
        if (!GitHubWebhookSignature.IsValid(secret, body, signature))
        {
            logger.LogWarning("Webhook de GitHub rechazado: firma inválida o GitHub:WebhookSecret sin configurar");
            return Unauthorized();
        }

        if (eventName == "ping") return Ok();
        using var payload = JsonDocument.Parse(body);
        await processor.ProcessAsync(eventName ?? "", payload.RootElement, ct);
        return Ok();
    }
}
