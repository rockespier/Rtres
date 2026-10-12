using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AnnualRentaAnd1662 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "Use1662AsCredit",
                table: "TaxSettings",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<decimal>(
                name: "IgvPaid",
                table: "TaxDueDates",
                type: "decimal(12,2)",
                precision: 12,
                scale: 2,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "RentaPaid",
                table: "TaxDueDates",
                type: "decimal(12,2)",
                precision: 12,
                scale: 2,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ForeignSupplierCountry",
                table: "Expenses",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ForeignSupplierName",
                table: "Expenses",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Form1662Number",
                table: "Expenses",
                type: "nvarchar(40)",
                maxLength: 40,
                nullable: true);

            migrationBuilder.AddColumn<DateOnly>(
                name: "Form1662PaidAt",
                table: "Expenses",
                type: "date",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsNonDeductible",
                table: "Expenses",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsNonDomiciledService",
                table: "Expenses",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeductible",
                table: "ExpenseCategories",
                type: "bit",
                nullable: false,
                defaultValue: true);

            // Cuotas de deuda con SUNAT y el préstamo para pagarla: son pago de deuda, no gasto (confirmado con el contador). Siguen en "Otros".
            migrationBuilder.Sql(@"UPDATE Expenses SET IsNonDeductible = 1
WHERE LTRIM(Description) LIKE N'Fracc SUNAT%' OR LTRIM(Description) LIKE N'Prestamo SUNAT%' OR LTRIM(Description) LIKE N'Préstamo SUNAT%'
   OR LTRIM(Description) LIKE N'PDT%' OR LTRIM(Description) LIKE N'Deuda Leslie%'");

            migrationBuilder.CreateTable(
                name: "AnnualTaxSettings",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Year = table.Column<int>(type: "int", nullable: false),
                    Uit = table.Column<decimal>(type: "decimal(12,2)", precision: 12, scale: 2, nullable: false),
                    ThresholdUits = table.Column<decimal>(type: "decimal(6,2)", precision: 6, scale: 2, nullable: false),
                    LowRate = table.Column<decimal>(type: "decimal(5,4)", precision: 5, scale: 4, nullable: false),
                    HighRate = table.Column<decimal>(type: "decimal(5,4)", precision: 5, scale: 4, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AnnualTaxSettings", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "AnnualTaxSettings",
                columns: new[] { "Id", "HighRate", "LowRate", "ThresholdUits", "Uit", "Year" },
                values: new object[] { new Guid("a7000000-0000-0000-0000-000000002026"), 0.295m, 0.10m, 15m, 5500m, 2026 });

            migrationBuilder.UpdateData(
                table: "ExpenseCategories",
                keyColumn: "Id",
                keyValue: new Guid("e0000000-0000-0000-0000-000000000000"),
                column: "IsDeductible",
                value: true);

            migrationBuilder.UpdateData(
                table: "ExpenseCategories",
                keyColumn: "Id",
                keyValue: new Guid("e0000000-0000-0000-0000-000000000001"),
                column: "IsDeductible",
                value: true);

            migrationBuilder.UpdateData(
                table: "ExpenseCategories",
                keyColumn: "Id",
                keyValue: new Guid("e0000000-0000-0000-0000-000000000002"),
                column: "IsDeductible",
                value: true);

            migrationBuilder.UpdateData(
                table: "ExpenseCategories",
                keyColumn: "Id",
                keyValue: new Guid("e0000000-0000-0000-0000-000000000003"),
                column: "IsDeductible",
                value: true);

            migrationBuilder.UpdateData(
                table: "ExpenseCategories",
                keyColumn: "Id",
                keyValue: new Guid("e0000000-0000-0000-0000-000000000004"),
                column: "IsDeductible",
                value: true);

            migrationBuilder.UpdateData(
                table: "ExpenseCategories",
                keyColumn: "Id",
                keyValue: new Guid("e0000000-0000-0000-0000-000000000005"),
                column: "IsDeductible",
                value: true);

            migrationBuilder.UpdateData(
                table: "ExpenseCategories",
                keyColumn: "Id",
                keyValue: new Guid("e0000000-0000-0000-0000-000000000006"),
                column: "IsDeductible",
                value: true);

            migrationBuilder.UpdateData(
                table: "ExpenseCategories",
                keyColumn: "Id",
                keyValue: new Guid("e0000000-0000-0000-0000-000000000007"),
                column: "IsDeductible",
                value: true);

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000001"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000002"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000003"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000004"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000005"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000006"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000007"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000008"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000009"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000010"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000011"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "TaxDueDates",
                keyColumn: "Id",
                keyValue: new Guid("7d000000-0000-0000-0000-202600000012"),
                columns: new[] { "IgvPaid", "RentaPaid" },
                values: new object[] { null, null });

            migrationBuilder.CreateIndex(
                name: "IX_AnnualTaxSettings_Year",
                table: "AnnualTaxSettings",
                column: "Year",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AnnualTaxSettings");

            migrationBuilder.DropColumn(
                name: "Use1662AsCredit",
                table: "TaxSettings");

            migrationBuilder.DropColumn(
                name: "IgvPaid",
                table: "TaxDueDates");

            migrationBuilder.DropColumn(
                name: "RentaPaid",
                table: "TaxDueDates");

            migrationBuilder.DropColumn(
                name: "ForeignSupplierCountry",
                table: "Expenses");

            migrationBuilder.DropColumn(
                name: "ForeignSupplierName",
                table: "Expenses");

            migrationBuilder.DropColumn(
                name: "Form1662Number",
                table: "Expenses");

            migrationBuilder.DropColumn(
                name: "Form1662PaidAt",
                table: "Expenses");

            migrationBuilder.DropColumn(
                name: "IsNonDeductible",
                table: "Expenses");

            migrationBuilder.DropColumn(
                name: "IsNonDomiciledService",
                table: "Expenses");

            migrationBuilder.DropColumn(
                name: "IsDeductible",
                table: "ExpenseCategories");
        }
    }
}
