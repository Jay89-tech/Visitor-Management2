// Attributes/AjaxOnlyAttribute.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace SkillsAuditSystem.Attributes
{
    public class AjaxOnlyAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext context)
        {
            var request = context.HttpContext.Request;

            if (!request.Headers.ContainsKey("X-Requested-With") ||
                request.Headers["X-Requested-With"] != "XMLHttpRequest")
            {
                context.Result = new BadRequestObjectResult(new { error = "This action only accepts AJAX requests." });
            }

            base.OnActionExecuting(context);
        }
    }
}