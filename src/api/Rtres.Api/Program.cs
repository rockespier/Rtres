using System.Text;
using System.Text.Json.Serialization;
using Hangfire;
using Hangfire.SqlServer;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
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
builder.Services.AddScoped<PayPalCheckoutService>();
builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy
    .WithOrigins(builder.Configuration["Frontend:PublicUrl"] ?? "https://rtres.net", builder.Configuration["Frontend:PortalUrl"] ?? "https://portal.rtres.net", "http://localhost:4200", "http://localhost:4201")
    .AllowAnyHeader().AllowAnyMethod()));
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options => options.TokenValidationParameters = new TokenValidationParameters
{
    ValidateIssuer = true, ValidateAudience = true, ValidateLifetime = true, ValidateIssuerSigningKey = true,
    ValidIssuer = builder.Configuration["Jwt:Issuer"], ValidAudience = builder.Configuration["Jwt:Audience"],
    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"] ?? "development-only-change-me-development-only-change-me"))
});
builder.Services.AddAuthorization();
// SqlServer (no MemoryStorage): los jobs encolados (recordatorios, sync de tipo de cambio) sobreviven a un reinicio de la API.
builder.Services.AddHangfire(config => config.UseSqlServerStorage(builder.Configuration.GetConnectionString("SqlServer"), new SqlServerStorageOptions { PrepareSchemaIfNecessary = true }));
builder.Services.AddHangfireServer();

var app = builder.Build();
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    using var scope = app.Services.CreateScope();
    await DbSeeder.SeedAsync(scope.ServiceProvider.GetRequiredService<RtresDbContext>());
}
app.UseHttpsRedirection();
app.UseCors();
app.UseAuthentication();
app.UseAuthorization();
app.UseHangfireDashboard("/jobs");
// 13:00 UTC = 8:00 en Lima.
RecurringJob.AddOrUpdate<RenewalReminderJob>("renewal-reminders", job => job.SendAsync(CancellationToken.None), Cron.Daily(13));
// 11:00 UTC = 6:00 en Lima, antes que corra cualquier otro job del día.
RecurringJob.AddOrUpdate<ExchangeRateSyncJob>("exchange-rate-sync", job => job.SyncAsync(CancellationToken.None), Cron.Daily(11));
app.MapControllers();
app.Run();

public partial class Program;
