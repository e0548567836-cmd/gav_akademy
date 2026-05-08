using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using students.Data;
using students.Models;

[Route("api/[controller]")]
[ApiController]
public class AdminController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public AdminController(ApplicationDbContext context)
    {
        _context = context;
    }

    // 1. מחיקת סטודנט לפי תעודת זהות
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

    // 2. הוספת קורס חדש
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

    // 3. שליפת כל הקורסים
    [HttpGet("GetCourses")]
    public async Task<ActionResult<IEnumerable<Course>>> GetCourses()
    {
        return await _context.Courses.ToListAsync();
    }

    // 4. שליפת כל הסטודנטים
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

    // 5. מחיקת קורס לפי CourseId
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

    // 6. שדרוג סטודנט למעמד מנהל (חדש!)
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
            // עדכון השדה ל-true (שימי לב שזה תואם לשם ב-SQL: management)
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