using Microsoft.AspNetCore.Http;

namespace students.Models;

public class UploadMaterialRequest
{
    public IFormFile File { get; set; } = null!;
    public int CourseId { get; set; }
    public int StudentId { get; set; }
}
