---
title: "Accessing request traces"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 15
type: "docs"
---

Depending on the request tracing tool that you have installed on your Knative
Serving cluster, see the corresponding section for details about how to
visualize and trace your requests.

If you have not yet installed the logging and monitoring components, go through
the [installation instructions](./installing-logging-metrics-traces.md) to set
up the necessary components.

## Configuring Traces

You can update the configuration file for tracing in [config-tracing.yaml](https://github.com/knative/serving/blob/master/config/config-tracing.yaml).

Follow the instructions in the file to set your configuration options. This file includes options such as sample rate (to determine what percentage of requests to trace), debug mode, and backend selection (zipkin or stackdriver).

You can quickly explore and update the ConfigMap object with the following command:
```shell
kubectl -n knative-serving edit configmap config-tracing
```

## Zipkin

In order to access request traces, you use the Zipkin visualization tool.

1.  To open the Zipkin UI, enter the following command:

    ```shell
    kubectl proxy
    ```

    This command starts a local proxy of Zipkin on port 8001. For security
    reasons, the Zipkin UI is exposed only within the cluster.

1.  Navigate to the
    [Zipkin UI](http://localhost:8001/api/v1/namespaces/istio-system/services/zipkin:9411/proxy/zipkin/).

1.  Click "Find Traces" to see the latest traces. You can search for a trace ID
    or look at traces of a specific application. Click on a trace to see a
    detailed view of a specific call.

<!--TODO: Consider adding a video here. -->

## Jaeger

In order to access request traces, you use the Jaeger visualization tool.

1.  To open the Jaeger UI, enter the following command:

    ```shell
    kubectl proxy
    ```

    This command starts a local proxy of Jaeger on port 8001. For security
    reasons, the Jaeger UI is exposed only within the cluster.

1.  Navigate to the
    [Jaeger UI](http://localhost:8001/api/v1/namespaces/istio-system/services/jaeger-query:16686/proxy/search/).

1.  Select the service of interest and click "Find Traces" to see the latest
    traces. Click on a trace to see a detailed view of a specific call.

<!--TODO: Consider adding a video here. -->
