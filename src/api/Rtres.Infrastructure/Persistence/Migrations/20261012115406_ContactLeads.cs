using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class ContactLeads : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ContactLeads",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Phone = table.Column<string>(type: "nvarchar(40)", maxLength: 40, nullable: true),
                    Company = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    Service = table.Column<string>(type: "nvarchar(60)", maxLength: 60, nullable: true),
                    Message = table.Column<string>(type: "nvarchar(4000)", maxLength: 4000, nullable: false),
                    Locale = table.Column<string>(type: "nvarchar(2)", maxLength: 2, nullable: false),
                    SourcePage = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    Status = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ContactLeads", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ContactLeads_CreatedAt",
                table: "ContactLeads",
                column: "CreatedAt");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ContactLeads");
        }
    }
}
