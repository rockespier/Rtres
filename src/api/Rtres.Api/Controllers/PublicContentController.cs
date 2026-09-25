using Microsoft.AspNetCore.Mvc;
using Rtres.Domain;

namespace Rtres.Api.Controllers;

[ApiController, Route("api/public/{locale}/pages")]
public sealed class PublicContentController(IWordPressContentClient content) : ControllerBase
{
    [HttpGet("{slug}")]
    public async Task<ActionResult<WordPressPage>> Get(string locale, string slug, CancellationToken cancellationToken)
    {
        if (locale is not ("es" or "en" or "it")) return NotFound();
        return await content.GetPageAsync(locale, slug, cancellationToken) is { } page ? Ok(page) : NotFound();
    }
}
