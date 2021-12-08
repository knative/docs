/*
Copyright 2020 The Knative Authors
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    https://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

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
