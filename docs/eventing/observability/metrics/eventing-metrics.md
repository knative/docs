# Knative Eventing metrics

Administrators can view metrics for Knative Eventing components.

## Broker - Ingress

Use the following metrics to debug how broker ingress performs and what events are dispatched via the ingress component.

By aggregating the metrics over the http code, events can be separated into two classes, successful (2xx) and failed events (5xx).

| Metric Name | Description | Type | Tags | Unit | Status |
|:-|:-|:-|:-|:-|:-|
| event_count | Number of events received by a Broker | Counter | broker_name<br>event_type<br>namespace_name<br>response_code<br>response_code_class<br>unique_name | Dimensionless | Stable
| event_dispatch_latencies | The time spent dispatching an event to a Channel | Histogram | broker_name<br>event_type<br>namespace_name<br>response_code<br>response_code_class<br>unique_name | Milliseconds | Stable

## Broker - Filter

Use the following metrics to debug how broker filter performs and what events are dispatched via the filter component.
Also user can measure the latency of the actual filtering action on an event.
By aggregating the metrics over the http code, events can be separated into two classes, successful (2xx) and failed events (5xx).

| Metric Name | Description | Type | Tags | Unit | Status |
|:-|:-|:-|:-|:-|:-|
| event_count | Number of events received by a Broker | Counter | broker_name<br>container_name=<br>filter_type<br>namespace_name<br>response_code<br>response_code_class<br>trigger_name<br>unique_name | Dimensionless | Stable
| event_dispatch_latencies | The time spent dispatching an event to a Channel | Histogram | broker_name<br>container_name<br>filter_type<br>namespace_name<br>response_code<br>response_code_class<br>trigger_name<br>unique_name | Milliseconds | Stable
| event_processing_latencies | The time spent processing an event before it is dispatched to a Trigger subscriber | Histogram | broker_name<br>container_name<br>filter_type<br>namespace_name<br>trigger_name<br>unique_name | Milliseconds | Stable

## In-memory Dispatcher

In-memory channel can be evaluated via the following metrics.
By aggregating the metrics over the http code, events can be separated into two classes, successful (2xx) and failed events (5xx).

| Metric Name | Description | Type | Tags | Unit | Status |
|:-|:-|:-|:-|:-|:-|
| event_count | Number of events dispatched by the in-memory channel | Counter | container_name<br>event_type=<br>namespace_name=<br>response_code<br>response_code_class<br>unique_name | Dimensionless | Stable
| event_dispatch_latencies | The time spent dispatching an event from a in-memory Channel | Histogram | container_name<br>event_type<br>namespace_name=<br>response_code<br>response_code_class<br>unique_name | Milliseconds | Stable

!!! note
    A number of metrics eg. controller, Go runtime and others are omitted here as they are common
    across most components. For more about these metrics check the
    [Serving metrics API section](../../../serving/observability/metrics/serving-metrics.md).

## Eventing sources

Eventing sources are created by users who own the related system, so they can trigger applications with events.
Every source exposes by default a number of metrics to help user monitor events dispatched. Use the following metrics
to verify that events have been delivered from the source side, thus verifying that the source and any connection with the source work as expected.

| Metric Name | Description | Type | Tags | Unit | Status |
|:-|:-|:-|:-|:-|:-|
| event_count | Number of events sent by the source | Counter | event_source<br>event_type<br>name<br>namespace_name<br>resource_group<br>response_code<br>response_code_class<br>response_error<br>response_timeout | Dimensionless  | Stable |
| retry_event_count | Number of events sent by the source in retries | Counter | event_source<br>event_type<br>name<br>namespace_name<br>resource_group<br>response_code<br>response_code_class<br>response_error<br>response_timeout | Dimensionless | Stable
