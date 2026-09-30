using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class FinanceIncomeModel : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "RetentionAmount",
                table: "TaxDocuments",
                type: "decimal(12,2)",
                precision: 12,
                scale: 2,
                nullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "ClientProductId",
                table: "PaymentTransactions",
                type: "uniqueidentifier",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier");

            migrationBuilder.AddColumn<Guid>(
                name: "ClientId",
                table: "PaymentTransactions",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<string>(
                name: "Notes",
                table: "PaymentTransactions",
                type: "nvarchar(max)",
                nullable: true);

            // Cada cobro guarda su cliente (antes solo se llegaba por el producto).
            migrationBuilder.Sql("UPDATE pt SET ClientId = cp.ClientId FROM PaymentTransactions pt JOIN ClientProducts cp ON cp.Id = pt.ClientProductId;");

            // Un ingreso = un cobro: los comprobantes emitidos a mano sin transacción pasan a tener su cobro (misma fecha y
            // monto; PEN al tipo de cambio más cercano a la fecha, como RateToPenAsync), así ya no se cuentan por separado.
            migrationBuilder.Sql("""
                DECLARE @Nuevos TABLE (DocumentId UNIQUEIDENTIFIER, PaymentId UNIQUEIDENTIFIER);
                INSERT INTO @Nuevos SELECT Id, NEWID() FROM TaxDocuments WHERE PaymentTransactionId IS NULL;
                INSERT INTO PaymentTransactions (Id, ClientId, ClientProductId, PayPalOrderIdOrSubscriptionId, Amount, Currency, Status, Method, Years, AmountPen, InternalCode, CreatedAt, Notes)
                SELECT n.PaymentId, d.ClientId, NULL, CONCAT('MANUAL-', REPLACE(CONVERT(VARCHAR(36), n.PaymentId), '-', '')), d.TotalAmount, d.Currency, 'COMPLETED', 'Transferencia', 1,
                       d.TotalAmount * CASE WHEN d.Currency = 'PEN' THEN 1 ELSE ISNULL((SELECT TOP 1 r.RateToPen FROM ExchangeRates r WHERE r.CurrencyCode = d.Currency ORDER BY ABS(DATEDIFF(DAY, r.[Date], d.IssueDate))), 1) END,
                       NULL, DATEADD(HOUR, 12, CAST(d.IssueDate AS DATETIME2)), CONCAT('Comprobante ', d.Series, '-', d.Number)
                FROM @Nuevos n JOIN TaxDocuments d ON d.Id = n.DocumentId;
                UPDATE d SET PaymentTransactionId = n.PaymentId FROM TaxDocuments d JOIN @Nuevos n ON n.DocumentId = d.Id;
                """);

            migrationBuilder.CreateIndex(
                name: "IX_PaymentTransactions_ClientId_CreatedAt",
                table: "PaymentTransactions",
                columns: new[] { "ClientId", "CreatedAt" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_PaymentTransactions_ClientId_CreatedAt",
                table: "PaymentTransactions");

            migrationBuilder.DropColumn(
                name: "RetentionAmount",
                table: "TaxDocuments");

            migrationBuilder.DropColumn(
                name: "ClientId",
                table: "PaymentTransactions");

            migrationBuilder.DropColumn(
                name: "Notes",
                table: "PaymentTransactions");

            migrationBuilder.AlterColumn<Guid>(
                name: "ClientProductId",
                table: "PaymentTransactions",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier",
                oldNullable: true);
        }
    }
}
