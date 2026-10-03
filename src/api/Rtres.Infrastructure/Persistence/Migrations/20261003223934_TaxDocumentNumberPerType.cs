using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class TaxDocumentNumberPerType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_TaxDocuments_Series_Number",
                table: "TaxDocuments");

            migrationBuilder.CreateIndex(
                name: "IX_TaxDocuments_Type_Series_Number",
                table: "TaxDocuments",
                columns: new[] { "Type", "Series", "Number" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_TaxDocuments_Type_Series_Number",
                table: "TaxDocuments");

            migrationBuilder.CreateIndex(
                name: "IX_TaxDocuments_Series_Number",
                table: "TaxDocuments",
                columns: new[] { "Series", "Number" },
                unique: true);
        }
    }
}
