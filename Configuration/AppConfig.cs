// Configuration/AppConfig.cs
namespace SkillsAuditSystem.Configuration
{
    public class AppConfig
    {
        public const string SectionName = "AppSettings";

        public string ApplicationName { get; set; } = "Skills Audit System";
        public string Version { get; set; } = "1.0.0";
        public bool EnableDetailedErrors { get; set; } = false;
        public int SessionTimeoutMinutes { get; set; } = 30;
        public int MaxFileUploadSizeMB { get; set; } = 10;
        public string DefaultRole { get; set; } = "employee";
        public string[] AllowedFileExtensions { get; set; } = { ".pdf", ".doc", ".docx", ".jpg", ".jpeg", ".png" };
        public string[] AvailableDepartments { get; set; } =
        {
            "National Treasury",
            "Finance",
            "Human Resources",
            "Information Technology",
            "Operations",
            "Legal",
            "Audit"
        };
        public string[] SkillLevels { get; set; } =
        {
            "Beginner",
            "Intermediate",
            "Advanced",
            "Expert"
        };
        public string[] SkillCategories { get; set; } =
        {
            "Technical",
            "Management",
            "Communication",
            "Financial",
            "Legal",
            "Administrative"
        };
        public string[] TrainingStatuses { get; set; } =
        {
            "Planned",
            "In Progress",
            "Completed",
            "Cancelled"
        };
    }
}