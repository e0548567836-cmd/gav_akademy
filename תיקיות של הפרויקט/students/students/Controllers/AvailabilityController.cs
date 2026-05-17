using Microsoft.AspNetCore.Mvc;
using students.Data;
using students.Models; // ייבוא המודל StudentInCourse

namespace students.Controllers
{
    [ApiController] // מגדיר את המחלקה כ-API
    [Route("api/[controller]")] // הכתובת תהיה: api/availability
    public class AvailabilityController : ControllerBase
    {
        private readonly ApplicationDbContext _context; // משתנה לגישה לדאטאבייס

        // בנאי (Constructor) שמקבל את החיבור ל-DB מהמערכת
        public AvailabilityController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpPost("update")] // מגדיר פונקציה שמקבלת בקשת POST לכתובת api/availability/update
        public IActionResult UpdateStudent([FromBody] StudentInCourse data)
        {
            // בדיקה אם הגיע מידע בכלל
            if (data == null) return BadRequest("לא התקבל מידע");

            // 1. חיפוש הסטודנט ב-SQL לפי ה-ID שהגיע מהפלאטר
            var studentInDb = _context.StudentInCourses
                .FirstOrDefault(s => s.StudentId == data.StudentId);

            // אם הסטודנט לא קיים בטבלה
            if (studentInDb == null) return NotFound("הסטודנט לא נמצא ב-SQL");

            // 2. עדכון השדות ב-DB מהמידע החדש שהגיע מהפרונט
            studentInDb.IsAvailable = data.IsAvailable;
            studentInDb.CourseId = data.CourseId;
            studentInDb.Latitude = data.Latitude;
            studentInDb.Longitude = data.Longitude;
            studentInDb.IsInPerson = data.IsInPerson;

            // 3. פקודה ששומרת את כל השינויים פיזית ב-SQL Server
            _context.SaveChanges();

            // החזרת תשובה חיובית לפלאטר
            return Ok(new { message = "עודכן בבסיס הנתונים בהצלחה!" });
        }
    }
}