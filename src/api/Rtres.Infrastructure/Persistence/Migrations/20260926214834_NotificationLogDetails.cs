using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class NotificationLogDetails : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DedupeKey",
                table: "NotificationLogs",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Error",
                table: "NotificationLogs",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Recipient",
                table: "NotificationLogs",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_NotificationLogs_DedupeKey",
                table: "NotificationLogs",
                column: "DedupeKey");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_NotificationLogs_DedupeKey",
                table: "NotificationLogs");

            migrationBuilder.DropColumn(
                name: "DedupeKey",
                table: "NotificationLogs");

            migrationBuilder.DropColumn(
                name: "Error",
                table: "NotificationLogs");

            migrationBuilder.DropColumn(
                name: "Recipient",
                table: "NotificationLogs");
        }
    }
}
