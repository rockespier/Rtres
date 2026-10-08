using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rtres.Api.Controllers;

namespace Rtres.Api.Tests;

public class LearningVideosTests
{
    [Theory]
    [InlineData("https://www.youtube.com/watch?v=dQw4w9WgXcQ", "dQw4w9WgXcQ")]
    [InlineData("https://youtube.com/watch?feature=share&v=dQw4w9WgXcQ&t=30", "dQw4w9WgXcQ")]
    [InlineData("https://youtu.be/dQw4w9WgXcQ?si=abc", "dQw4w9WgXcQ")]
    [InlineData("youtube.com/shorts/dQw4w9WgXcQ", "dQw4w9WgXcQ")]
    [InlineData("https://www.youtube.com/embed/dQw4w9WgXcQ", "dQw4w9WgXcQ")]
    [InlineData("dQw4w9WgXcQ", "dQw4w9WgXcQ")]
    [InlineData("https://vimeo.com/123456", null)]
    [InlineData("https://www.youtube.com/watch?v=corto", null)]
    [InlineData("", null)]
    public void Youtube_links_are_parsed(string input, string? expected) => Assert.Equal(expected, LearningVideosController.ParseYoutubeId(input));

    [Fact]
    public async Task Site_gets_only_published_videos_of_its_language_or_for_all()
    {
        using var db = TestData.Db(out _);
        var videos = new LearningVideosController(db);
        Assert.IsType<CreatedResult>(await videos.Create(new LearningVideoRequest("https://youtu.be/aaaaaaaaaaa", "Marca personal", "Marca personal", "es", null), CancellationToken.None));
        Assert.IsType<CreatedResult>(await videos.Create(new LearningVideoRequest("bbbbbbbbbbb", "Habits", "Disciplina y hábitos", "en", null), CancellationToken.None));
        Assert.IsType<CreatedResult>(await videos.Create(new LearningVideoRequest("ccccccccccc", "Para todos", "Negocios", null, null), CancellationToken.None));
        Assert.IsType<CreatedResult>(await videos.Create(new LearningVideoRequest("ddddddddddd", "Borrador", "Negocios", "es", null, IsPublished: false), CancellationToken.None));
        Assert.IsType<ConflictObjectResult>(await videos.Create(new LearningVideoRequest("https://www.youtube.com/watch?v=aaaaaaaaaaa", "Repetido", "X", null, null), CancellationToken.None));
        Assert.IsType<BadRequestObjectResult>(await videos.Create(new LearningVideoRequest("https://vimeo.com/1", "X", "X", null, null), CancellationToken.None));

        var es = Assert.IsAssignableFrom<IEnumerable<PublicVideoDto>>(Assert.IsType<OkObjectResult>(await videos.PublicVideos("es", CancellationToken.None)).Value);
        Assert.Equal(["aaaaaaaaaaa", "ccccccccccc"], es.Select(x => x.YoutubeId));
        Assert.IsType<NotFoundResult>(await videos.PublicVideos("fr", CancellationToken.None));

        var ids = await db.LearningVideos.OrderByDescending(x => x.YoutubeId).Select(x => x.Id).ToListAsync();
        Assert.IsType<NoContentResult>(await videos.Reorder(ids, CancellationToken.None));
        es = Assert.IsAssignableFrom<IEnumerable<PublicVideoDto>>(Assert.IsType<OkObjectResult>(await videos.PublicVideos("es", CancellationToken.None)).Value);
        Assert.Equal(["ccccccccccc", "aaaaaaaaaaa"], es.Select(x => x.YoutubeId));
    }
}
