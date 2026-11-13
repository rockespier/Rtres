using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class UserAreaJobTitleManager : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Area",
                table: "UserAccounts",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "JobTitle",
                table: "UserAccounts",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ManagerId",
                table: "UserAccounts",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserAccounts_ManagerId",
                table: "UserAccounts",
                column: "ManagerId");

            migrationBuilder.AddForeignKey(
                name: "FK_UserAccounts_UserAccounts_ManagerId",
                table: "UserAccounts",
                column: "ManagerId",
                principalTable: "UserAccounts",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_UserAccounts_UserAccounts_ManagerId",
                table: "UserAccounts");

            migrationBuilder.DropIndex(
                name: "IX_UserAccounts_ManagerId",
                table: "UserAccounts");

            migrationBuilder.DropColumn(
                name: "Area",
                table: "UserAccounts");

            migrationBuilder.DropColumn(
                name: "JobTitle",
                table: "UserAccounts");

            migrationBuilder.DropColumn(
                name: "ManagerId",
                table: "UserAccounts");
        }
    }
}
