# Custom event sources

If you need to ingress events from an event producer that is not included in Knative, or from a producer that emits events which are not in the CloudEvent format that is used by Knative, you can do this by using one of the following methods:

- [Create a custom Knative event source](custom-event-source/README.md).
- Use a PodSpecable object as an event source, by creating a [SinkBinding](sinkbinding/README.md).
- Use a container as an event source, by creating a [ContainerSource](containersource/README.md).
