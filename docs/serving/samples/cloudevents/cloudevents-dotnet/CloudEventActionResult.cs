using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using CloudNative.CloudEvents;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;

namespace CloudEventsSample
{
    /// <summary>
    /// CloudEvents SDK doesn't provide any helpers to respond back with IActionResult.
    /// This helper class wraps CloudEventContent in IActionResult.
    /// </summary>
    public class CloudEventActionResult : IActionResult
    {
        private readonly HttpStatusCode statusCode;
        private readonly CloudEventContent content;

        public CloudEventActionResult(HttpStatusCode statusCode, CloudEventContent content)
        {
            this.statusCode = statusCode;
            this.content = content;
        }

        public async Task ExecuteResultAsync(ActionContext context)
        {
            context.HttpContext.Response.StatusCode = (int)this.statusCode;
            foreach (var header in this.content.Headers)
            {
                context.HttpContext.Response.Headers.TryAdd(header.Key, new StringValues(header.Value.ToArray()));
            }

            await using var stream = await this.content.ReadAsStreamAsync();
            await stream.CopyToAsync(context.HttpContext.Response.Body);
            await context.HttpContext.Response.Body.FlushAsync();
        }
    }
}
