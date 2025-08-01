---
audience: developer
components:
  - eventing
function: explanation
---

# Event Mesh

An Event Mesh is dynamic, interconnected infrastructure which is designed to simplify distributing events from senders to recipients.  Similar to traditional message-channel architectures like Apache Kafka or RabbitMQ, an Event Mesh provides asynchronous (store-and-forward) delivery of messages which allows decoupling senders and recipients in time.  Unlike traditional message-channel based integration patterns, Event Meshes also simplify the routing concerns of senders and recipients by decoupling them from the underlying event transport infrastructure (which may be a federated set of solutions like Kafka, RabbitMQ, or cloud provider infrastructure).  The mesh transports events from producers to consumers via a network of interconnected _event brokers_ across any environment, and even between clouds in a seamless and loosely coupled way.

In an Event Mesh, both producing and consuming applications do not need to implement event routing or subscription management.  Event producers can publish all events to the mesh, which can route events to interested subscribers without needing the application to subdivide events to channels.  Event consumers can use mesh configuration to receive events of interest using fine-grained filter expressions rather than needing to implement multiple subscriptions and application-level event filtering to select the events of interest.  Event serialization and de-serialization can be handled by language-native libraries without needing to implement heavier-weight routing and filtering.

## Knative Event Mesh

The above mentioned _event brokers_ map directly to a core API in Knative Eventing: the [`Broker` API](../brokers) offers a discoverable endpoint for event ingress and the [`Trigger` API](../triggers) completes the offering with its event filtering and delivery capabilities.  With these APIs Knative Eventing offers an Event Mesh as defined above:

![Raw Trace](images/mesh.png)

As visible in the above diagram, the Event Mesh is defined with the `Broker` and `Trigger` APIs for the ingress and the egress of events.  Knative Eventing enables multiple resources to participate in the Event Mesh with a partial schema pattern called "duck typing".  Duck typing allows multiple resource types to advertise common capabilities, such as "can receive events at a URL" or "can deliver events to a destination".  Knative Eventing uses these capabilities to offer [a pool of interoperable sources](../sources) for sending events to the `Broker` and [as destinations for `Trigger`-routed events](../triggers).  The Knative Eventing APIs contain three categories of APIs:

* **Events Ingress**: Support for connecting event senders: Source duck type and [SinkBinding](../custom-event-source/sinkbinding) to support easily configuring applications to deliver events to a `Broker`.  Applications can submit events and use Eventing even without any sources installed.
* **Event routing**: `Broker` and `Trigger` objects support defining the mesh and event routing.  Note that `Broker` matches the definition of an Addressable event destination, so it is possible to relay events from a Broker in one cluster to a Broker in another cluster.  Similarly, `Trigger` uses the same Deliverable duck type as many sources, so it is easy to substitute an event mesh for direct delivery of events.
* **Event egress** : The Deliverable contract supports specifying either a bare URL or referencing a Kubernetes object which implements the Addressable interface (has a `status.address.url`) as a destination.  All event destinations ("sinks") must implement the CloudEvents delivery specification, but do not necessarily need to implement any Kubernetes behavior -- a bare VM referenced by URL is an acceptable event egress.

It is important to note that event sources and sinks are supporting components of the eventing ecosystem but are not directly part of the Event Mesh.  While not part of the Event Mesh, these ecosystem components complement the mesh and benefit from the duck type APIs (`Callable`/`Addressable`) for a smooth integration or connection with the "Event Mesh".
