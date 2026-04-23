using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace students.Migrations
{
    /// <inheritdoc />
    public partial class T1 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_StudentsInCourses",
                table: "StudentsInCourses");

            migrationBuilder.RenameTable(
                name: "StudentsInCourses",
                newName: "StudentInCourses");

            migrationBuilder.AddPrimaryKey(
                name: "PK_StudentInCourses",
                table: "StudentInCourses",
                columns: new[] { "StudentId", "CourseId" });

            migrationBuilder.CreateTable(
                name: "Students",
                columns: table => new
                {
                    StudentId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    studentName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    studentEmail = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    studentPhone = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Students", x => x.StudentId);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Students");

            migrationBuilder.DropPrimaryKey(
                name: "PK_StudentInCourses",
                table: "StudentInCourses");

            migrationBuilder.RenameTable(
                name: "StudentInCourses",
                newName: "StudentsInCourses");

            migrationBuilder.AddPrimaryKey(
                name: "PK_StudentsInCourses",
                table: "StudentsInCourses",
                columns: new[] { "StudentId", "CourseId" });
        }
    }
}
