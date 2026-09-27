using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Rtres.Domain;
using Rtres.Infrastructure.Notifications;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Infrastructure;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddRtresInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<RtresDbContext>(options => options.UseSqlServer(configuration.GetConnectionString("SqlServer")));
        services.AddMemoryCache();
        services.AddHttpClient<IWordPressContentClient, WordPressContentClient>(client =>
        {
            client.BaseAddress = new Uri(configuration["WordPress:BaseUrl"] ?? "https://cms.rtres.net/");
            client.DefaultRequestHeaders.UserAgent.ParseAdd("Rtres.Api/1.0 (+https://rtres.net)");
        });
        services.AddHttpClient<IPayPalClient, PayPalClient>(client => client.BaseAddress = new Uri(configuration["PayPal:BaseUrl"] ?? "https://api-m.sandbox.paypal.com/"));
        services.AddScoped<IGitHubIssuesClient, GitHubIssuesClient>();
        services.AddHttpClient<IExchangeRateClient, ExchangeRateClient>(client => client.DefaultRequestHeaders.UserAgent.ParseAdd("Mozilla/5.0 (compatible; Rtres.Api/1.0; +https://rtres.net)"));
        if (string.IsNullOrWhiteSpace(configuration["Smtp:Host"])) services.AddScoped<IEmailSender, LoggingEmailSender>();
        else services.AddScoped<IEmailSender, SmtpEmailSender>();
        return services;
    }
}
