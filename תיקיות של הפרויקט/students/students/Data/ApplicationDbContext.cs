using Microsoft.EntityFrameworkCore;
using students.Models;

namespace students.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        // טבלאות המערכת
        public DbSet<Student> Students { get; set; }
        public DbSet<Course> Courses { get; set; }
        public DbSet<StudentInCourse> StudentInCourses { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // הגדרת מפתח מורכב לטבלת הרישום (שילוב של תלמיד וקורס)
            modelBuilder.Entity<StudentInCourse>()
                .HasKey(sc => new { sc.StudentId, sc.CourseId });

            // הגדרת מפתח ראשי לסטודנט
            modelBuilder.Entity<Student>()
                .HasKey(s => s.StudentId);

            // הגדרת מפתח ראשי לקורס - מעודכן לשם השדה החדש CourseId
            modelBuilder.Entity<Course>()
                .HasKey(c => c.CourseId);
        }
    }
}