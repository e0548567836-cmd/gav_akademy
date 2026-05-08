using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using students.Data;
using students.Models;
using students.Helpers;
using System.Text.Json;

namespace students.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StudentController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public StudentController(ApplicationDbContext context)
        {
            _context = context;
        }

        // 1. שליפת סטודנט לפי ID (מהפרויקט הגדול)
        [HttpGet("{id}")]
        public async Task<IActionResult> GetStudent(string id)
        {
            var student = await _context.Students.FirstOrDefaultAsync(s => s.StudentId == id);
            if (student == null) return NotFound("הסטודנט לא נמצא");

            return Ok(new
            {
                studentName = student.studentName,
                studentEmail = student.studentEmail,
                studentPhone = student.studentPhone,
                management = student.management
            });
        }

        // 2. הוספת סטודנט (משלב את הלוגיקה שלך עם הבדיקות)
        [HttpPost("AddStudent")]
        public async Task<IActionResult> AddStudent([FromBody] Student newStudent)
        {
            if (newStudent == null) return BadRequest("לא התקבלו נתונים");

            // בדיקת ת"ז מהקוד שלך
            if (!IsValid.IsValidId(newStudent.StudentId))
                return BadRequest("מספר תעודת הזהות אינו תקין");

            // בדיקת טלפון מהקוד שלך - קביעת ברירת מחדל אם לא תקין
            if (!IsValid.IsValidPhoneNumber(newStudent.studentPhone))
            {
                newStudent.studentPhone = "0500000000";
            }

            var exists = await _context.Students.AnyAsync(s => s.StudentId == newStudent.StudentId);
            if (exists) return BadRequest("סטודנט עם תעודת זהות זו כבר רשום במערכת");

            _context.Students.Add(newStudent);
            await _context.SaveChangesAsync();

            return Ok("הסטודנט נשמר בהצלחה");
        }

        // 3. התחברות (כולל שדה management מהפרויקט הגדול)
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] Student loginData)
        {
            var student = await _context.Students
                .FirstOrDefaultAsync(s => s.StudentId == loginData.StudentId);

            if (student == null) return NotFound("סטודנט לא נמצא");

            if (student.StudentPassword != loginData.StudentPassword)
                return Unauthorized("סיסמה שגויה");

            // החזרת הנתונים כולל הרשאת ניהול
            return Ok(new
            {
                studentId = student.StudentId,
                name = student.studentName,
                management = student.management
            });
        }

        // 4. עדכון סטודנט (משתמש בשיטה הדינמית והחזקה מהפרויקט הגדול)
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateStudent(string id, [FromBody] JsonElement updatedData)
        {
            var student = await _context.Students.FirstOrDefaultAsync(s => s.StudentId == id);
            if (student == null) return NotFound("הסטודנט לא נמצא");

            try
            {
                if (updatedData.TryGetProperty("studentName", out var nameProp))
                {
                    student.studentName = nameProp.GetString();
                }

                if (updatedData.TryGetProperty("studentEmail", out var emailProp))
                {
                    student.studentEmail = emailProp.GetString();
                }

                if (updatedData.TryGetProperty("studentPhone", out var phoneProp))
                {
                    var phone = phoneProp.GetString();
                    // ולידציה לטלפון מהקוד המקומי שלך
                    if (!string.IsNullOrWhiteSpace(phone) && IsValid.IsValidPhoneNumber(phone))
                        student.studentPhone = phone;
                    else
                        student.studentPhone = "0500000000";
                }

                await _context.SaveChangesAsync();
                return Ok("הנתונים עודכנו בהצלחה");
            }
            catch (Exception ex)
            {
                return BadRequest("שגיאה בעדכון הנתונים: " + ex.Message);
            }
        }

        // 5. התחברות עם גוגל (מהפרויקט הגדול)
        [HttpPost("google-signin")]
        public async Task<IActionResult> GoogleSignIn([FromBody] GoogleSignInRequest request)
        {
            if (string.IsNullOrEmpty(request.Email))
                return BadRequest("לא התקבל אימייל");

            var student = await _context.Students
                .FirstOrDefaultAsync(s => s.studentEmail == request.Email);

            if (student == null)
                return Ok(new { isNewUser = true, email = request.Email, name = request.Name });

            return Ok(new
            {
                isNewUser = false,
                studentId = student.StudentId,
                name = student.studentName,
                management = student.management
            });
        }
    }

    public class GoogleSignInRequest
    {
        public string Email { get; set; }
        public string Name { get; set; }
    }
}