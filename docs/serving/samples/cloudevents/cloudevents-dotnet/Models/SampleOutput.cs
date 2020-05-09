using System.Text.Json.Serialization;

namespace CloudEventsSample.Models
{
    public class SampleOutput
    {
        [JsonPropertyName("message")]
        public string Message { get; set; }

        public override string ToString()
        {
            return $"Message: {this.Message}";
        }
    }
}
