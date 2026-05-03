using System;
using System.ComponentModel.DataAnnotations;

namespace students.Models
{
    public class StudentInCourse
    {
        public required string StudentId { get; set; }
        public required string CourseId { get; set; } // חזר ל-string

        public bool IsAvailable { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public bool IsInPerson { get; set; }

        public StudentInCourse() { }

        public StudentInCourse(string studentId, string courseId)
        {
            StudentId = studentId;
            CourseId = courseId;
            IsAvailable = false;
            IsInPerson = false;
        }
    }
}