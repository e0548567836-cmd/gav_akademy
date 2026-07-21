using students.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using students.Data;

namespace students.Controllers
{
    /// <summary>
    /// Manages student availability and matching for courses.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class AvailabilityController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public AvailabilityController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Represents the availability data sent by the client.
        /// </summary>
        public class UpdateAvailabilityRequest
        {
            public string StudentId { get; set; } = "";
            public string CourseId { get; set; } = "";
            public bool IsAvailable { get; set; }
            public bool IsInPerson { get; set; }

            public bool WantsHelp { get; set; }
            public bool WantsToTeach { get; set; }
            public bool WantsPartner { get; set; }

            public double? MaxDistanceKm { get; set; }

            public double? Latitude { get; set; }
            public double? Longitude { get; set; }
        }

        /// <summary>
        /// Updates a student's availability settings for a course.
        /// </summary>
        [HttpPut("UpdateAvailability")]
        public async Task<IActionResult> UpdateAvailability([FromBody] UpdateAvailabilityRequest data)
        {
            if (data == null)
                return BadRequest("לא התקבל מידע");

            var studentInDb = await _context.StudentInCourses.FirstOrDefaultAsync(s =>
                s.StudentId == data.StudentId &&
                s.CourseId == data.CourseId
            );

            if (studentInDb == null)
                return NotFound("הסטודנט לא רשום לקורס הזה");

            studentInDb.IsAvailable = data.IsAvailable;
            studentInDb.IsInPerson = data.IsInPerson;
            studentInDb.WantsHelp = data.WantsHelp;
            studentInDb.WantsToTeach = data.WantsToTeach;
            studentInDb.WantsPartner = data.WantsPartner;
            studentInDb.MaxDistanceKm = data.MaxDistanceKm;
            studentInDb.Latitude = data.Latitude;
            studentInDb.Longitude = data.Longitude;

            await _context.SaveChangesAsync();

            return Ok(new { message = "הזמינות עודכנה בהצלחה" });
        }

        /// <summary>
        /// Retrieves students who match the requested availability criteria.
        /// </summary>
        [HttpGet("AvailableStudents")]
        public IActionResult GetAvailableStudents(
            [FromQuery] string studentId,
            [FromQuery] string courseId,
            [FromQuery] bool isInPerson,
            [FromQuery] bool wantsToTeach,
            [FromQuery] bool wantsPartner,
            [FromQuery] double? latitude,
            [FromQuery] double? longitude,
            [FromQuery] double? distanceKm)
        {
            var currentStudent = _context.Students.FirstOrDefault(s => s.StudentId == studentId);

            if (currentStudent == null)
                return NotFound("הסטודנט לא נמצא");

            var currentGrade = currentStudent.Grade;

            var students = _context.StudentInCourses
                .Where(sc =>
                    sc.CourseId == courseId &&
                    sc.IsAvailable &&
                    sc.IsInPerson == isInPerson &&
                    sc.StudentId != studentId &&
                    (
                        wantsPartner
                            ? sc.WantsPartner
                            : sc.WantsToTeach != wantsToTeach && !sc.WantsPartner
                    )
                )
                .Join(
                    _context.Students,
                    sc => sc.StudentId,
                    s => s.StudentId,
                    (sc, s) => new
                    {
                        studentId = s.StudentId,
                        studentName = s.studentName,
                        studentEmail = s.studentEmail,
                        grade = s.Grade,
                        isInPerson = sc.IsInPerson,
                        wantsHelp = sc.WantsHelp,
                        wantsToTeach = sc.WantsToTeach,
                        wantsPartner = sc.WantsPartner,
                        maxDistanceKm = sc.MaxDistanceKm,
                        latitude = sc.Latitude,
                        longitude = sc.Longitude
                    }
                )
                .AsEnumerable()
                .Where(s =>
                    !currentGrade.HasValue || !s.grade.HasValue ||
                    (
                        wantsPartner
                            ? Math.Abs(currentGrade.Value - s.grade.Value) <= 10
                            : (wantsToTeach
                                ? currentGrade.Value > s.grade.Value
                                : s.grade.Value > currentGrade.Value)
                    )
                )
                .Where(s =>
                    !isInPerson ||
                    (
                        latitude.HasValue &&
                        longitude.HasValue &&
                        distanceKm.HasValue &&
                        s.latitude.HasValue &&
                        s.longitude.HasValue &&
                        CalculateDistanceKm(
                            latitude.Value,
                            longitude.Value,
                            s.latitude.Value,
                            s.longitude.Value
                        ) <= distanceKm.Value &&
                        (
                            !s.maxDistanceKm.HasValue ||
                            CalculateDistanceKm(
                                latitude.Value,
                                longitude.Value,
                                s.latitude.Value,
                                s.longitude.Value
                            ) <= s.maxDistanceKm.Value
                        )
                    )
                )
                .Select(s => new
                {
                    s.studentId,
                    s.studentName,
                    s.studentEmail,
                    s.grade,
                    s.isInPerson,
                    s.wantsHelp,
                    s.wantsToTeach,
                    s.wantsPartner,
                    s.maxDistanceKm,
                    s.latitude,
                    s.longitude,
                    distanceKm = isInPerson && latitude.HasValue && longitude.HasValue && s.latitude.HasValue && s.longitude.HasValue
                        ? Math.Round(
                            CalculateDistanceKm(
                                latitude.Value,
                                longitude.Value,
                                s.latitude.Value,
                                s.longitude.Value
                            ),
                            2
                        )
                        : (double?)null
                })
                .ToList();

            return Ok(students);
        }

        /// <summary>
        /// Calculates the distance between two geographic coordinates in kilometers.
        /// </summary>
        private static double CalculateDistanceKm(
            double lat1,
            double lon1,
            double lat2,
            double lon2)
        {
            const double earthRadiusKm = 6371;

            double dLat = ToRadians(lat2 - lat1);
            double dLon = ToRadians(lon2 - lon1);

            double a =
                Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(ToRadians(lat1)) *
                Math.Cos(ToRadians(lat2)) *
                Math.Sin(dLon / 2) *
                Math.Sin(dLon / 2);

            double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));

            return earthRadiusKm * c;
        }

        /// <summary>
        /// Converts degrees to radians.
        /// </summary>
        private static double ToRadians(double degrees)
        {
            return degrees * Math.PI / 180;
        }
    }
}