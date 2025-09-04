// Configuration/EmailConfig.cs
namespace SkillsAuditSystem.Configuration
{
    public class EmailConfig
    {
        public const string SectionName = "Email";

        public string SmtpServer { get; set; } = string.Empty;
        public int SmtpPort { get; set; } = 587;
        public string SmtpUsername { get; set; } = string.Empty;
        public string SmtpPassword { get; set; } = string.Empty;
        public bool EnableSsl { get; set; } = true;
        public string FromEmail { get; set; } = string.Empty;
        public string FromName { get; set; } = "Skills Audit System";
        public bool EnableEmailNotifications { get; set; } = true;
        public string[] AdminEmails { get; set; } = Array.Empty<string>();

        // Email Templates
        public string WelcomeEmailTemplate { get; set; } = "WelcomeTemplate";
        public string PasswordResetTemplate { get; set; } = "PasswordResetTemplate";
        public string TrainingReminderTemplate { get; set; } = "TrainingReminderTemplate";
        public string CertificationExpiryTemplate { get; set; } = "CertificationExpiryTemplate";
    }
}