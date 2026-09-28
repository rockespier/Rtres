using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class ProductPayPalPlan : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PayPalPlanId",
                table: "Products",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "PayPalPlanPrice",
                table: "Products",
                type: "decimal(12,2)",
                precision: 12,
                scale: 2,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PayPalPlanId",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "PayPalPlanPrice",
                table: "Products");
        }
    }
}
