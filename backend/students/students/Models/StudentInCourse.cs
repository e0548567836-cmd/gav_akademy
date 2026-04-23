using System;
using System.ComponentModel.DataAnnotations; // לצורך הגדרות SQL 

namespace students.Models
{
    public class StudentInCourse //student learns course --The unique fields are the combination of StudentId and CourseId number.
    {
    public required string StudentId { get; set; }//student id

    public required string CourseId { get; set; }//course identify

    public bool IsAvailable { get; set; }//is aviable to learn

    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public bool IsInPerson { get; set; }//whants to  learn online or frontaly


    // (Parameterless Constructor)
    public StudentInCourse() { }


    // (Parameterized Constructor)
    public StudentInCourse(string studentId, string courseId)
    {
        StudentId = studentId;
        CourseId = courseId;
        IsAvailable = false;
        Latitude= null;
        Longitude = null;
        IsInPerson = false;// isInPerson;
    }
}
}