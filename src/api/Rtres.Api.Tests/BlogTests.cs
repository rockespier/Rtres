using System.Net;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Options;
using Rtres.Api.Controllers;
using Rtres.Domain;
using Rtres.Infrastructure;

namespace Rtres.Api.Tests;

public class BlogTests
{
    private static string Post(string slug, string tag = "Software") => $$$"""
        {"slug":"{{{slug}}}","date_gmt":"2026-11-04T15:00:00","modified_gmt":"2026-11-05T16:30:00",
         "title":{"rendered":"Qu&eacute; revisar &#8211; hosting"},
         "excerpt":{"rendered":"<p>Copias y certificados [&hellip;]</p>\n"},
         "content":{"rendered":"<p>{{{string.Join(' ', Enumerable.Repeat("palabra", 450))}}}</p>","protected":false},
         "_embedded":{"wp:featuredmedia":[{"source_url":"https://web.rtres.net/a.jpg","alt_text":"Servidores"}],
           "wp:term":[[{"taxonomy":"category","name":"blog-es"}],[{"taxonomy":"post_tag","name":"{{{tag}}}"}]]}}
        """;

    [Fact]
    public void WordPress_post_is_mapped_to_a_blog_post()
    {
        using var json = JsonDocument.Parse(Post("revisar-hosting", "Hosting &amp; dominios"));
        var post = WordPressContentClient.ParseBlogPost(json.RootElement)!;
        Assert.Equal("revisar-hosting", post.Slug);
        Assert.Equal("Qué revisar – hosting", post.Title);
        Assert.Equal("Copias y certificados…", post.Excerpt);
        Assert.Equal("Hosting & dominios", post.Tag);
        Assert.Equal(new DateTimeOffset(2026, 11, 4, 15, 0, 0, TimeSpan.Zero), post.PublishedAt);
        Assert.Equal(3, post.ReadingMinutes);
        Assert.Equal("https://web.rtres.net/a.jpg", post.CoverUrl);
        Assert.Equal("Servidores", post.CoverAlt);
    }

    [Fact]
    public void Password_protected_posts_are_not_published()
    {
        using var json = JsonDocument.Parse("""{"content":{"rendered":"","protected":true}}""");
        Assert.Null(WordPressContentClient.ParseBlogPost(json.RootElement));
    }

    [Fact]
    public async Task Client_reads_every_page_of_the_category_of_the_language()
    {
        var client = Client(new FakeWordPress(request => request.RequestUri!.PathAndQuery switch
        {
            var q when q.Contains("categories?slug=blog-it") => Json("[{\"id\":40}]"),
            var q when q.Contains("categories=40") && q.Contains("&page=1&") => Json($"[{Post("uno")}]", totalPages: 2),
            var q when q.Contains("categories=40") && q.Contains("&page=2&") => Json($"[{Post("dos")}]", totalPages: 2),
            _ => new HttpResponseMessage(HttpStatusCode.NotFound),
        }));
        Assert.Equal(["uno", "dos"], (await client.GetBlogPostsAsync("it")).Select(x => x.Slug));
    }

    [Fact]
    public async Task Missing_category_is_an_empty_blog() =>
        Assert.Empty(await Client(new FakeWordPress(_ => Json("[]"))).GetBlogPostsAsync("es"));

    [Fact]
    public async Task WordPress_failure_is_an_error_when_there_is_no_previous_copy()
    {
        var client = Client(new FakeWordPress(_ => new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)));
        await Assert.ThrowsAsync<HttpRequestException>(() => client.GetBlogPostsAsync("es"));
    }

    [Fact]
    public async Task WordPress_failure_keeps_serving_the_last_copy()
    {
        var failing = false;
        using var cache = new MemoryCache(Options.Create(new MemoryCacheOptions()));
        var client = Client(new FakeWordPress(request =>
        {
            if (failing) return new HttpResponseMessage(HttpStatusCode.ServiceUnavailable);
            return request.RequestUri!.PathAndQuery.Contains("categories?slug") ? Json("[{\"id\":1}]") : Json($"[{Post("uno")}]");
        }), cache);
        await client.GetBlogPostsAsync("es");
        cache.Remove("wp:blog:es"); // vence el caché de 5 minutos
        failing = true;
        Assert.Equal("uno", Assert.Single(await client.GetBlogPostsAsync("es")).Slug);
    }

    [Fact]
    public async Task Post_brings_related_posts_of_the_same_topic_first()
    {
        var controller = Controller(Item("a", "Hosting"), Item("b", "Software"), Item("c", "Hosting"), Item("d", null));
        var post = Assert.IsType<BlogPostDto>(Assert.IsType<OkObjectResult>((await controller.GetBlogPost("es", "a", CancellationToken.None)).Result).Value);
        Assert.Equal("<p>a</p>", post.Html);
        Assert.Equal(["c", "b"], post.Related.Select(x => x.Slug));
    }

    [Fact]
    public async Task Unknown_post_or_language_is_not_found()
    {
        var controller = Controller(Item("a", null));
        Assert.IsType<NotFoundResult>((await controller.GetBlogPost("es", "otro", CancellationToken.None)).Result);
        Assert.IsType<NotFoundResult>((await controller.GetBlogPost("fr", "a", CancellationToken.None)).Result);
        Assert.IsType<NotFoundResult>((await controller.GetBlogPosts("fr", CancellationToken.None)).Result);
    }

    [Fact]
    public async Task WordPress_down_is_reported_as_unavailable()
    {
        var controller = new PublicContentController(new FakeContent(null), null!);
        Assert.Equal(503, Assert.IsType<StatusCodeResult>((await controller.GetBlogPosts("es", CancellationToken.None)).Result).StatusCode);
        Assert.Equal(503, Assert.IsType<StatusCodeResult>((await controller.GetBlogPost("es", "a", CancellationToken.None)).Result).StatusCode);
    }

    private static WordPressBlogPost Item(string slug, string? tag) =>
        new(slug, slug, slug, $"<p>{slug}</p>", tag, DateTimeOffset.UnixEpoch, DateTimeOffset.UnixEpoch, 1, null, null);

    private static PublicContentController Controller(params WordPressBlogPost[] posts) => new(new FakeContent(posts), null!);

    private static WordPressContentClient Client(HttpMessageHandler handler, IMemoryCache? cache = null) =>
        new(new HttpClient(handler) { BaseAddress = new Uri("https://wp.test/") }, cache ?? new MemoryCache(Options.Create(new MemoryCacheOptions())));

    private static HttpResponseMessage Json(string body, int totalPages = 1)
    {
        var response = new HttpResponseMessage(HttpStatusCode.OK) { Content = new StringContent(body, Encoding.UTF8, "application/json") };
        response.Headers.Add("X-WP-TotalPages", totalPages.ToString());
        return response;
    }

    private sealed class FakeWordPress(Func<HttpRequestMessage, HttpResponseMessage> respond) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken) => Task.FromResult(respond(request));
    }

    /// <summary>Con <c>posts</c> null simula a WordPress caído.</summary>
    private sealed class FakeContent(IReadOnlyList<WordPressBlogPost>? posts) : IWordPressContentClient
    {
        public Task<IReadOnlyList<WordPressBlogPost>> GetBlogPostsAsync(string locale, CancellationToken cancellationToken = default) =>
            posts is null ? throw new HttpRequestException("caído") : Task.FromResult(posts);
        public Task<WordPressPage?> GetPageAsync(string locale, string slug, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<IReadOnlyList<WordPressProject>> GetProjectsAsync(string locale, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<IReadOnlyList<WordPressReview>> GetReviewsAsync(string locale, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<string?> GetHeroPhotoUrlAsync(CancellationToken cancellationToken = default) => throw new NotSupportedException();
    }
}
