// Models/ViewModels/Profile/ProfileViewModel.cs
using System.ComponentModel.DataAnnotations;

namespace SkillsAuditSystem.Models.ViewModels.Profile
{
    public class ProfileViewModel
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string EmployeeId { get; set; } = string.Empty;
        public string Department { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? Position { get; set; }
        public DateTime JoinDate { get; set; }
        public string FullName => $"{FirstName} {LastName}";
    }
}