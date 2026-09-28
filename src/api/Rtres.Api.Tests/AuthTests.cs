using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Rtres.Api.Controllers;
using Rtres.Api.Services;

namespace Rtres.Api.Tests;

public class AuthTests
{
    private const string Password = "Clave-Correcta-2026";
    internal static readonly JwtSettings Jwt = JwtSettings.From(new ConfigurationBuilder().Build(), isDevelopment: true);

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData(JwtSettings.DevelopmentKey)]
    public void Outside_development_a_real_key_is_required(string? key) =>
        Assert.Throws<InvalidOperationException>(() => JwtSettings.From(Config(key), isDevelopment: false));

    [Fact]
    public void Short_keys_are_rejected() =>
        Assert.Throws<InvalidOperationException>(() => JwtSettings.From(Config("corta"), isDevelopment: true));

    [Fact]
    public void Development_falls_back_to_the_example_key_and_production_uses_its_own()
    {
        Assert.Equal(JwtSettings.DevelopmentKey, JwtSettings.From(Config(null), isDevelopment: true).Key);
        var key = new string('k', 48);
        Assert.Equal(key, JwtSettings.From(Config(key), isDevelopment: false).Key);
    }

    [Fact]
    public async Task Too_many_failed_logins_lock_the_email_for_a_while()
    {
        using var db = TestData.Db(out var seed);
        var clock = new ManualClock();
        var throttle = new LoginThrottle(clock);
        seed.User.PasswordHash = AccountController.Hasher.HashPassword(seed.User, Password); db.SaveChanges();
        Task<ActionResult> Login(string password) =>
            new AuthController(db, Jwt, throttle) { ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() } }.Login(new LoginRequest(seed.User.Email, password), CancellationToken.None);

        for (var i = 0; i < LoginThrottle.MaxFailures; i++) Assert.IsType<UnauthorizedObjectResult>(await Login("mala"));
        Assert.Equal(429, Assert.IsType<ObjectResult>(await Login(Password)).StatusCode); // bloqueado aunque ahora acierte

        clock.Advance(LoginThrottle.Window);
        Assert.IsType<OkObjectResult>(await Login(Password));
    }

    [Fact]
    public void A_successful_login_resets_the_count()
    {
        var throttle = new LoginThrottle(new ManualClock());
        for (var i = 0; i < LoginThrottle.MaxFailures - 1; i++) throttle.Failed("ana@andes.pe");
        throttle.Succeeded("ana@andes.pe");
        throttle.Failed("ANA@andes.pe ");
        Assert.Null(throttle.RetryAfter("ana@andes.pe"));
    }

    private static IConfiguration Config(string? key) =>
        new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Jwt:Key"] = key }).Build();

    private sealed class ManualClock : TimeProvider
    {
        private DateTimeOffset now = new(2026, 9, 28, 12, 0, 0, TimeSpan.Zero);
        public override DateTimeOffset GetUtcNow() => now;
        public void Advance(TimeSpan by) => now += by;
    }
}
