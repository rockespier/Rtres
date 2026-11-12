using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using Rtres.Api.Controllers;
using Rtres.Api.Services;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Api.Tests;

public class GoogleLoginTests
{
    const string Refused = "No se pudo iniciar sesión con Google. Usa una cuenta habilitada en el portal.";

    [Fact]
    public async Task Active_client_user_signs_in_with_email_in_any_case()
    {
        using var db = TestData.Db(out var seed);
        var ok = Assert.IsType<OkObjectResult>(await Google(db, new FirebaseIdentity(" ROBERTO@Example.com ", true)));
        Assert.False(string.IsNullOrEmpty(Prop<string>(ok.Value!, "token")));
        var user = Prop<object>(ok.Value!, "user");
        Assert.Equal(("Cliente", seed.User.Name, seed.Client.CompanyName), (Prop<string>(user, "role"), Prop<string>(user, "name"), Prop<string>(user, "clientName")));
    }

    [Fact]
    public async Task Unknown_email_is_refused() =>
        AssertRefused(await Google(TestData.Db(out _), new FirebaseIdentity("otra@example.com", true)));

    [Fact]
    public async Task Inactive_user_is_refused()
    {
        using var db = TestData.Db(out var seed);
        seed.User.IsActive = false; db.SaveChanges();
        AssertRefused(await Google(db, new FirebaseIdentity(seed.User.Email, true)));
    }

    [Theory]
    [InlineData(UserRole.Admin)]
    [InlineData(UserRole.SuperAdmin)]
    public async Task Admin_roles_stay_password_only(UserRole role)
    {
        using var db = TestData.Db(out var seed);
        seed.User.Role = role; db.SaveChanges();
        AssertRefused(await Google(db, new FirebaseIdentity(seed.User.Email, true)));
    }

    [Fact]
    public async Task Unverified_email_is_refused()
    {
        using var db = TestData.Db(out var seed);
        AssertRefused(await Google(db, new FirebaseIdentity(seed.User.Email, false)));
    }

    [Fact]
    public async Task Invalid_token_is_refused() =>
        AssertRefused(await Google(TestData.Db(out _), null));

    [Fact]
    public async Task Deactivated_client_gets_403()
    {
        using var db = TestData.Db(out var seed);
        seed.Client.IsActive = false; db.SaveChanges();
        var result = Assert.IsType<ObjectResult>(await Google(db, new FirebaseIdentity(seed.User.Email, true)));
        Assert.Equal(403, result.StatusCode);
        Assert.Equal("Este cliente está dado de baja. Contacta a Rtres.", Prop<string>(result.Value!, "message"));
    }

    [Fact]
    public async Task Refused_calls_never_create_accounts()
    {
        using var db = TestData.Db(out _);
        var before = db.UserAccounts.Count();
        AssertRefused(await Google(db, new FirebaseIdentity("nuevo@example.com", true)));
        Assert.Equal(before, db.UserAccounts.Count());
    }

    [Fact]
    public async Task Real_verifier_without_project_id_rejects_every_token()
    {
        var verifier = new FirebaseTokenVerifier(new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?> { ["Firebase:ProjectId"] = "" }).Build());
        Assert.Null(await verifier.VerifyAsync("eyJhbGciOiJSUzI1NiJ9.e30.firma", CancellationToken.None));
    }

    // Todas las negativas devuelven el mismo 401: la respuesta no revela si el correo existe ni por qué se rechazó.
    private static void AssertRefused(ActionResult result) =>
        Assert.Equal(Refused, Prop<string>(Assert.IsType<UnauthorizedObjectResult>(result).Value!, "message"));

    private static Task<ActionResult> Google(RtresDbContext db, FirebaseIdentity? identity) =>
        new AuthController(db, ClientOnboardingTests.TestJwt, new MemoryCache(new MemoryCacheOptions()), new FakeFirebase(identity)).Google(new GoogleLoginRequest("id-token"), CancellationToken.None);

    private static T Prop<T>(object value, string name) => (T)value.GetType().GetProperty(name)!.GetValue(value)!;
}

internal sealed class FakeFirebase(FirebaseIdentity? identity) : IFirebaseTokenVerifier
{
    public Task<FirebaseIdentity?> VerifyAsync(string idToken, CancellationToken ct) => Task.FromResult(identity);
}
