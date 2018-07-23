# Knative Events

Knative Events is a work-in-progress eventing system that is designed to
address a common need for cloud native development:

1. Services are loosely coupled during development and deployed independently
1. A producer can generate events before a consumer is listening, and a consumer
can express an interest in an event or class of events that is not yet being
produced.
1. Services can be connected to create new applications
    - without modifying producer or consumer.
    - with the ability to select a specific subset of events from a particular
    producer

The above concerns are consistent with the [design goals](https://github.com/cloudevents/spec/blob/master/spec.md#design-goals) of CloudEvents, a common specification for cross-service interoperability being developed by the CNCF Serverless WG.

## System design notes

We’re following an agile process, starting from a working prototype that
addresses a single use case and iterating to support additional use cases.

Knative Events depends on [knative/serving](https://github.com/knative/serving) and
together with [knative/build](https://github.com/knative/build) provides a
complete serverless platform.

The primary goal of *events* is interoperability; therefore, we expect to
provide common libraries that can be used in other systems to emit or consume
events.


## Naming

We'll be tracking the CloudEvents nomenclature as much as possible; however,
that is in flux and many of the needed terms are outside of the current scope
of the specification. We use the term "feed" to represent the concept of
attaching an event (or filtered event stream via a "trigger) to an action.

# Getting Started

* [Setup Knative Serving](https://github.com/knative/docs/blob/master/install/README.md)
* [Setup Knative Eventing](https://github.com/knative/eventing/blob/master/DEVELOPMENT.md)
* [Run samples](https://github.com/knative/eventing/blob/master/sample/README.md)


# Kubernetes Extensions

Eventing extends Kubernetes with Custom Resource Definitions (CRDs). The
following Custom Resources (CRs) are used in the production and consumption of
events:

#### Channels

 - Bus, ClusterBus
 - Channel
 - Subscription

#### Feeds

 - Feed
 - EventSource
 - EventType

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
