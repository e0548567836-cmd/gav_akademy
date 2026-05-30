using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace students.Migrations
{
    /// <inheritdoc />
    public partial class FixMaterialsCascadeDelete : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "RelatedCourseId",
                table: "Materials",
                type: "TEXT",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "INTEGER");

            migrationBuilder.CreateIndex(
                name: "IX_Materials_RelatedCourseId",
                table: "Materials",
                column: "RelatedCourseId");

            migrationBuilder.AddForeignKey(
                name: "FK_Materials_Courses_RelatedCourseId",
                table: "Materials",
                column: "RelatedCourseId",
                principalTable: "Courses",
                principalColumn: "CourseId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Materials_Courses_RelatedCourseId",
                table: "Materials");

            migrationBuilder.DropIndex(
                name: "IX_Materials_RelatedCourseId",
                table: "Materials");

            migrationBuilder.AlterColumn<int>(
                name: "RelatedCourseId",
                table: "Materials",
                type: "INTEGER",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "TEXT");
        }
    }
}
