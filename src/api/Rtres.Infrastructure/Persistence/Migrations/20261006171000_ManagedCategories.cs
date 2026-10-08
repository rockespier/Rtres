using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class ManagedCategories : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ExpenseCategories",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    IsIncomeTax = table.Column<bool>(type: "bit", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExpenseCategories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ProductCategories",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProductCategories", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "ExpenseCategories",
                columns: new[] { "Id", "Code", "IsIncomeTax", "Name", "SortOrder" },
                values: new object[,]
                {
                    { new Guid("e0000000-0000-0000-0000-000000000000"), "Hosting", false, "Hosting", 0 },
                    { new Guid("e0000000-0000-0000-0000-000000000001"), "Dominios", false, "Dominios", 1 },
                    { new Guid("e0000000-0000-0000-0000-000000000002"), "SuscripcionesIA", false, "Suscripciones IA", 2 },
                    { new Guid("e0000000-0000-0000-0000-000000000003"), "ApisPorUso", false, "APIs por uso", 3 },
                    { new Guid("e0000000-0000-0000-0000-000000000004"), "Sueldos", false, "Sueldos", 4 },
                    { new Guid("e0000000-0000-0000-0000-000000000005"), "Otros", false, "Otros", 5 },
                    { new Guid("e0000000-0000-0000-0000-000000000006"), "ImpuestoRenta", true, "Impuesto a la Renta", 6 },
                    { new Guid("e0000000-0000-0000-0000-000000000007"), "Comisiones", false, "Comisiones", 7 }
                });

            // Los gastos existentes pasan del antiguo enum (entero 0-7) a la categoría sembrada con el mismo orden.
            migrationBuilder.AddColumn<Guid>(
                name: "CategoryId",
                table: "Expenses",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("e0000000-0000-0000-0000-000000000005"));

            migrationBuilder.Sql("""
                UPDATE Expenses SET CategoryId = CONVERT(uniqueidentifier, 'E0000000-0000-0000-0000-00000000000' + CAST(Category AS varchar(1)))
                WHERE Category BETWEEN 0 AND 7;
                """);

            migrationBuilder.DropColumn(
                name: "Category",
                table: "Expenses");

            // Las categorías que ya usan los productos (texto libre) pasan a la lista administrable.
            migrationBuilder.Sql("""
                INSERT INTO ProductCategories (Id, Name, SortOrder)
                SELECT NEWID(), Name, ROW_NUMBER() OVER (ORDER BY Name) - 1
                FROM (SELECT DISTINCT LTRIM(RTRIM(Category)) AS Name FROM Products WHERE Category IS NOT NULL AND LTRIM(RTRIM(Category)) <> '') AS c;
                UPDATE Products SET Category = LTRIM(RTRIM(Category)) WHERE Category IS NOT NULL;
                """);

            migrationBuilder.CreateIndex(
                name: "IX_Expenses_CategoryId",
                table: "Expenses",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_ExpenseCategories_Name",
                table: "ExpenseCategories",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ProductCategories_Name",
                table: "ProductCategories",
                column: "Name",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Expenses_ExpenseCategories_CategoryId",
                table: "Expenses",
                column: "CategoryId",
                principalTable: "ExpenseCategories",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Expenses_ExpenseCategories_CategoryId",
                table: "Expenses");

            migrationBuilder.DropIndex(
                name: "IX_Expenses_CategoryId",
                table: "Expenses");

            migrationBuilder.AddColumn<int>(
                name: "Category",
                table: "Expenses",
                type: "int",
                nullable: false,
                defaultValue: 5);

            // Las de sistema recuperan su valor del enum (último dígito del id); las creadas después vuelven a "Otros" (5).
            migrationBuilder.Sql("""
                UPDATE Expenses SET Category = CAST(RIGHT(CONVERT(varchar(36), CategoryId), 1) AS int)
                WHERE CONVERT(varchar(36), CategoryId) LIKE 'E0000000-0000-0000-0000-00000000000[0-7]';
                """);

            migrationBuilder.DropColumn(
                name: "CategoryId",
                table: "Expenses");

            migrationBuilder.DropTable(
                name: "ExpenseCategories");

            migrationBuilder.DropTable(
                name: "ProductCategories");
        }
    }
}
