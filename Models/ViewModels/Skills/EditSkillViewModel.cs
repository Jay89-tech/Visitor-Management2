using System.ComponentModel.DataAnnotations;

namespace SkillsAuditSystem.Models.ViewModels.Skills
{
    public class EditSkillViewModel
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        public string Category { get; set; } = string.Empty;

        [Required]
        public string Level { get; set; } = string.Empty;

        [StringLength(500)]
        public string? Description { get; set; }

        [Range(0, 50)]
        public int YearsExperience { get; set; }
    }
}
