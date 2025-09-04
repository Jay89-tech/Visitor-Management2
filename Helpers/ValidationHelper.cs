// Helpers/ValidationHelper.cs
using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;

namespace SkillsAuditSystem.Helpers
{
    public static class ValidationHelper
    {
        public static bool IsValidEmail(string email)
        {
            if (string.IsNullOrEmpty(email))
                return false;

            return new EmailAddressAttribute().IsValid(email);
        }

        public static bool IsValidEmployeeId(string employeeId)
        {
            if (string.IsNullOrEmpty(employeeId))
                return false;

            // Employee ID format: EMP followed by 4-6 digits
            var pattern = @"^EMP\d{4,6}$";
            return Regex.IsMatch(employeeId, pattern, RegexOptions.IgnoreCase);
        }

        public static bool IsValidPhoneNumber(string phoneNumber)
        {
            if (string.IsNullOrEmpty(phoneNumber))
                return true; // Phone number is optional

            // South African phone number pattern
            var pattern = @"^(\+27|0)[1-9]\d{8}$";
            return Regex.IsMatch(phoneNumber, pattern);
        }

        public static bool IsPasswordStrong(string password)
        {
            if (string.IsNullOrEmpty(password) || password.Length < 8)
                return false;

            // At least one uppercase, one lowercase, one digit, one special character
            var hasUpper = password.Any(char.IsUpper);
            var hasLower = password.Any(char.IsLower);
            var hasDigit = password.Any(char.IsDigit);
            var hasSpecial = password.Any(c => !char.IsLetterOrDigit(c));

            return hasUpper && hasLower && hasDigit && hasSpecial;
        }

        public static string ValidateSkillLevel(string level)
        {
            var validLevels = new[] { "Beginner", "Intermediate", "Advanced", "Expert" };
            return validLevels.Contains(level) ? string.Empty : "Invalid skill level";
        }

        public static string ValidateTrainingStatus(string status)
        {
            var validStatuses = new[] { "Planned", "In Progress", "Completed", "Cancelled" };
            return validStatuses.Contains(status) ? string.Empty : "Invalid training status";
        }

        public static string ValidateDepartment(string department)
        {
            var validDepartments = new[]
            {
                "National Treasury", "Finance", "Human Resources",
                "Information Technology", "Operations", "Legal", "Audit"
            };
            return validDepartments.Contains(department) ? string.Empty : "Invalid department";
        }

        public static bool IsValidFileExtension(string fileName, string[] allowedExtensions)
        {
            if (string.IsNullOrEmpty(fileName))
                return false;

            var extension = Path.GetExtension(fileName).ToLowerInvariant();
            return allowedExtensions.Contains(extension);
        }

        public static bool IsFileSizeValid(long fileSizeInBytes, int maxSizeInMB)
        {
            var maxSizeInBytes = maxSizeInMB * 1024 * 1024;
            return fileSizeInBytes <= maxSizeInBytes;
        }
    }
}