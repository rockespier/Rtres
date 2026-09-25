using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Rtres.Domain;
using Rtres.Infrastructure.Persistence;

namespace Rtres.Infrastructure;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddRtresInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<RtresDbContext>(options => options.UseNpgsql(configuration.GetConnectionString("Postgres")));
        services.AddHttpClient<IWordPressContentClient, WordPressContentClient>(client => client.BaseAddress = new Uri(configuration["WordPress:BaseUrl"] ?? "https://cms.rtres.net/"));
        services.AddHttpClient<IPayPalClient, PayPalClient>(client => client.BaseAddress = new Uri(configuration["PayPal:BaseUrl"] ?? "https://api-m.sandbox.paypal.com/"));
        services.AddScoped<IGitHubIssuesClient, GitHubIssuesClient>();
        services.AddScoped<INotificationSender, LoggingNotificationSender>();
        return services;
    }
}
