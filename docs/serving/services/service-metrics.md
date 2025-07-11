---
audience: developer
components:
  - serving
function: reference
---

# Service metrics

Every Knative Service has a proxy container that proxies the connections to the application container. A number of metrics are reported for the queue proxy performance.

Using the following metrics, you can measure if requests are queued at the proxy side (need for backpressure) and what is the actual delay in serving requests at the application side.

## Queue proxy metrics

Requests endpoint.

| Metric Name | Description | Type | Tags | Unit | Status |
|:-|:-|:-|:-|:-|:-|
| ```revision_request_count``` | The number of requests that are routed to queue-proxy | Counter | ```configuration_name```<br>```container_name```<br>```namespace_name```<br>```pod_name```<br>```response_code```<br>```response_code_class```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```revision_request_latencies``` | The response time in millisecond | Histogram | ```configuration_name```<br>```container_name```<br>```namespace_name```<br>```pod_name```<br>```response_code```<br>```response_code_class```<br>```revision_name```<br>```service_name``` |  Milliseconds | Stable |
| ```revision_app_request_count``` | The number of requests that are routed to user-container | Counter | ```configuration_name```<br>```container_name```<br>```namespace_name```<br>```pod_name```<br>```response_code```<br>```response_code_class```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```revision_app_request_latencies``` | The response time in millisecond |  Histogram | ```configuration_name```<br>```namespace_name```<br>```pod_name```<br>```response_code```<br>```response_code_class```<br>```revision_name```<br>```service_name``` | Milliseconds | Stable |
| ```revision_queue_depth``` | The current number of items in the serving and waiting queue, or not reported if unlimited concurrency | Gauge | ```configuration_name```<br>```event-display```<br>```container_name```<br>```namespace_name```<br>```pod_name```<br>```response_code_class```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |

!!! note
    The `revision_queue_depth` metric will be exported only if the revision concurrency hard limit is set to a value greater than 1.

## Exposing Queue proxy metrics

Queue proxy exports metrics for the requests endpoint on port 9091. The metrics can be scraped by Prometheus when `metrics.request-metrics-backend-destination` is set to `prometheus` (default) in the configmap `observability`. The backend can be changed to `opencensus` which uses a push model and requires a destination
address which can be set in the same configmap via `metrics.opencensus-address`. User can control the reporting period for both backends with
`metrics.request-metrics-reporting-period-seconds`. If `metrics.request-metrics-reporting-period-seconds` is not set at all then the reporting period depends on the value of the global reporting period, `metrics.reporting-period-seconds`, that affects both control and data planes. If both properties are not available then the reporting period defaults to 5s for the Prometheus backend and 60s for the Opencensus one.

Here is a sample configuration for the observability configmap in order to connect to the [OpenTelemetry collector](../observability/metrics/collecting-metrics.md#understanding-the-collector):

```
metrics.request-metrics-backend-destination: "opencensus"
metrics.opencensus-address: "otel-collector.metrics:55678"
metrics.request-metrics-reporting-period-seconds: "1"
```

!!! note
    The reporting period is to 1s so that we can push metrics as soon as possible but this could be overwhelming for the targeted metrics backend.
    Setting a value of zero or a negative value defaults to 10s (does not mean no delay) which is the default reporting period defined by the Opencensus metrics client library. The latter is used by Knative Serving for exporting metrics.
