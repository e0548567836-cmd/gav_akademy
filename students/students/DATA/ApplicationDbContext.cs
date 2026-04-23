using System.Collections.Generic;
using System.Reflection.Emit;
using Microsoft.EntityFrameworkCore;
using students.Models;

namespace students.Data
{
    public class ApplicationDbContext : DbContext
    {
        // הקונסטרקטור הזה מאפשר למערכת להעביר הגדרות (כמו הכתובת של ה-SQL) לתוך ה-Context
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // השורה הזו אומרת ל-Entity Framework ליצור טבלה ב-SQL שמבוססת על המודל StudentInCourse
        public DbSet<StudentInCourse> StudentInCourses { get; set; }

        public DbSet<Student> Students { get; set; }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // מכיוון שאין לנו שדה אחד שנקרא "Id", אנחנו מגדירים ששני השדות יחד הם המפתח
            // זה נקרא Composite Key (מפתח מורכב)
            modelBuilder.Entity<StudentInCourse>()
                .HasKey(sc => new { sc.StudentId, sc.CourseId });


            modelBuilder.Entity<Student>()
                .HasKey(sc => new { sc.StudentId });
        }
    }
}