# Knative Eventing

Knative Eventing enables developers to use an [event-driven architecture](https://en.wikipedia.org/wiki/Event-driven_architecture) with serverless applications. An event-driven architecture is based on the concept of decoupled relationships between event producers that create events, and event consumers, or [_sinks_](../../developer/eventing/sinks), that receive events.

In a Knative Eventing deployment, event [Sources](../../eventing/sources) are the primary event producers, however you can also configure a sink or _subscriber_ to respond to HTTP requests by sending a response event. Examples of sinks in a Knative Eventing deployment include Knative Services, Channels and Brokers.
<!--TODO: Add response / reply event information, maybe diagrams-->

Knative Eventing uses standard HTTP POST requests to send and receive events between event producers and sinks. These events conform to the [CloudEvents specifications](https://cloudevents.io/), which enables creating, parsing, sending, and receiving events in any programming language.

## Common use cases

Knative Eventing supports the following use cases:

Publish an event without creating a consumer
:   You can send events to a broker as an HTTP POST, and use binding to decouple the destination configuration from your application that produces events.

Consume an event without creating a publisher
:   You can use a trigger to consume events from a broker based on event attributes. The application receives events as an HTTP POST.

!!! tip
    Multiple event producers and sinks can be used together to create more advanced [Knative Eventing flows](../../eventing/flows/) to solve complex use cases.

<!--TODO: What about channels?-->

## Design overview

Knative Eventing is designed around the following goals:

1. Knative Eventing resources are loosely coupled, and can be developed and deployed independently of each other.
1. Event producers and event consumers are independent. Any producer can generate events before there are active event consumers that are listening. Any event consumer can express interest in an event or class of events, before there are producers that are creating those events.
1. Knative Eventing is consistent with the [CloudEvents](https://github.com/cloudevents/spec/blob/master/spec.md#design-goals) specification that is developed by the [CNCF Serverless WG](https://lists.cncf.io/g/cncf-wg-serverless), which ensures cross-service interoperability.
1. Other services can be connected to the Knative Eventing system. These services can perform the following functions:
    - Create new applications without modifying the event producer or event   consumer.
    - Select and target specific subsets of the events from their producers.

### Event registry

Knative Eventing defines an EventType object to make it easier for consumers to
discover the types of events they can consume from Brokers.

The registry consists of a collection of event types. The event types stored in
the registry contain (all) the required information for a consumer to create a
Trigger without resorting to some other out-of-band mechanism.

To learn how to use the registry, see the
[Event Registry documentation](../../eventing/event-registry).
