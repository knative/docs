# Knative Serving metrics

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

## Webhook

Webhook metrics report useful info about operations. For example, if a large number of operations fail, this could indicate an issue with a user-created resource.

| Metric Name | Description | Type | Tags | Unit | Status |
|:-|:-|:-|:-|:-|:-|
| ```request_count``` | The number of requests that are routed to webhook | Counter |  ```admission_allowed```<br>```kind_group```<br>```kind_kind```<br>```kind_version```<br>```request_operation```<br>```resource_group```<br>```resource_namespace```<br>```resource_resource```<br>```resource_version``` | Dimensionless | Stable |
| ```request_latencies``` | The response time in milliseconds | Histogram |  ```admission_allowed```<br>```kind_group```<br>```kind_kind```<br>```kind_version```<br>```request_operation```<br>```resource_group```<br>```resource_namespace```<br>```resource_resource```<br>```resource_version``` | Milliseconds | Stable |

## Go Runtime - memstats

Each Knative Serving control plane process emits a number of Go runtime [memory statistics](https://golang.org/pkg/runtime/#MemStats) (shown next).
As a baseline for monitoring purposes, user could start with a subset of the metrics: current allocations (go_alloc), total allocations (go_total_alloc), system memory (go_sys), mallocs (go_mallocs), frees (go_frees) and garbage collection total pause time (total_gc_pause_ns), next gc target heap size (go_next_gc) and number of garbage collection cycles (num_gc).

| Metric Name | Description | Type | Tags | Unit | Status |
|:-|:-|:-|:-|:-|:-|
| ```go_alloc``` | The number of bytes of allocated heap objects (same as heap_alloc) | Gauge | ```name``` | Dimensionless | Stable |
| ```go_total_alloc``` | The cumulative bytes allocated for heap objects | Gauge | ```name``` | Dimensionless | Stable |
| ```go_sys``` | The total bytes of memory obtained from the OS | Gauge | ```name``` | Dimensionless | Stable |
| ```go_lookups``` | The number of pointer lookups performed by the runtime | Gauge | ```name``` | Dimensionless | Stable |
| ```go_mallocs``` | The cumulative count of heap objects allocated | Gauge | ```name``` | Dimensionless | Stable |
| ```go_frees``` | The cumulative count of heap objects freed | Gauge | ```name``` | Dimensionless | Stable |
| ```go_heap_alloc``` | The number of bytes of allocated heap objects | Gauge | ```name``` | Dimensionless | Stable |
| ```go_heap_sys``` | The number of bytes of heap memory obtained from the OS | Gauge | ```name``` | Dimensionless | Stable |
| ```go_heap_idle``` | The number of bytes in idle (unused) spans | Gauge | ```name``` | Dimensionless | Stable |
| ```go_heap_in_use``` | The number of bytes in in-use spans | Gauge | ```name``` | Dimensionless | Stable |
| ```go_heap_released``` | The number of bytes of physical memory returned to the OS | Gauge | ```name``` | Dimensionless | Stable |
| ```go_heap_objects``` | The number of allocated heap objects | Gauge | ```name``` | Dimensionless | Stable |
| ```go_stack_in_use``` | The number of bytes in stack spans | Gauge | ```name``` | Dimensionless | Stable |
| ```go_stack_sys``` | The number of bytes of stack memory obtained from the OS | Gauge | ```name``` | Dimensionless | Stable |
| ```go_mspan_in_use``` | The number of bytes of allocated mspan structures | Gauge | ```name``` | Dimensionless | Stable |
| ```go_mspan_sys``` | The number of bytes of memory obtained from the OS for mspan structures | Gauge | ```name``` | Dimensionless | Stable |
| ```go_mcache_in_use``` | The number of bytes of allocated mcache structures | Gauge | ```name``` | Dimensionless | Stable |
| ```go_mcache_sys``` | The number of bytes of memory obtained from the OS for mcache structures | Gauge | ```name``` | Dimensionless | Stable |
| ```go_bucket_hash_sys``` | The number of bytes of memory in profiling bucket hash tables. | Gauge | ```name``` | Dimensionless | Stable |
| ```go_gc_sys``` | The number of bytes of memory in garbage collection metadata | Gauge | ```name``` | Dimensionless | Stable |
| ```go_other_sys``` | The number of bytes of memory in miscellaneous off-heap runtime allocations | Gauge | ```name``` | Dimensionless | Stable |
| ```go_next_gc``` | The target heap size of the next GC cycle | Gauge | ```name``` | Dimensionless | Stable |
| ```go_last_gc``` | The time the last garbage collection finished, as nanoseconds since 1970 (the UNIX epoch) | Gauge | ```name``` | Nanoseconds | Stable |
| ```go_total_gc_pause_ns``` | The cumulative nanoseconds in GC stop-the-world pauses since the program started | Gauge | ```name``` | Nanoseconds | Stable |
| ```go_num_gc``` | The number of completed GC cycles. | Gauge | ```name``` | Dimensionless | Stable |
| ```go_num_forced_gc``` | The number of GC cycles that were forced by the application calling the GC function. | Gauge | ```name``` | Dimensionless | Stable |
| ```go_gc_cpu_fraction``` | The fraction of this program's available CPU time used by the GC since the program started | Gauge | ```name``` | Dimensionless | Stable |

!!! note
    The name tag is empty.
