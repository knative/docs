
## Webhook Metrics

Webhook metrics report useful info about operations. For example, if a large number of operations fail, this could indicate an issue with a user-created resource.

### `http.server.request.duration`

Knative implements the [semantic conventions for HTTP Servers](https://opentelemetry.io/docs/specs/semconv/http/http-metrics/#http-server) using the OpenTelemetry [otel-go/otelhttp](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) package.

Please refer to the [OpenTelemetry docs](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) for details about the HTTP Server metrics it exports.

The following attributes are included with the metric

Name | Type | Description | Examples
-|-|-|-
`kn.webhook.type` | string | Specifies the type of webhook invoked | `admission`, `defaulting`, `validation`, `conversion` |
`kn.webhook.resource.group` | string | Specifies the resource Kubernetes group name |
`kn.webhook.resource.version` | string | Specifies the resource Kubernetes group version|
`kn.webhook.resource.kind` | string | Specifies the resource Kubernetes group kind |
`kn.webhook.subresource` | string | Specifies the subresource | "" (empty), `status`, `scale` |
`kn.webhook.operation.type` | string | Specifies the operation that invoked the webhook | `CREATE`, `UPDATE`, `DELETE` |
`kn.webhook.operation.status` | string | Specifies whether the operation was successful | `success`, `failed` |

### `kn.webhook.handler.duration`

**Instrument Type:** Histogram

**Unit ([[UCUM](https://ucum.org)):** s

**Description:** The duration of task execution.

The following attributes are included with the metric

Name | Type | Description | Examples
-|-|-|-
`kn.webhook.type` | string | Specifies the type of webhook invoked | `admission`, `defaulting`, `validation`, `conversion` |
`kn.webhook.resource.group` | string | Specifies the resource Kubernetes group name |
`kn.webhook.resource.version` | string | Specifies the resource Kubernetes group version|
`kn.webhook.resource.kind` | string | Specifies the resource Kubernetes group kind |
`kn.webhook.subresource` | string | Specifies the subresource | "" (empty), `status`, `scale` |
`kn.webhook.operation.type` | string | Specifies the operation that invoked the webhook | `CREATE`, `UPDATE`, `DELETE` |
`kn.webhook.operation.status` | string | Specifies whether the operation was successful | `success`, `failed` |

## Workqueue Metrics

Knative controllers expose [client-go workqueue metrics](https://pkg.go.dev/k8s.io/client-go/util/workqueue#MetricsProvider)

The following attributes are included with the metrics below

Name | Type | Description |
-|-|-
`name` | string | Name of the work queue

### `kn.workqueue.depth`

**Instrument Type:** Int64UpDownCounter

**Unit ([UCUM](https://ucum.org)):** {item}

**Description:** Number of current items in the queue

### `kn.workqueue.adds`

**Instrument Type:**  Int64Counter

**Unit ([UCUM](https://ucum.org)):**  {item}

**Description:**  Number of items added to the queue

### `kn.workqueue.queue.duration`

**Instrument Type:**

**Unit ([UCUM](https://ucum.org)):** s

**Description:** How long an item stays in workqueue

### `kn.workqueue.process.duration`

**Instrument Type:** Float64Histogram

**Unit ([UCUM](https://ucum.org)):** s

**Description:** How long in seconds processing an item from workqueue takes

### `kn.workqueue.unfinished_work`

**Instrument Type:** Float64Gauge

**Unit ([UCUM](https://ucum.org)):** s

**Description:** How many seconds of work the reconciler has done that is in progress and hasn't been observed by duration. Large values indicate stuck threads. One can deduce the number of stuck threads by observing the rate at which this increases.

### `kn.workqueue.longest_running_processor`

**Instrument Type:** Float64Gauge

**Unit ([UCUM](https://ucum.org)):** s

**Description:** How long the longest worker thread has been running

### `kn.workqueue.retries`

**Instrument Type:** Int64Counter

**Unit ([UCUM](https://ucum.org)):** {item}

**Description:** Number of items re-added to the queue


## Go Runtime

Knative implements the [semantic conventions for Go runtime metrics](https://opentelemetry.io/docs/specs/semconv/runtime/go-metrics/) using the OpenTelemetry [otel-go/instrumentation/runtime](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/runtime) package. 

Please refer to the [OpenTelemetry docs](https://opentelemetry.io/docs/specs/semconv/runtime/go-metrics/) for details about the go runtime metrics it exports.
