using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;

namespace Rtres.Infrastructure.Persistence;

public static class DbSeeder
{
    public static async Task SeedAsync(RtresDbContext db, CancellationToken ct = default)
    {
        await db.Database.MigrateAsync(ct);
        var hasher = new PasswordHasher<UserAccount>();
        var existingUser = await db.UserAccounts.SingleOrDefaultAsync(x => x.Email == "roberto.ramos@r3solucionesweb.com", ct);
        if (existingUser is not null)
        {
            var changed = false;
            if (string.IsNullOrWhiteSpace(existingUser.Name)) { existingUser.Name = "Roberto Ramos"; changed = true; }
            if (existingUser.Role != UserRole.Admin) { existingUser.Role = UserRole.Admin; changed = true; }
            if (changed) await db.SaveChangesAsync(ct);
        }
        if (await db.Clients.AnyAsync(ct))
        {
            await EnsurePhase3SeedAsync(db, hasher, ct);
            return;
        }

        var client = new Client { CompanyName = "Cabalgatas Andinas", ContactName = "Roberto Ramos", Email = "roberto.ramos@r3solucionesweb.com", PreferredLanguage = "es" };
        var project = new Project { ClientId = client.Id, Name = "Cabalgatas Andinas Web", Slug = "cabalgatas-andinas-web", GithubRepoOwner = "rtres-web", GithubRepoName = "cabalgatas-andinas-web" };
        var user = new UserAccount { ClientId = client.Id, Email = client.Email, Name = "Roberto Ramos", Role = UserRole.Admin };
        user.PasswordHash = hasher.HashPassword(user, "Rtres2026!");

        var hosting = new Product { Type = ProductType.Hosting, Name = "Hosting anual", BillingCycle = BillingCycle.Anual, BasePrice = 90m, Currency = "USD" };
        var dominio = new Product { Type = ProductType.Dominio, Name = "Dominio", BillingCycle = BillingCycle.Anual, BasePrice = 20m, Currency = "USD" };
        var ssl = new Product { Type = ProductType.Ssl, Name = "Certificado SSL", BillingCycle = BillingCycle.Anual, BasePrice = 0m, Currency = "USD" };
        var backup = new Product { Type = ProductType.BackupBd, Name = "Backup de base de datos", BillingCycle = BillingCycle.Mensual, BasePrice = 0m, Currency = "USD" };
        var soporte = new Product { Type = ProductType.SoporteMensual, Name = "Soporte mensual", BillingCycle = BillingCycle.Mensual, BasePrice = 90m, Currency = "USD" };

        var renewsAt = new DateTime(2026, 10, 14, 0, 0, 0, DateTimeKind.Utc);
        var clientProducts = new[]
        {
            new ClientProduct { ClientId = client.Id, ProjectId = project.Id, ProductId = hosting.Id, Status = ClientProductStatus.Activo, RenewsAt = renewsAt, Price = hosting.BasePrice },
            new ClientProduct { ClientId = client.Id, ProjectId = project.Id, ProductId = dominio.Id, Status = ClientProductStatus.Activo, RenewsAt = renewsAt, Price = dominio.BasePrice, DomainName = "cabalgatasandinas.com" },
            new ClientProduct { ClientId = client.Id, ProjectId = project.Id, ProductId = ssl.Id, Status = ClientProductStatus.PorVencer, RenewsAt = renewsAt, PriceLabelOverride = "Incluido en plan" },
            new ClientProduct { ClientId = client.Id, ProjectId = project.Id, ProductId = backup.Id, Status = ClientProductStatus.Activo, LastBackupAt = DateTime.UtcNow },
            new ClientProduct { ClientId = client.Id, ProjectId = project.Id, ProductId = soporte.Id, Status = ClientProductStatus.Activo, NextChargeAt = new DateTime(2026, 10, 1, 0, 0, 0, DateTimeKind.Utc), Price = soporte.BasePrice },
        };

        var tickets = new[]
        {
            new Ticket { Code = "RT-101", ClientId = client.Id, ProjectId = project.Id, CreatedByUserId = user.Id, Type = TicketType.Soporte, Status = TicketStatus.Abierto, Title = "El formulario de contacto no envía correos", Description = "Los leads no llegan al correo configurado.", CurrentBehavior = "No llega el correo.", ExpectedBehavior = "Debe llegar el correo al enviar el formulario.", StepsToReproduce = "1. Ir a /contacto 2. Enviar el formulario", Environment = "Producción", AcceptanceCriteria = "El correo llega en menos de 1 minuto." },
            new Ticket { Code = "RT-102", ClientId = client.Id, ProjectId = project.Id, CreatedByUserId = user.Id, Type = TicketType.Cambio, Status = TicketStatus.EnProgreso, Title = "Agregar pasarela de reservas online", Description = "Se necesita un módulo de reservas.", CurrentBehavior = "No existe reserva online.", ExpectedBehavior = "Debe permitir reservar y pagar online.", AcceptanceCriteria = "El cliente puede reservar y pagar.", EstimatedImpact = "Alto: nueva fuente de ingresos." },
            new Ticket { Code = "RT-103", ClientId = client.Id, ProjectId = project.Id, CreatedByUserId = user.Id, Type = TicketType.Soporte, Status = TicketStatus.Resuelto, Title = "Actualizar horarios de atención", Description = "Los horarios en el footer están desactualizados.", CurrentBehavior = "Muestra horario antiguo.", ExpectedBehavior = "Debe mostrar el horario nuevo.", AcceptanceCriteria = "El footer muestra el horario correcto." },
            new Ticket { Code = "RT-104", ClientId = client.Id, ProjectId = project.Id, CreatedByUserId = user.Id, Type = TicketType.Cambio, Status = TicketStatus.Publicado, Title = "Rediseñar galería de fotos", Description = "La galería actual no es responsive.", CurrentBehavior = "Se ve cortada en móvil.", ExpectedBehavior = "Debe adaptarse a cualquier pantalla.", AcceptanceCriteria = "La galería se ve bien en móvil y desktop.", EstimatedImpact = "Medio: mejora la experiencia de usuario." },
        };

        db.AddRange(client, project, user, hosting, dominio, ssl, backup, soporte);
        db.AddRange(clientProducts);
        db.AddRange(tickets);
        await db.SaveChangesAsync(ct);
        await EnsurePhase3SeedAsync(db, hasher, ct);
    }

    private static async Task EnsurePhase3SeedAsync(RtresDbContext db, PasswordHasher<UserAccount> hasher, CancellationToken ct)
    {
        if (!await db.UserAccounts.AnyAsync(x => x.Email == "admin@rtres.net", ct))
        {
            var superAdmin = new UserAccount { Email = "admin@rtres.net", Name = "Administración Rtres", Role = UserRole.SuperAdmin };
            superAdmin.PasswordHash = hasher.HashPassword(superAdmin, "RtresAdmin2026!");
            db.UserAccounts.Add(superAdmin);
        }

        if (!await db.Clients.AnyAsync(x => x.Email == "contacto@selvaviva.pe", ct))
        {
            var client = new Client { CompanyName = "Selva Viva", ContactName = "Lucía Torres", Email = "contacto@selvaviva.pe", PreferredLanguage = "es" };
            var user = new UserAccount { ClientId = client.Id, Email = client.Email, Name = "Lucía Torres", Role = UserRole.Admin };
            user.PasswordHash = hasher.HashPassword(user, "SelvaViva2026!");
            var project = new Project { ClientId = client.Id, Name = "Selva Viva Web", Slug = "selva-viva-web", GithubRepoOwner = "rtres-web", GithubRepoName = "selva-viva-web" };
            var product = new Product { Type = ProductType.Hosting, Name = "Hosting anual", BillingCycle = BillingCycle.Anual, BasePrice = 120m, Currency = "USD" };
            db.AddRange(client, user, project, product,
                new ClientProduct { ClientId = client.Id, ProjectId = project.Id, ProductId = product.Id, Status = ClientProductStatus.Activo, RenewsAt = DateTime.UtcNow.AddMonths(5), Price = 120m },
                new Ticket { Code = "RT-201", ClientId = client.Id, ProjectId = project.Id, CreatedByUserId = user.Id, Type = TicketType.Soporte, Status = TicketStatus.EnProgreso, Title = "Actualizar imágenes", Description = "Actualizar las fotografías de portada." });
        }
        await db.SaveChangesAsync(ct);
    }
}
