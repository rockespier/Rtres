using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class TaxCalendar : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsGoodTaxpayer",
                table: "TaxSettings",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Ruc",
                table: "TaxSettings",
                type: "nvarchar(11)",
                maxLength: 11,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "TaxDueDates",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Period = table.Column<DateOnly>(type: "date", nullable: false),
                    Digit0 = table.Column<DateOnly>(type: "date", nullable: false),
                    Digit1 = table.Column<DateOnly>(type: "date", nullable: false),
                    Digit2And3 = table.Column<DateOnly>(type: "date", nullable: false),
                    Digit4And5 = table.Column<DateOnly>(type: "date", nullable: false),
                    Digit6And7 = table.Column<DateOnly>(type: "date", nullable: false),
                    Digit8And9 = table.Column<DateOnly>(type: "date", nullable: false),
                    GoodTaxpayer = table.Column<DateOnly>(type: "date", nullable: false),
                    FiledAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TaxDueDates", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "TaxDueDates",
                columns: new[] { "Id", "Digit0", "Digit1", "Digit2And3", "Digit4And5", "Digit6And7", "Digit8And9", "FiledAt", "GoodTaxpayer", "Period" },
                values: new object[,]
                {
                    { new Guid("7d000000-0000-0000-0000-202600000001"), new DateOnly(2026, 2, 16), new DateOnly(2026, 2, 17), new DateOnly(2026, 2, 18), new DateOnly(2026, 2, 19), new DateOnly(2026, 2, 20), new DateOnly(2026, 2, 23), null, new DateOnly(2026, 2, 24), new DateOnly(2026, 1, 1) },
                    { new Guid("7d000000-0000-0000-0000-202600000002"), new DateOnly(2026, 3, 16), new DateOnly(2026, 3, 17), new DateOnly(2026, 3, 18), new DateOnly(2026, 3, 19), new DateOnly(2026, 3, 20), new DateOnly(2026, 3, 23), null, new DateOnly(2026, 3, 24), new DateOnly(2026, 2, 1) },
                    { new Guid("7d000000-0000-0000-0000-202600000003"), new DateOnly(2026, 4, 17), new DateOnly(2026, 4, 20), new DateOnly(2026, 4, 21), new DateOnly(2026, 4, 22), new DateOnly(2026, 4, 23), new DateOnly(2026, 4, 24), null, new DateOnly(2026, 4, 27), new DateOnly(2026, 3, 1) },
                    { new Guid("7d000000-0000-0000-0000-202600000004"), new DateOnly(2026, 5, 18), new DateOnly(2026, 5, 19), new DateOnly(2026, 5, 20), new DateOnly(2026, 5, 21), new DateOnly(2026, 5, 22), new DateOnly(2026, 5, 25), null, new DateOnly(2026, 5, 26), new DateOnly(2026, 4, 1) },
                    { new Guid("7d000000-0000-0000-0000-202600000005"), new DateOnly(2026, 6, 15), new DateOnly(2026, 6, 16), new DateOnly(2026, 6, 17), new DateOnly(2026, 6, 18), new DateOnly(2026, 6, 19), new DateOnly(2026, 6, 22), null, new DateOnly(2026, 6, 23), new DateOnly(2026, 5, 1) },
                    { new Guid("7d000000-0000-0000-0000-202600000006"), new DateOnly(2026, 7, 15), new DateOnly(2026, 7, 16), new DateOnly(2026, 7, 17), new DateOnly(2026, 7, 20), new DateOnly(2026, 7, 21), new DateOnly(2026, 7, 22), null, new DateOnly(2026, 7, 24), new DateOnly(2026, 6, 1) },
                    { new Guid("7d000000-0000-0000-0000-202600000007"), new DateOnly(2026, 8, 18), new DateOnly(2026, 8, 19), new DateOnly(2026, 8, 20), new DateOnly(2026, 8, 21), new DateOnly(2026, 8, 24), new DateOnly(2026, 8, 25), null, new DateOnly(2026, 8, 26), new DateOnly(2026, 7, 1) },
                    { new Guid("7d000000-0000-0000-0000-202600000008"), new DateOnly(2026, 9, 15), new DateOnly(2026, 9, 16), new DateOnly(2026, 9, 17), new DateOnly(2026, 9, 18), new DateOnly(2026, 9, 21), new DateOnly(2026, 9, 22), null, new DateOnly(2026, 9, 23), new DateOnly(2026, 8, 1) },
                    { new Guid("7d000000-0000-0000-0000-202600000009"), new DateOnly(2026, 10, 16), new DateOnly(2026, 10, 19), new DateOnly(2026, 10, 20), new DateOnly(2026, 10, 21), new DateOnly(2026, 10, 22), new DateOnly(2026, 10, 23), null, new DateOnly(2026, 10, 26), new DateOnly(2026, 9, 1) },
                    { new Guid("7d000000-0000-0000-0000-202600000010"), new DateOnly(2026, 11, 16), new DateOnly(2026, 11, 17), new DateOnly(2026, 11, 18), new DateOnly(2026, 11, 19), new DateOnly(2026, 11, 20), new DateOnly(2026, 11, 23), null, new DateOnly(2026, 11, 24), new DateOnly(2026, 10, 1) },
                    { new Guid("7d000000-0000-0000-0000-202600000011"), new DateOnly(2026, 12, 17), new DateOnly(2026, 12, 18), new DateOnly(2026, 12, 21), new DateOnly(2026, 12, 22), new DateOnly(2026, 12, 23), new DateOnly(2026, 12, 24), null, new DateOnly(2026, 12, 28), new DateOnly(2026, 11, 1) },
                    { new Guid("7d000000-0000-0000-0000-202600000012"), new DateOnly(2027, 1, 18), new DateOnly(2027, 1, 19), new DateOnly(2027, 1, 20), new DateOnly(2027, 1, 21), new DateOnly(2027, 1, 22), new DateOnly(2027, 1, 25), null, new DateOnly(2027, 1, 26), new DateOnly(2026, 12, 1) }
                });

            migrationBuilder.CreateIndex(
                name: "IX_TaxDueDates_Period",
                table: "TaxDueDates",
                column: "Period",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TaxDueDates");

            migrationBuilder.DropColumn(
                name: "IsGoodTaxpayer",
                table: "TaxSettings");

            migrationBuilder.DropColumn(
                name: "Ruc",
                table: "TaxSettings");
        }
    }
}
