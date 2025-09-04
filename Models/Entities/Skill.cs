// Models/Entities/Skill.cs
using Google.Cloud.Firestore;

namespace SkillsAuditSystem.Models.Entities
{
    [FirestoreData]
    public class Skill
    {
        [FirestoreProperty("id")]
        public string Id { get; set; } = string.Empty;

        [FirestoreProperty("userId")]
        public string UserId { get; set; } = string.Empty;

        [FirestoreProperty("name")]
        public string Name { get; set; } = string.Empty;

        [FirestoreProperty("category")]
        public string Category { get; set; } = string.Empty;

        [FirestoreProperty("level")]
        public string Level { get; set; } = string.Empty; // Beginner, Intermediate, Advanced, Expert

        [FirestoreProperty("description")]
        public string? Description { get; set; }

        [FirestoreProperty("yearsExperience")]
        public int YearsExperience { get; set; }

        [FirestoreProperty("isVerified")]
        public bool IsVerified { get; set; } = false;

        [FirestoreProperty("createdAt")]
        public DateTime CreatedAt { get; set; }

        [FirestoreProperty("updatedAt")]
        public DateTime UpdatedAt { get; set; }
    }
}