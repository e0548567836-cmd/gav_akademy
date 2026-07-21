using Microsoft.AspNetCore.Http;

namespace students.Models;

/// <summary>
/// Represents a request to upload course material.
/// </summary>
public class UploadMaterialRequest
{
    public IFormFile File { get; set; } = null!;
    public string CourseId { get; set; } = string.Empty;
    public int StudentId { get; set; }
}
