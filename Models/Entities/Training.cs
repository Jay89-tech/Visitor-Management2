// Models/Entities/Training.cs
using Google.Cloud.Firestore;

namespace SkillsAuditSystem.Models.Entities
{
    [FirestoreData]
    public class Training
    {
        [FirestoreProperty("id")]
        public string Id { get; set; } = string.Empty;

        [FirestoreProperty("userId")]
        public string UserId { get; set; } = string.Empty;

        [FirestoreProperty("title")]
        public string Title { get; set; } = string.Empty;

        [FirestoreProperty("provider")]
        public string Provider { get; set; } = string.Empty;

        [FirestoreProperty("category")]
        public string Category { get; set; } = string.Empty;

        [FirestoreProperty("status")]
        public string Status { get; set; } = string.Empty; // Planned, In Progress, Completed

        [FirestoreProperty("startDate")]
        public DateTime? StartDate { get; set; }

        [FirestoreProperty("endDate")]
        public DateTime? EndDate { get; set; }

        [FirestoreProperty("duration")]
        public int Duration { get; set; } // Hours

        [FirestoreProperty("certificateUrl")]
        public string? CertificateUrl { get; set; }

        [FirestoreProperty("description")]
        public string? Description { get; set; }

        [FirestoreProperty("createdAt")]
        public DateTime CreatedAt { get; set; }

        [FirestoreProperty("updatedAt")]
        public DateTime UpdatedAt { get; set; }
    }
}