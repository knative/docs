# Configuring Request Log Settings

The request logging for knative serving is managed through the `config-observability` ConfigMap in `knative-serving` namespace. The request logs will be printed by the queue-proxy sidecar.

Mentioned below are the flags used to configure request logging and other obervability features.


| ConfigMap key                     | Description                                                                                                                                                      |
| :-------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `logging.enable-var-log-collection`               |  The fluentd daemon set will be set up to collect /var/log if this flag is true. This field defaults to false.                                                                       |
| `logging.revision-url-template`         | This field provides a template to use for producing the logging URL that is injected into the status of each Revision.                                                               |
| `logging.request-log-template`      | The value determines the shape of the request logs and it must be a valid go text/template. It is important to keep this as a single line. Multiple lines are parsed as separate entities by most collection agents and will split the request logs into multiple records.                                                                                                   |
| `logging.enable-request-log` | If true, the request logging will be enabled. |
| `logging.enable-probe-request-log`            | If true, this enables queue proxy writing request logs for probe requests to stdout. It uses the same template for user requests, i.e. logging.request-log-template.  |
| `metrics.backend-destination` | This field specifies the system metrics destination. It supports either prometheus (the default) or opencensus. |
| `metrics.request-metrics-backend-destination` | This field specifies the request metrics destination. It enables queue proxy to send request metrics. Currently supported values: prometheus (the default), opencensus. |
| `profiling.enable` | This field indicates whether it is allowed to retrieve runtime profiling data from the pods via an HTTP server in the format expected by the pprof visualization tool. When enabled, the Knative Serving pods expose the profiling data on an alternate HTTP port 8008. The HTTP context root for profiling is then /debug/pprof/. |




