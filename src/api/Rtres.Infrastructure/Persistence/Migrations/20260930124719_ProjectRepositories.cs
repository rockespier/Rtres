using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Rtres.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class ProjectRepositories : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "RepositoryId",
                table: "Tickets",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "ProjectRepositories",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ProjectId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Owner = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Label = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsDefault = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProjectRepositories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ProjectRepositories_Projects_ProjectId",
                        column: x => x.ProjectId,
                        principalTable: "Projects",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ProjectRepositories_Owner_Name",
                table: "ProjectRepositories",
                columns: new[] { "Owner", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ProjectRepositories_ProjectId",
                table: "ProjectRepositories",
                column: "ProjectId");

            // El repo de cada proyecto pasa a ser su repositorio principal (si dos proyectos compartían repo, se queda con el primero).
            migrationBuilder.Sql(@"
INSERT INTO ProjectRepositories (Id, ProjectId, Owner, Name, Label, IsDefault)
SELECT NEWID(), x.Id, x.Owner, x.Name, NULL, 1
FROM (SELECT p.Id, LTRIM(RTRIM(p.GithubRepoOwner)) AS Owner, LTRIM(RTRIM(p.GithubRepoName)) AS Name,
             ROW_NUMBER() OVER (PARTITION BY LTRIM(RTRIM(p.GithubRepoOwner)), LTRIM(RTRIM(p.GithubRepoName)) ORDER BY p.Id) AS n
      FROM Projects p WHERE LTRIM(RTRIM(p.GithubRepoOwner)) <> '' AND LTRIM(RTRIM(p.GithubRepoName)) <> '') x
WHERE x.n = 1;
UPDATE t SET RepositoryId = r.Id FROM Tickets t JOIN ProjectRepositories r ON r.ProjectId = t.ProjectId WHERE t.GithubIssueNumber IS NOT NULL;");

            migrationBuilder.DropColumn(
                name: "GithubRepoName",
                table: "Projects");

            migrationBuilder.DropColumn(
                name: "GithubRepoOwner",
                table: "Projects");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "GithubRepoName",
                table: "Projects",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "GithubRepoOwner",
                table: "Projects",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            // Vuelve al repo principal de cada proyecto; los repositorios adicionales se pierden.
            migrationBuilder.Sql(@"
UPDATE p SET GithubRepoOwner = r.Owner, GithubRepoName = r.Name
FROM Projects p CROSS APPLY (SELECT TOP 1 Owner, Name FROM ProjectRepositories WHERE ProjectId = p.Id ORDER BY IsDefault DESC) r;");

            migrationBuilder.DropTable(
                name: "ProjectRepositories");

            migrationBuilder.DropColumn(
                name: "RepositoryId",
                table: "Tickets");
        }
    }
}
