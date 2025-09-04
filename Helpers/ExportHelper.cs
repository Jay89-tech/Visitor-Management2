// Helpers/ExportHelper.cs
using System.Text.Json;
using System.Text;
using SkillsAuditSystem.Models.DTOs;

namespace SkillsAuditSystem.Helpers
{
    public static class ExportHelper
    {
        public static byte[] ExportToCsv<T>(List<T> data, string[] headers, Func<T, string[]> rowSelector)
        {
            var csv = new StringBuilder();

            // Add headers
            csv.AppendLine(string.Join(",", headers.Select(EscapeCsvField)));

            // Add data rows
            foreach (var item in data)
            {
                var row = rowSelector(item);
                csv.AppendLine(string.Join(",", row.Select(EscapeCsvField)));
            }

            return Encoding.UTF8.GetBytes(csv.ToString());
        }

        public static byte[] ExportToJson<T>(List<T> data)
        {
            var json = JsonSerializer.Serialize(data, new JsonSerializerOptions
            {
                WriteIndented = true
            });

            return Encoding.UTF8.GetBytes(json);
        }

        public static byte[] ExportSkillsToCsv(List<SkillDto> skills)
        {
            var headers = new[] { "Name", "Category", "Level", "Years Experience", "Description", "Verified", "Created Date" };

            return ExportToCsv(skills, headers, skill => new[]
            {
                skill.Name,
                skill.Category,
                skill.Level,
                skill.YearsExperience.ToString(),
                skill.Description ?? "",
                skill.IsVerified ? "Yes" : "No",
                skill.CreatedAt.ToString("yyyy-MM-dd")
            });
        }

        public static byte[] ExportTrainingToCsv(List<TrainingDto> trainings)
        {
            var headers = new[] { "Title", "Provider", "Category", "Status", "Start Date", "End Date", "Duration (Hours)", "Description", "Created Date" };

            return ExportToCsv(trainings, headers, training => new[]
            {
                training.Title,
                training.Provider,
                training.Category,
                training.Status,
                training.StartDate?.ToString("yyyy-MM-dd") ?? "",
                training.EndDate?.ToString("yyyy-MM-dd") ?? "",
                training.Duration.ToString(),
                training.Description ?? "",
                training.CreatedAt.ToString("yyyy-MM-dd")
            });
        }

        private static string EscapeCsvField(string field)
        {
            if (string.IsNullOrEmpty(field))
                return "\"\"";

            if (field.Contains("\""))
                field = field.Replace("\"", "\"\"");

            if (field.Contains(",") || field.Contains("\"") || field.Contains("\r") || field.Contains("\n"))
                field = $"\"{field}\"";

            return field;
        }
    }
}