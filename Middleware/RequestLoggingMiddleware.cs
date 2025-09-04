// Middleware/RequestLoggingMiddleware.cs
using System.Diagnostics;

namespace SkillsAuditSystem.Middleware
{
    public class RequestLoggingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<RequestLoggingMiddleware> _logger;

        public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            var stopwatch = Stopwatch.StartNew();

            var requestId = Guid.NewGuid().ToString();
            context.Items["RequestId"] = requestId;

            // Log request
            _logger.LogInformation(
                "Request started: {RequestId} {Method} {Path} {QueryString}",
                requestId,
                context.Request.Method,
                context.Request.Path,
                context.Request.QueryString);

            try
            {
                await _next(context);
            }
            finally
            {
                stopwatch.Stop();

                // Log response
                _logger.LogInformation(
                    "Request completed: {RequestId} {StatusCode} in {ElapsedMilliseconds}ms",
                    requestId,
                    context.Response.StatusCode,
                    stopwatch.ElapsedMilliseconds);
            }
        }
    }
}