using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class TaxDocumentLines : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "TaxDocumentLines",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    TaxDocumentId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ClientProductId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    Description = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: false),
                    Amount = table.Column<decimal>(type: "decimal(12,2)", precision: 12, scale: 2, nullable: false),
                    Order = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TaxDocumentLines", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TaxDocumentLines_ClientProducts_ClientProductId",
                        column: x => x.ClientProductId,
                        principalTable: "ClientProducts",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_TaxDocumentLines_TaxDocuments_TaxDocumentId",
                        column: x => x.TaxDocumentId,
                        principalTable: "TaxDocuments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_TaxDocumentLines_ClientProductId",
                table: "TaxDocumentLines",
                column: "ClientProductId");

            migrationBuilder.CreateIndex(
                name: "IX_TaxDocumentLines_TaxDocumentId",
                table: "TaxDocumentLines",
                column: "TaxDocumentId");

            // Documentos ya emitidos: una línea con el producto de su cobro.
            migrationBuilder.Sql(@"
INSERT INTO TaxDocumentLines (Id, TaxDocumentId, ClientProductId, Description, Amount, [Order])
SELECT NEWID(), d.Id, cp.Id,
       LEFT(COALESCE(p.Name, 'Producto') + CASE WHEN NULLIF(LTRIM(RTRIM(cp.DomainName)), '') IS NULL THEN '' ELSE N' — ' + cp.DomainName END, 300),
       d.TotalAmount, 0
FROM TaxDocuments d
JOIN PaymentTransactions t ON t.Id = d.PaymentTransactionId
JOIN ClientProducts cp ON cp.Id = t.ClientProductId
LEFT JOIN Products p ON p.Id = cp.ProductId;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TaxDocumentLines");
        }
    }
}
