using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Controllers;

/// <summary>Videos de la página Recursos: el portal los administra y el sitio lee los publicados de su idioma.</summary>
[ApiController]
public sealed partial class LearningVideosController(RtresDbContext db) : ControllerBase
{
    [HttpGet("api/public/{locale}/videos")]
    public async Task<ActionResult> PublicVideos(string locale, CancellationToken ct)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        return Ok(await db.LearningVideos.Where(x => x.IsPublished && (x.Language == null || x.Language == locale))
            .OrderBy(x => x.SortOrder).ThenByDescending(x => x.CreatedAt)
            .Select(x => new PublicVideoDto(x.YoutubeId, x.Title, x.Category, x.Description)).ToListAsync(ct));
    }

    [HttpGet("api/admin/learning-videos"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> List(CancellationToken ct) =>
        Ok(await db.LearningVideos.OrderBy(x => x.SortOrder).ThenByDescending(x => x.CreatedAt).Select(x => ToDto(x)).ToListAsync(ct));

    [HttpPost("api/admin/learning-videos"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Create(LearningVideoRequest request, CancellationToken ct)
    {
        var video = new LearningVideo { SortOrder = await db.LearningVideos.CountAsync(ct) };
        if (Apply(video, request) is { } error) return BadRequest(new { message = error });
        if (await db.LearningVideos.AnyAsync(x => x.YoutubeId == video.YoutubeId, ct)) return Conflict(new { message = "Ese video ya está en la lista." });
        db.LearningVideos.Add(video); await db.SaveChangesAsync(ct);
        return Created($"/api/admin/learning-videos/{video.Id}", ToDto(video));
    }

    [HttpPut("api/admin/learning-videos/{id:guid}"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Update(Guid id, LearningVideoRequest request, CancellationToken ct)
    {
        var video = await db.LearningVideos.FindAsync([id], ct); if (video is null) return NotFound();
        if (Apply(video, request) is { } error) return BadRequest(new { message = error });
        if (await db.LearningVideos.AnyAsync(x => x.Id != id && x.YoutubeId == video.YoutubeId, ct)) return Conflict(new { message = "Ese video ya está en la lista." });
        await db.SaveChangesAsync(ct); return Ok(ToDto(video));
    }

    [HttpDelete("api/admin/learning-videos/{id:guid}"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Delete(Guid id, CancellationToken ct)
    {
        var video = await db.LearningVideos.FindAsync([id], ct); if (video is null) return NotFound();
        db.LearningVideos.Remove(video); await db.SaveChangesAsync(ct); return NoContent();
    }

    /// <summary>Nuevo orden de la lista: los ids en el orden en que deben mostrarse.</summary>
    [HttpPost("api/admin/learning-videos/reorder"), Authorize(Roles = "SuperAdmin")]
    public async Task<ActionResult> Reorder(IReadOnlyList<Guid> ids, CancellationToken ct)
    {
        var videos = await db.LearningVideos.ToListAsync(ct);
        foreach (var v in videos) v.SortOrder = ids.Contains(v.Id) ? ids.ToList().IndexOf(v.Id) : ids.Count + v.SortOrder;
        await db.SaveChangesAsync(ct); return NoContent();
    }

    private static string? Apply(LearningVideo video, LearningVideoRequest r)
    {
        if (ParseYoutubeId(r.Url) is not { } youtubeId) return "Pega el enlace de un video de YouTube (ej. https://www.youtube.com/watch?v=…).";
        if (string.IsNullOrWhiteSpace(r.Title)) return "El título es obligatorio.";
        if (string.IsNullOrWhiteSpace(r.Category)) return "La categoría es obligatoria.";
        var language = string.IsNullOrWhiteSpace(r.Language) ? null : r.Language.Trim().ToLowerInvariant();
        if (language is not (null or "es" or "en" or "it")) return "Idioma inválido: es, en, it o vacío para todos.";
        video.YoutubeId = youtubeId; video.Title = r.Title.Trim(); video.Category = r.Category.Trim(); video.Language = language;
        video.Description = string.IsNullOrWhiteSpace(r.Description) ? null : r.Description.Trim(); video.IsPublished = r.IsPublished;
        return null;
    }

    /// <summary>Acepta youtube.com/watch?v=, youtu.be/, /embed/, /shorts/, /live/ o el id de 11 caracteres solo.</summary>
    public static string? ParseYoutubeId(string? input)
    {
        if (string.IsNullOrWhiteSpace(input)) return null;
        var value = input.Trim();
        if (YoutubeIdRegex().IsMatch(value)) return value;
        var match = YoutubeUrlRegex().Match(value);
        return match.Success ? match.Groups["id"].Value : null;
    }

    [GeneratedRegex("^[A-Za-z0-9_-]{11}$")]
    private static partial Regex YoutubeIdRegex();

    [GeneratedRegex(@"^(?:https?://)?(?:www\.|m\.|music\.)?(?:youtube\.com/(?:watch\?(?:.*&)?v=|embed/|shorts/|live/)|youtu\.be/)(?<id>[A-Za-z0-9_-]{11})(?:[?&#/].*)?$", RegexOptions.IgnoreCase)]
    private static partial Regex YoutubeUrlRegex();

    private static LearningVideoDto ToDto(LearningVideo x) => new(x.Id, x.YoutubeId, x.Title, x.Category, x.Language, x.Description, x.SortOrder, x.IsPublished);
}

public sealed record LearningVideoRequest(string Url, string Title, string Category, string? Language, string? Description, bool IsPublished = true);
public sealed record LearningVideoDto(Guid Id, string YoutubeId, string Title, string Category, string? Language, string? Description, int SortOrder, bool IsPublished);
public sealed record PublicVideoDto(string YoutubeId, string Title, string Category, string? Description);
