// Services/Firebase/FirebaseContext.cs
using Google.Cloud.Firestore;

namespace SkillsAuditSystem.Services.Firebase
{
    public class FirebaseContext
    {
        private readonly FirestoreDb _firestoreDb;
        private readonly ILogger<FirebaseContext> _logger;

        public FirebaseContext(IConfiguration configuration, ILogger<FirebaseContext> logger)
        {
            _logger = logger;
            var projectId = configuration["Firebase:ProjectId"];
            _firestoreDb = FirestoreDb.Create(projectId);
        }

        public FirestoreDb Database => _firestoreDb;

        public CollectionReference Users => _firestoreDb.Collection("users");
        public CollectionReference Skills => _firestoreDb.Collection("skills");
        public CollectionReference Training => _firestoreDb.Collection("training");
        public CollectionReference Reports => _firestoreDb.Collection("reports");
        public CollectionReference Notifications => _firestoreDb.Collection("notifications");

        public async Task<bool> TestConnectionAsync()
        {
            try
            {
                var testDoc = _firestoreDb.Collection("test").Document("connection");
                await testDoc.SetAsync(new { timestamp = DateTime.UtcNow });
                await testDoc.DeleteAsync();
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Firebase connection test failed");
                return false;
            }
        }

        public async Task<Dictionary<string, object>> GetDatabaseStatsAsync()
        {
            try
            {
                var stats = new Dictionary<string, object>();

                var usersSnapshot = await Users.GetSnapshotAsync();
                stats["totalUsers"] = usersSnapshot.Count;

                var skillsSnapshot = await Skills.GetSnapshotAsync();
                stats["totalSkills"] = skillsSnapshot.Count;

                var trainingSnapshot = await Training.GetSnapshotAsync();
                stats["totalTraining"] = trainingSnapshot.Count;

                return stats;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting database stats");
                return new Dictionary<string, object>();
            }
        }
    }
}