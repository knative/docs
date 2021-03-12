---
title: "Knative Eventing"
linkTitle: "Eventing Component"
weight: 60
type: "docs"
aliases:
    - /eventing/README
---

Knative Eventing is a system that is designed to address a common need for cloud
native development and provides composable primitives to enable late-binding
event sources and event consumers.

## Getting Started

- [Install Knative](../install)
- [Run samples](./samples/)
- [Default Channels](./channels/default-channels) provide a way to choose the
  persistence strategy for Channels across the cluster.

## Functionality

Knative Eventing supports multiple modes of usage. The following scenarios are
well-supported by the existing components; since the system is modular, it's
also possible to combine the components in novel ways.

1. **I just want to publish events, I don't care who consumes them.** Send
   events to a [broker](./broker) as an HTTP POST. [Sink binding](./sources/sinkbinding) can be useful to decouple the destination
   configuration from your application.

1. **I just want to consume events like X, I don't care how they are
   published.** Use a [trigger](./triggers) to consume events from a Broker based
   on CloudEvents attributes. Your application will receive the events as an
   HTTP POST.

1. **I want to transform events through a series of steps.** Use [channels and
   subscriptions](./channels) to define complex message-passing topologies. For
   simple pipelines, the [Sequence](./flows/sequence) automates construction of
   channels and subscriptions between each stage.

Knative also supports some additional patterns such as
[Parallel](./flows/parallel) fanout of events, and routing response events from
both Channels and Brokers.

## Design overview

Knative Eventing is designed around the following goals:

1. The Knative Eventing resources are loosely coupled. These resources can be
   developed and deployed independently on, and across a variety of platforms
   (for example Kubernetes, VMs, SaaS or FaaS).
1. Event producers and event consumers are independent. Any producer (or
   source), can generate events before there are active event consumers that are
   listening. Any event consumer can express interest in an event or class of
   events, before there are producers that are creating those events.
1. Other services can be connected to the Eventing system. These services can
   perform the following functions:
   - Create new applications without modifying the event producer or event
     consumer.
   - Select and target specific subsets of the events from their producers.
1. Ensure cross-service interoperability. Knative Eventing is consistent with
   the
   [CloudEvents](https://github.com/cloudevents/spec/blob/master/spec.md#design-goals)
   specification that is developed by the
   [CNCF Serverless WG](https://lists.cncf.io/g/cncf-wg-serverless).

### Event consumers

To enable delivery to multiple types of Services, Knative Eventing defines two
generic interfaces that can be implemented by multiple Kubernetes resources:

1. **Addressable** objects are able to receive and acknowledge an event
   delivered over HTTP to an address defined in their `status.address.url`
   field. As a special case, the core
   [Kubernetes Service object](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#service-v1-core)
   also fulfils the Addressable interface.
1. **Callable** objects are able to receive an event delivered over HTTP and
   transform the event, returning 0 or 1 new events in the HTTP response. These
   returned events may be further processed in the same way that events from an
   external event source are processed.

### Event sources

To learn about using event sources, see the [event sources](./sources) documentation.

### Event brokers and triggers

Broker and Trigger objects make it easy to filter events based on event
attributes.

A Broker provides a bucket of events which can be selected by attribute. It
receives events and forwards them to subscribers defined by one or more matching
Triggers. Since a Broker implements Addressable, event senders can submit events
to the Broker by POSTing the event to the Broker's `status.address.url`.

A Trigger describes a filter on event attributes which should be delivered to an
Addressable. You can create as many Triggers as necessary.

For most use cases, a single bucket (Broker) per namespace is sufficient, but
there are serveral use cases where multiple buckets (Brokers) can simplify
architecture. For example, separate Brokers for events containing Personally
Identifiable Information (PII) and non-PII events can simplify audit and access
control rules.

![Broker Trigger Diagram](./images/broker-trigger-overview.svg)

### Event registry

Knative Eventing defines an EventType object to make it easier for consumers to
discover the types of events they can consume from Brokers.

The registry consists of a collection of event types. The event types stored in
the registry contain (all) the required information for a consumer to create a
Trigger without resorting to some other out-of-band mechanism.

To learn how to use the registry, see the
[Event Registry documentation](./event-registry).

### Event channels and subscriptions

Knative Eventing also defines an event forwarding and persistence layer, called
a [channel](./channels/).
Each channel is a separate Kubernetes [custom resource](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).
Events are delivered to services or forwarded to other channels
(possibly of a different type) using
[subscriptions](./channels/subscriptions).
This allows message delivery in a cluster to vary based on requirements, so that
some events might be handled by an in-memory implementation while others would
be persisted using Apache Kafka or NATS Streaming.

See the [List of Channel implementations](./channels/channels-crds).

### Higher Level eventing constructs

There are cases where you may want to utilize a set of co-operating functions
together and for those use cases, Knative Eventing provides two additional
resources:

1. **[Sequence](./flows/sequence)** provides a way to define an in-order list of functions.
1. **[Parallel](./flows/parallel)** provides a way to define a list of branches for events.
