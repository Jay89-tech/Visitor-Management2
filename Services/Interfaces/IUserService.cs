// Services/Interfaces/IUserService.cs
using SkillsAuditSystem.Models.Entities;
using SkillsAuditSystem.Models.ViewModels.Profile;
using SkillsAuditSystem.Models.DTOs;

namespace SkillsAuditSystem.Services.Interfaces
{
    public interface IUserService
    {
        Task<UserDto?> GetUserByIdAsync(string userId);
        Task<UserDto?> GetUserByEmailAsync(string email);
        Task<UserDto?> GetUserByEmployeeIdAsync(string employeeId);
        Task<bool> CreateUserAsync(User user);
        Task<bool> UpdateUserAsync(string userId, ProfileViewModel model);
        Task<bool> DeleteUserAsync(string userId);
        Task<List<UserDto>> GetAllUsersAsync();
        Task<List<UserDto>> GetUsersByDepartmentAsync(string department);
        Task<List<UserDto>> GetUsersByRoleAsync(string role);
        Task<bool> UpdateUserRoleAsync(string userId, string role);
        Task<bool> ActivateUserAsync(string userId);
        Task<bool> DeactivateUserAsync(string userId);
        Task<ProfileViewModel?> GetUserProfileAsync(string userId);
        Task<bool> UpdateUserProfileAsync(string userId, EditProfileViewModel model);
        Task<Dictionary<string, object>> GetUserStatsAsync(string userId);
        Task<bool> IsUserActiveAsync(string userId);
    }
}