<!-- Snippet used in the following topics:
- /docs/eventing/README.md
- /docs/concepts/README.md
-->
Knative Eventing is a collection of APIs that enable you to use an [event-driven architecture](https://en.wikipedia.org/wiki/Event-driven_architecture){target=_blank} with your applications. You can use these APIs to create components that route events from event producers (known as sources) to event consumers (known as sinks) that receive events. Sinks can also be configured to respond to HTTP requests by sending a response event.

``` mermaid
architecture-beta
    group eventing[Eventing]
    group sources[Event Sources]

    service source(cloud)[Event Source] in sources
    service broker(database)[Broker] in eventing
    service trigger(server)[Trigger] in eventing
    service sink(internet)[Event Target]

    source{group}:T --> B:broker
    broker:R -- L:trigger
    trigger:B --> T:sink
```

Knative Eventing is a standalone platform that provides support for various types of workloads, including standard Kubernetes Services and Knative Serving Services.

Knative Eventing uses standard HTTP POST requests to send and receive events between event producers and sinks. These events conform to the [CloudEvents specifications](https://cloudevents.io/){target=_blank}, which enables creating, parsing, sending, and receiving events in any programming language.

Knative Eventing components are loosely coupled, and can be developed and deployed independently of each other. Any producer can generate events before there are active event consumers that are listening for those events. Any event consumer can express interest in a class of events before there are producers that are creating those events.
