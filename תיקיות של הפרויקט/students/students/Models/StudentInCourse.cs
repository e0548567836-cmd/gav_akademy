using System;
using System.ComponentModel.DataAnnotations;

namespace students.Models
{
    public class StudentInCourse
    {
        [Required]
        public required string StudentId { get; set; }

        [Required]
        public required string CourseId { get; set; }

        public bool IsAvailable { get; set; }

        public double? Latitude { get; set; }

        public double? Longitude { get; set; }

        public bool IsInPerson { get; set; }

        public double? MaxDistanceKm { get; set; }

        public bool WantsHelp { get; set; } = false;

        public bool WantsToTeach { get; set; } = false;

        public bool WantsPartner { get; set; } = false;

        // Parameterless constructor required by Entity Framework
        public StudentInCourse() { }

        // Constructor for creating a new enrollment record
        public StudentInCourse(string studentId, string courseId)
        {
            StudentId = studentId;
            CourseId = courseId;

            IsAvailable = false;

            Latitude = null;
            Longitude = null;

            IsInPerson = false;

            MaxDistanceKm = null;

            WantsHelp = false;
            WantsToTeach = false;
            WantsPartner = false;
        }
    }
}
