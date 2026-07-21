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
        public DbSet<Message> Messages { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Primary key definitions
            modelBuilder.Entity<StudentInCourse>()
                .HasKey(sc => new { sc.StudentId, sc.CourseId });

            modelBuilder.Entity<Student>()
                .HasKey(s => s.StudentId);

            modelBuilder.Entity<Course>()
                .HasKey(c => c.CourseId);

            modelBuilder.Entity<Material>()
                .HasKey(m => m.MaterialId);

            // Cascade delete: removing a course also removes all its materials
            modelBuilder.Entity<Material>()
                .HasOne<Course>()
                .WithMany()
                .HasForeignKey(m => m.RelatedCourseId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
