using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Mvc;
using students.Data;
using students.Models;
using students.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore; // מאפשר שימוש ב-ToListAsync

namespace students.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MaterialsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly CloudinaryService _cloudinaryService;

        public MaterialsController(ApplicationDbContext context, CloudinaryService cloudinaryService)
        {
            _context = context;
            _cloudinaryService = cloudinaryService;
        }

        [HttpPost("UploadNewMaterial")]
        [Consumes("multipart/form-data")] // מודיע ל-Swagger שמדובר בהעלאת קובץ
        public async Task<IActionResult> PostMaterial([FromForm] UploadMaterialRequest request)
        {
            // בדיקה מקדימה שהבקשה והקובץ אינם null
            if (request == null || request.File == null || request.File.Length == 0)
            {
                Console.WriteLine("❌ שגיאה: לא התקבל קובץ או שהבקשה ריקה");
                return BadRequest("לא נבחר קובץ תקני");
            }

            var file = request.File;
            var courseId = request.CourseId;
            var studentId = request.StudentId;

            Console.WriteLine("=== התחלת UploadNewMaterial ===");
            Console.WriteLine($"courseId: {courseId}, studentId: {studentId}");
            Console.WriteLine($"✅ קובץ התקבל: {file.FileName}, גודל: {file.Length} bytes");

            try
            {
                // 1. העלאה ל-Cloudinary
                Console.WriteLine("⏳ שולח ל-Cloudinary...");
                var uploadResult = await _cloudinaryService.UploadImageAsync(file);

                Console.WriteLine($"Cloudinary StatusCode: {uploadResult.StatusCode}");
                Console.WriteLine($"Cloudinary PublicId: {uploadResult.PublicId}");
                Console.WriteLine($"Cloudinary SecureUrl: {uploadResult.SecureUrl}");
                Console.WriteLine($"Cloudinary Error: {(uploadResult.Error != null ? uploadResult.Error.Message : "אין שגיאה")}");

                if (uploadResult.Error != null)
                {
                    Console.WriteLine($"❌ שגיאת Cloudinary: {uploadResult.Error.Message}");
                    return BadRequest("שגיאה בעלייה לענן: " + uploadResult.Error.Message);
                }

                if (uploadResult.SecureUrl == null)
                {
                    Console.WriteLine("❌ SecureUrl הוא null — הקובץ לא עלה!");
                    return StatusCode(500, "הקובץ לא עלה, SecureUrl ריק");
                }

                // 2. יצירת האובייקט לשמירה
                Console.WriteLine("⏳ שומר בבסיס הנתונים...");
                var newMaterial = new Material
                {
                    FileLink = uploadResult.SecureUrl.ToString(),
                    CloudFileName = uploadResult.PublicId,
                    UserFileName = file.FileName,
                    UploadDate = DateTime.Now,
                    RelatedCourseId = courseId,
                    UploaderStudentId = studentId
                };

                // 3. שמירה בבסיס הנתונים
                _context.Materials.Add(newMaterial);
                await _context.SaveChangesAsync();

                Console.WriteLine($"✅ נשמר בהצלחה! ID: {newMaterial.MaterialId}");
                Console.WriteLine("=== סיום UploadNewMaterial בהצלחה ===");

                return Ok(new
                {
                    message = "החומר עלה בהצלחה!",
                    link = newMaterial.FileLink,
                    publicId = uploadResult.PublicId,
                    fileName = newMaterial.UserFileName
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Exception: {ex.Message}");
                Console.WriteLine($"❌ StackTrace: {ex.StackTrace}");
                return StatusCode(500, "שגיאה פנימית: " + ex.Message);
            }
        }

        [HttpGet("GetMaterialsByCourse/{courseId}")]
        public async Task<IActionResult> GetMaterials(int courseId)
        {
            // שינוי ל-ToListAsync לביצועים אסינכרוניים טובים יותר
            var materials = await _context.Materials
                .Where(m => m.RelatedCourseId == courseId)
                .OrderByDescending(m => m.UploadDate)
                .ToListAsync();

            return Ok(materials);
        }

        [HttpDelete("DeleteMaterial/{id}")]
        public async Task<IActionResult> DeleteMaterial(int id)
        {
            var material = await _context.Materials.FindAsync(id);
            if (material == null) return NotFound("החומר לא נמצא");

            var publicIdClean = material.CloudFileName;

            // זיהוי סוג המשאב מול Cloudinary (קובץ כללי מול תמונה)
            var resourceType = material.UserFileName.ToLower().EndsWith(".pdf") ? "raw" : "image";

            var result = await _cloudinaryService.DeleteImageAsync(publicIdClean, resourceType);

            if (result.Result == "ok" || result.Result == "not found")
            {
                _context.Materials.Remove(material);
                await _context.SaveChangesAsync();
                return Ok(new { message = "הקובץ נמחק בהצלחה" });
            }

            return BadRequest("שגיאה במחיקה מהענן: " + (result.Error != null ? result.Error.Message : "שגיאה לא ידועה"));
        }
    }
}