// Services/Implementation/TrainingService.cs
using Google.Cloud.Firestore;
using SkillsAuditSystem.Services.Interfaces;
using SkillsAuditSystem.Models.Entities;
using SkillsAuditSystem.Models.ViewModels.Training;
using SkillsAuditSystem.Models.DTOs;
using SkillsAuditSystem.Services.Firebase;
using System.Globalization;

namespace SkillsAuditSystem.Services.Implementation
{
    public class TrainingService : ITrainingService
    {
        private readonly FirestoreDb _firestoreDb;
        private readonly ILogger<TrainingService> _logger;

        public TrainingService(FirestoreDb firestoreDb, ILogger<TrainingService> logger)
        {
            _firestoreDb = firestoreDb;
            _logger = logger;
        }

        private static TrainingDto MapToTrainingDto(Training training)
        {
            return new TrainingDto
            {
                Id = training.Id,
                Title = training.Title,
                Provider = training.Provider,
                Category = training.Category,
                Status = training.Status,
                StartDate = training.StartDate,
                EndDate = training.EndDate,
                Duration = training.Duration,
                CertificateUrl = training.CertificateUrl,
                Description = training.Description,
                CreatedAt = training.CreatedAt,
                UpdatedAt = training.UpdatedAt
            };
        }

        public async Task<List<TrainingDto>> GetUserTrainingsAsync(string userId)
        {
            try
            {
                var query = await _firestoreDb.Collection("training")
                    .WhereEqualTo("userId", userId)
                    .OrderByDescending("createdAt")
                    .GetSnapshotAsync();
                return query.Documents
                    .Select(doc => MapToTrainingDto(doc.ConvertTo<Training>()))
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user training for user: {UserId}", userId);
                return new List<TrainingDto>();
            }
        }

        public async Task<TrainingDto?> GetTrainingByIdAsync(string trainingId)
        {
            try
            {
                var trainingDoc = await _firestoreDb.Collection("training").Document(trainingId).GetSnapshotAsync();
                if (!trainingDoc.Exists)
                    return null;
                var training = trainingDoc.ConvertTo<Training>();
                return MapToTrainingDto(training);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting training by ID: {TrainingId}", trainingId);
                return null;
            }
        }

        public async Task<bool> AddTrainingAsync(string userId, AddTrainingViewModel model)
        {
            try
            {
                var training = new Training
                {
                    Id = FirebaseHelper.GenerateId(),
                    UserId = userId,
                    Title = model.Title,
                    Provider = model.Provider,
                    Category = model.Category,
                    Status = model.Status,
                    StartDate = model.StartDate,
                    EndDate = model.EndDate,
                    Duration = model.Duration,
                    CertificateUrl = model.CertificateUrl,
                    Description = model.Description,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                await _firestoreDb.Collection("training").Document(training.Id).SetAsync(training);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding training for user: {UserId}", userId);
                return false;
            }
        }

        public async Task<bool> UpdateTrainingAsync(string trainingId, EditTrainingViewModel model)
        {
            try
            {
                var updates = new Dictionary<string, object>
                {
                    { "title", model.Title },
                    { "provider", model.Provider },
                    { "category", model.Category },
                    { "status", model.Status },
                    { "duration", model.Duration },
                    { "description", model.Description ?? "" },
                    { "updatedAt", DateTime.UtcNow }
                };

                if (model.StartDate.HasValue)
                    updates.Add("startDate", model.StartDate.Value);

                if (model.EndDate.HasValue)
                    updates.Add("endDate", model.EndDate.Value);

                if (!string.IsNullOrEmpty(model.CertificateUrl))
                    updates.Add("certificateUrl", model.CertificateUrl);

                await _firestoreDb.Collection("training").Document(trainingId).UpdateAsync(updates);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating training: {TrainingId}", trainingId);
                return false;
            }
        }

        public async Task<bool> DeleteTrainingAsync(string trainingId)
        {
            try
            {
                await _firestoreDb.Collection("training").Document(trainingId).DeleteAsync();
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting training: {TrainingId}", trainingId);
                return false;
            }
        }

        public async Task<List<TrainingDto>> GetTrainingsByStatusAsync(string userId, string status)
        {
            try
            {
                var query = await _firestoreDb.Collection("training")
                    .WhereEqualTo("userId", userId)
                    .WhereEqualTo("status", status)
                    .OrderByDescending("createdAt")
                    .GetSnapshotAsync();
                return query.Documents
                    .Select(doc => MapToTrainingDto(doc.ConvertTo<Training>()))
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting training by status for user: {UserId}", userId);
                return new List<TrainingDto>();
            }
        }

        public async Task<List<TrainingDto>> GetTrainingsByDateRangeAsync(string userId, DateTime startDate, DateTime endDate)
        {
            try
            {
                var query = await _firestoreDb.Collection("training")
                    .WhereEqualTo("userId", userId)
                    .WhereGreaterThanOrEqualTo("startDate", startDate)
                    .WhereLessThanOrEqualTo("startDate", endDate)
                    .OrderByDescending("createdAt")
                    .GetSnapshotAsync();
                return query.Documents
                    .Select(doc => MapToTrainingDto(doc.ConvertTo<Training>()))
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting training by date range for user: {UserId}", userId);
                return new List<TrainingDto>();
            }
        }

        Task<List<TrainingDto>> ITrainingService.GetUserTrainingsAsync(string userId)
        {
            throw new NotImplementedException();
        }

        Task<TrainingDto?> ITrainingService.GetTrainingByIdAsync(string trainingId)
        {
            throw new NotImplementedException();
        }

        Task<bool> ITrainingService.AddTrainingAsync(string userId, AddTrainingViewModel model)
        {
            throw new NotImplementedException();
        }

        Task<bool> ITrainingService.UpdateTrainingAsync(string trainingId, EditTrainingViewModel model)
        {
            throw new NotImplementedException();
        }

        Task<bool> ITrainingService.DeleteTrainingAsync(string trainingId)
        {
            throw new NotImplementedException();
        }

        Task<List<TrainingDto>> ITrainingService.GetTrainingsByStatusAsync(string userId, string status)
        {
            throw new NotImplementedException();
        }

        Task<List<TrainingDto>> ITrainingService.GetTrainingsByDateRangeAsync(string userId, DateTime startDate, DateTime endDate)
        {
            throw new NotImplementedException();
        }

        Task<bool> ITrainingService.ValidateTrainingOwnershipAsync(string trainingId, string userId)
        {
            throw new NotImplementedException();
        }

        Task<Dictionary<string, object>> ITrainingService.GetTrainingStatsAsync(string userId)
        {
            throw new NotImplementedException();
        }

        Task<List<TrainingDto>> ITrainingService.GetUpcomingTrainingsAsync(string userId)
        {
            throw new NotImplementedException();
        }

        Task<List<TrainingDto>> ITrainingService.GetCompletedTrainingsAsync(string userId)
        {
            throw new NotImplementedException();
        }

        Task<int> ITrainingService.GetTrainingHoursAsync(string userId)
        {
            throw new NotImplementedException();
        }
    }
}