---
audience: developer
components:
  - eventing
function: explanation
---

# Brokers

Brokers are Kubernetes custom resources that define an [event mesh](../concepts/event-mesh.md) for collecting a pool of events. Brokers provide a discoverable endpoint for event ingress, and use Triggers for event delivery. Event producers can send events to a broker by POSTing the event.

![Source 1 and Source 2 are transmitting some data -- ones and twos -- to the Broker, which then gets filtered by Triggers to the desired Sink.](https://user-images.githubusercontent.com/16281246/116248768-1fe56080-a73a-11eb-9a85-8bdccb82d16c.png){draggable=false}

## Event delivery

Event delivery mechanics are an implementation detail that depend on the configured Broker class. Using Brokers and Triggers abstracts the details of event routing from the event producer and event consumer.

A producer addresses the Broker rather than choosing each subscriber. A Trigger
names that Broker, selects events by their CloudEvents attributes and extensions,
and identifies a subscriber destination. This separates publishing from the
subscription configuration. A Ready Broker or Trigger indicates that its
configuration has reconciled; verifying a route also requires observing event
receipt at the subscriber.

Filters select which events take a route; delivery settings govern what happens
when delivery fails. Those are different concerns: changing retries will not make
an event match a filter. The [Trigger filtering reference](../triggers/reference.md)
states dialect support and matching behavior. The
[Event delivery reference](../reference/event-delivery.md) states delivery fields
and Broker/Channel support without assuming all implementations behave alike.

## Advanced use cases

For most use cases, a single Broker per namespace is sufficient, but
there are several use cases where multiple Brokers can simplify
architecture. For example, separate Brokers for events containing Personally
Identifiable Information (PII) and non-PII events can simplify audit and access
control rules.

## Next steps

- Create a [Broker](create-broker.md).
- [Route matching events to a subscriber](../triggers/README.md) and verify receipt.
- [Configure and test retries and a dead-letter sink](../event-delivery.md).
- Investigate [events not reaching a subscriber](../troubleshooting/events-not-delivered.md)
  or [repeated delivery failures](../troubleshooting/delivery-failures.md).
- Configure [default Broker ConfigMap settings](../configuration/broker-configuration.md).

## Additional resources

- [Broker specifications](https://github.com/knative/specs/blob/main/specs/eventing/overview.md#broker){target=_blank}
