using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace students.Migrations
{
    /// <inheritdoc />
    public partial class AddWantsPartner : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "WantsPartner",
                table: "StudentInCourses",
                type: "INTEGER",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "WantsPartner",
                table: "StudentInCourses");
        }
    }
}
