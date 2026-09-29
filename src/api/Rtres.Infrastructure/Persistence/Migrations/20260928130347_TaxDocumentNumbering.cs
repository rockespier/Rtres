using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class TaxDocumentNumbering : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "FacturaNextNumber",
                table: "TaxSettings",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<string>(
                name: "FacturaSeries",
                table: "TaxSettings",
                type: "nvarchar(4)",
                maxLength: 4,
                nullable: false,
                defaultValue: "F001");

            migrationBuilder.AddColumn<int>(
                name: "ReciboNextNumber",
                table: "TaxSettings",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<string>(
                name: "ReciboSeries",
                table: "TaxSettings",
                type: "nvarchar(4)",
                maxLength: 4,
                nullable: false,
                defaultValue: "E001");

            migrationBuilder.AddColumn<int>(
                name: "TaxDocumentType",
                table: "Products",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "RequiresTaxDocument",
                table: "Clients",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.CreateIndex(
                name: "IX_TaxDocuments_PaymentTransactionId",
                table: "TaxDocuments",
                column: "PaymentTransactionId",
                unique: true,
                filter: "[PaymentTransactionId] IS NOT NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_TaxDocuments_PaymentTransactionId",
                table: "TaxDocuments");

            migrationBuilder.DropColumn(
                name: "FacturaNextNumber",
                table: "TaxSettings");

            migrationBuilder.DropColumn(
                name: "FacturaSeries",
                table: "TaxSettings");

            migrationBuilder.DropColumn(
                name: "ReciboNextNumber",
                table: "TaxSettings");

            migrationBuilder.DropColumn(
                name: "ReciboSeries",
                table: "TaxSettings");

            migrationBuilder.DropColumn(
                name: "TaxDocumentType",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "RequiresTaxDocument",
                table: "Clients");
        }
    }
}
