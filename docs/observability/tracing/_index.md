---
title: "Tracing"
linkTitle: "Tracing"
weight: 10
type: "docs"
aliases:
  - /docs/serving/accessing-traces
---

After you have installed Knative Serving, you can access request traces if you have a request tracing tool installed on your cluster.
For example:
- [Zipkin visualization tool](#using-zipkin)
- [Jaeger visualization tool](#using-jaeger)
<!--TODO: List of tools that work / can be used, links to docs for them?-->

You can update the configuration file for tracing in [config-tracing.yaml](https://github.com/knative/serving/blob/master/config/core/configmaps/tracing.yaml).
This file includes options such as sample rate, debug mode, and backend selection.

You can quickly explore and update the ConfigMap object by using the following command:

```shell
kubectl -n knative-serving edit configmap config-tracing
```

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
