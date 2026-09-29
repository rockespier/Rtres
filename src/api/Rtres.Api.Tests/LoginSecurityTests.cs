using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class LoginSecurityTests
{
    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("corta")]
    [InlineData("development-only-change-me-development-only-change-me")]
    public void Api_does_not_start_without_a_real_jwt_key(string? key)
    {
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Jwt:Key"] = key }).Build();
        Assert.Throws<InvalidOperationException>(() => JwtSettings.FromConfiguration(config));
    }

    [Fact]
    public async Task Account_is_locked_after_repeated_failed_logins()
    {
        using var db = DbWithPassword(out var seed);
        var cache = new MemoryCache(new MemoryCacheOptions());
        for (var i = 0; i < 5; i++)
            Assert.IsType<UnauthorizedObjectResult>(await Login(db, cache, seed.User.Email, "incorrecta"));

        // Ya bloqueada: ni siquiera la contraseña correcta entra, y el correo en otro formato cuenta igual.
        var locked = Assert.IsType<ObjectResult>(await Login(db, cache, " " + seed.User.Email.ToUpperInvariant(), Password));
        Assert.Equal(429, locked.StatusCode);
    }

    [Fact]
    public async Task Successful_login_resets_the_failed_attempts()
    {
        using var db = DbWithPassword(out var seed);
        var cache = new MemoryCache(new MemoryCacheOptions());
        for (var i = 0; i < 4; i++) await Login(db, cache, seed.User.Email, "incorrecta");
        Assert.IsType<OkObjectResult>(await Login(db, cache, seed.User.Email, Password));
        for (var i = 0; i < 4; i++) await Login(db, cache, seed.User.Email, "incorrecta");
        Assert.IsType<OkObjectResult>(await Login(db, cache, seed.User.Email, Password));
    }

    const string Password = "Correcta-2026";

    private static RtresDbContext DbWithPassword(out Seed seed)
    {
        var db = TestData.Db(out seed);
        seed.User.PasswordHash = new PasswordHasher<UserAccount>().HashPassword(seed.User, Password);
        db.SaveChanges();
        return db;
    }

    private static Task<ActionResult> Login(RtresDbContext db, IMemoryCache cache, string email, string password) =>
        new AuthController(db, ClientOnboardingTests.TestJwt, cache).Login(new LoginRequest(email, password), CancellationToken.None);
}
