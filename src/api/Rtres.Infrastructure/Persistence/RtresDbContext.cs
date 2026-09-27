using Microsoft.EntityFrameworkCore;
using Rtres.Domain;

namespace Rtres.Infrastructure.Persistence;

public sealed class RtresDbContext(DbContextOptions<RtresDbContext> options) : DbContext(options)
{
    public DbSet<Client> Clients => Set<Client>(); public DbSet<UserAccount> UserAccounts => Set<UserAccount>();
    public DbSet<Project> Projects => Set<Project>(); public DbSet<Product> Products => Set<Product>(); public DbSet<ClientProduct> ClientProducts => Set<ClientProduct>();
    public DbSet<Ticket> Tickets => Set<Ticket>(); public DbSet<TicketAttachment> TicketAttachments => Set<TicketAttachment>(); public DbSet<TicketComment> TicketComments => Set<TicketComment>(); public DbSet<PaymentTransaction> PaymentTransactions => Set<PaymentTransaction>(); public DbSet<NotificationLog> NotificationLogs => Set<NotificationLog>();
    public DbSet<ExchangeRate> ExchangeRates => Set<ExchangeRate>(); public DbSet<TaxDocument> TaxDocuments => Set<TaxDocument>(); public DbSet<Expense> Expenses => Set<Expense>(); public DbSet<TaxSettings> TaxSettings => Set<TaxSettings>();
    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<Client>().HasIndex(x => x.Email).IsUnique(); b.Entity<UserAccount>().HasIndex(x => x.Email).IsUnique(); b.Entity<Project>().HasIndex(x => x.Slug).IsUnique(); b.Entity<ClientProduct>().HasIndex(x => x.PayPalSubscriptionId).IsUnique(); b.Entity<ClientProduct>().HasIndex(x => x.PayPalOrderId).IsUnique(); b.Entity<Ticket>().HasIndex(x => x.Code).IsUnique(); b.Entity<Ticket>().HasIndex(x => x.GithubIssueNumber); b.Entity<TicketComment>().HasIndex(x => x.GithubCommentId).IsUnique(); b.Entity<NotificationLog>().HasIndex(x => x.DedupeKey); b.Entity<NotificationLog>().Property(x => x.DedupeKey).HasMaxLength(200);
        b.Entity<Product>().Property(x => x.BasePrice).HasPrecision(12, 2); b.Entity<ClientProduct>().Property(x => x.Price).HasPrecision(12, 2); b.Entity<PaymentTransaction>().Property(x => x.Amount).HasPrecision(12, 2); b.Entity<PaymentTransaction>().Property(x => x.AmountPen).HasPrecision(12, 2); b.Entity<PaymentTransaction>().HasIndex(x => x.InternalCode).IsUnique();
        b.Entity<ExchangeRate>().HasIndex(x => new { x.Date, x.CurrencyCode }).IsUnique(); b.Entity<ExchangeRate>().Property(x => x.RateToPen).HasPrecision(12, 6);
        b.Entity<TaxDocument>().HasIndex(x => new { x.Series, x.Number }).IsUnique(); b.Entity<TaxDocument>().Property(x => x.BaseAmount).HasPrecision(12, 2); b.Entity<TaxDocument>().Property(x => x.IgvAmount).HasPrecision(12, 2); b.Entity<TaxDocument>().Property(x => x.TotalAmount).HasPrecision(12, 2);
        b.Entity<Expense>().Property(x => x.Amount).HasPrecision(12, 2); b.Entity<Expense>().Property(x => x.AmountPen).HasPrecision(12, 2);
        b.Entity<TaxSettings>().Property(x => x.IgvRate).HasPrecision(5, 4); b.Entity<TaxSettings>().Property(x => x.RentaRate).HasPrecision(5, 4);
    }
}
