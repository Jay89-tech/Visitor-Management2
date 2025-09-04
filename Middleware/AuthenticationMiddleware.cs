// Middleware/AuthenticationMiddleware.cs
using System.Security.Claims;
using SkillsAuditSystem.Services.Interfaces;

namespace SkillsAuditSystem.Middleware
{
    public class AuthenticationMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<AuthenticationMiddleware> _logger;

        public AuthenticationMiddleware(RequestDelegate next, ILogger<AuthenticationMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context, IAuthService authService, IUserService userService)
        {
            try
            {
                var token = GetTokenFromRequest(context);

                if (!string.IsNullOrEmpty(token))
                {
                    var isValid = await authService.ValidateTokenAsync(token);

                    if (isValid)
                    {
                        var userId = await authService.GetUserIdFromTokenAsync(token);

                        if (!string.IsNullOrEmpty(userId))
                        {
                            var user = await userService.GetUserByIdAsync(userId);

                            if (user != null && user.IsActive)
                            {
                                var claims = new List<Claim>
                                {
                                    new(ClaimTypes.NameIdentifier, user.Id),
                                    new(ClaimTypes.Email, user.Email),
                                    new(ClaimTypes.Name, user.FullName),
                                    new(ClaimTypes.Role, user.Role),
                                    new("EmployeeId", user.EmployeeId),
                                    new("Department", user.Department)
                                };

                                var identity = new ClaimsIdentity(claims, "Firebase");
                                context.User = new ClaimsPrincipal(identity);

                                // Set session data
                                context.Session.SetString("UserId", user.Id);
                                context.Session.SetString("UserRole", user.Role);
                                context.Session.SetString("UserEmail", user.Email);
                                context.Session.SetString("UserFullName", user.FullName);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in authentication middleware");
            }

            await _next(context);
        }

        private string? GetTokenFromRequest(HttpContext context)
        {
            // Try Authorization header first
            var authHeader = context.Request.Headers["Authorization"].FirstOrDefault();
            if (!string.IsNullOrEmpty(authHeader) && authHeader.StartsWith("Bearer "))
            {
                return authHeader["Bearer ".Length..];
            }

            // Try cookie
            return context.Request.Cookies["auth_token"];
        }
    }
}