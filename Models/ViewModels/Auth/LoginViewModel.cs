// Models/ViewModels/Auth/LoginViewModel.cs
using System.ComponentModel.DataAnnotations;

namespace SkillsAuditSystem.Models.ViewModels.Auth
{
    public class LoginViewModel
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [DataType(DataType.Password)]
        public string Password { get; set; } = string.Empty;

        public bool RememberMe { get; set; }
    }
}