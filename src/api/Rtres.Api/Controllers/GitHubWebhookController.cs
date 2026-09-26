using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Rtres.Api.GitHub;
using Rtres.Domain;

namespace Rtres.Api.Controllers;

[ApiController, Route("api/webhooks/github")]
public sealed class GitHubWebhookController(GitHubWebhookProcessor processor, IConfiguration configuration, ILogger<GitHubWebhookController> logger) : ControllerBase
{
    [HttpPost]
    public async Task<ActionResult> Receive(CancellationToken ct)
    {
        using var buffer = new MemoryStream();
        await Request.Body.CopyToAsync(buffer, ct);
        var body = buffer.ToArray();
        var secret = configuration["GitHub:WebhookSecret"] ?? string.Empty;
        if (!GitHubWebhookSignature.IsValid(secret, body, Request.Headers["X-Hub-Signature-256"]))
        {
            logger.LogWarning("Webhook de GitHub rechazado: firma inválida o GitHub:WebhookSecret sin configurar");
            return Unauthorized();
        }

        var eventName = Request.Headers["X-GitHub-Event"].ToString();
        if (eventName == "ping") return Ok();
        using var payload = JsonDocument.Parse(body);
        await processor.ProcessAsync(eventName, payload.RootElement, ct);
        return Ok();
    }
}
