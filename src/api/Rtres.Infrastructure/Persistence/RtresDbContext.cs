using Microsoft.EntityFrameworkCore;
using Rtres.Domain;

namespace Rtres.Infrastructure.Persistence;

public sealed class RtresDbContext(DbContextOptions<RtresDbContext> options) : DbContext(options)
{
    public DbSet<Client> Clients => Set<Client>(); public DbSet<UserAccount> UserAccounts => Set<UserAccount>();
    public DbSet<Project> Projects => Set<Project>(); public DbSet<Product> Products => Set<Product>(); public DbSet<ClientProduct> ClientProducts => Set<ClientProduct>();
    public DbSet<Ticket> Tickets => Set<Ticket>(); public DbSet<TicketAttachment> TicketAttachments => Set<TicketAttachment>(); public DbSet<TicketComment> TicketComments => Set<TicketComment>(); public DbSet<PaymentTransaction> PaymentTransactions => Set<PaymentTransaction>(); public DbSet<NotificationLog> NotificationLogs => Set<NotificationLog>();
    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<Client>().HasIndex(x => x.Email).IsUnique(); b.Entity<UserAccount>().HasIndex(x => x.Email).IsUnique(); b.Entity<Project>().HasIndex(x => x.Slug).IsUnique(); b.Entity<ClientProduct>().HasIndex(x => x.PayPalSubscriptionId).IsUnique(); b.Entity<ClientProduct>().HasIndex(x => x.PayPalOrderId).IsUnique(); b.Entity<Ticket>().HasIndex(x => x.Code).IsUnique();
        b.Entity<Product>().Property(x => x.BasePrice).HasPrecision(12, 2); b.Entity<ClientProduct>().Property(x => x.Price).HasPrecision(12, 2); b.Entity<PaymentTransaction>().Property(x => x.Amount).HasPrecision(12, 2);
    }
}
