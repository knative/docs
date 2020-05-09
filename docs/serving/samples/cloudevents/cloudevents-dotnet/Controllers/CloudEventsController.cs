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
    [Route("api/events")]
    public class CloudEventsController : ControllerBase
    {
        private readonly ILogger<CloudEventsController> logger;

        public CloudEventsController(ILogger<CloudEventsController> logger)
        {
            this.logger = logger;
        }

        /// <summary>
        /// Responds to the post request with a CloudEvent containing SampleOutput as the data.
        /// </summary>
        [HttpPost]
        public IActionResult Post([FromBody] CloudEvent receivedEvent)
        {
            this.logger?.LogInformation($"Received event {JsonSerializer.Serialize(receivedEvent)}");
            try
            {
                var content = GetResponseForEvent(receivedEvent);
                this.HttpContext.Response.RegisterForDispose(content);
                return new CloudEventActionResult(HttpStatusCode.OK, content);
            }
            catch (Exception ex)
            {
                return this.Problem($"Failed to process CloudEvent: {ex.Message}");
            }
        }

        /// <summary>
        /// Sends a CloudEvent to the endpoint specified K_SINK environment variable and responds back with its result.
        /// </summary>
        [HttpPost, Route("sink")]
        public async Task<IActionResult> Sink([FromBody] CloudEvent receivedEvent)
        {
            this.logger?.LogInformation($"Received event {JsonSerializer.Serialize(receivedEvent)}");
            try
            {
                var sinkUrl = Environment.GetEnvironmentVariable("K_SINK");
                if (string.IsNullOrEmpty(sinkUrl))
                {
                    return this.Problem("K_SINK is not set");
                }

                using var content = GetResponseForEvent(receivedEvent);
                using var client = new HttpClient();
                using var result = await client.PostAsync(sinkUrl, content);
                return this.StatusCode((int)result.StatusCode, await result.Content.ReadAsStringAsync());
            }
            catch (Exception ex)
            {
                return this.Problem($"Failed to process CloudEvent: {ex.Message}");
            }
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
                new CloudEvent(Constants.ResponseType, new Uri(Constants.ResponseUri))
                {
                    DataContentType = new ContentType(MediaTypeNames.Application.Json),
                    Data = JsonSerializer.Serialize(new SampleOutput {Message = $"Hello, {input.Name}"}),
                },
                ContentMode.Structured,
                new JsonEventFormatter()
            );
            return content;
        }
    }
}
