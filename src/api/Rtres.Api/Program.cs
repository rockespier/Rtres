using System.Text.Json.Serialization;
using System.Threading.RateLimiting;
using Hangfire;
using Hangfire.SqlServer;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.IdentityModel.Tokens;
using Rtres.Api.Controllers;
using Rtres.Api.GitHub;
using Rtres.Api.Jobs;
using Rtres.Api.Notifications;
using Rtres.Domain;
using Rtres.Api.Services;
using Rtres.Infrastructure;
using Rtres.Infrastructure.Persistence;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.local.json", optional: true, reloadOnChange: true);
builder.Services.AddControllers().AddJsonOptions(o => o.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));
builder.Services.AddOpenApi();
builder.Services.AddRtresInfrastructure(builder.Configuration);
builder.Services.AddScoped<GitHubWebhookProcessor>();
builder.Services.AddScoped<ExchangeRateSyncJob>();
builder.Services.AddScoped<INotificationSender, QueuedNotificationSender>();
builder.Services.AddScoped<NotificationJob>();
builder.Services.AddScoped<AccessEmailService>();
builder.Services.AddScoped<PayPalCheckoutService>();
builder.Services.AddScoped<PayPalPaymentService>();
builder.Services.AddScoped<TaxDocumentService>();
builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy
    .WithOrigins(PayPalCheckoutService.AllowedOrigins(builder.Configuration))
    .AllowAnyHeader().AllowAnyMethod()));
// Falla al arrancar si Jwt:Key no está definida o es insegura: nunca se firma con una clave conocida.
var jwt = JwtSettings.FromConfiguration(builder.Configuration);
builder.Services.AddSingleton(jwt);
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options => options.TokenValidationParameters = new TokenValidationParameters
{
    ValidateIssuer = true, ValidateAudience = true, ValidateLifetime = true, ValidateIssuerSigningKey = true,
    ValidIssuer = jwt.Issuer, ValidAudience = jwt.Audience, IssuerSigningKey = jwt.SigningKey,
    ClockSkew = TimeSpan.FromMinutes(1)
});
builder.Services.AddAuthorization();
builder.Services.AddMemoryCache();
// Detrás de nginx la IP real llega en X-Forwarded-For; sin esto todos los logins compartirían el límite del proxy.
builder.Services.Configure<ForwardedHeadersOptions>(o =>
{
    o.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    o.KnownIPNetworks.Clear(); o.KnownProxies.Clear();
});
builder.Services.AddRateLimiter(o =>
{
    o.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    o.OnRejected = (ctx, ct) => new ValueTask(ctx.HttpContext.Response.WriteAsJsonAsync(new { message = "Demasiados intentos de inicio de sesión. Espera un minuto e inténtalo de nuevo." }, ct));
    o.AddPolicy(AuthController.LoginRateLimitPolicy, http => RateLimitPartition.GetFixedWindowLimiter(
        http.Connection.RemoteIpAddress?.ToString() ?? "unknown",
        _ => new FixedWindowRateLimiterOptions { PermitLimit = 10, Window = TimeSpan.FromMinutes(1), QueueLimit = 0 }));
});
// SqlServer (no MemoryStorage): los jobs encolados (recordatorios, sync de tipo de cambio) sobreviven a un reinicio de la API.
builder.Services.AddHangfire(config => config.UseSqlServerStorage(builder.Configuration.GetConnectionString("SqlServer"), new SqlServerStorageOptions { PrepareSchemaIfNecessary = true }));
builder.Services.AddHangfireServer();

var app = builder.Build();
app.UseForwardedHeaders();
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    using var scope = app.Services.CreateScope();
    await DbSeeder.SeedAsync(scope.ServiceProvider.GetRequiredService<RtresDbContext>());
}
app.UseHttpsRedirection();
app.UseCors();
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
app.UseHangfireDashboard("/jobs");
// 13:00 UTC = 8:00 en Lima.
RecurringJob.AddOrUpdate<RenewalReminderJob>("renewal-reminders", job => job.SendAsync(CancellationToken.None), Cron.Daily(13));
// 11:00 UTC = 6:00 en Lima, antes que corra cualquier otro job del día.
RecurringJob.AddOrUpdate<ExchangeRateSyncJob>("exchange-rate-sync", job => job.SyncAsync(CancellationToken.None), Cron.Daily(11));
// Cobros de suscripciones PayPal que no llegaron por webhook (ver PayPalReconciliationJob).
// Columna "Status" de los GitHub Projects → estado del ticket (GitHub no envía webhooks de proyectos de usuario).
RecurringJob.AddOrUpdate<GitHubProjectStatusSyncJob>("github-project-status", job => job.SyncAsync(CancellationToken.None), "*/5 * * * *");
RecurringJob.AddOrUpdate<PayPalReconciliationJob>("paypal-reconciliation", job => job.ReconcileAsync(CancellationToken.None), Cron.Hourly);
app.MapControllers();
app.Run();

public partial class Program;
