---
audience: administrator
components:
  - serving
function: how-to
---

# Accessing request traces

Traces give us the big picture of what happens when a request is made to an application. 
Knative Serving is instrumented with [OpenTelemetry](https://opentelemetry.io/docs/what-is-opentelemetry/) which can emit traces to a multitude of different backends.

## Backends

### Jaeger V2

Following [these instructions](https://github.com/jaegertracing/jaeger-operator?tab=readme-ov-file#jaeger-v2-operator) to setup Jaeger V2 on Kubernetes and access your traces.

## Configuring Serving Tracing

You can update the configuration for tracing in using the [`config-observability` ConfigMap](https://github.com/knative/serving/blob/main/config/core/configmaps/observability.yaml).

**Example:**

The following example `config-observability` ConfigMap samples 10% of all requests:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-observability
  namespace: knative-serving
data:
  tracing-protocol: "grpc"
  tracing-endpoint: "http://jaeger-collector.observability:4318/v1/traces"
  tracing-sampling-rate: "0.1"
```

### Configuration options

You can configure your `config-observability` with following options:

 * `tracing-protocol`: Valid values are `grpc` or `http/protobuf`. The default is `none`.

 * `tracing-endpoint`: Specifies the URL to the backend where you want to send the traces.
   Must be set if backend is set to `grpc` or `http/protobuf`.

 * `tracing-sampling-rate`: Specifies the sampling rate. Valid values are decimals from `0` to `1`
   (interpreted as a float64), which indicate the probability that any given request is sampled.
   An example value is `0.5`, which gives each request a 50% sampling probablity.

### Viewing your `config-observability` ConfigMap

To view your current configuration:

```bash
kubectl -n knative-eventing get configmap config-observability -oyaml
```

### Editing and deploying your `config-observability` ConfigMap

To edit and then immediately deploy changes to your ConfigMap, run the following command:

```bash
kubectl -n knative-eventing edit configmap config-observability
```
