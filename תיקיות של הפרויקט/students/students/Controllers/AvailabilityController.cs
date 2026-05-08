using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using students.Data;
using students.Models;

namespace students.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AvailabilityController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public AvailabilityController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpPost("update")]
        public async Task<IActionResult> UpdateStudent([FromBody] StudentInCourse data)
        {
            if (data == null) return BadRequest("לא התקבל מידע");

            // שימוש ב-FirstOrDefaultAsync לביצועים טובים יותר
            var studentInDb = await _context.StudentInCourses
                .FirstOrDefaultAsync(s => s.StudentId == data.StudentId && s.CourseId == data.CourseId);

            if (studentInDb == null)
                return NotFound("הרשומה לא נמצאה בבסיס הנתונים");

            // עדכון השדות מהמידע שהגיע מה-Flutter
            studentInDb.IsAvailable = data.IsAvailable;
            studentInDb.Latitude = data.Latitude;
            studentInDb.Longitude = data.Longitude;
            studentInDb.IsInPerson = data.IsInPerson;

            try
            {
                await _context.SaveChangesAsync();
                return Ok(new { message = "הנתונים עודכנו ב-SQL בהצלחה!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"שגיאה בשמירה: {ex.Message}");
            }
        }
    }
}