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

        // Get student by ID
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
                management = student.management,
                grade = student.Grade ?? 80
            });
        }

        // Register a new student with ID and phone validation
        [HttpPost("AddStudent")]
        public async Task<IActionResult> AddStudent([FromBody] Student newStudent)
        {
            if (newStudent == null) return BadRequest("לא התקבלו נתונים");

            if (!IsValid.IsValidId(newStudent.StudentId))
                return BadRequest("מספר תעודת הזהות אינו תקין");

            // If phone is invalid, fall back to a default value
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

        // Login — returns student ID, name, admin flag, and grade
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] Student loginData)
        {
            var student = await _context.Students
                .FirstOrDefaultAsync(s => s.StudentId == loginData.StudentId);

            if (student == null) return NotFound("סטודנט לא נמצא");

            if (student.StudentPassword != loginData.StudentPassword)
                return Unauthorized("סיסמה שגויה");

            return Ok(new
            {
                studentId = student.StudentId,
                name = student.studentName,
                management = student.management,
                grade = student.Grade ?? 80
            });
        }

        // Partial update — only fields present in the JSON body are updated
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateStudent(string id, [FromBody] JsonElement updatedData)
    {
        var student = await _context.Students.FirstOrDefaultAsync(s => s.StudentId == id);
        if (student == null) return NotFound("הסטודנט לא נמצא");

        try
        {
            if (updatedData.TryGetProperty("studentName", out var nameProp))
            {
                student.studentName = nameProp.GetString() ?? student.studentName;
            }

            if (updatedData.TryGetProperty("studentEmail", out var emailProp))
            {
                student.studentEmail = emailProp.GetString() ?? student.studentEmail;
            }

            if (updatedData.TryGetProperty("studentPhone", out var phoneProp))
            {
                var phone = phoneProp.GetString();
                if (!string.IsNullOrWhiteSpace(phone) && IsValid.IsValidPhoneNumber(phone))
                    student.studentPhone = phone;
                else
                    student.studentPhone = "0500000000";
            }

            if (updatedData.TryGetProperty("grade", out var gradeProp))
            {
                if (gradeProp.ValueKind == JsonValueKind.Number)
                {
                    student.Grade = gradeProp.GetDouble();
                }
                else if (gradeProp.ValueKind == JsonValueKind.String &&
                        double.TryParse(gradeProp.GetString(), out var parsedGrade))
                {
                    student.Grade = parsedGrade;
                }
            }

            await _context.SaveChangesAsync();
            return Ok("הנתונים עודכנו בהצלחה");
        }
        catch (Exception ex)
        {
            return BadRequest("שגיאה בעדכון הנתונים: " + ex.Message);
        }
    }

        // Google OAuth sign-in — returns isNewUser flag so the client can prompt registration
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
                management = student.management,
                grade = student.Grade ?? 80
            });
        }
    }

    public class GoogleSignInRequest
    {
        public string Email { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
    }
}