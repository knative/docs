using System;

namespace CloudEventsSample.Controllers
{
    public class Configuration
    {
        private static readonly Lazy<Configuration> Lazy =
            new Lazy<Configuration>(() => new Configuration());

        public static Configuration Instance => Lazy.Value;

        public string K_SINK { get; private set; }

        private Configuration()
        {
            this.K_SINK = Environment.GetEnvironmentVariable("K_SINK");
        }
    }
}
