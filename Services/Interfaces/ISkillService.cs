// Services/Interfaces/ISkillService.cs
using SkillsAuditSystem.Models.Entities;
using SkillsAuditSystem.Models.ViewModels.Skills;
using SkillsAuditSystem.Models.DTOs;

namespace SkillsAuditSystem.Services.Interfaces
{
    public interface ISkillService
    {
        Task<List<SkillDto>> GetUserSkillsAsync(string userId);
        Task<SkillDto?> GetSkillByIdAsync(string skillId);
        Task<bool> AddSkillAsync(string userId, AddSkillViewModel model);
        Task<bool> UpdateSkillAsync(string skillId, EditSkillViewModel model);
        Task<bool> DeleteSkillAsync(string skillId);
        Task<List<SkillDto>> GetSkillsByCategoryAsync(string category);
        Task<List<string>> GetSkillCategoriesAsync();
        Task<List<SkillDto>> SearchSkillsAsync(string userId, string searchTerm);
        Task<bool> ValidateSkillOwnershipAsync(string skillId, string userId);
        Task<Dictionary<string, int>> GetSkillsStatsByUserAsync(string userId);
        Task<List<SkillDto>> GetTopSkillsAsync(int count = 10);
        Task<bool> ImportSkillsAsync(string userId, List<Skill> skills);
        Task<byte[]> ExportUserSkillsAsync(string userId, string format = "pdf");
    }
}