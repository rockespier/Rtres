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

    /// <summary>Lista del blog (sin el contenido). Un post nuevo aparece aquí sin publicar el sitio; el caché dura 5 minutos.</summary>
    [HttpGet("{locale}/blog")]
    public async Task<ActionResult<IReadOnlyList<BlogPostSummaryDto>>> GetBlogPosts(string locale, CancellationToken cancellationToken)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        try { return Ok((await content.GetBlogPostsAsync(locale, cancellationToken)).Select(Summary).ToList()); }
        catch (HttpRequestException) { return StatusCode(StatusCodes.Status503ServiceUnavailable); }
    }

    [HttpGet("{locale}/blog/{slug}")]
    public async Task<ActionResult<BlogPostDto>> GetBlogPost(string locale, string slug, CancellationToken cancellationToken)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        IReadOnlyList<WordPressBlogPost> posts;
        try { posts = await content.GetBlogPostsAsync(locale, cancellationToken); }
        catch (HttpRequestException) { return StatusCode(StatusCodes.Status503ServiceUnavailable); }
        if (posts.FirstOrDefault(x => x.Slug == slug) is not { } post) return NotFound();
        // "Sigue leyendo": primero los del mismo tema; la lista ya viene del más reciente al más antiguo.
        var related = posts.Where(x => x.Slug != slug).OrderByDescending(x => post.Tag is not null && x.Tag == post.Tag).Take(2).Select(Summary).ToList();
        return Ok(new BlogPostDto(post.Slug, post.Title, post.Excerpt, post.Html, post.Tag, post.PublishedAt, post.UpdatedAt, post.ReadingMinutes, post.CoverUrl, post.CoverAlt, related));
    }

    private static BlogPostSummaryDto Summary(WordPressBlogPost x) => new(x.Slug, x.Title, x.Excerpt, x.Tag, x.PublishedAt, x.ReadingMinutes, x.CoverUrl, x.CoverAlt);

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
public sealed record BlogPostSummaryDto(string Slug, string Title, string Excerpt, string? Tag, DateTimeOffset PublishedAt, int ReadingMinutes, string? CoverUrl, string? CoverAlt);
public sealed record BlogPostDto(string Slug, string Title, string Excerpt, string Html, string? Tag, DateTimeOffset PublishedAt, DateTimeOffset UpdatedAt, int ReadingMinutes, string? CoverUrl, string? CoverAlt, IReadOnlyList<BlogPostSummaryDto> Related);
