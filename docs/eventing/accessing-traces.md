# Accessing CloudEvent traces

Depending on the request tracing tool that you have installed on your Knative
Eventing cluster, see the corresponding section for details about how to
visualize and trace your requests.

## Before you begin

You must have a Knative cluster running with the Eventing component installed. [Learn more](../install/README.md).

## Configuring tracing

With the exception of importers, the Knative Eventing tracing is configured through the
`config-tracing` ConfigMap in the `knative-eventing` namespace.

Most importers do _not_ use the ConfigMap and instead, use a static 1% sampling rate.

You can use the `config-tracing` ConfigMap to configure the following Eventing components:

 - Brokers
 - Triggers
 - InMemoryChannel
 - ApiServerSource
 - PingSource
 - GitlabSource
 - KafkaSource
 - PrometheusSource

**Example:**

The following example `config-tracing` ConfigMap samples 10% of all CloudEvents:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-tracing
  namespace: knative-eventing
data:
  backend: "zipkin"
  zipkin-endpoint: "http://zipkin.istio-system.svc.cluster.local:9411/api/v2/spans"
  sample-rate: "0.1"
```

### Configuration options

You can configure your `config-tracing` with following options:

 * `backend`: Valid values are `zipkin` or `none`. The default is `none`.

 * `zipkin-endpoint`: Specifies the URL to the zipkin collector where you want to send the traces.
   Must be set if backend is set to `zipkin`.

 * `sample-rate`: Specifies the sampling rate. Valid values are decimals from `0` to `1`
   (interpreted as a float64), which indicate the probability that any given request is sampled.
   An example value is `0.5`, which gives each request a 50% sampling probablity.

 * `debug`: Enables debugging. Valid values are `true` or `false`. Defaults to `false` when not specified.
   Set to `true` to enable debug mode, which forces the `sample-rate` to `1.0` and sends all spans to
   the server.

### Viewing your `config-tracing` ConfigMap

To view your current configuration:

```bash
kubectl -n knative-eventing get configmap config-tracing -oyaml
```

### Editing and deploying your `config-tracing` ConfigMap

To edit and then immediately deploy changes to your ConfigMap, run the following command:

```bash
kubectl -n knative-eventing edit configmap config-tracing
```

## Accessing traces in Eventing

To access the traces, you use either the Zipkin or Jaeger tool. Details about using these tools to access traces are provided in the Knative Serving observability section:

 - [Zipkin](../serving/accessing-traces.md#zipkin)
 - [Jaeger](../serving/accessing-traces.md#jaeger)

### Example

The following demonstrates how to trace requests in Knative Eventing with Zipkin, using the [`TestBrokerTracing`](https://github.com/knative/eventing/blob/main/test/conformance/broker_tracing_test.go) End-to-End test.

For this example, assume the following details:

- Everything happens in the `includes-incoming-trace-id-2qszn` namespace.
- The Broker is named `br`.
- There are two Triggers that are associated with the Broker:
    - `transformer` - Filters to only allow events whose type is `transformer`.
      Sends the event to the Kubernetes Service `transformer`, which will reply with an
      identical event, except the replied event's type will be `logger`.
    - `logger` - Filters to only allow events whose type is `logger`. Sends the event to
      the Kubernetes Service `logger`.
- An event is sent to the Broker with the type `transformer`, by the Pod named `sender`.

Given this scenario, the expected path and behavior of an event is as follows:

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

![Annotated Trace](images/AnnotatedTrace.png)

This is the same screenshot without the annotations.

![Raw Trace](images/RawTrace.png)

If you are interested, here is the [raw JSON](data/2e571e6948ff981283825bb2bf51c87d.json) of the trace.
