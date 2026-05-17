namespace students.Models
{
    public class Material
    {
        public int MaterialId { get; set; }
        public string FileLink { get; set; }

        public string CloudFileName { get; set; }
        public string UserFileName { get; set; }
        public DateTime UploadDate { get; set; }
        public int RelatedCourseId { get; set; }

        public int UploaderStudentId { get; set; }

        public Material() { }
        public Material(int materialId, string fileLink, string userFileName, DateTime uploadDate, int relatedCourseId, int uploaderStudentId, string cloudFileName)
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
