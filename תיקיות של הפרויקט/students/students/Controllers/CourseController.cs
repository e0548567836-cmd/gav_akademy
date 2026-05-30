using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using students.Data;
using students.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace students.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CourseController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CourseController(ApplicationDbContext context)
        {
            _context = context;
        }

        // 1. הוספת קורס לקטלוג (נעשה דרך Swagger)
        [HttpPost("AddCourseToCatalog")]
        public async Task<IActionResult> AddCourseToCatalog([FromBody] Course newCourse)
        {
            if (newCourse == null || string.IsNullOrEmpty(newCourse.Name))
                return BadRequest(new { message = "נתוני קורס חסרים" });

            var exists = await _context.Courses.AnyAsync(c => c.CourseId == newCourse.CourseId);
            if (exists) return BadRequest(new { message = "קוד קורס זה כבר קיים בקטלוג" });

            _context.Courses.Add(newCourse);
            await _context.SaveChangesAsync();
            return Ok(new { message = "הקורס נוסף לקטלוג בהצלחה!" });
        }

        // 2. שליפת כל הקטלוג (בשביל החיפוש באפליקציה)
        [HttpGet("GetAllCourses")]
        public async Task<ActionResult<IEnumerable<Course>>> GetAllCourses()
        {
            return await _context.Courses.ToListAsync();
        }

        // 3. רישום סטודנט לקורס
        [HttpPost("Enroll")]
        public async Task<IActionResult> Enroll([FromBody] StudentInCourse enrollment)
        {
            var exists = await _context.StudentInCourses.AnyAsync(sic =>
                sic.StudentId == enrollment.StudentId && sic.CourseId == enrollment.CourseId);

            if (exists) return BadRequest(new { message = "אתה כבר רשום לקורס זה" });

            _context.StudentInCourses.Add(enrollment);
            await _context.SaveChangesAsync();
            return Ok(new { message = "נרשמת לקורס בהצלחה" });
        }

        // 4. שליפת הקורסים שלי (כולל השמות מהקטלוג)
        [HttpGet("MyCourses/{studentId}")]
        public async Task<IActionResult> GetMyCourses(string studentId)
        {
            var myCourses = await _context.StudentInCourses
                .Where(sic => sic.StudentId == studentId)
                .Join(_context.Courses,
                      sic => sic.CourseId,
                      course => course.CourseId,
                      (sic, course) => new
                      {
                          courseId = sic.CourseId,
                          name = course.Name,
                          isAvailable = sic.IsAvailable
                      })
                .ToListAsync();

            return Ok(myCourses);
        }

        // 5. מחיקת קורס (ביטול רישום)
        [HttpDelete("Unenroll/{studentId}/{courseId}")]
        public async Task<IActionResult> Unenroll(string studentId, string courseId)
        {
            var enrollment = await _context.StudentInCourses
                .FirstOrDefaultAsync(sic => sic.StudentId == studentId && sic.CourseId == courseId);

            if (enrollment == null)
                return NotFound(new { message = "לא נמצא רישום לקורס זה" });

            _context.StudentInCourses.Remove(enrollment);
            await _context.SaveChangesAsync();

            return Ok(new { message = "הקורס הוסר בהצלחה" });
        }

        // 6.שינוי סטטוס זמינות
        public class UpdateAvailabilityRequest
        {
            public string StudentId { get; set; }
            public string CourseId { get; set; }
            public bool IsAvailable { get; set; }
        }
        [HttpPut("UpdateAvailability")]
        public async Task<IActionResult> UpdateAvailability([FromBody] UpdateAvailabilityRequest request)
        {
            if (request == null || string.IsNullOrEmpty(request.StudentId) || string.IsNullOrEmpty(request.CourseId))
            {
                return BadRequest(new { message = "Missing data" });
            }

            var studentCourse = await _context.StudentInCourses
                .FirstOrDefaultAsync(sc =>
                    sc.StudentId == request.StudentId &&
                    sc.CourseId == request.CourseId);

            if (studentCourse == null)
            {
                return NotFound(new { message = "Student is not enrolled in this course" });
            }

            studentCourse.IsAvailable = request.IsAvailable;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Availability updated successfully" });
        }
    }
}