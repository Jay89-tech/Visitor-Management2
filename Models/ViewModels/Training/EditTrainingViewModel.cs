using System.ComponentModel.DataAnnotations;

namespace SkillsAuditSystem.Models.ViewModels.Training
{
    public class EditTrainingViewModel
    {
        [Required]
        [StringLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [StringLength(100)]
        public string Provider { get; set; } = string.Empty;

        [Required]
        public string Category { get; set; } = string.Empty;

        [Required]
        public string Status { get; set; } = string.Empty;

        public DateTime? StartDate { get; set; }

        public DateTime? EndDate { get; set; }

        [Range(1, 1000)]
        public int Duration { get; set; }

        [Url]
        public string? CertificateUrl { get; set; }

        [StringLength(1000)]
        public string? Description { get; set; }
    }
}
