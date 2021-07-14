---
title: "Apache Kafka ResetOffset Example"
linkTitle: "ResetOffset Example"
weight: 20
type: "docs"
---

Kafka backed Channels are potentially different from other implementations in
that they provide temporal persistence of events. This capability allows for
certain advanced use cases to be supported, including the ability to "replay"
prior events via repositioning the current location in the event-stream.  This
capability can be extremely useful when attempting to recover from unexpected
Subscriber downtime.

The
[ResetOffset CRD](https://github.com/knative-sandbox/eventing-kafka/tree/main/config/command/resetoffset)
exposes the ability to manipulate the location of the ConsumerGroup Offsets in
the event stream of a given Knative Subscription. Without the ResetOffset CRD
you would be responsible for manually stopping ConsumerGroups and manipulating
Offsets.

!!! note
    Repositioning the ConsumerGroup Offsets will impact the event ordering and
    is intended for failure recovery scenarios. This capability needs to be used
    with caution only after reviewing the CRD documentation linked above.

!!! note
    ResetOffsets are currently only supported by the Distributed KafkaChannel
    implementation. It is expected that the Consolidated KafkaChannel
    implementation will support them in the near future.

## Prerequisites

- A Kubernetes cluster with
  [Knative Kafka Channel installed](../../../../admin/install/).
- A valid KafkaChannel and Subscription exist.

## Examples

The following examples assume a Kubernetes Namespace called `my-namespace`
containing a KafkaChannel Subscription named `my-subscription` and should be
updated according to your use case.

### Repositioning the Offsets to the oldest available event

The following ResetOffset instance will move the offsets back to the oldest
available event in the Kafka Topic retention window.

```yaml
apiVersion: kafka.eventing.knative.dev/v1alpha1
kind: ResetOffset
metadata:
  name: my-resetoffset
  namespace: my-namespace
spec:
  offset:
    time: earliest
  ref:
    apiVersion: messaging.knative.dev/v1
    kind: Subscription
    namespace: my-namespace
    name: my-subscription
```

### Repositioning the Offsets to a specific point in the event stream

The following ResetOffset instance will move the offsets back to the specified
point in the Kafka Topic retention window. You will need to set an appropriate
[RFC3339](https://datatracker.ietf.org/doc/html/rfc3339) timestamp relative to
your use case.

```yaml
apiVersion: kafka.eventing.knative.dev/v1alpha1
kind: ResetOffset
metadata:
  name: my-resetoffset
  namespace: my-namespace
spec:
  offset:
    time: "2021-06-17T17:30:00Z"
  ref:
    apiVersion: messaging.knative.dev/v1
    kind: Subscription
    namespace: my-namespace
    name: my-subscription
```

!!! note
    The ResetOffset CRD is a single use operation or "command", and should be
    deleted from the cluster once it has completed execution.
