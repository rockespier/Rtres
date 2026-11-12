using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Rtres.Api.Controllers;
using Rtres.Api.Notifications;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class LoginLinkTests
{
    [Fact]
    public async Task Registered_user_gets_a_link_that_signs_in_once()
    {
        using var db = TestData.Db(out var seed);
        var mailer = new FakeMailer();
        AssertSent(await Controller(db, mailer).Send(new LoginLinkRequest(" ROBERTO@Example.com "), CancellationToken.None));

        var message = Assert.Single(mailer.Sent);
        Assert.Equal(seed.User.Email, message.To);
        Assert.Contains("https://portal.rtres.net/login/enlace?t=", message.Text);
        var token = TokenFrom(message);
        // Solo se guarda el hash: el token en claro no está en la BD.
        Assert.DoesNotContain(db.LoginLinks, x => x.TokenHash.Contains(token));

        var ok = Assert.IsType<OkObjectResult>(await Controller(db, mailer).Verify(new LoginLinkVerifyRequest(token), CancellationToken.None));
        Assert.Equal("Cliente", Prop<string>(Prop<object>(ok.Value!, "user"), "role"));
        AssertInvalid(await Controller(db, mailer).Verify(new LoginLinkVerifyRequest(token), CancellationToken.None));
    }

    [Fact]
    public async Task Unknown_or_inactive_email_gets_the_same_answer_and_no_email()
    {
        using var db = TestData.Db(out var seed);
        var mailer = new FakeMailer();
        AssertSent(await Controller(db, mailer).Send(new LoginLinkRequest("otra@example.com"), CancellationToken.None));
        seed.User.IsActive = false; db.SaveChanges();
        AssertSent(await Controller(db, mailer).Send(new LoginLinkRequest(seed.User.Email), CancellationToken.None));
        Assert.Empty(mailer.Sent);
        Assert.Empty(db.LoginLinks);
    }

    [Fact]
    public async Task Deactivated_client_gets_no_link()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.IsActive = false; db.SaveChanges();
        var mailer = new FakeMailer();
        AssertSent(await Controller(db, mailer).Send(new LoginLinkRequest(seed.User.Email), CancellationToken.None));
        Assert.Empty(mailer.Sent);
    }

    [Fact]
    public async Task SuperAdmin_without_client_gets_a_link_in_spanish()
    {
        using var db = TestData.Db(out var seed);
        seed.User.Role = UserRole.SuperAdmin; seed.User.ClientId = null; db.SaveChanges();
        var mailer = new FakeMailer();
        await Controller(db, mailer).Send(new LoginLinkRequest(seed.User.Email), CancellationToken.None);
        var message = Assert.Single(mailer.Sent);
        Assert.Equal("Tu enlace para entrar al portal de Rtres", message.Subject);
        var ok = Assert.IsType<OkObjectResult>(await Controller(db, mailer).Verify(new LoginLinkVerifyRequest(TokenFrom(message)), CancellationToken.None));
        Assert.Equal("SuperAdmin", Prop<string>(Prop<object>(ok.Value!, "user"), "role"));
    }

    [Fact]
    public async Task Sends_at_most_three_links_per_window()
    {
        using var db = TestData.Db(out var seed);
        var mailer = new FakeMailer();
        var cache = new MemoryCache(new MemoryCacheOptions());
        for (var i = 0; i < 5; i++) AssertSent(await Controller(db, mailer, cache).Send(new LoginLinkRequest(seed.User.Email), CancellationToken.None));
        Assert.Equal(3, mailer.Sent.Count);
    }

    [Fact]
    public async Task Expired_link_is_refused()
    {
        using var db = TestData.Db(out _);
        var mailer = new FakeMailer();
        await Controller(db, mailer).Send(new LoginLinkRequest("roberto@example.com"), CancellationToken.None);
        db.LoginLinks.Single().ExpiresAt = DateTime.UtcNow.AddSeconds(-1); db.SaveChanges();
        AssertInvalid(await Controller(db, mailer).Verify(new LoginLinkVerifyRequest(TokenFrom(mailer.Sent[0])), CancellationToken.None));
    }

    [Fact]
    public async Task Link_of_a_user_deactivated_afterwards_is_refused()
    {
        using var db = TestData.Db(out var seed);
        var mailer = new FakeMailer();
        await Controller(db, mailer).Send(new LoginLinkRequest(seed.User.Email), CancellationToken.None);
        seed.User.IsActive = false; db.SaveChanges();
        AssertInvalid(await Controller(db, mailer).Verify(new LoginLinkVerifyRequest(TokenFrom(mailer.Sent[0])), CancellationToken.None));
    }

    [Theory, InlineData(""), InlineData("no-existe")]
    public async Task Unknown_token_is_refused(string token) =>
        AssertInvalid(await Controller(TestData.Db(out _), new FakeMailer()).Verify(new LoginLinkVerifyRequest(token), CancellationToken.None));

    static void AssertSent(ActionResult result) =>
        Assert.Equal(LoginLinkController.Sent, Prop<string>(Assert.IsType<AcceptedResult>(result).Value!, "message"));

    static void AssertInvalid(ActionResult result) =>
        Assert.Equal(LoginLinkController.Invalid, Prop<string>(Assert.IsType<UnauthorizedObjectResult>(result).Value!, "message"));

    static string TokenFrom(EmailMessage message) => Uri.UnescapeDataString(Regex.Match(message.Text, @"enlace\?t=(\S+)").Groups[1].Value);

    static LoginLinkController Controller(RtresDbContext db, FakeMailer mailer, IMemoryCache? cache = null) =>
        new(db, ClientOnboardingTests.TestJwt, cache ?? new MemoryCache(new MemoryCacheOptions()), mailer, new ConfigurationBuilder().Build());

    static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name)!.GetValue(value)!;
}

internal sealed class FakeMailer : ILoginLinkMailer
{
    public List<EmailMessage> Sent { get; } = [];
    public void Send(EmailMessage message) => Sent.Add(message);
}
