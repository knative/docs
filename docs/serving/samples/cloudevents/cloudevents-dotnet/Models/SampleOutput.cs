using System.Text.Json.Serialization;

namespace CloudEventsSample.Models
{
    public class SampleOutput
    {
        /// <summary>
        /// Cloud Events SDK for .NET unfortunately still uses Newtonsoft.Json and is not up to date with .Net Core 3.
        /// We need to provide Newtonsoft.Json.JsonProperty attribute to ensure that CloudEvent.Data is serialized
        /// the way we want it to.
        /// JsonPropertyName is to ensure that deserialization through System.Text.Json.Serialization is done correctly.
        /// </summary>
        [JsonPropertyName("message")]
        [Newtonsoft.Json.JsonProperty("message")]
        public string Message { get; set; }
    }
}
