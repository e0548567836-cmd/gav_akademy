using System;
using System.ComponentModel.DataAnnotations; // לצורך הגדרות SQL
                                            
                                             
namespace students.Models
{
    public class Student
    {
        public required string StudentId { get; set; }//student id

        public  string StudentPassword { get; set; }= string.Empty;//student passward

        public string studentName { get; set; } = string.Empty;//student name

        public string studentEmail { get; set; } = string.Empty;//student email

        public string studentPhone { get; set; } = string.Empty;//student phon

        public Student() { }

        public Student(string StudentId,string StudentPassword, string studentName, string studentEmail, string studentPhone)
        {
            this.StudentId = StudentId;
            this.StudentPassword = StudentPassword;
            this.studentName = studentName;
            this.studentEmail = studentEmail;
            this.studentPhone = studentPhone;
        }


    }
}
