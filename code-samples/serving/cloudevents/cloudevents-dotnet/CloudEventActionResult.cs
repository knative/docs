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

using System.Net;
using System.Threading.Tasks;
using CloudNative.CloudEvents;
using CloudNative.CloudEvents.AspNetCore;
using CloudNative.CloudEvents.SystemTextJson;
using Microsoft.AspNetCore.Mvc;

namespace CloudEventsSample
{
    public class CloudEventActionResult : IActionResult
    {
        private readonly HttpStatusCode statusCode;
        private readonly CloudEvent cloudEvent;

        public CloudEventActionResult(HttpStatusCode statusCode, CloudEvent cloudEvent)
        {
            this.statusCode = statusCode;
            this.cloudEvent = cloudEvent;
        }

        public async Task ExecuteResultAsync(ActionContext context)
        {
            context.HttpContext.Response.StatusCode = (int)this.statusCode;
            await this.cloudEvent.CopyToHttpResponseAsync(context.HttpContext.Response,
                ContentMode.Structured, new JsonEventFormatter());
        }
    }
}
