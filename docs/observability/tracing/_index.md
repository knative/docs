---
title: "Tracing"
linkTitle: "Tracing"
weight: 10
type: "docs"
aliases:
  - /docs/serving/accessing-traces
  - /docs/eventing/accessing-traces
showlandingtoc: "false"
---

After you have installed Knative Serving or Eventing, you can access request traces if you have a request tracing tool installed on your cluster.

For example:
- [Zipkin visualization tool](#using-zipkin)
- [Jaeger visualization tool](#using-jaeger)

## Configuring tracing

You can configure tracing for Serving or Eventing components by modifying the `config-tracing` ConfigMap in the namespace for the component.

### Configuring tracing for Eventing components

With the exception of importers, Knative Eventing tracing is configured through the
`config-tracing` ConfigMap in the `knative-eventing` namespace.
See the [example ConfigMap](https://github.com/knative/eventing/blob/master/config/core/configmaps/tracing.yaml).

**NOTE:** Most importers do not use the ConfigMap, and instead use a static 1% sampling rate.

You can use the `config-tracing` ConfigMap to configure tracing for the following Eventing components:
 - Brokers
 - Triggers
 - InMemoryChannel
 - ApiServerSource
 - GitlabSource
 - KafkaSource
 - PrometheusSource

To view your current configuration:

```shell
kubectl -n knative-eventing get configmap config-tracing -oyaml
```

You can quickly explore and update the ConfigMap object by using the following command:

```shell
kubectl -n knative-eventing edit configmap config-tracing
```

### Configuring tracing for Serving components

Knative Serving tracing is configured through the `config-tracing` ConfigMap in the `knative-serving` namespace. See the [example ConfigMap](https://github.com/knative/serving/blob/master/config/core/configmaps/tracing.yaml).

This file includes options such as sample rate, debug mode, and backend selection.

To view your current configuration:

```shell
kubectl -n knative-serving get configmap config-tracing -oyaml
```

You can quickly explore and update the ConfigMap object by using the following command:

```shell
kubectl -n knative-serving edit configmap config-tracing
```

### Configuration options

You can configure your `config-tracing` with following options:

 * `backend`: Valid values are `zipkin`, `stackdriver`, or `none`. The default is `none`.

 * `zipkin-endpoint`: Specifies the URL to the zipkin collector where you want to send the traces.
   Must be set if backend is set to `zipkin`.

 * `stackdriver-project-id`: Specifies the GCP project ID into which the Stackdriver traces are written.
   You must specify the `backend` as `stackdriver`. If `backend`is unspecified, the GCP project ID is read
   from GCP metadata when running on GCP.

 * `sample-rate`: Specifies the sampling rate. Valid values are decimals from `0` to `1`
   (interpreted as a float64), which indicate the probability that any given request is sampled.
   An example value is `0.5`, which gives each request a 50% sampling probablity.

 * `debug`: Enables debugging. Valid values are `true` or `false`. Defaults to `false` when not specified.
   Set to `true` to enable debug mode, which forces the `sample-rate` to `1.0` and sends all spans to
   the server.

## Using Zipkin

You can use the Zipkin visualization tool to access request traces.

1.  Open the Zipkin UI:

    ```shell
    kubectl proxy
    ```

    This command starts a local proxy of Zipkin on port 8001. For security
    reasons, the Zipkin UI is exposed only within the cluster.
1.  Navigate to the
    [Zipkin UI](http://localhost:8001/api/v1/namespaces/istio-system/services/zipkin:9411/proxy/zipkin/).
1.  Click **Find Traces** to see the latest traces. You can search for a trace ID
    or look at traces of a specific application. Click on a trace to see a
    detailed view of a specific call.

### Knative Eventing with Zipkin example

You can trace requests in Knative Eventing with Zipkin, using the
[`TestBrokerTracing`](https://github.com/knative/eventing/blob/master/test/conformance/broker_tracing_test.go)
end-to-end test.

For this example, assume the following details:
- Everything happens in the `includes-incoming-trace-id-2qszn` namespace.
- The broker is named `br`.
- There are two triggers that are associated with the broker:
    - `transformer` - Filters to only allow events whose type is `transformer`.
      Sends the event to the Kubernetes service `transformer`, which will reply with an
      identical event, except the replied event's type will be `logger`.
    - `logger` - Filters to only allow events whose type is `logger`. Sends the event to
      the Kubernetes service `logger`.
- An event is sent to the broker with the type `transformer`, by the pod named `sender`.

Given the above, the expected path and behavior of an event is as follows:

1. `sender` pod sends the request to the broker.
1. Go to the ingress pod of the broker.
1. Go to the `imc-dispatcher` channel (InMemoryChannel).
1. Go to both triggers.
    1. Go to the broker filter pod for the `logger` trigger. The filter of the trigger ignores this event.
    1. Go to the broker filter pod for the `transformer` trigger. The filter does pass, so it goes to the Kubernetes service pointed at, also named `transformer`.
        1. `transformer` pod replies with the modified event.
        1. Go to an InMemoryChannel dispatcher.
        1. Go to the ingress pod of the broker.
        1. Go to the InMemoryChannel dispatcher.
        1. Go to both triggers.
            1. Go to the broker filter pod for the `transformer` trigger. The filter of the trigger ignores the event.
            1. Go to the broker filter pod for the `logger` trigger. The filter passes.
                1. Go to the `logger` pod. There is no reply.

This is a screenshot of the trace view in Zipkin. All the red letters have been added to the screenshot and correspond to the expectations earlier in this section:

![Annotated Trace](/docs/eventing/images/AnnotatedTrace.png)

This is the same screenshot without the annotations.

![Raw Trace](/docs/eventing/images/RawTrace.png)

If you are interested, here is the [raw JSON](/docs/eventing/data/ee46c4c6be1df717b3b82f55b531912f.json) of the trace.

## Using Jaeger

You can use the Jaeger visualization tool to access request traces.

1.  To open the Jaeger UI, enter the following command:

    ```shell
    kubectl proxy
    ```

    This command starts a local proxy of Jaeger on port 8001. For security
    reasons, the Jaeger UI is exposed only within the cluster.
1.  Navigate to the
    [Jaeger UI](http://localhost:8001/api/v1/namespaces/istio-system/services/jaeger-query:16686/proxy/search/).
1.  Select the service of interest and click **Find Traces** to see the latest
    traces. Click on a trace to see a detailed view of a specific call.
