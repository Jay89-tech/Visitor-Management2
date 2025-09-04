using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Google.Cloud.Firestore;
using SkillsAuditSystem.Models.Entities;
using SkillsAuditSystem.Models.ViewModels.Auth;
using SkillsAuditSystem.Services.Interfaces;
using System.Net.Http;
using System.Text;
using System.Text.Json;

namespace SkillsAuditSystem.Services.Implementation
{
    public class FirebaseAuthService : IAuthService
    {
        private readonly HttpClient _httpClient;
        private readonly FirestoreDb _firestoreDb;
        private readonly ILogger<FirebaseAuthService> _logger;
        private readonly IConfiguration _configuration;
        private readonly string _apiKey;
        private readonly string _authUrl;

        public FirebaseAuthService(ILogger<FirebaseAuthService> logger, IConfiguration configuration, HttpClient httpClient)
        {
            _logger = logger;
            _configuration = configuration;
            _httpClient = httpClient;
            _apiKey = _configuration["Firebase:ApiKey"];
            _authUrl = "https://identitytoolkit.googleapis.com/v1/accounts";

            // Initialize Firestore
            _firestoreDb = FirestoreDb.Create(_configuration["Firebase:ProjectId"]);
        }

        public async Task<AuthResult> LoginAsync(LoginViewModel model)
        {
            try
            {
                var requestBody = new
                {
                    email = model.Email,
                    password = model.Password,
                    returnSecureToken = true
                };

                var json = JsonSerializer.Serialize(requestBody);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var response = await _httpClient.PostAsync($"{_authUrl}:signInWithPassword?key={_apiKey}", content);
                var responseContent = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    var errorResponse = JsonSerializer.Deserialize<FirebaseErrorResponse>(responseContent);
                    return new AuthResult { Success = false, Message = GetAuthErrorMessage(errorResponse?.Error?.Message) };
                }

                var authResponse = JsonSerializer.Deserialize<FirebaseAuthResponse>(responseContent);

                if (authResponse == null || string.IsNullOrEmpty(authResponse.LocalId))
                {
                    return new AuthResult { Success = false, Message = "Invalid login credentials" };
                }

                // Get user data from Firestore
                var userDoc = await _firestoreDb.Collection("users").Document(authResponse.LocalId).GetSnapshotAsync();
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
                    UserId = authResponse.LocalId,
                    Token = authResponse.IdToken,
                    Email = authResponse.Email,
                    Role = userData.ContainsKey("role") ? userData["role"].ToString() : "employee"
                };
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

                var requestBody = new
                {
                    email = model.Email,
                    password = model.Password,
                    returnSecureToken = true
                };

                var json = JsonSerializer.Serialize(requestBody);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var response = await _httpClient.PostAsync($"{_authUrl}:signUp?key={_apiKey}", content);
                var responseContent = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    var errorResponse = JsonSerializer.Deserialize<FirebaseErrorResponse>(responseContent);
                    return new AuthResult { Success = false, Message = GetAuthErrorMessage(errorResponse?.Error?.Message) };
                }

                var authResponse = JsonSerializer.Deserialize<FirebaseAuthResponse>(responseContent);

                if (authResponse == null || string.IsNullOrEmpty(authResponse.LocalId))
                {
                    return new AuthResult { Success = false, Message = "Failed to create user account" };
                }

                // Create user profile in Firestore
                var user = new User
                {
                    Id = authResponse.LocalId,
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

                await _firestoreDb.Collection("users").Document(authResponse.LocalId).SetAsync(user);

                return new AuthResult
                {
                    Success = true,
                    Message = "Registration successful",
                    UserId = authResponse.LocalId,
                    Token = authResponse.IdToken,
                    Email = authResponse.Email,
                    Role = "employee"
                };
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
                var requestBody = new
                {
                    requestType = "PASSWORD_RESET",
                    email = email
                };

                var json = JsonSerializer.Serialize(requestBody);
                var content = new StringContent(json, Encoding.UTF8, "application/json");

                var response = await _httpClient.PostAsync($"{_authUrl}:sendOobCode?key={_apiKey}", content);
                var responseContent = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    var errorResponse = JsonSerializer.Deserialize<FirebaseErrorResponse>(responseContent);
                    return new AuthResult { Success = false, Message = GetAuthErrorMessage(errorResponse?.Error?.Message) };
                }

                return new AuthResult { Success = true, Message = "Password reset email sent successfully" };
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
                var updates = new Dictionary<string, object>
                {
                    { "lastActivity", DateTime.UtcNow }
                };

                await _firestoreDb.Collection("users").Document(uid).UpdateAsync(updates);
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
                var loginResult = await LoginAsync(new LoginViewModel { Email = email, Password = currentPassword });
                if (!loginResult.Success) return false;

                // Check if Firebase Admin is initialized before using it
                if (FirebaseApp.DefaultInstance == null)
                {
                    _logger.LogWarning("Firebase Admin not initialized - cannot change password server-side");
                    return false;
                }

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
                // Check if Firebase Admin is initialized before using it
                if (FirebaseApp.DefaultInstance == null)
                {
                    _logger.LogWarning("Firebase Admin not initialized - cannot update email server-side");
                    return false;
                }

                var userRecord = await FirebaseAuth.DefaultInstance.UpdateUserAsync(new UserRecordArgs
                {
                    Uid = uid,
                    Email = newEmail
                });

                // Update email in Firestore as well
                var updates = new Dictionary<string, object>
                {
                    { "email", newEmail },
                    { "updatedAt", DateTime.UtcNow }
                };

                await _firestoreDb.Collection("users").Document(uid).UpdateAsync(updates);

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

        private string GetAuthErrorMessage(string errorMessage)
        {
            return errorMessage switch
            {
                "EMAIL_NOT_FOUND" => "No account found with this email address",
                "INVALID_PASSWORD" => "Invalid password",
                "INVALID_EMAIL" => "Invalid email address format",
                "EMAIL_EXISTS" => "An account already exists with this email",
                "WEAK_PASSWORD" => "Password is too weak",
                "TOO_MANY_ATTEMPTS_TRY_LATER" => "Too many failed attempts. Please try again later",
                "USER_DISABLED" => "This account has been disabled",
                _ => "Authentication failed. Please try again"
            };
        }
    }

    // Helper classes for Firebase REST API responses
    public class FirebaseAuthResponse
    {
        public string IdToken { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;
        public string ExpiresIn { get; set; } = string.Empty;
        public string LocalId { get; set; } = string.Empty;
    }

    public class FirebaseErrorResponse
    {
        public FirebaseError Error { get; set; } = new();
    }

    public class FirebaseError
    {
        public int Code { get; set; }
        public string Message { get; set; } = string.Empty;
    }
}