using System.ComponentModel.DataAnnotations;

namespace SkillsAuditSystem.Models.ViewModels.Profile
{
    public class EditProfileViewModel
    {
        [Required]
        [StringLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Phone]
        public string? PhoneNumber { get; set; }

        [StringLength(100)]
        public string? Position { get; set; }

        [Required]
        public string Department { get; set; } = string.Empty;
    }
}
