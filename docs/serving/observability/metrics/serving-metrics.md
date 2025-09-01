---
audience: administrator
components:
  - serving
function: reference
---

# Knative Serving Metrics

Administrators can monitor Serving control plane based on the metrics exposed by each Serving component.

!!! note

    These metrics may chance as we have just switch Knative from OpenCensus 
    to OpenTelemetry

## Queue Proxy

The queue proxy is the per-pod sidecar that enforces container concurrency and provides metrics to the autoscaler. The following metrics provide you insights into queued
requests and user-container behavior.

###  `kn.queueproxy.depth`

**Instrument Type:** Int64Gauge

**Unit (UCUM):** {item}

**Description:** Number of current items in the queue proxy queue

### `kn.queueproxy.app.duration`

**Instrument Type:** Float64Histogram

**Unit (UCUM):** s

**Description:** The duration of the task execution

## Activator

The following metrics can help you to understand how an application responds when traffic passes through the activator. For example, when scaling from zero, high request latency might mean that requests are taking too much time to be fulfilled.


### `kn.revision.request.concurrency`

**Instrument Type:** Float64Gauge

**Unit (UCUM):** {request}

**Description:** Concurrent requests that are routed to the Activator

The following attributes are included with the metrics below

Name | Type | Description
-|-|-
`k8s.namespace.name` | string | Namespace of the Revision
`kn.service.name` | string | Knative Service name associated with this Revision
`kn.configuration.name` | string | Knative Configuration name associated with this Revision
`kn.revision.name` | string | The name of the Revision

## Autoscaler

Autoscaler component exposes a number of metrics related to its decisions per revision. For example, at any given time, you can monitor the desired pods the Autoscaler wants to allocate for a Service, the average number of requests per second during the stable window, or whether autoscaler is in panic mode (KPA).

### `kn.autoscaler.scrape.duration`

**Instrument Type:** Float64Histogram

**Unit (UCUM):** s

**Description:** The duration of scraping the revision

### `kn.revision.pods.desired`

**Instrument Type:** Int64Gauge

**Unit (UCUM):** {item}

**Description:** Number of pods the autoscaler wants to allocate

### `kn.revision.capacity.excess`

**Instrument Type:** Float64Gauge

**Unit (UCUM):** {concurrency}

**Description:** Excess burst capacity observed over the stable window

### `kn.revision.concurrency.stable`

**Instrument Type:** Float64Gauge

**Unit (UCUM):** {concurrency}

**Description:** Average of request count per observed pod over the stable window

### `kn.revision.concurrency.panic`

**Instrument Type:** Float64Gauge

**Unit (UCUM):** {concurrency}

**Description:** Average of request count per observed pod over the panic window

### `kn.revision.concurrency.target`

**Instrument Type:** Float64Gauge

**Unit (UCUM):** {concurrency}

**Description:** The desired concurrent requests for each pod

### `kn.revision.rps.stable`

**Instrument Type:** Float64Gauge

**Unit (UCUM):** {request}/s

**Description:** Average of requests-per-second per observed pod over the stable window

### `kn.revision.rps.panic`

**Instrument Type:** Float64Gauge

**Unit (UCUM):** {request}/s

**Description:** Average of requests-per-second per observed pod over the panic window


### `kn.revision.pods.requested`

**Instrument Type:** Int64Gauge

**Unit (UCUM):** {pod}

**Description:** Number of pods autoscaler requested from Kubernetes

### `kn.revision.pods.count`

**Instrument Type:** Int64Gauge

**Unit (UCUM):** {pod}

**Description:** Number of pods that are allocated currently

### `kn.revision.pods.not_ready.count`

**Instrument Type:** Int64Gauge

**Unit (UCUM):** {pod}

**Description:** Number of pods that are not ready currently

### `kn.revision.pods.pending.count`

**Instrument Type:** Int64Gauge

**Unit (UCUM):** {pod}

**Description:** Number of pods that are pending currently

### `kn.revision.pods.terminating.count`

**Instrument Type:** Int64Gauge

**Unit (UCUM):** {pod}

**Description:** Number of pods that are terminating currently

--8<-- "observability-shared-metrics.md"
