// Services/Implementation/FirebaseAuthService.cs
using Firebase.Auth;
using Google.Cloud.Firestore;
using SkillsAuditSystem.Services.Interfaces;
using SkillsAuditSystem.Models.ViewModels.Auth;
using SkillsAuditSystem.Models.Entities;
using System.Text.Json;
using FirebaseAdmin.Auth;
using SkillsAuditSystem.Configuration;

namespace SkillsAuditSystem.Services.Implementation
{
    public class FirebaseAuthService : IAuthService
    {
        private readonly FirebaseAuthProvider _authProvider;
        private readonly FirestoreDb _firestoreDb;
        private readonly ILogger<FirebaseAuthService> _logger;
        private readonly IConfiguration _configuration;

        public FirebaseAuthService(ILogger<FirebaseAuthService> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            var apiKey = _configuration["Firebase:ApiKey"];
            _authProvider = new FirebaseAuthProvider(new FirebaseConfig(apiKey));
            _firestoreDb = FirestoreDb.Create(_configuration["Firebase:ProjectId"]);
        }

        public async Task<AuthResult> LoginAsync(LoginViewModel model)
        {
            try
            {
                var auth = await _authProvider.SignInWithEmailAndPasswordAsync(model.Email, model.Password);

                if (auth?.User == null)
                {
                    return new AuthResult { Success = false, Message = "Invalid login credentials" };
                }

                // Get user data from Firestore
                var userDoc = await _firestoreDb.Collection("users").Document(auth.User.LocalId).GetSnapshotAsync();
                if (!userDoc.Exists)
                {
                    return new AuthResult { Success = false, Message = "User profile not found" };
                }

                var userData = userDoc.ToDictionary();
                var isActive = userData.ContainsKey("isActive") ? (bool)userData["isActive"] : true;

                if (!isActive)
                {
                    return new AuthResult { Success = false, Message = "Account is deactivated" };
                }

                return new AuthResult
                {
                    Success = true,
                    Message = "Login successful",
                    UserId = auth.User.LocalId,
                    Token = auth.FirebaseToken,
                    Email = auth.User.Email,
                    Role = userData.ContainsKey("role") ? userData["role"].ToString() : "employee"
                };
            }
            catch (FirebaseAuthException ex)
            {
                _logger.LogError(ex, "Firebase authentication error during login");
                return new AuthResult { Success = false, Message = GetAuthErrorMessage(ex.Reason) };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during login");
                return new AuthResult { Success = false, Message = "An unexpected error occurred" };
            }
        }

        public async Task<AuthResult> RegisterAsync(RegisterViewModel model)
        {
            try
            {
                // Check if email already exists
                if (await IsEmailExistsAsync(model.Email))
                {
                    return new AuthResult { Success = false, Message = "Email already registered" };
                }

                // Check if employee ID already exists
                if (await IsEmployeeIdExistsAsync(model.EmployeeId))
                {
                    return new AuthResult { Success = false, Message = "Employee ID already registered" };
                }

                // Create Firebase Auth user
                var auth = await _authProvider.CreateUserWithEmailAndPasswordAsync(model.Email, model.Password);

                if (auth?.User == null)
                {
                    return new AuthResult { Success = false, Message = "Failed to create user account" };
                }

                // Create user profile in Firestore
                var user = new User
                {
                    Id = auth.User.LocalId,
                    FirstName = model.FirstName,
                    LastName = model.LastName,
                    Email = model.Email,
                    EmployeeId = model.EmployeeId,
                    Department = model.Department,
                    Role = "employee",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                await _firestoreDb.Collection("users").Document(auth.User.LocalId).SetAsync(user);

                return new AuthResult
                {
                    Success = true,
                    Message = "Registration successful",
                    UserId = auth.User.LocalId,
                    Token = auth.FirebaseToken,
                    Email = auth.User.Email,
                    Role = "employee"
                };
            }
            catch (FirebaseAuthException ex)
            {
                _logger.LogError(ex, "Firebase authentication error during registration");
                return new AuthResult { Success = false, Message = GetAuthErrorMessage(ex.Reason) };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during registration");
                return new AuthResult { Success = false, Message = "An unexpected error occurred" };
            }
        }

        public async Task<AuthResult> ResetPasswordAsync(string email)
        {
            try
            {
                await _authProvider.SendPasswordResetEmailAsync(email);
                return new AuthResult { Success = true, Message = "Password reset email sent successfully" };
            }
            catch (FirebaseAuthException ex)
            {
                _logger.LogError(ex, "Firebase authentication error during password reset");
                return new AuthResult { Success = false, Message = GetAuthErrorMessage(ex.Reason) };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during password reset");
                return new AuthResult { Success = false, Message = "An unexpected error occurred" };
            }
        }

        public async Task<bool> LogoutAsync(string uid)
        {
            try
            {
                // Update user's last activity
                await _firestoreDb.Collection("users").Document(uid)
                    .UpdateAsync("lastActivity", DateTime.UtcNow);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during logout for user {UserId}", uid);
                return false;
            }
        }

        public async Task<bool> ValidateTokenAsync(string token)
        {
            try
            {
                var payload = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(token);
                return payload != null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Token validation failed");
                return false;
            }
        }

        public async Task<string> GetUserIdFromTokenAsync(string token)
        {
            try
            {
                var payload = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(token);
                return payload?.Uid ?? string.Empty;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to get user ID from token");
                return string.Empty;
            }
        }

        public async Task<bool> ChangePasswordAsync(string uid, string currentPassword, string newPassword)
        {
            try
            {
                // Get user email first
                var userDoc = await _firestoreDb.Collection("users").Document(uid).GetSnapshotAsync();
                if (!userDoc.Exists) return false;

                var email = userDoc.GetValue<string>("email");

                // Verify current password by attempting to sign in
                await _authProvider.SignInWithEmailAndPasswordAsync(email, currentPassword);

                // Update password using Firebase Admin SDK
                var userRecord = await FirebaseAuth.DefaultInstance.UpdateUserAsync(new UserRecordArgs
                {
                    Uid = uid,
                    Password = newPassword
                });

                return userRecord != null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error changing password for user {UserId}", uid);
                return false;
            }
        }

        public async Task<bool> UpdateEmailAsync(string uid, string newEmail)
        {
            try
            {
                var userRecord = await FirebaseAuth.DefaultInstance.UpdateUserAsync(new UserRecordArgs
                {
                    Uid = uid,
                    Email = newEmail
                });

                // Update email in Firestore as well
                await _firestoreDb.Collection("users").Document(uid)
                    .UpdateAsync("email", newEmail, "updatedAt", DateTime.UtcNow);

                return userRecord != null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating email for user {UserId}", uid);
                return false;
            }
        }

        public async Task<bool> IsEmailExistsAsync(string email)
        {
            try
            {
                var query = await _firestoreDb.Collection("users")
                    .WhereEqualTo("email", email)
                    .GetSnapshotAsync();

                return query.Documents.Count > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking email existence");
                return false;
            }
        }

        public async Task<bool> IsEmployeeIdExistsAsync(string employeeId)
        {
            try
            {
                var query = await _firestoreDb.Collection("users")
                    .WhereEqualTo("employeeId", employeeId)
                    .GetSnapshotAsync();

                return query.Documents.Count > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking employee ID existence");
                return false;
            }
        }

        private string GetAuthErrorMessage(AuthErrorReason reason)
        {
            return reason switch
            {
                AuthErrorReason.UserNotFound => "No account found with this email address",
                AuthErrorReason.WrongPassword => "Invalid password",
                AuthErrorReason.InvalidEmailAddress => "Invalid email address format",
                AuthErrorReason.EmailExists => "An account already exists with this email",
                AuthErrorReason.WeakPassword => "Password is too weak",
                AuthErrorReason.TooManyAttempts => "Too many failed attempts. Please try again later",
                AuthErrorReason.UserDisabled => "This account has been disabled",
                _ => "Authentication failed. Please try again"
            };
        }
    }
}
