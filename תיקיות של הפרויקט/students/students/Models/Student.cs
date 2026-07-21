using System;
using System.ComponentModel.DataAnnotations;

namespace students.Models
{
    public class Student
    {
        [Key]
        public required string StudentId { get; set; }

        public string StudentPassword { get; set; } = string.Empty;

        public string studentName { get; set; } = string.Empty;

        public string studentEmail { get; set; } = string.Empty;

        public string studentPhone { get; set; } = string.Empty;

        public double? Grade { get; set; }

        public string? Address { get; set; }

        // false by default; set to true via the MakeAdmin endpoint
        public bool management { get; set; } = false;

        public Student() { }

        public Student(string StudentId, string StudentPassword, string studentName, string studentEmail, string studentPhone)
        {
            this.StudentId = StudentId;
            this.StudentPassword = StudentPassword;
            this.studentName = studentName;
            this.studentEmail = studentEmail;
            this.studentPhone = studentPhone;
            this.management = false;
        }
    }
}
