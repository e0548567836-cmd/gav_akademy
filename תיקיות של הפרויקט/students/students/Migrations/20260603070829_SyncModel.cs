using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace students.Migrations
{
    /// <inheritdoc />
    public partial class SyncModel : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Address",
                table: "Students",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "Grade",
                table: "Students",
                type: "REAL",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Address",
                table: "StudentInCourses",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "MaxDistanceKm",
                table: "StudentInCourses",
                type: "REAL",
                nullable: true);

           
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Address",
                table: "Students");

            migrationBuilder.DropColumn(
                name: "Grade",
                table: "Students");

            migrationBuilder.DropColumn(
                name: "Address",
                table: "StudentInCourses");

            migrationBuilder.DropColumn(
                name: "MaxDistanceKm",
                table: "StudentInCourses");

            
        }
    }
}
