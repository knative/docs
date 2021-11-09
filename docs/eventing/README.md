# Knative Eventing

Knative Eventing provides tools for routing events from event producers to sinks, enabling developers to use an [event-driven architecture](https://en.wikipedia.org/wiki/Event-driven_architecture) with their applications.

Knative Eventing resources are loosely coupled, and can be developed and deployed independently of each other. Any producer can generate events before there are active event consumers that are listening. Any event consumer can express interest in an event or class of events, before there are producers that are creating those events.

Knative Eventing uses standard HTTP POST requests to send and receive events between event producers and sinks. These events conform to the [CloudEvents specifications](https://cloudevents.io/), which enables creating, parsing, sending, and receiving events in any programming language.

Other services can be connected to the Knative Eventing system. These services can perform the following functions:

- Create new applications without modifying the event producer or event   consumer.
- Select and target specific subsets of the events from their producers.

## Common use cases

Knative Eventing supports the following use cases:

Publish an event without creating a consumer
:   You can send events to a broker as an HTTP POST, and use binding to decouple the destination configuration from your application that produces events.

Consume an event without creating a publisher
:   You can use a trigger to consume events from a broker based on event attributes. The application receives events as an HTTP POST.

!!! tip
    Multiple event producers and sinks can be used together to create more advanced [Knative Eventing flows](flows/README.md) to solve complex use cases.

<!--TODO: What about channels?-->

## Eventing components

An event-driven architecture is based on the concept of decoupled relationships between event producers that create events, and event consumers, or [_sinks_](../eventing/sinks/README.md), that receive events. It builds on  delivery over HTTP by providing configuration and management of pluggable event-routing components.

A sink or _subscriber_ can also be configured to respond to HTTP requests by sending a response event. Examples of sinks in a Knative Eventing deployment include Knative Services, Channels and Brokers.

### Event sources

In a Knative Eventing deployment, event [Sources](../eventing/sources/README.md) are the primary event producers. Events are sent to a sink or _subscriber_.

### Broker and Trigger

[Brokers](../eventing/broker/README.md) and [Triggers](../eventing/broker/triggers/README.md) provide an "event mesh" model, which allows an event producer to deliver events to a Broker, which then distributes them uniformly to consumers by using Triggers.

This delivers the following benefits:

- Consumers can register for specific types of events without needing to
  negotiate directly with event producers.
- Event routing can be optimized by the underlying platform using the specified
  filter conditions.

### Channel and Subscription

[Channels](../eventing/channels/README.md) and [Subscriptions](../eventing/channels/subscriptions.md) provide a "event pipe" model which transforms and routes events between Channels using Subscriptions.

This model is appropriate for event pipelines where events from one system need to be transformed and then routed to another process.

### Event registry

Knative Eventing defines an EventType object to make it easier for consumers to
discover the types of events they can consume from Brokers.

The registry consists of a collection of event types. The event types stored in
the registry contain (all) the required information for a consumer to create a
Trigger without resorting to some other out-of-band mechanism.

To learn how to use the registry, see the [Event Registry documentation](event-registry.md).
