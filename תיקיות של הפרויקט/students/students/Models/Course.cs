//namespace students.Models
//{
//  public class Course
// {
//   public string CourseId { get; set; } = ""; // מזהה טקסטואלי עדי
//  public string Name { get; set; } = "";
// public string Description { get; set; } = "";
//}
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace students.Models
{
    public class Course
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public string CourseId { get; set; } // שׁינינו ל-CourseId וסוג string

        [Required]
        public string Name { get; set; }
    }
}
