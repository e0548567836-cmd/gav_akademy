using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using students.Helpers;// is valid id
using students.Models;
using students.Data;

namespace students.Controllers
{
    [Route("api/[controller]")] // זה מגדיר את /api/Student
    [ApiController] // זה קריטי כדי שהשרת יזהה את הפונקציות
    public class StudentController : ControllerBase
    {   

        // 1. הצהרה על המשתנה
        private readonly ApplicationDbContext _context;

        // 2. הבנאי (Constructor) שמקבל את ההקשר מהמערכת
        public StudentController(ApplicationDbContext context)
        {
            _context = context;
        }
        [HttpPost("AddStudent")]
        public async Task<IActionResult> AddStudent([FromBody] Student newStudent)
        {
            // 1. בדיקה שהנתונים הגיעו
            if (newStudent == null) return BadRequest("לא התקבלו נתונים");

            // 2. בדיקת תקינות תעודת הזהות
            if (!IsValid.IsValidId(newStudent.StudentId))
            {
                return BadRequest("מספר תעודת הזהות אינו תקין");
            }

            if (!IsValid.IsValidPhoneNumber(newStudent.studentPhone))
            {
                newStudent.studentPhone = "0500000000";
            }
        



            // 3. בדיקה אם הסטודנט כבר קיים (לפי ת"ז) כדי למנוע כפילויות
            var exists = await _context.Students.AnyAsync(s => s.StudentId == newStudent.StudentId);
            if (exists)
            {
                return BadRequest("סטודנט עם תעודת זהות זו כבר רשום במערכת");
            }

            // 4. הוספה לטבלה ושמירה
            _context.Students.Add(newStudent);
            await _context.SaveChangesAsync();

            return Ok("הסטודנט נשמר בהצלחה בבסיס הנתונים");
        }








        ///////////////////////////////////////////

        // 1. פונקציית התחברות (Login)
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] Student loginData)
        {
            // מחפשים סטודנט בבסיס הנתונים עם ה-ID שהוזן
            var student = await _context.Students
                .FirstOrDefaultAsync(s => s.StudentId == loginData.StudentId);

            if (student == null)
            {
                return NotFound("סטודנט לא נמצא");
            }

            if (student.StudentPassword != loginData.StudentPassword)
            {
                return Unauthorized("סיסמה שגויה");
            }

            return Ok(new { studentId = student.StudentId, name = student.studentName });
        }

        // 2. פונקציית עדכון (Update) - עבור דף עריכת הפרופיל
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateStudent(string id, [FromBody] Student updatedData)
        {
            var student = await _context.Students.FirstOrDefaultAsync(s => s.StudentId == id);

            if (student == null) return NotFound("הסטודנט לא נמצא");

            // עדכון השדות
            student.studentName = updatedData.studentName;
            student.studentEmail = updatedData.studentEmail;
            if (!IsValid.IsValidPhoneNumber(updatedData.studentPhone))
            {
                updatedData.studentPhone = "0500000000";
            }

            student.studentPhone = updatedData.studentPhone;

            await _context.SaveChangesAsync();
            return Ok("הנתונים עודכנו בהצלחה");
        }


    }
}
