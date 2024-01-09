# Vision: Secure Event processing and improved Event discoverability

**Authors: Pierangelo Di Pilato, Senior Software Engineer @ Red Hat, Matthias Weßendorf, Senior
Principal Software Engineer @ Red Hat**

## What is next in Knative Eventing?

Knative Eventing has made significant strides and solidified its position as the platform on
Kubernetes for event-driven applications. However, our journey with the project is far from over; we
are committed to its ongoing evolution. Our efforts involve enhancing existing APIs and introducing
new features to further empower Knative Eventing. Below, we provide a high-level overview of our
upcoming initiatives for the next months.

We value your feedback, as it plays a crucial role in shaping the project's future. If you spot any
missing features or identify areas needing improvement, please don't hesitate to share your thoughts
with us. Your input is invaluable to us!

## Secure Event Processing

Secure event processing refers to the practice of processing and analyzing events or data streams in
a secure and trusted manner. Events can include various types of data, such as user interactions,
system logs, sensor readings, network traffic, or any other form of real-time or near-real-time
data.

The primary goal of secure event processing is to ensure the confidentiality, integrity, and
availability of the processed events while maintaining the privacy and security of the underlying
data.

### Transport encryption

Presently, event delivery within the cluster lacks encryption, imposing limitations on the types of
events that can be transmitted—usually those of low compliance value or with a relaxed compliance
posture. Alternatively, administrators must resort to a service mesh or encrypted CNI to encrypt the
traffic, introducing multiple challenges for Knative Eventing adopters.

The forthcoming solution lies in Knative Brokers and Channels, which will offer HTTPS endpoints to
receive events. However, since these endpoints typically lack public DNS names (e.g.,
svc.cluster.local or similar), they must be signed by a non-public CA, specific to the cluster or
organization.

To facilitate this, event producers will have the ability to know the CA root used to sign the
Broker or Channel certificate from the Knative resource's metadata.

For more detailed information, please refer to
the [transport-encryption feature](/docs/eventing/experimental-features/transport-encryption/)

### Authorization and admission policies

Event-driven architecture aims to reduce organizational silos and barriers, promoting resilient
systems and enhancing business agility. However, achieving this vision necessitates the
implementation of event admission policies and robust safeguards to ensure security and data
quality.

Event admission policies will tackle the critical requirement of authorization policies, determining
who has the privilege to send events to a specific event hub, such as a Knative Broker or Channel.
Additionally, these policies will govern what content is deemed valid for the events being
transmitted, including schemas and other related elements.

Authorization and admission policies serve as the pivotal feature bridging the secure event
processing aspect with the event discovery realm, as detailed below.

## Improved Event discovery

Event discovery helps developers to understand which events they can consume and how the events look
like, without having to dig through various levels of service documentation.

Knative defines an EventType API which allows for discovery of the types of events that are
available in the Knative Eventing system. This helps developers understand what kinds of events can
be listened to and processed, which can be particularly helpful in systems with a large number of
events being produced.

However currently the EventType is unfortunately underused and is limited to sources which implement
the Knative Source Ducktype in combination with the Knative Broker API.

In order to improve the developer experience of Knative Eventing we are enhancing the event
discovery in a couple of ways!

* Automatic event type creation
* Usage beyond the broker API
* Event Type definitions

### Automatic Event Type creation

Currently, the `EventType` API requires developers to create `EventType` objects manually.

To address this problem we introduce an optional feature flag which can be _enabled_ in order to
have support for an automatic creation of EventTypes.

For more detailed information, please refer to
the [`eventtype-auto-creation` feature documentation](/docs/eventing/experimental-features/eventtype-auto-creation)

We see this feature as a quick way of documenting and discovering events that are flowing across an
organization, however, manually creating `EventType`s is still possible.

### Support for more than just Knative Brokers

Currently, the `EventType` API is usable only when using the Knative Broker API because it contains
a field called `broker` which represents the name of the Knative Broker that consumers can use to
subscribe to such events.

The EventType API will deprecate the `.spec.broker` field and add a `.spec.reference` field,
which can reference any Knative resource, including channels and sinks.

This removes the limitation to use the event type metadata with the Broker API
only and allows using the `EventType` API with any other resource.

### CRD for Event Type Definitions

`EventType` objects represents events that are actively been sent by a source system.

Many times, when building event-driven architectures, teams have a design phase where the event
structure and their metadata are decided and documented before having any source system sending
such events.

The `EventTypeDefinition` API will be the object types that teams and system integrators can use
to document to other teams that such event types are _potentially_ usable.

For more detailed information, please refer to
the [feature track document](https://docs.google.com/document/d/1vwEWtAm28g_QY9j0b63h8sRpGhvyB1K5ViNr8X3vIiM/edit)

## Conclusion

As you can see we are committed to move the Knative Eventing project forward. The above shows that
topics like secure event processing or improved event discoverability are addressed to improve the
developer experience for all Knative Eventing users.

However, we are not done! We are passionate about improving Knative Eventing and also continue to
innovate in the area of event driven architectures for Kubernetes. But we can not just do this
alone: We also need your help!

If you're curious and want to get involved, please explore
the [Github Projects](https://github.com/orgs/knative/projects) we have or feel free
to join us in our [Slack channels](https://knative.dev/docs/community/#communication-channels). Your
collaboration and contributions are invaluable to the continued success of Knative.
Together, we can shape the future of event-driven applications on Kubernetes!
