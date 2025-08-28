// Services/Interfaces/ITrainingService.cs
using SkillsAuditSystem.Models.Entities;
using SkillsAuditSystem.Models.ViewModels.Training;
using SkillsAuditSystem.Models.DTOs;

namespace SkillsAuditSystem.Services.Interfaces
{
    public interface ITrainingService
    {
        Task<List<TrainingDto>> GetUserTrainingsAsync(string userId);
        Task<TrainingDto?> GetTrainingByIdAsync(string trainingId);
        Task<bool> AddTrainingAsync(string userId, AddTrainingViewModel model);
        Task<bool> UpdateTrainingAsync(string trainingId, EditTrainingViewModel model);
        Task<bool> DeleteTrainingAsync(string trainingId);
        Task<List<TrainingDto>> GetTrainingsByStatusAsync(string userId, string status);
        Task<List<TrainingDto>> GetTrainingsByDateRangeAsync(string userId, DateTime startDate, DateTime endDate);
        Task<bool> ValidateTrainingOwnershipAsync(string trainingId, string userId);
        Task<Dictionary<string, object>> GetTrainingStatsAsync(string userId);
        Task<List<TrainingDto>> GetUpcomingTrainingsAsync(string userId);
        Task<List<TrainingDto>> GetCompletedTrainingsAsync(string userId);
        Task<int> GetTrainingHoursAsync(string userId);
    }
}