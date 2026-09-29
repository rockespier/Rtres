using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class ClientProductDiscount : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "Discount",
                table: "ClientProducts",
                type: "decimal(12,2)",
                precision: 12,
                scale: 2,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DiscountEndsAt",
                table: "ClientProducts",
                type: "datetime2",
                nullable: true);

            // Precios especiales existentes (menores al catálogo) pasan a ser descuento del periodo actual.
            // Estados: Pendiente = 4 (el descuento se usa en el primer cobro). Ciclos: Mensual = 1 (termina en NextChargeAt).
            migrationBuilder.Sql("""
                UPDATE cp SET
                    Discount = p.BasePrice - cp.Price,
                    DiscountEndsAt = CASE WHEN cp.Status = 4 THEN NULL
                                          ELSE COALESCE(CASE WHEN cp.BillingCycle = 1 THEN cp.NextChargeAt ELSE cp.RenewsAt END, '9999-12-31') END
                FROM ClientProducts cp JOIN Products p ON p.Id = cp.ProductId
                WHERE p.BasePrice IS NOT NULL AND cp.Price IS NOT NULL AND cp.Price < p.BasePrice;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Discount",
                table: "ClientProducts");

            migrationBuilder.DropColumn(
                name: "DiscountEndsAt",
                table: "ClientProducts");
        }
    }
}
