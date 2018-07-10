### Accessing request traces
If logging and monitoring components are not installed yet, go through the 
[installation instructions](./installing-logging-metrics-traces.md) to setup the 
necessary components first.

To open the Zipkin UI (the visualization tool for request traces), enter the following command:

```shell
kubectl proxy
```

This starts a local proxy of Zipkin on port 8001. The Zipkin UI is only exposed within
the cluster for security reasons.

Navigate to the [Zipkin UI](http://localhost:8001/api/v1/namespaces/istio-system/services/zipkin:9411/proxy/zipkin/).
Click on "Find Traces" to see the latest traces. You can search for a trace ID
or look at traces of a specific application. Click on a trace to see a detailed
view of a specific call.

<!--TODO: Consider adding a video here. -->
