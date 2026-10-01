using Microsoft.EntityFrameworkCore;
using Rtres.Domain;

namespace Rtres.Infrastructure.Persistence;

public sealed class RtresDbContext(DbContextOptions<RtresDbContext> options) : DbContext(options)
{
    public DbSet<Client> Clients => Set<Client>(); public DbSet<UserAccount> UserAccounts => Set<UserAccount>();
    public DbSet<Project> Projects => Set<Project>(); public DbSet<ProjectRepository> ProjectRepositories => Set<ProjectRepository>(); public DbSet<PortalNotification> PortalNotifications => Set<PortalNotification>(); public DbSet<Product> Products => Set<Product>(); public DbSet<ClientProduct> ClientProducts => Set<ClientProduct>();
    public DbSet<Ticket> Tickets => Set<Ticket>(); public DbSet<TicketAttachment> TicketAttachments => Set<TicketAttachment>(); public DbSet<TicketComment> TicketComments => Set<TicketComment>(); public DbSet<PaymentTransaction> PaymentTransactions => Set<PaymentTransaction>(); public DbSet<NotificationLog> NotificationLogs => Set<NotificationLog>();
    public DbSet<ExchangeRate> ExchangeRates => Set<ExchangeRate>(); public DbSet<TaxDocument> TaxDocuments => Set<TaxDocument>(); public DbSet<Expense> Expenses => Set<Expense>(); public DbSet<TaxSettings> TaxSettings => Set<TaxSettings>();
    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<Client>().HasIndex(x => x.Email).IsUnique(); b.Entity<UserAccount>().HasIndex(x => x.Email).IsUnique(); b.Entity<Project>().HasIndex(x => x.Slug).IsUnique(); b.Entity<ClientProduct>().HasIndex(x => x.PayPalSubscriptionId).IsUnique(); b.Entity<ClientProduct>().HasIndex(x => x.PayPalOrderId).IsUnique(); b.Entity<Ticket>().HasIndex(x => x.Code).IsUnique(); b.Entity<Ticket>().HasIndex(x => x.GithubIssueNumber); b.Entity<TicketComment>().HasIndex(x => x.GithubCommentId).IsUnique(); b.Entity<NotificationLog>().HasIndex(x => x.DedupeKey); b.Entity<NotificationLog>().Property(x => x.DedupeKey).HasMaxLength(200);
        b.Entity<Product>().Property(x => x.BasePrice).HasPrecision(12, 2); b.Entity<Product>().Property(x => x.PayPalPlanPrice).HasPrecision(12, 2); b.Entity<ClientProduct>().Property(x => x.Price).HasPrecision(12, 2); b.Entity<ClientProduct>().Property(x => x.Discount).HasPrecision(12, 2); b.Entity<ClientProduct>().Ignore(x => x.AppliedIgvRate); b.Entity<PaymentTransaction>().Property(x => x.Amount).HasPrecision(12, 2); b.Entity<PaymentTransaction>().Property(x => x.AmountPen).HasPrecision(12, 2); b.Entity<PaymentTransaction>().HasIndex(x => x.InternalCode).IsUnique(); b.Entity<PaymentTransaction>().HasIndex(x => new { x.ClientId, x.CreatedAt }); b.Entity<TaxDocument>().Property(x => x.RetentionAmount).HasPrecision(12, 2); b.Entity<PaymentTransaction>().Property(x => x.Method).HasMaxLength(20); b.Entity<PaymentTransaction>().Property(x => x.PayPalOrderIdOrSubscriptionId).HasMaxLength(100); b.Entity<PaymentTransaction>().HasIndex(x => x.PayPalOrderIdOrSubscriptionId).IsUnique();
        // Un repo de GitHub pertenece a un solo proyecto: el webhook ubica el ticket por dueño/nombre del repo.
        b.Entity<ProjectRepository>().HasIndex(x => new { x.Owner, x.Name }).IsUnique(); b.Entity<ProjectRepository>().Property(x => x.Owner).HasMaxLength(100); b.Entity<ProjectRepository>().Property(x => x.Name).HasMaxLength(100); b.Entity<ProjectRepository>().Property(x => x.Label).HasMaxLength(100);
        b.Entity<PortalNotification>().HasIndex(x => new { x.ClientId, x.CreatedAt }); b.Entity<PortalNotification>().HasIndex(x => x.DedupeKey); b.Entity<PortalNotification>().Property(x => x.Type).HasMaxLength(40); b.Entity<PortalNotification>().Property(x => x.DedupeKey).HasMaxLength(200);
        b.Entity<Product>().Property(x => x.Category).HasMaxLength(100); b.Entity<Product>().Property(x => x.Tags).HasMaxLength(500);
        b.Entity<ExchangeRate>().HasIndex(x => new { x.Date, x.CurrencyCode }).IsUnique(); b.Entity<ExchangeRate>().Property(x => x.RateToPen).HasPrecision(12, 6);
        b.Entity<TaxDocument>().HasIndex(x => new { x.Series, x.Number }).IsUnique(); b.Entity<TaxDocument>().HasIndex(x => x.PaymentTransactionId).IsUnique().HasFilter("[PaymentTransactionId] IS NOT NULL"); b.Entity<TaxSettings>().Property(x => x.FacturaSeries).HasMaxLength(4); b.Entity<TaxSettings>().Property(x => x.ReciboSeries).HasMaxLength(4); b.Entity<TaxDocument>().Property(x => x.BaseAmount).HasPrecision(12, 2); b.Entity<TaxDocument>().Property(x => x.IgvAmount).HasPrecision(12, 2); b.Entity<TaxDocument>().Property(x => x.TotalAmount).HasPrecision(12, 2);
        b.Entity<Expense>().Property(x => x.Amount).HasPrecision(12, 2); b.Entity<Expense>().Property(x => x.AmountPen).HasPrecision(12, 2);
        b.Entity<TaxSettings>().Property(x => x.IgvRate).HasPrecision(5, 4); b.Entity<TaxSettings>().Property(x => x.RentaRate).HasPrecision(5, 4);
    }
}
