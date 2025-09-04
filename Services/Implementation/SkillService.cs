// Services/Implementation/SkillService.cs
using Google.Cloud.Firestore;
using SkillsAuditSystem.Services.Interfaces;
using SkillsAuditSystem.Models.Entities;
using SkillsAuditSystem.Models.ViewModels.Skills;
using SkillsAuditSystem.Models.DTOs;
using SkillsAuditSystem.Services.Firebase;

namespace SkillsAuditSystem.Services.Implementation
{
    public class SkillService : ISkillService
    {
        private readonly FirestoreDb _firestoreDb;
        private readonly ILogger<SkillService> _logger;

        public SkillService(FirestoreDb firestoreDb, ILogger<SkillService> logger)
        {
            _firestoreDb = firestoreDb;
            _logger = logger;
        }

        public async Task<List<SkillDto>> GetUserSkillsAsync(string userId)
        {
            try
            {
                var query = await _firestoreDb.Collection("skills")
                    .WhereEqualTo("userId", userId)
                    .OrderBy("name")
                    .GetSnapshotAsync();

                return query.Documents
                    .Select(doc => MapToSkillDto(doc.ConvertTo<Skill>()))
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user skills for user: {UserId}", userId);
                return new List<SkillDto>();
            }
        }

        public async Task<SkillDto?> GetSkillByIdAsync(string skillId)
        {
            try
            {
                var skillDoc = await _firestoreDb.Collection("skills").Document(skillId).GetSnapshotAsync();

                if (!skillDoc.Exists)
                    return null;

                var skill = skillDoc.ConvertTo<Skill>();
                return MapToSkillDto(skill);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting skill by ID: {SkillId}", skillId);
                return null;
            }
        }

        public async Task<bool> AddSkillAsync(string userId, AddSkillViewModel model)
        {
            try
            {
                var skill = new Skill
                {
                    Id = FirebaseHelper.GenerateId(),
                    UserId = userId,
                    Name = model.Name,
                    Category = model.Category,
                    Level = model.Level,
                    Description = model.Description,
                    YearsExperience = model.YearsExperience,
                    IsVerified = false,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                await _firestoreDb.Collection("skills").Document(skill.Id).SetAsync(skill);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding skill for user: {UserId}", userId);
                return false;
            }
        }

        public async Task<bool> UpdateSkillAsync(string skillId, EditSkillViewModel model)
        {
            try
            {
                var updates = new Dictionary<string, object>
                {
                    { "name", model.Name },
                    { "category", model.Category },
                    { "level", model.Level },
                    { "description", model.Description ?? "" },
                    { "yearsExperience", model.YearsExperience },
                    { "updatedAt", Timestamp.FromDateTime(DateTime.UtcNow) }
                };

                await _firestoreDb.Collection("skills").Document(skillId).UpdateAsync(updates);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating skill: {SkillId}", skillId);
                return false;
            }
        }

        public async Task<bool> DeleteSkillAsync(string skillId)
        {
            try
            {
                await _firestoreDb.Collection("skills").Document(skillId).DeleteAsync();
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting skill: {SkillId}", skillId);
                return false;
            }
        }

        public async Task<List<SkillDto>> GetSkillsByCategoryAsync(string category)
        {
            try
            {
                var query = await _firestoreDb.Collection("skills")
                    .WhereEqualTo("category", category)
                    .OrderBy("name")
                    .GetSnapshotAsync();

                return query.Documents
                    .Select(doc => MapToSkillDto(doc.ConvertTo<Skill>()))
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting skills by category: {Category}", category);
                return new List<SkillDto>();
            }
        }

        public async Task<List<string>> GetSkillCategoriesAsync()
        {
            try
            {
                var query = await _firestoreDb.Collection("skills").GetSnapshotAsync();

                return query.Documents
                    .Select(doc => doc.GetValue<string>("category"))
                    .Where(category => !string.IsNullOrEmpty(category))
                    .Distinct()
                    .OrderBy(category => category)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting skill categories");
                return new List<string>();
            }
        }

        public async Task<List<SkillDto>> SearchSkillsAsync(string userId, string searchTerm)
        {
            try
            {
                var allSkills = await GetUserSkillsAsync(userId);

                return allSkills
                    .Where(skill => skill.Name.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ||
                                   (skill.Description?.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ?? false))
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching skills for user: {UserId}", userId);
                return new List<SkillDto>();
            }
        }

        public async Task<bool> ValidateSkillOwnershipAsync(string skillId, string userId)
        {
            try
            {
                var skillDoc = await _firestoreDb.Collection("skills").Document(skillId).GetSnapshotAsync();

                if (!skillDoc.Exists)
                    return false;

                return skillDoc.GetValue<string>("userId") == userId;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error validating skill ownership: {SkillId}", skillId);
                return false;
            }
        }

        public async Task<Dictionary<string, int>> GetSkillsStatsByUserAsync(string userId)
        {
            try
            {
                var skills = await GetUserSkillsAsync(userId);

                return new Dictionary<string, int>
                {
                    { "total", skills.Count },
                    { "beginner", skills.Count(s => s.Level == "Beginner") },
                    { "intermediate", skills.Count(s => s.Level == "Intermediate") },
                    { "advanced", skills.Count(s => s.Level == "Advanced") },
                    { "expert", skills.Count(s => s.Level == "Expert") },
                    { "verified", skills.Count(s => s.IsVerified) }
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting skills stats for user: {UserId}", userId);
                return new Dictionary<string, int>();
            }
        }

        public async Task<List<SkillDto>> GetTopSkillsAsync(int count = 10)
        {
            try
            {
                // This would require aggregation - simplified version
                var query = await _firestoreDb.Collection("skills")
                    .OrderByDescending("yearsExperience")
                    .Limit(count)
                    .GetSnapshotAsync();

                return query.Documents
                    .Select(doc => MapToSkillDto(doc.ConvertTo<Skill>()))
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting top skills");
                return new List<SkillDto>();
            }
        }

        public async Task<bool> ImportSkillsAsync(string userId, List<Skill> skills)
        {
            try
            {
                var batch = _firestoreDb.StartBatch();

                foreach (var skill in skills)
                {
                    skill.Id = FirebaseHelper.GenerateId();
                    skill.UserId = userId;
                    skill.CreatedAt = DateTime.UtcNow;
                    skill.UpdatedAt = DateTime.UtcNow;

                    var docRef = _firestoreDb.Collection("skills").Document(skill.Id);
                    batch.Set(docRef, skill);
                }

                await batch.CommitAsync();
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error importing skills for user: {UserId}", userId);
                return false;
            }
        }

        public async Task<byte[]> ExportUserSkillsAsync(string userId, string format = "pdf")
        {
            try
            {
                var skills = await GetUserSkillsAsync(userId);

                // For now, return CSV export - PDF would require additional library
                return Helpers.ExportHelper.ExportSkillsToCsv(skills);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error exporting skills for user: {UserId}", userId);
                return Array.Empty<byte>();
            }
        }

        private SkillDto MapToSkillDto(Skill skill)
        {
            return new SkillDto
            {
                Id = skill.Id,
                UserId = skill.UserId,
                Name = skill.Name,
                Category = skill.Category,
                Level = skill.Level,
                Description = skill.Description,
                YearsExperience = skill.YearsExperience,
                IsVerified = skill.IsVerified,
                CreatedAt = skill.CreatedAt,
                UpdatedAt = skill.UpdatedAt
            };
        }
    }
}