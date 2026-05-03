using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using students.Helpers;
using students.Models;
using students.Data;
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

        [HttpPost("AddStudent")]
        public async Task<IActionResult> AddStudent([FromBody] Student newStudent)
        {
            if (newStudent == null) return BadRequest("לא התקבלו נתונים");
            if (!IsValid.IsValidId(newStudent.StudentId)) return BadRequest("מספר תעודת הזהות אינו תקין");

            var exists = await _context.Students.AnyAsync(s => s.StudentId == newStudent.StudentId);
            if (exists) return BadRequest("סטודנט עם תעודת זהות זו כבר רשום במערכת");

            _context.Students.Add(newStudent);
            await _context.SaveChangesAsync();
            return Ok("הסטודנט נשמר בהצלחה");
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] Student loginData)
        {
            var student = await _context.Students.FirstOrDefaultAsync(s => s.StudentId == loginData.StudentId);
            if (student == null) return NotFound("סטודנט לא נמצא");
            if (student.StudentPassword != loginData.StudentPassword) return Unauthorized("סיסמה שגויה");
            // מחזירים גם את ה-studentId וגם את השם כדי שהפלאטר יוכל להשתמש בהם למעבר בין דפים
            return Ok(new { studentId = student.StudentId, name = student.studentName, management = student.management });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateStudent(string id, [FromBody] JsonElement updatedData)
        {
            // חיפוש הסטודנט לפי תעודת הזהות (id) שמגיעה מה-URL
            var student = await _context.Students.FirstOrDefaultAsync(s => s.StudentId == id);
            if (student == null) return NotFound("הסטודנט לא נמצא");

            try
            {
                // עדכון שם הסטודנט אם הוא קיים בבקשה
                if (updatedData.TryGetProperty("studentName", out var nameProp))
                {
                    student.studentName = nameProp.GetString();
                }

                // עדכון אימייל אם הוא קיים בבקשה
                if (updatedData.TryGetProperty("studentEmail", out var emailProp))
                {
                    student.studentEmail = emailProp.GetString();
                }

                // עדכון טלפון אם הוא קיים בבקשה
                if (updatedData.TryGetProperty("studentPhone", out var phoneProp))
                {
                    string phone = phoneProp.GetString();
                    // שימוש בפונקציית העזר לבדיקת תקינות הטלפון
                    student.studentPhone = IsValid.IsValidPhoneNumber(phone) ? phone : student.studentPhone;
                }

                await _context.SaveChangesAsync();
                return Ok("הנתונים עודכנו בהצלחה");
            }
            catch (Exception ex)
            {
                return BadRequest("שגיאה בעדכון הנתונים: " + ex.Message);
            }
        }
    }
}