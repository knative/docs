using System.Text.Json.Serialization;

namespace CloudEventsSample.Models
{
    public class SampleInput
    {
        [JsonPropertyName("name")]
        public string Name { get; set; }

        public override string ToString()
        {
            return $"Name: {this.Name}";
        }
    }
}
