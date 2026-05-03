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
                    student.studentName = nameProp.GetString();

                if (updatedData.TryGetProperty("studentEmail", out var emailProp))
                    student.studentEmail = emailProp.GetString();

                if (updatedData.TryGetProperty("studentPhone", out var phoneProp))
                {
                    string phone = phoneProp.GetString();
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

        [HttpGet("login-google")]
        public IActionResult LoginWithGoogle()
        {
            var props = new AuthenticationProperties
            {
                RedirectUri = "/api/Student/google-callback"
            };
            return Challenge(props, "Google");
        }

        [HttpGet("google-callback")]
        public async Task<IActionResult> GoogleCallback()
        {
            var result = await HttpContext.AuthenticateAsync("Cookies");
            if (result?.Principal == null) return Unauthorized("כניסה עם גוגל נכשלה");

            var claims = result.Principal.Identities.First().Claims;
            string email = claims.First(c => c.Type == System.Security.Claims.ClaimTypes.Email).Value;
            string name  = claims.First(c => c.Type == System.Security.Claims.ClaimTypes.Name).Value;

            // בדיקה אם המשתמש קיים לפי אימייל
            var student = await _context.Students.FirstOrDefaultAsync(s => s.studentEmail == email);

            if (student == null)
            {
                // משתמש חדש – מפנים למסך השלמת פרטים (ת.ז)
                return Redirect($"http://localhost:5022/complete-profile?email={Uri.EscapeDataString(email)}&name={Uri.EscapeDataString(name)}");
            }

            // משתמש קיים – מחזירים את הפרטים כמו login רגיל
            return Ok(new { studentId = student.StudentId, name = student.studentName, management = student.management });
        }
    }
}