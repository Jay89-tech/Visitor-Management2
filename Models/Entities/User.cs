// Models/Entities/User.cs
using Google.Cloud.Firestore;

namespace SkillsAuditSystem.Models.Entities
{
    [FirestoreData]
    public class User
    {
        [FirestoreProperty("id")]
        public string Id { get; set; } = string.Empty;

        [FirestoreProperty("firstName")]
        public string FirstName { get; set; } = string.Empty;

        [FirestoreProperty("lastName")]
        public string LastName { get; set; } = string.Empty;

        [FirestoreProperty("email")]
        public string Email { get; set; } = string.Empty;

        [FirestoreProperty("employeeId")]
        public string EmployeeId { get; set; } = string.Empty;

        [FirestoreProperty("department")]
        public string Department { get; set; } = string.Empty;

        [FirestoreProperty("role")]
        public string Role { get; set; } = "employee";

        [FirestoreProperty("isActive")]
        public bool IsActive { get; set; } = true;

        [FirestoreProperty("phoneNumber")]
        public string? PhoneNumber { get; set; }

        [FirestoreProperty("position")]
        public string? Position { get; set; }

        [FirestoreProperty("createdAt")]
        public DateTime CreatedAt { get; set; }

        [FirestoreProperty("updatedAt")]
        public DateTime UpdatedAt { get; set; }
    }
}