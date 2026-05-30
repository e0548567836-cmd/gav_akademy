using System;

namespace students.Models
{
    public class Material
    {
        public int MaterialId { get; set; }
        public string FileLink { get; set; }

        public string CloudFileName { get; set; }
        public string UserFileName { get; set; }
        public DateTime UploadDate { get; set; }

        // 1. שינוי סוג הנתונים ל-string כדי להתאים ל-CourseId
        public string RelatedCourseId { get; set; }

        public int UploaderStudentId { get; set; }

        public Material() { }

        // 2. עדכון ה-int ל-string בפרמטר של הבנאי (relatedCourseId)
        public Material(int materialId, string fileLink, string userFileName, DateTime uploadDate, string relatedCourseId, int uploaderStudentId, string cloudFileName)
        {
            MaterialId = materialId;
            FileLink = fileLink;
            UserFileName = userFileName;
            UploadDate = uploadDate;

            // 3. ההשמה עכשיו תעבוד בצורה תקינה בין string ל-string
            RelatedCourseId = relatedCourseId;

            UploaderStudentId = uploaderStudentId;
            CloudFileName = cloudFileName;
        }
    }
}