using Microsoft.EntityFrameworkCore;
using students.Models;

namespace students.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<Student> Students { get; set; }
        public DbSet<Course> Courses { get; set; }
        public DbSet<StudentInCourse> StudentInCourses { get; set; }
        public DbSet<Material> Materials { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // 1. הגדרת מפתחות ראשיים (הקוד הקיים שלך)
            modelBuilder.Entity<StudentInCourse>()
                .HasKey(sc => new { sc.StudentId, sc.CourseId });

            modelBuilder.Entity<Student>()
                .HasKey(s => s.StudentId);

            modelBuilder.Entity<Course>()
                .HasKey(c => c.CourseId);

            modelBuilder.Entity<Material>()
                .HasKey(m => m.MaterialId);

            // 2. הגדרת הקשר והמחיקה המשורשרת (התיקון החדש עבור אסתי)
            modelBuilder.Entity<Material>()
                .HasOne<Course>()                       // לכל חומר לימודי יש קורס אחד אליו הוא שייך
                .WithMany()                             // לקורס אחד יכולים להיות חומרים לימודיים רבים
                .HasForeignKey(m => m.RelatedCourseId)  // שדה הקישור (המפתח הזר) בטבלת Materials
                .OnDelete(DeleteBehavior.Cascade);      // הפעלת מחיקה משורשרת אוטומטית (Cascade Delete)
        }
    }
}