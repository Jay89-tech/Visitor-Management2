// Helpers/ConstantsHelper.cs
namespace SkillsAuditSystem.Helpers
{
    public static class ConstantsHelper
    {
        // Roles
        public static class Roles
        {
            public const string Admin = "admin";
            public const string Manager = "manager";
            public const string Employee = "employee";
        }

        // Skill Levels
        public static class SkillLevels
        {
            public const string Beginner = "Beginner";
            public const string Intermediate = "Intermediate";
            public const string Advanced = "Advanced";
            public const string Expert = "Expert";

            public static readonly Dictionary<string, int> LevelValues = new()
            {
                { Beginner, 1 },
                { Intermediate, 2 },
                { Advanced, 3 },
                { Expert, 4 }
            };
        }

        // Training Statuses
        public static class TrainingStatuses
        {
            public const string Planned = "Planned";
            public const string InProgress = "In Progress";
            public const string Completed = "Completed";
            public const string Cancelled = "Cancelled";
        }

        // Departments
        public static class Departments
        {
            public const string Treasury = "National Treasury";
            public const string Finance = "Finance";
            public const string HR = "Human Resources";
            public const string IT = "Information Technology";
            public const string Operations = "Operations";
            public const string Legal = "Legal";
            public const string Audit = "Audit";
        }

        // File Upload
        public static class FileUpload
        {
            public const int MaxFileSizeMB = 10;
            public static readonly string[] AllowedExtensions = { ".pdf", ".doc", ".docx", ".jpg", ".jpeg", ".png" };
            public const string UploadPath = "uploads";
        }

        // Cache Keys
        public static class CacheKeys
        {
            public const string UserProfile = "user_profile_{0}";
            public const string UserSkills = "user_skills_{0}";
            public const string DepartmentUsers = "department_users_{0}";
            public const string SkillCategories = "skill_categories";
        }

        // Session Keys
        public static class SessionKeys
        {
            public const string UserId = "UserId";
            public const string UserRole = "UserRole";
            public const string UserEmail = "UserEmail";
            public const string UserFullName = "UserFullName";
        }
    }
}