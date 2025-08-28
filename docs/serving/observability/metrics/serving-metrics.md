---
audience: administrator
components:
  - serving
function: reference
---

# Knative Serving Metrics

Administrators can monitor Serving control plane based on the metrics exposed by each Serving component.
Metrics are listed next.

## Activator

The following metrics can help you to understand how an application responds when traffic passes through the activator. For example, when scaling from zero, high request latency might mean that requests are taking too much time to be fulfilled.

| Metric Name | Description | Type | Tags | Unit | Status |
|:-|:-|:-|:-|:-|:-|
| ```request_concurrency``` | Concurrent requests that are routed to Activator<br>These are requests reported by the concurrency reporter which may not be done yet.<br> This is the average concurrency over a reporting period | Gauge | ```configuration_name```<br>```container_name```<br>```namespace_name```<br>```pod_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```request_count``` | The number of requests that are routed to Activator.<br>These are requests that have been fulfilled from the activator handler. | Counter | ```configuration_name```<br>```container_name```<br>```namespace_name```<br>```pod_name```<br>```response_code```<br>```response_code_class```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```request_latencies``` | The response time in millisecond for the fulfilled routed requests | Histogram | ```configuration_name```<br>```container_name```<br>```namespace_name```<br>```pod_name```<br>```response_code```<br>```response_code_class```<br>```revision_name```<br>```service_name``` | Milliseconds | Stable |

## Autoscaler

Autoscaler component exposes a number of metrics related to its decisions per revision. For example, at any given time, you can monitor the desired pods the Autoscaler wants to allocate for a Service, the average number of requests per second during the stable window, or whether autoscaler is in panic mode (KPA).

| Metric Name | Description | Type | Tags | Unit | Status |
|:-|:-|:-|:-|:-|:-|
| ```desired_pods``` | Number of pods autoscaler wants to allocate | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```excess_burst_capacity``` | Excess burst capacity overserved over the stable window | Gauge |  ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```stable_request_concurrency``` | Average of requests count per observed pod over the stable window | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```panic_request_concurrency``` | Average of requests count per observed pod over the panic window | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```target_concurrency_per_pod``` | The desired number of concurrent requests for each pod | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```stable_requests_per_second``` | Average requests-per-second per observed pod over the stable window | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```panic_requests_per_second``` | Average requests-per-second per observed pod over the panic window | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```target_requests_per_second``` | The desired requests-per-second for each pod | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```panic_mode``` | 1 if autoscaler is in panic mode, 0 otherwise | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```requested_pods``` | Number of pods autoscaler requested from Kubernetes | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```actual_pods``` | Number of pods that are allocated currently in ready state | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` |  Dimensionless | Stable |
| ```not_ready_pods``` | Number of pods that are not ready currently | Gauge | ```configuration_name=```<br>```namespace_name=```<br>```revision_name```<br>```service_name``` |  Dimensionless | Stable |
| ```pending_pods``` | Number of pods that are pending currently | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name``` | Dimensionless | Stable |
| ```terminating_pods``` | Number of pods that are terminating currently | Gauge | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name<br>``` | Dimensionless | Stable |
| ```scrape_time``` | Time autoscaler takes to scrape metrics from the service pods in milliseconds | Histogram | ```configuration_name```<br>```namespace_name```<br>```revision_name```<br>```service_name```<br> | Milliseconds | Stable |

## Controller

The following metrics are emitted by any component that implements a controller logic.
The metrics show details about the reconciliation operations and the workqueue behavior on which
reconciliation requests are enqueued.

| Metric Name | Description | Type | Tags | Unit | Status |
|:-|:-|:-|:-|:-|:-|
| ```work_queue_depth``` | Depth of the work queue | Gauge | ```reconciler``` | Dimensionless | Stable |
| ```reconcile_count``` | Number of reconcile operations | Counter | ```reconciler```<br>```success```<br> | Dimensionless | Stable |
| ```reconcile_latency``` | Latency of reconcile operations | Histogram | ```reconciler```<br>```success```<br> | Milliseconds | Stable |
| ```workqueue_adds_total``` | Total number of adds handled by workqueue | Counter | ```name``` | Dimensionless | Stable |
| ```workqueue_depth``` | Current depth of workqueue | Gauge | ```reconciler``` | Dimensionless | Stable |
| ```workqueue_queue_latency_seconds``` | How long in seconds an item stays in workqueue before being requested | Histogram | ```name``` | Seconds | Stable |
| ```workqueue_retries_total``` | Total number of retries handled by workqueue | Counter | ```name``` | Dimensionless | Stable |
| ```workqueue_work_duration_seconds``` | How long in seconds processing an item from a workqueue takes. | Histogram | ```name``` | Seconds| Stable |
| ```workqueue_unfinished_work_seconds``` | How long in seconds the outstanding workqueue items have been in flight (total). | Histogram | ```name``` | Seconds | Stable |
| ```workqueue_longest_running_processor_seconds``` | How long in seconds the longest outstanding workqueue item has been in flight | Histogram | ```name``` | Seconds | Stable |

--8<-- "observability-shared-metrics.md"
