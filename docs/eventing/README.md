# Knative Eventing

Knative Eventing is a collection of APIs that enable you to use an [event-driven architecture](https://en.wikipedia.org/wiki/Event-driven_architecture) with your applications.

You can use these APIs to create components that route events from event producers to event consumers, or _sinks_, that receive events. Sinks can also be configured to respond to HTTP requests by sending a response event.

Knative Eventing uses standard HTTP POST requests to send and receive events between event producers and sinks. These events conform to the [CloudEvents specifications](https://cloudevents.io/), which enables creating, parsing, sending, and receiving events in any programming language.

In a Knative Eventing deployment, event [Sources](../eventing/sources/README.md) are the primary event producers. Examples of [sinks](../eventing/sinks/README.md) include [Brokers](../eventing/broker/README.md), [Channels](../eventing/channels/README.md), and [Services](../serving/services/README.md).

## Common use cases

Knative Eventing components are loosely coupled, and can be developed and deployed independently of each other. Any producer can generate events before there are active event consumers that are listening for those events. Any event consumer can express interest in a class of events before there are producers that are creating those events.

Examples of supported Knative Eventing use cases:

- Publish an event without creating a consumer. You can send events to a broker as an HTTP POST, and use binding to decouple the destination configuration from your application that produces events.

- Consume an event without creating a publisher. You can use a trigger to consume events from a broker based on event attributes. The application receives events as an HTTP POST.

!!! tip
    Multiple event producers and sinks can be used together to create more advanced [Knative Eventing flows](flows/README.md) to solve complex use cases.

## Eventing examples

:material-file-document: [Creating and responding to Kubernetes API events](../eventing/sources/apiserversource/README.md){target=blank}

--8<-- "YouTube_icon.svg"
[Creating an image processing pipeline](https://www.youtube.com/watch?v=DrmOpjAunlQ){target=blank}

--8<-- "YouTube_icon.svg"
[Facilitating AI workloads at the edge in large-scale, drone-powered sustainable agriculture projects](https://www.youtube.com/watch?v=lVfJ5WEQ5_s){target=blank}

## Next steps

- You can install Knative Eventing by using the methods listed on the [installation page](../install/README.md).
