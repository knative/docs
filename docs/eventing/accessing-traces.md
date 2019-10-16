---
title: "Accessing CloudEvent Traces"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 15
type: "docs"
---

Depending on the request tracing tool that you have installed on your Knative
Eventing cluster, see the corresponding section for details about how to
visualize and trace your requests.

## Installation

Knative Eventing uses the same tracing plugin as Knative Serving. See the 
[Tracing installation instructions](./../serving/installing-logging-metrics-traces.md#end-to-end-request-tracing)
in the Knative Serving section for details. Note that you do not need to install the 
Knative Serving component itself. To enable request tracing in Knative Eventing 
you need to install only Elasticsearch and either the Zipkin or Jaeger plugins.

## Configuration

Most Knative Eventing tracing configuration is handled by the `config-tracing` ConfigMap in the `knative-eventing` namespace. This single ConfigMap controls tracing for:
 - Brokers
 - Triggers
 - InMemoryChannel

Here is an example ConfigMap that samples 10% of all CloudEvents.
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-tracing
  namespace: knative-eventing
data:
  enable: "true"
  zipkin-endpoint: "http://zipkin.istio-system.svc.cluster.local:9411/api/v2/spans"
  sample-rate: "0.1"
```

To see your current configuration:

```shell script
kubectl -n knative-eventing get configmap config-tracing -oyaml
```

Configuration options:

  * `backend`: Valid values are `zipkin`, `stackdriver`, or `none`. The default is `none`.

 * `zipkin-endpoint`: Specifies the URL to the zipkin collector where you want to send the traces. Must be set if backend is set to `zipkin`.

 * `stackdriver-project-id`: Specifies the GCP project into which stackdriver traces will be written. Only has an effect if `backend` is set to `stackdriver`. If unspecified, the project-id is read from GCP metadata when running on GCP.

 * `sample-rate`: Specifies the probability of sampling any given request. Valid values are decimals from `0` to `1` (interpreted as a float64).

 * `debug`: Valid values are `true` or `false`. If not specified, defaults to `false`. Set to `true` to enable debug mode, which bypasses `sample-rate` and sends all spans to the server.

Updating the ConfigMap will cause the new configuration to go live almost immediately:

```shell script
kubectl -n knative-eventing edit configmap config-tracing
```

### Importer Configuration

Most importers do _not_ use the configuration from the shared ConfigMap. Instead, they have a static, 1% sampling rate.


## Tools

To access the traces, you will use a tool such as Zipkin or Jaeger. Follow the Knative Serving [instructions](./../serving/accessing-traces.md) for accessing the traces:
 - [Zipkin](./../serving/accessing-traces.md#zipkin)
 - [Jaeger](./../serving/accessing-traces.md#jaeger)

### Example

> This example is the [`TestBrokerTracing`](https://github.com/knative/eventing/blob/master/test/conformance/broker_tracing_test.go) End-to-End test.

For this example, everything happens in the `includes-incoming-trace-id-2qszn` namespace.
- Broker named `br`
- Two Triggers associated with the Broker:
    - `transformer` - Filters to only allow events whose type is `transformer`. Sends the event to the Kubernetes Service `transformer`, which will reply with an identical event, except the replied event's type will be `logger`.
    - `logger` - Filters to only allow events whose type is `logger`. Sends the event to the Kubernetes Service `logger`.
- An event is sent to the Broker with the type `transformer`, by the Pod named `sender`.

So we expect the event to do the  following:

1. `sender` Pod sends the request to the Broker.
1. Go to the Broker's ingress Pod.
1. Go to the `imc-dispatcher` Channel (imc stands for InMemoryChannel).
1. Go to both Triggers.
    1. Go to the Broker's filter Pod for the Trigger `logger`. The Trigger's filter ignores this event.
    1. Go to the Broker's filter Pod for the Trigger `transformer`. The filter does pass, so it goes to the Kubernetes Service pointed at, also named `transformer`.
        1. `transformer` Pod replies with the modified event.
        1. Go to an InMemory dispatcher.
        1. Go to the Broker's ingress Pod.
        1. Go to the InMemory dispatcher.
        1. Go to both Triggers.
            1. Go to the Broker's filter Pod for the Trigger `transformer`. The Trigger's filter ignores the event.
            1. Go to the Broker's filter Pod for the Trigger `logger`. The filter passes.
                1. Go to the `logger` Pod. There is no reply.

This is a screenshot of the trace view in Zipkin. All the red letters have been added to the screenshot and correspond to the expectations earlier in this section:

![Annotated Trace](./images/AnnotatedTrace.png)

This is the same screenshot without the annotations.

![Raw Trace](./images/RawTrace.png)

If you are interested, here is the [raw JSON](./data/ee46c4c6be1df717b3b82f55b531912f.json) of the trace.
