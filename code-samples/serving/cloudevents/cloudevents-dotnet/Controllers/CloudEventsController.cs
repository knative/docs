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
using System.Text.Json;
using System.Threading.Tasks;
using CloudEventsSample.Models;
using CloudNative.CloudEvents;
using CloudNative.CloudEvents.AspNetCore;
using CloudNative.CloudEvents.Http;
using CloudNative.CloudEvents.SystemTextJson;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace CloudEventsSample.Controllers
{
    [ApiController]
    [Route("")]
    public class CloudEventsController : ControllerBase
    {
        private const string CloudEventResponseType = "dev.knative.docs.sample";
        private const string CloudEventResponseUri =
            "https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-dotnet";

        private readonly string sinkUri;
        private readonly IHttpClientFactory clients;
        private readonly ILogger<CloudEventsController> logger;

        public CloudEventsController(ILogger<CloudEventsController> logger,
            IHttpClientFactory clients, IConfiguration configuration)
        {
            this.logger = logger;
            this.clients = clients;
            this.sinkUri = configuration["K_SINK"];
        }

        [HttpPost]
        public async Task<IActionResult> Post()
        {
            CloudEvent receivedEvent;
            SampleInput input;
            try
            {
                receivedEvent = await this.ReadEvent();
                if (receivedEvent.Data is not JsonElement data || data.ValueKind != JsonValueKind.Object)
                {
                    return this.BadRequest("Event data must be a JSON object containing a name.");
                }
                input = data.Deserialize<SampleInput>();
                if (input == null || string.IsNullOrWhiteSpace(input.Name))
                {
                    return this.BadRequest("Event data must contain a nonempty name.");
                }
            }
            catch (Exception ex) when (IsInvalidEvent(ex))
            {
                return this.BadRequest("Expected a valid CloudEvent with JSON data.");
            }

            // Log attributes rather than serializing SDK implementation details.
            this.logger.LogInformation("Received event {Id} of type {Type}", receivedEvent.Id, receivedEvent.Type);
            var response = GetResponseForInput(input);
            return string.IsNullOrEmpty(this.sinkUri)
                ? this.ReceiveAndReply(response)
                : await this.ReceiveAndSend(response);
        }

        private IActionResult ReceiveAndReply(CloudEvent response)
        {
            return new CloudEventActionResult(HttpStatusCode.OK, response);
        }

        private async Task<IActionResult> ReceiveAndSend(CloudEvent response)
        {
            try
            {
                using var content = response.ToHttpContent(ContentMode.Structured, new JsonEventFormatter());
                using var result = await this.clients.CreateClient("sink").PostAsync(this.sinkUri, content);
                return this.StatusCode((int)result.StatusCode, await result.Content.ReadAsStringAsync());
            }
            catch (HttpRequestException ex)
            {
                this.logger.LogWarning(ex, "Failed to send event to K_SINK");
                return this.StatusCode(502, "Failed to send event to K_SINK.");
            }
            catch (TaskCanceledException)
            {
                return this.StatusCode(504, "K_SINK request timed out.");
            }
        }

        // Echo the original event using the SDK formatter, not its internal object representation.
        [HttpPost("echo")]
        public async Task<IActionResult> Echo()
        {
            try
            {
                return new CloudEventActionResult(HttpStatusCode.OK, await this.ReadEvent());
            }
            catch (Exception ex) when (IsInvalidEvent(ex))
            {
                return this.BadRequest("Expected a valid CloudEvent with JSON data.");
            }
        }

        private async Task<CloudEvent> ReadEvent()
        {
            var receivedEvent = await this.Request.ToCloudEventAsync(new JsonEventFormatter());
            receivedEvent.Validate();
            return receivedEvent;
        }

        private static bool IsInvalidEvent(Exception ex) =>
            ex is JsonException or ArgumentException or InvalidOperationException or FormatException;

        private static CloudEvent GetResponseForInput(SampleInput input) => new CloudEvent
        {
            Id = Guid.NewGuid().ToString(),
            Time = DateTimeOffset.UtcNow,
            Type = CloudEventResponseType,
            Source = new Uri(CloudEventResponseUri),
            DataContentType = "application/json",
            Data = new SampleOutput { Message = $"Hello, {input.Name}" }
        };
    }
}
