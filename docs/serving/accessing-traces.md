---
title: "Accessing request traces"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 15
---

If you have not yet installed the logging and monitoring components, go through
the [installation instructions](../installing-logging-metrics-traces/) to set
up the necessary components.

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

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
