# Accessing request traces

Depending on the request tracing tool that you have installed on your Knative
Serving cluster, see the corresponding section for details about how to
visualize and trace your requests.

## Configuring Traces

You can update the configuration file for tracing in [tracing.yaml](https://github.com/knative/serving/blob/main/config/core/configmaps/tracing.yaml).

Follow the instructions in the file to set your configuration options. This file includes options such as sample rate (to determine what percentage of requests to trace), debug mode, and backend selection (zipkin or none).

You can quickly explore and update the ConfigMap object with the following command:
```bash
kubectl -n knative-serving edit configmap config-tracing
```

## Zipkin

In order to access request traces, you use the Zipkin visualization tool.

1.  To open the Zipkin UI, enter the following command:

    ```bash
    kubectl proxy
    ```

    This command starts a local proxy of Zipkin on port 8001. For security
    reasons, the Zipkin UI is exposed only within the cluster.

1. Access the Zipkin UI at the following URL:

    ```
    http://localhost:8001/api/v1/namespaces/<namespace>/services/zipkin:9411/proxy/zipkin/
    ```
    Where `<namespace>` is the namespace where Zipkin is deployed, for example, `knative-serving`.
1.  Click "Find Traces" to see the latest traces. You can search for a trace ID
    or look at traces of a specific application. Click on a trace to see a
    detailed view of a specific call.

<!--TODO: Consider adding a video here. -->

## Jaeger

In order to access request traces, you use the Jaeger visualization tool.

1.  To open the Jaeger UI, enter the following command:

    ```bash
    kubectl proxy
    ```

    This command starts a local proxy of Jaeger on port 8001. For security
    reasons, the Jaeger UI is exposed only within the cluster.

1.  Access the Jaeger UI at the following URL:

    ```
    http://localhost:8001/api/v1/namespaces/<namespace>/services/jaeger-query:16686/proxy/search/
    ```
    Where `<namespace>` is the namespace where Jaeger is deployed, for example, `knative-serving`.

1.  Select the service of interest and click "Find Traces" to see the latest
    traces. Click on a trace to see a detailed view of a specific call.

<!--TODO: Consider adding a video here. -->
