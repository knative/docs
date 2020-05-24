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

using System;
using System.Net;
using System.Net.Http;
using System.Net.Mime;
using System.Text.Json;
using System.Threading.Tasks;
using CloudEventsSample.Models;
using Microsoft.AspNetCore.Mvc;
using CloudNative.CloudEvents;
using Microsoft.Extensions.Logging;

namespace CloudEventsSample.Controllers
{
    [ApiController]
    [Route("")]
    public class CloudEventsController : ControllerBase
    {
        private const string CloudEventResponseType = "dev.knative.docs.sample";
        private const string CloudEventResponseUri =
            "https://github.com/knative/docs/docs/serving/samples/cloudevents/cloudevents-dotnet";

        private static readonly Lazy<string> SinkUri =
            new Lazy<string>(() => Environment.GetEnvironmentVariable("K_SINK"));

        private readonly ILogger<CloudEventsController> logger;

        public CloudEventsController(ILogger<CloudEventsController> logger)
        {
            this.logger = logger;
        }

        /// <summary>
        /// Responds to the post request by calling ReceiveAndReply if K_SINK is not set,
        /// or by calling ReceiveAndSend if K_SINK is set.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> Post([FromBody] CloudEvent receivedEvent)
        {
            try
            {
                if (string.IsNullOrEmpty(SinkUri.Value))
                {
                    return this.ReceiveAndReply(receivedEvent);
                }
                else
                {
                    return await this.ReceiveAndSend(receivedEvent);
                }
            }
            catch (JsonException)
            {
                return this.BadRequest("Failed to read the JSON data.");
            }
        }

        /// <summary>
        /// This is called whenever an event is received if K_SINK environment variable is NOT set.
        /// Replies with a new event.
        /// </summary>
        private IActionResult ReceiveAndReply(CloudEvent receivedEvent)
        {
            this.logger?.LogInformation($"Received event {JsonSerializer.Serialize(receivedEvent)}");
            var content = GetResponseForEvent(receivedEvent);
            this.HttpContext.Response.RegisterForDispose(content);
            return new CloudEventActionResult(HttpStatusCode.OK, content);
        }

        /// <summary>
        /// This is called whenever an event is received if K_SINK environment variable is set.
        /// Sends a new event to the url in K_SINK.
        /// </summary>
        private async Task<IActionResult> ReceiveAndSend(CloudEvent receivedEvent)
        {
            this.logger?.LogInformation($"Received event {JsonSerializer.Serialize(receivedEvent)}");
            using var content = GetResponseForEvent(receivedEvent);
            using var client = new HttpClient();
            using var result = await client.PostAsync(SinkUri.Value, content);
            return this.StatusCode((int)result.StatusCode, await result.Content.ReadAsStringAsync());
        }

        /// <summary>
        /// Respond back with the JSON serialized request.
        /// </summary>
        [HttpPost, Route("echo")]
        public ActionResult Echo([FromBody] CloudEvent receivedEvent)
        {
            this.logger.LogInformation($"Echo: {JsonSerializer.Serialize(receivedEvent)}");
            return this.Ok(JsonSerializer.Serialize(receivedEvent));
        }

        private static CloudEventContent GetResponseForEvent(CloudEvent receivedEvent)
        {
            var input = JsonSerializer.Deserialize<SampleInput>(receivedEvent.Data.ToString());
            var content = new CloudEventContent
            (
                new CloudEvent(CloudEventResponseType, new Uri(CloudEventResponseUri))
                {
                    DataContentType = new ContentType(MediaTypeNames.Application.Json),
                    Data = new SampleOutput {Message = $"Hello, {input.Name}"},
                },
                ContentMode.Structured,
                new JsonEventFormatter()
            );
            return content;
        }
    }
}
