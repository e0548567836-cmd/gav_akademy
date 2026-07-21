using System;

namespace students.Models
{
    public class Material
    {
        public int MaterialId { get; set; }
        public string FileLink { get; set; } = string.Empty;

        public string CloudFileName { get; set; } = string.Empty;
        public string UserFileName { get; set; } = string.Empty;
        public DateTime UploadDate { get; set; }

        public string RelatedCourseId { get; set; } = string.Empty;

        public int UploaderStudentId { get; set; }

        public Material() { }

        public Material(int materialId, string fileLink, string userFileName, DateTime uploadDate, string relatedCourseId, int uploaderStudentId, string cloudFileName)
        {
            MaterialId = materialId;
            FileLink = fileLink;
            UserFileName = userFileName;
            UploadDate = uploadDate;
            RelatedCourseId = relatedCourseId;
            UploaderStudentId = uploaderStudentId;
            CloudFileName = cloudFileName;
        }
    }
}
