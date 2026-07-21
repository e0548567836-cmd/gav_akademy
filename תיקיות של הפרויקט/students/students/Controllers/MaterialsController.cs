using CloudinaryDotNet.Actions;
using Microsoft.AspNetCore.Mvc;
using students.Data;
using students.Models;
using students.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace students.Controllers
{
    /// <summary>
    /// Manages course material uploads, retrieval, and deletion.
    /// </summary>
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

        /// <summary>
        /// Uploads a new course material file.
        /// </summary>
        [HttpPost("UploadNewMaterial")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> PostMaterial([FromForm] UploadMaterialRequest request)
        {
            if (request == null || request.File == null || request.File.Length == 0)
            {
                Console.WriteLine("Error: No file received or request is empty");
                return BadRequest("לא נבחר קובץ תקני");
            }

            var file = request.File;
            var courseId = request.CourseId;
            var studentId = request.StudentId;

            Console.WriteLine("=== Start UploadNewMaterial ===");
            Console.WriteLine($"courseId: {courseId}, studentId: {studentId}");
            Console.WriteLine($"File received: {file.FileName}, size: {file.Length} bytes");

            try
            {
                Console.WriteLine("Uploading to Cloudinary...");
                var uploadResult = await _cloudinaryService.UploadImageAsync(file);

                if (uploadResult.Error != null)
                {
                    Console.WriteLine($"Cloudinary error: {uploadResult.Error.Message}");
                    return BadRequest("שגיאה בעלייה לענן: " + uploadResult.Error.Message);
                }

                if (uploadResult.SecureUrl == null)
                {
                    Console.WriteLine("SecureUrl is null — file was not uploaded");
                    return StatusCode(500, "הקובץ לא עלה, SecureUrl ריק");
                }

                Console.WriteLine("Saving to database...");
                var newMaterial = new Material
                {
                    FileLink = uploadResult.SecureUrl.ToString(),
                    CloudFileName = uploadResult.PublicId,
                    UserFileName = file.FileName,
                    UploadDate = DateTime.Now,
                    RelatedCourseId = courseId,
                    UploaderStudentId = studentId
                };

                _context.Materials.Add(newMaterial);
                await _context.SaveChangesAsync();

                Console.WriteLine($"Saved successfully! ID: {newMaterial.MaterialId}");
                Console.WriteLine("=== UploadNewMaterial completed ===");

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
                Console.WriteLine($"Exception: {ex.Message}");
                return StatusCode(500, "שגיאה פנימית: " + ex.Message);
            }
        }

        /// <summary>
        /// Retrieves all materials for a specific course.
        /// </summary>
        [HttpGet("GetMaterialsByCourse/{courseId}")]
        public async Task<IActionResult> GetMaterials(string courseId)
        {
            var materials = await _context.Materials
                .Where(m => m.RelatedCourseId == courseId)
                .OrderByDescending(m => m.UploadDate)
                .ToListAsync();

            return Ok(materials);
        }

        /// <summary>
        /// Deletes a course material file.
        /// </summary>
        [HttpDelete("DeleteMaterial/{id}")]
        public async Task<IActionResult> DeleteMaterial(int id)
        {
            var material = await _context.Materials.FindAsync(id);
            if (material == null) return NotFound("החומר לא נמצא");

            var publicIdClean = material.CloudFileName;
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