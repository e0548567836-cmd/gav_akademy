using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace students.Models
{
    public class Course
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public string CourseId { get; set; } = "";

        [Required]
        public string Name { get; set; } = "";

        public string Description { get; set; } = "";
    }
}