using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

[ApiController, Route("api/public")]
public sealed class PublicContentController(IWordPressContentClient content, RtresDbContext db) : ControllerBase
{
    [HttpGet("{locale}/pages/{slug}")]
    public async Task<ActionResult<WordPressPage>> GetPage(string locale, string slug, CancellationToken cancellationToken)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        return await content.GetPageAsync(locale, slug, cancellationToken) is { } page ? Ok(page) : NotFound();
    }

    [HttpGet("{locale}/projects")]
    public async Task<ActionResult<IReadOnlyList<WordPressProject>>> GetProjects(string locale, CancellationToken cancellationToken)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        return Ok(await content.GetProjectsAsync(locale, cancellationToken));
    }

    [HttpGet("{locale}/reviews")]
    public async Task<ActionResult<IReadOnlyList<WordPressReview>>> GetReviews(string locale, CancellationToken cancellationToken)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        return Ok(await content.GetReviewsAsync(locale, cancellationToken));
    }

    [HttpGet("hero-photo")]
    public async Task<ActionResult> GetHeroPhoto(CancellationToken cancellationToken)
    {
        var url = await content.GetHeroPhotoUrlAsync(cancellationToken);
        return url is null ? NotFound() : Ok(new { url });
    }

    /// <summary>Cifras del sitio (Quiénes somos): clientes activos registrados en el portal. Solo el total, sin datos de nadie.</summary>
    [HttpGet("stats")]
    public async Task<ActionResult<PublicStatsDto>> GetStats(CancellationToken cancellationToken) =>
        Ok(new PublicStatsDto(await db.Clients.CountAsync(x => x.IsActive, cancellationToken)));
}

public sealed record PublicStatsDto(int ActiveClients);
