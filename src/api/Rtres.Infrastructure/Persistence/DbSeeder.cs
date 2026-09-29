using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Rtres.Domain;

namespace Rtres.Infrastructure.Persistence;

/// <summary>
/// Arranque en Development: aplica migraciones y deja solo lo mínimo para entrar al portal (SuperAdmin) y operar la
/// contabilidad (TaxSettings). No crea clientes, productos ni tickets de demo: esos se cargan con la importación.
/// </summary>
public static class DbSeeder
{
    public static async Task SeedAsync(RtresDbContext db, CancellationToken ct = default)
    {
        await db.Database.MigrateAsync(ct);
        if (!await db.TaxSettings.AnyAsync(ct)) db.TaxSettings.Add(new TaxSettings());
        if (!await db.UserAccounts.AnyAsync(x => x.Email == "admin@rtres.net", ct))
        {
            var superAdmin = new UserAccount { Email = "admin@rtres.net", Name = "Administración Rtres", Role = UserRole.SuperAdmin };
            superAdmin.PasswordHash = new PasswordHasher<UserAccount>().HashPassword(superAdmin, "RtresAdmin2026!");
            db.UserAccounts.Add(superAdmin);
        }
        await db.SaveChangesAsync(ct);
    }
}
