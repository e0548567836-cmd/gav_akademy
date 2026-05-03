using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication;
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

        [HttpGet("{id}")]
        public async Task<IActionResult> GetStudent(string id)
        {
            var student = await _context.Students.FirstOrDefaultAsync(s => s.StudentId == id);
            if (student == null) return NotFound("הסטודנט לא נמצא");
            return Ok(new
            {
                studentName = student.studentName,
                studentEmail = student.studentEmail,
                studentPhone = student.studentPhone
            });
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
            return Ok(new { studentId = student.StudentId, name = student.studentName, management = student.management });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateStudent(string id, [FromBody] JsonElement updatedData)
        {
            var student = await _context.Students.FirstOrDefaultAsync(s => s.StudentId == id);
            if (student == null) return NotFound("הסטודנט לא נמצא");
            try
            {
                if (updatedData.TryGetProperty("studentName", out var nameProp))
                {
                    var name = nameProp.GetString();
                    if (!string.IsNullOrWhiteSpace(name))
                        student.studentName = name;
                }
                if (updatedData.TryGetProperty("studentEmail", out var emailProp))
                {
                    var email = emailProp.GetString();
                    if (!string.IsNullOrWhiteSpace(email))
                        student.studentEmail = email;
                }
                if (updatedData.TryGetProperty("studentPhone", out var phoneProp))
                {
                    var phone = phoneProp.GetString();
                    if (!string.IsNullOrWhiteSpace(phone) && IsValid.IsValidPhoneNumber(phone))
                        student.studentPhone = phone;
                }
                await _context.SaveChangesAsync();
                return Ok("הנתונים עודכנו בהצלחה");
            }
            catch (Exception ex)
            {
                return BadRequest("שגיאה בעדכון הנתונים: " + ex.Message);
            }
        }

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