// Helpers/DateTimeHelper.cs
namespace SkillsAuditSystem.Helpers
{
    public static class DateTimeHelper
    {
        public static string FormatDate(DateTime date)
        {
            return date.ToString("dd MMM yyyy");
        }

        public static string FormatDateTime(DateTime dateTime)
        {
            return dateTime.ToString("dd MMM yyyy HH:mm");
        }

        public static string GetTimeAgo(DateTime dateTime)
        {
            var timeSpan = DateTime.UtcNow - dateTime;

            if (timeSpan.TotalMinutes < 1)
                return "Just now";

            if (timeSpan.TotalMinutes < 60)
                return $"{(int)timeSpan.TotalMinutes} minutes ago";

            if (timeSpan.TotalHours < 24)
                return $"{(int)timeSpan.TotalHours} hours ago";

            if (timeSpan.TotalDays < 30)
                return $"{(int)timeSpan.TotalDays} days ago";

            if (timeSpan.TotalDays < 365)
                return $"{(int)(timeSpan.TotalDays / 30)} months ago";

            return $"{(int)(timeSpan.TotalDays / 365)} years ago";
        }

        public static bool IsWithinDateRange(DateTime date, DateTime? startDate, DateTime? endDate)
        {
            if (startDate.HasValue && date < startDate.Value)
                return false;

            if (endDate.HasValue && date > endDate.Value)
                return false;

            return true;
        }

        public static int GetQuarter(DateTime date)
        {
            return (date.Month - 1) / 3 + 1;
        }

        public static DateTime GetStartOfWeek(DateTime date, DayOfWeek startOfWeek = DayOfWeek.Monday)
        {
            int diff = (7 + (date.DayOfWeek - startOfWeek)) % 7;
            return date.AddDays(-1 * diff).Date;
        }

        public static DateTime GetEndOfWeek(DateTime date, DayOfWeek startOfWeek = DayOfWeek.Monday)
        {
            return GetStartOfWeek(date, startOfWeek).AddDays(6);
        }

        public static bool IsExpiringSoon(DateTime expiryDate, int daysThreshold = 30)
        {
            return (expiryDate - DateTime.UtcNow).TotalDays <= daysThreshold;
        }
    }
}