using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using students.Data;
using students.Models;

namespace students.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AdminController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public AdminController(ApplicationDbContext context)
        {
            _context = context;
        }

        // Delete a student and all their course enrollments
        [HttpDelete("RemoveStudent/{id}")]
        public async Task<IActionResult> RemoveStudent(string id)
        {
            var student = await _context.Students.FindAsync(id);
            if (student == null) return NotFound("הסטודנט לא נמצא במערכת");

            try
            {
                var studentCourses = _context.StudentInCourses.Where(sc => sc.StudentId == id);
                _context.StudentInCourses.RemoveRange(studentCourses);

                _context.Students.Remove(student);
                await _context.SaveChangesAsync();

                return Ok("הסטודנט וכל הרשומות המקושרות נמחקו בהצלחה");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"שגיאה במחיקה: {ex.Message}");
            }
        }

        // Add a new course to the catalog
        [HttpPost("AddCourse")]
        public async Task<IActionResult> AddCourse([FromBody] Course course)
        {
            if (course == null) return BadRequest("נתוני קורס חסרים");

            var exists = await _context.Courses.AnyAsync(c => c.CourseId == course.CourseId);
            if (exists) return BadRequest("מספר קורס זה כבר קיים במערכת");

            _context.Courses.Add(course);
            await _context.SaveChangesAsync();

            return Ok("הקורס נוסף בהצלחה למאגר");
        }

        // Get all courses
        [HttpGet("GetCourses")]
        public async Task<ActionResult<IEnumerable<Course>>> GetCourses()
        {
            return await _context.Courses.ToListAsync();
        }

        // Get all students
        [HttpGet("GetStudents")]
        public async Task<ActionResult<IEnumerable<Student>>> GetStudents()
        {
            try
            {
                return await _context.Students.ToListAsync();
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"שגיאה בשליפת הסטודנטים: {ex.Message}");
            }
        }

        // Delete a course and all its student enrollments
        [HttpDelete("RemoveCourse/{id}")]
        public async Task<IActionResult> RemoveCourse(string id)
        {
            var course = await _context.Courses.FindAsync(id);

            if (course == null)
            {
                return NotFound("הקורס לא נמצא במערכת");
            }

            try
            {
                var linkedStudents = _context.StudentInCourses.Where(sc => sc.CourseId == id);
                _context.StudentInCourses.RemoveRange(linkedStudents);

                _context.Courses.Remove(course);
                await _context.SaveChangesAsync();

                return Ok("הקורס נמחק בהצלחה");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"שגיאה במחיקת הקורס: {ex.Message}");
            }
        }

        // Promote a student to admin (sets management = true)
        [HttpPut("MakeAdmin/{id}")]
        public async Task<IActionResult> MakeAdmin(string id)
        {
            var student = await _context.Students.FindAsync(id);

            if (student == null)
            {
                return NotFound("הסטודנט לא נמצא במערכת");
            }

            try
            {
                student.management = true;

                _context.Students.Update(student);
                await _context.SaveChangesAsync();

                return Ok(new { message = "הסטודנט מונה למנהל בהצלחה" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"שגיאה בעדכון ההרשאה: {ex.Message}");
            }
        }
    }
}
