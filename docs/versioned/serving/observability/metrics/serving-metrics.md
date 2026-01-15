---
audience: administrator
components:
  - serving
function: reference
---

# Knative Serving Metrics

Administrators can monitor Serving control plane based on the metrics exposed by each Serving component.

!!! note

    These metrics may change as we flush out our migration from OpenCensus to OpenTelemetry

## Workload Metrics

Each workload pod has a sidecar that enforces container concurrency and provides metrics to the autoscaler. The following OTel metrics provide you insights into queued
requests and user-container behavior.

The following attributes are included with workload metrics

Name | Type | Description
-|-|-
`container.name` | string | Name of the container emit metrics. This is hardcoded to `queue-proxy`.
`k8s.namespace.name` | string | Namespace of the workload
`k8s.pod.name` | string | Name of the workload pod
`service.version` | string | Version of the sidecar emitting metrics
`service.name` | string | Either the name of the Knative Service, Configuration or Revision.
`service.instance.id` | string | Identifier of the instance which is the same as the `k8s.pod.name`
`kn.service.name` | string | Knative Service name associated with this Revision
`kn.configuration.name` | string | Knative Configuration name associated with this Revision
`kn.revision.name` | string | The name of the Revision

###  `kn.serving.queue.depth`

**Instrument Type:** Int64Gauge

**Unit ([UCUM](https://ucum.org)):** {request}

**Description:** Number of current items in the queue proxy queue

### `kn.serving.invocation.duration`

**Instrument Type:** Float64Histogram

**Unit ([UCUM](https://ucum.org)):** s

**Description:** The duration of the task execution

The following attributes are included with the metric

Name | Type | Description
-|-|-
`http.response.status_code` | int | Status code of the duration

### HTTP metrics

Since the sidecar receives and forwards requests to the user container it has both HTTP server and client metrics.

#### HTTP Server Metrics

Knative implements the [semantic conventions for HTTP Servers](https://opentelemetry.io/docs/specs/semconv/http/http-metrics/#http-server) using the OpenTelemetry [otel-go/otelhttp](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) package.

Please refer to the [OpenTelemetry docs](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) for details about the HTTP Server metrics it exports.

#### HTTP Client Metrics

Knative implements the [semantic conventions for HTTP Clients](https://opentelemetry.io/docs/specs/semconv/http/http-metrics/#http-client) using the OpenTelemetry [otel-go/otelhttp](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) package.

Please refer to the [OpenTelemetry docs](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) for details about the HTTP Client metrics it exports.

## Activator

The following metrics can help you to understand how an application responds when traffic passes through the activator. For example, when scaling from zero, high request latency might mean that requests are taking too much time to be fulfilled.


### `kn.revision.request.concurrency`

**Instrument Type:** Float64Gauge

**Unit ([UCUM](https://ucum.org)):** {request}

**Description:** Concurrent requests that are routed to the Activator

The following attributes are included with the metric

Name | Type | Description
-|-|-
`k8s.namespace.name` | string | Namespace of the resource
`kn.service.name` | string | Knative Service name associated with this Revision
`kn.configuration.name` | string | Knative Configuration name associated with this Revision
`kn.revision.name` | string | The name of the Revision

### `kn.activator.stats.conn.reachable`

**Instrument Type:** Int64Gauge

**Unit ([UCUM](https://ucum.org)):** {reachable}

**Description:** Whether a peer is reachable from the activator (1 = reachable, 0 = not reachable)

The following attributes are included with the metric

Name | Type | Description
-|-|-
`peer` | string | The peer service the activator is connecting to (e.g., `autoscaler`)

This metric helps operators identify connectivity issues between the activator and its peer components. The metric is recorded:

- When a connection is established (value = 1)
- When a connection is lost (value = 0)

### `kn.activator.connection_errors`

**Instrument Type:** Int64Counter

**Unit ([UCUM](https://ucum.org)):** {error}

**Description:** Number of connection errors from the activator

The following attributes are included with the metric

Name | Type | Description
-|-|-
`peer` | string | The peer service the activator is connecting to (e.g., `autoscaler`)

This counter increments each time the activator fails to communicate with a peer. It complements the `kn.activator.reachable` gauge by providing a cumulative count of errors, which is useful for:

- Detecting flaky connections that might be missed by point-in-time gauge sampling
- Creating rate-based alerts (e.g., alert if error rate exceeds threshold over 5 minutes)
- Tracking connection stability trends over time

### HTTP metrics

Since the activator receives and forwards requests to the user workload it has both HTTP server and client metrics.

#### HTTP Server Metrics

Knative implements the [semantic conventions for HTTP Servers](https://opentelemetry.io/docs/specs/semconv/http/http-metrics/#http-server) using the OpenTelemetry [otel-go/otelhttp](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) package.

Please refer to the [OpenTelemetry docs](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) for details about the HTTP Server metrics it exports.

The following attributes are included in the server metrics

Name | Type | Description
-|-|-
`kn.service.name` | string | Knative Service name associated with this Revision
`kn.configuration.name` | string | Knative Configuration name associated with this Revision
`kn.revision.name` | string | The name of the Revision
`k8s.namespace.name` | string | Namespace of the resource

#### HTTP Client Metrics

Knative implements the [semantic conventions for HTTP Clients](https://opentelemetry.io/docs/specs/semconv/http/http-metrics/#http-client) using the OpenTelemetry [otel-go/otelhttp](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) package.

Please refer to the [OpenTelemetry docs](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) for details about the HTTP Client metrics it exports.

## Autoscaler

Autoscaler component exposes a number of metrics related to its decisions per revision. For example, at any given time, you can monitor the desired pods the Autoscaler wants to allocate for a Service, the average number of requests per second during the stable window, or whether autoscaler is in panic mode (KPA).

The following attributes are included with the autoscaling metrics below

Name | Type | Description
-|-|-
`k8s.namespace.name` | string | Namespace of the Revision
`kn.service.name` | string | Knative Service name associated with this Revision
`kn.configuration.name` | string | Knative Configuration name associated with this Revision
`kn.revision.name` | string | The name of the Revision


### `kn.autoscaler.scrape.duration`

**Instrument Type:** Float64Histogram

**Unit ([UCUM](https://ucum.org)):** s

**Description:** The duration of scraping the revision

### `kn.revision.pods.desired`

**Instrument Type:** Int64Gauge

**Unit ([UCUM](https://ucum.org)):** {pod}

**Description:** Number of pods the autoscaler wants to allocate

### `kn.revision.capacity.excess`

**Instrument Type:** Float64Gauge

**Unit ([UCUM](https://ucum.org)):** {concurrency}

**Description:** Excess burst capacity observed over the stable window

### `kn.revision.concurrency.stable`

**Instrument Type:** Float64Gauge

**Unit ([UCUM](https://ucum.org)):** {concurrency}

**Description:** Average of request count per observed pod over the stable window

### `kn.revision.concurrency.panic`

**Instrument Type:** Float64Gauge

**Unit ([UCUM](https://ucum.org)):** {concurrency}

**Description:** Average of request count per observed pod over the panic window

### `kn.revision.concurrency.target`

**Instrument Type:** Float64Gauge

**Unit ([UCUM](https://ucum.org)):** {concurrency}

**Description:** The desired concurrent requests for each pod

### `kn.revision.rps.stable`

**Instrument Type:** Float64Gauge

**Unit ([UCUM](https://ucum.org)):** {request}/s

**Description:** Average of requests-per-second per observed pod over the stable window

### `kn.revision.rps.panic`

**Instrument Type:** Float64Gauge

**Unit ([UCUM](https://ucum.org)):** {request}/s

**Description:** Average of requests-per-second per observed pod over the panic window

### `kn.revision.pods.requested`

**Instrument Type:** Int64Gauge

**Unit ([UCUM](https://ucum.org)):** {pod}

**Description:** Number of pods autoscaler requested from Kubernetes

### `kn.revision.pods.count`

**Instrument Type:** Int64Gauge

**Unit ([UCUM](https://ucum.org)):** {pod}

**Description:** Number of pods that are allocated currently

### `kn.revision.pods.not_ready.count`

**Instrument Type:** Int64Gauge

**Unit ([UCUM](https://ucum.org)):** {pod}

**Description:** Number of pods that are not ready currently

### `kn.revision.pods.pending.count`

**Instrument Type:** Int64Gauge

**Unit ([UCUM](https://ucum.org)):** {pod}

**Description:** Number of pods that are pending currently

### `kn.revision.pods.terminating.count`

**Instrument Type:** Int64Gauge

**Unit ([UCUM](https://ucum.org)):** {pod}

**Description:** Number of pods that are terminating currently

--8<-- "observability-shared-metrics.md"
