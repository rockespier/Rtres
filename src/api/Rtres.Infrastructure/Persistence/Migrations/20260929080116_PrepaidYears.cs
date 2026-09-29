using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class PrepaidYears : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Years",
                table: "PaymentTransactions",
                type: "int",
                nullable: false,
                defaultValue: 1); // los pagos existentes cubren un periodo

            migrationBuilder.AddColumn<int>(
                name: "PayPalOrderYears",
                table: "ClientProducts",
                type: "int",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Years",
                table: "PaymentTransactions");

            migrationBuilder.DropColumn(
                name: "PayPalOrderYears",
                table: "ClientProducts");
        }
    }
}
