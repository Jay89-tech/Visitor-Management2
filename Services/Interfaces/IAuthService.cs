// Services/Interfaces/IAuthService.cs
using SkillsAuditSystem.Models.ViewModels.Auth;

namespace SkillsAuditSystem.Services.Interfaces
{
    public interface IAuthService
    {
        Task<AuthResult> LoginAsync(LoginViewModel model);
        Task<AuthResult> RegisterAsync(RegisterViewModel model);
        Task<AuthResult> ResetPasswordAsync(string email);
        Task<bool> LogoutAsync(string uid);
        Task<bool> ValidateTokenAsync(string token);
        Task<string> GetUserIdFromTokenAsync(string token);
        Task<bool> ChangePasswordAsync(string uid, string currentPassword, string newPassword);
        Task<bool> UpdateEmailAsync(string uid, string newEmail);
        Task<bool> IsEmailExistsAsync(string email);
        Task<bool> IsEmployeeIdExistsAsync(string employeeId);
    }

    public class AuthResult
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public string UserId { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
    }
}