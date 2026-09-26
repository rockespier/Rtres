using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class GitHubTicketSync : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "GithubAuthorLogin",
                table: "TicketComments",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "GithubCommentId",
                table: "TicketComments",
                type: "bigint",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Tickets_GithubIssueNumber",
                table: "Tickets",
                column: "GithubIssueNumber");

            migrationBuilder.CreateIndex(
                name: "IX_TicketComments_GithubCommentId",
                table: "TicketComments",
                column: "GithubCommentId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Tickets_GithubIssueNumber",
                table: "Tickets");

            migrationBuilder.DropIndex(
                name: "IX_TicketComments_GithubCommentId",
                table: "TicketComments");

            migrationBuilder.DropColumn(
                name: "GithubAuthorLogin",
                table: "TicketComments");

            migrationBuilder.DropColumn(
                name: "GithubCommentId",
                table: "TicketComments");
        }
    }
}
