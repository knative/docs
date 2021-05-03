---
title: "Metrics API"
weight: 99
type: "docs"
---

## Developer - User Services

Every Knative service has a proxy container that proxies the connections to the application container.
A number of metrics are reported for the queue peroxy performance. Using the following metrics application
developers, devops and others, could measure if requests are queued at the proxy side (need for backpressure) and what is the actual delay in serving requests at the application side.

### Queue proxy

Requests endpoint

| Metric Name | Description | Type | Tags | Unit | Status |
|:-|:-|:-|:-|:-|:-|
| revision_request_count | The number of requests that are routed to queue-proxy | Counter | configuration_name<br>container_name<br>namespace_name<br>pod_name<br>response_code<br>response_code_class<br>revision_name<br>service_name | Dimensionless | Stable |
| revision_request_latencies | The response time in millisecond | Histogram | configuration_name<br>container_name<br>namespace_name<br>pod_name<br>response_code<br>response_code_class<br>revision_name<br>service_name |  Milliseconds | Stable |
| revision_app_request_count | The number of requests that are routed to user-container | Counter | configuration_name<br>container_name<br>namespace_name<br>pod_name<br>response_code<br>response_code_class<br>revision_name<br>service_name | Dimensionless | Stable |
| revision_app_request_latencies | The response time in millisecond |  Histogram | configuration_name<br>namespace_name<br>pod_name<br>response_code<br>response_code_class<br>revision_name<br>service_name | Milliseconds | Stable |
| revision_queue_depth | The current number of items in the serving and waiting queue, or not reported if unlimited concurrency | Gauge | configuration_name<br>event-display<br>container_name<br>namespace_name<br>pod_name<br>response_code_class<br>revision_name<br>service_name | Dimensionless | Stable |
