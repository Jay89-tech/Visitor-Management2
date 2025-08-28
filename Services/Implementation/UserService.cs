// Services/Implementation/UserService.cs
using Google.Cloud.Firestore;
using SkillsAuditSystem.Services.Interfaces;
using SkillsAuditSystem.Models.Entities;
using SkillsAuditSystem.Models.ViewModels.Profile;
using SkillsAuditSystem.Models.DTOs;

namespace SkillsAuditSystem.Services.Implementation
{
    public class UserService : IUserService
    {
        private readonly FirestoreDb _firestoreDb;
        private readonly ILogger<UserService> _logger;

        public UserService(FirestoreDb firestoreDb, ILogger<UserService> logger)
        {
            _firestoreDb = firestoreDb;
            _logger = logger;
        }

        public async Task<UserDto?> GetUserByIdAsync(string userId)
        {
            try
            {
                var userDoc = await _firestoreDb.Collection("users").Document(userId).GetSnapshotAsync();

                if (!userDoc.Exists)
                    return null;

                var user = userDoc.ConvertTo<User>();
                return MapToUserDto(user);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user by ID: {UserId}", userId);
                return null;
            }
        }

        public async Task<UserDto?> GetUserByEmailAsync(string email)
        {
            try
            {
                var query = await _firestoreDb.Collection("users")
                    .WhereEqualTo("email", email)
                    .GetSnapshotAsync();

                if (query.Documents.Count == 0)
                    return null;

                var user = query.Documents.First().ConvertTo<User>();
                return MapToUserDto(user);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user by email: {Email}", email);
                return null;
            }
        }

        public async Task<UserDto?> GetUserByEmployeeIdAsync(string employeeId)
        {
            try
            {
                var query = await _firestoreDb.Collection("users")
                    .WhereEqualTo("employeeId", employeeId)
                    .GetSnapshotAsync();

                if (query.Documents.Count == 0)
                    return null;

                var user = query.Documents.First().ConvertTo<User>();
                return MapToUserDto(user);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user by employee ID: {EmployeeId}", employeeId);
                return null;
            }
        }

        public async Task<bool> CreateUserAsync(User user)
        {
            try
            {
                await _firestoreDb.Collection("users").Document(user.Id).SetAsync(user);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating user: {UserId}", user.Id);
                return false;
            }
        }

        public async Task<bool> UpdateUserAsync(string userId, ProfileViewModel model)
        {
            try
            {
                var updates = new Dictionary<string, object>
                {
                    { "firstName", model.FirstName },
                    { "lastName", model.LastName },
                    { "department", model.Department },
                    { "phoneNumber", model.PhoneNumber ?? "" },
                    { "position", model.Position ?? "" },
                    { "updatedAt", DateTime.UtcNow }
                };

                await _firestoreDb.Collection("users").Document(userId).UpdateAsync(updates);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user: {UserId}", userId);
                return false;
            }
        }

        public async Task<bool> DeleteUserAsync(string userId)
        {
            try
            {
                // Soft delete - mark as inactive
                await _firestoreDb.Collection("users").Document(userId)
                    .UpdateAsync("isActive", false, "updatedAt", DateTime.UtcNow);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting user: {UserId}", userId);
                return false;
            }
        }

        public async Task<List<UserDto>> GetAllUsersAsync()
        {
            try
            {
                var query = await _firestoreDb.Collection("users")
                    .WhereEqualTo("isActive", true)
                    .GetSnapshotAsync();

                return query.Documents
                    .Select(doc => MapToUserDto(doc.ConvertTo<User>()))
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting all users");
                return new List<UserDto>();
            }
        }

        public async Task<List<UserDto>> GetUsersByDepartmentAsync(string department)
        {
            try
            {
                var query = await _firestoreDb.Collection("users")
                    .WhereEqualTo("department", department)
                    .WhereEqualTo("isActive", true)
                    .GetSnapshotAsync();

                return query.Documents
                    .Select(doc => MapToUserDto(doc.ConvertTo<User>()))
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting users by department: {Department}", department);
                return new List<UserDto>();
            }
        }

        public async Task<List<UserDto>> GetUsersByRoleAsync(string role)
        {
            try
            {
                var query = await _firestoreDb.Collection("users")
                    .WhereEqualTo("role", role)
                    .WhereEqualTo("isActive", true)
                    .GetSnapshotAsync();

                return query.Documents
                    .Select(doc => MapToUserDto(doc.ConvertTo<User>()))
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting users by role: {Role}", role);
                return new List<UserDto>();
            }
        }

        public async Task<bool> UpdateUserRoleAsync(string userId, string role)
        {
            try
            {
                await _firestoreDb.Collection("users").Document(userId)
                    .UpdateAsync("role", role, "updatedAt", DateTime.UtcNow);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user role: {UserId}", userId);
                return false;
            }
        }

        public async Task<bool> ActivateUserAsync(string userId)
        {
            try
            {
                await _firestoreDb.Collection("users").Document(userId)
                    .UpdateAsync("isActive", true, "updatedAt", DateTime.UtcNow);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error activating user: {UserId}", userId);
                return false;
            }
        }

        public async Task<bool> DeactivateUserAsync(string userId)
        {
            try
            {
                await _firestoreDb.Collection("users").Document(userId)
                    .UpdateAsync("isActive", false, "updatedAt", DateTime.UtcNow);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deactivating user: {UserId}", userId);
                return false;
            }
        }

        public async Task<ProfileViewModel?> GetUserProfileAsync(string userId)
        {
            try
            {
                var userDoc = await _firestoreDb.Collection("users").Document(userId).GetSnapshotAsync();

                if (!userDoc.Exists)
                    return null;

                var user = userDoc.ConvertTo<User>();
                return new ProfileViewModel
                {
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    Email = user.Email,
                    EmployeeId = user.EmployeeId,
                    Department = user.Department,
                    PhoneNumber = user.PhoneNumber,
                    Position = user.Position,
                    JoinDate = user.CreatedAt
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user profile: {UserId}", userId);
                return null;
            }
        }

        public async Task<bool> UpdateUserProfileAsync(string userId, EditProfileViewModel model)
        {
            try
            {
                var updates = new Dictionary<string, object>
                {
                    { "firstName", model.FirstName },
                    { "lastName", model.LastName },
                    { "phoneNumber", model.PhoneNumber ?? "" },
                    { "position", model.Position ?? "" },
                    { "department", model.Department },
                    { "updatedAt", DateTime.UtcNow }
                };

                await _firestoreDb.Collection("users").Document(userId).UpdateAsync(updates);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user profile: {UserId}", userId);
                return false;
            }
        }

        public async Task<Dictionary<string, object>> GetUserStatsAsync(string userId)
        {
            try
            {
                var stats = new Dictionary<string, object>();

                // Get skills count
                var skillsQuery = await _firestoreDb.Collection("skills")
                    .WhereEqualTo("userId", userId)
                    .GetSnapshotAsync();
                stats["totalSkills"] = skillsQuery.Documents.Count;

                // Get training count
                var trainingQuery = await _firestoreDb.Collection("training")
                    .WhereEqualTo("userId", userId)
                    .GetSnapshotAsync();
                stats["totalTraining"] = trainingQuery.Documents.Count;

                // Get qualifications count
                var qualificationsQuery = await _firestoreDb.Collection("qualifications")
                    .WhereEqualTo("userId", userId)
                    .GetSnapshotAsync();
                stats["totalQualifications"] = qualificationsQuery.Documents.Count;

                // Calculate profile completion
                var userDoc = await _firestoreDb.Collection("users").Document(userId).GetSnapshotAsync();
                if (userDoc.Exists)
                {
                    var user = userDoc.ConvertTo<User>();
                    var completionPercentage = CalculateProfileCompletion(user);
                    stats["profileCompletion"] = completionPercentage;
                }

                return stats;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user stats: {UserId}", userId);
                return new Dictionary<string, object>();
            }
        }

        public async Task<bool> IsUserActiveAsync(string userId)
        {
            try
            {
                var userDoc = await _firestoreDb.Collection("users").Document(userId).GetSnapshotAsync();

                if (!userDoc.Exists)
                    return false;

                return userDoc.GetValue<bool>("isActive");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if user is active: {UserId}", userId);
                return false;
            }
        }

        private UserDto MapToUserDto(User user)
        {
            return new UserDto
            {
                Id = user.Id,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                EmployeeId = user.EmployeeId,
                Department = user.Department,
                Role = user.Role,
                IsActive = user.IsActive,
                PhoneNumber = user.PhoneNumber,
                Position = user.Position,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt
            };
        }

        private int CalculateProfileCompletion(User user)
        {
            int completedFields = 0;
            int totalFields = 8;

            if (!string.IsNullOrEmpty(user.FirstName)) completedFields++;
            if (!string.IsNullOrEmpty(user.LastName)) completedFields++;
            if (!string.IsNullOrEmpty(user.Email)) completedFields++;
            if (!string.IsNullOrEmpty(user.EmployeeId)) completedFields++;
            if (!string.IsNullOrEmpty(user.Department)) completedFields++;
            if (!string.IsNullOrEmpty(user.PhoneNumber)) completedFields++;
            if (!string.IsNullOrEmpty(user.Position)) completedFields++;
            if (user.CreatedAt != default) completedFields++;

            return (int)Math.Round((double)completedFields / totalFields * 100);
        }
    }
}