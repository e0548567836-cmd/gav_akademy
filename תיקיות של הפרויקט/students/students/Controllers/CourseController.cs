using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using students.Data;
using students.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace students.Controllers
{
    /// <summary>
    /// Provides operations for managing courses and student enrollments.
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    public class CourseController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CourseController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Adds a new course to the catalog.
        /// </summary>
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

        /// <summary>
        /// Retrieves the complete course catalog.
        /// </summary>
        [HttpGet("GetAllCourses")]
        public async Task<ActionResult<IEnumerable<Course>>> GetAllCourses()
        {
            return await _context.Courses.ToListAsync();
        }

        /// <summary>
        /// Enrolls a student in a course.
        /// </summary>
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

        /// <summary>
        /// Retrieves the list of courses in which the student is enrolled.
        /// </summary>
        [HttpGet("MyCourses/{studentId}")]
        public async Task<IActionResult> GetMyCourses(string studentId)
        {
            var myCourses = await _context.StudentInCourses
                .Where(sic => sic.StudentId == studentId)
                .Join(
                    _context.Courses,
                    sic => sic.CourseId,
                    course => course.CourseId,
                    (sic, course) => new
                    {
                        courseId = sic.CourseId,
                        name = course.Name,

                        isAvailable = sic.IsAvailable,
                        isInPerson = sic.IsInPerson,

                        wantsHelp = sic.WantsHelp,
                        wantsToTeach = sic.WantsToTeach,
                        wantsPartner = sic.WantsPartner,

                        maxDistanceKm = sic.MaxDistanceKm,

                        latitude = sic.Latitude,
                        longitude = sic.Longitude
                    }
                )
                .ToListAsync();

            return Ok(myCourses);
        }

        /// <summary>
        /// Removes a student from a course.
        /// </summary>
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

        /// <summary>
        /// Represents a request to update a student's availability.
        /// </summary>
        public class UpdateAvailabilityRequest
        {
            public string StudentId { get; set; } = string.Empty;
            public string CourseId { get; set; } = string.Empty;
            public bool IsAvailable { get; set; }
        }

        /// <summary>
        /// Updates a student's availability status for a course.
        /// </summary>
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