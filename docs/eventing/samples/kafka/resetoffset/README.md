# ResetOffset Example

Kafka-backed Channels differ from other Channel implementations because they provide temporal persistence of events.

Event persistence enables certain advanced use cases to be supported, such as the ability to replay prior events by repositioning their current location in the event stream. This feature is useful when attempting to recover from unexpected Subscriber downtime.

The [ResetOffset custom resource definition (CRD)](https://github.com/knative-sandbox/eventing-kafka/tree/main/config/command/resetoffset) exposes the ability to manipulate the location of the ConsumerGroup Offsets in the event stream of a given Knative Subscription. Without the ResetOffset CRD, you must manually stop ConsumerGroups and manipulating Offsets.

!!! note
    ResetOffsets are currently only supported by the Distributed KafkaChannel
    implementation.

!!! warning
    Repositioning the ConsumerGroup Offsets impacts the event ordering and
    is intended for failure recovery scenarios. This capability needs to be used
    with caution only after reviewing the [CRD documentation](https://github.com/knative-sandbox/eventing-kafka/tree/main/config/command/resetoffset).

## Prerequisites

- A Kubernetes cluster with the [Kafka Channel implementation](https://knative.dev/docs/eventing/channels/channels-crds/) installed.
- A valid KafkaChannel resource and Subscription exist.

!!! note
    The ResetOffset CRD is a single-use operation, and should be
    deleted from the cluster once it has been executed.

## Repositioning offsets to the oldest available event

The following ResetOffset instance moves the offsets back to the oldest
available event in the Kafka Topic retention window:

```yaml
apiVersion: kafka.eventing.knative.dev/v1alpha1
kind: ResetOffset
metadata:
  name: <resetoffset-name>
  namespace: <namespace>
spec:
  offset:
    time: earliest
  ref:
    apiVersion: messaging.knative.dev/v1
    kind: Subscription
    namespace: <subscription-namespace>
    name: <subscription-name>
```

Where:

- `<resetoffset-name>` is the name of the ResetOffset CRD.
- `<namespace>` is the namespace where you want to create the ResetOffset CRD.
- `<subcription-namespace>` is the namespace where your Subscription exists.
- `<subscription-name>` is the name of the Subscription.

## Repositioning offsets to a specific point in the event stream

The following ResetOffset instance moves the offsets back to the specified
point in the Kafka Topic retention window.

```yaml
apiVersion: kafka.eventing.knative.dev/v1alpha1
kind: ResetOffset
metadata:
  name: <resetoffset-name>
  namespace: <namespace>
spec:
  offset:
    time: <offset-time>
  ref:
    apiVersion: messaging.knative.dev/v1
    kind: Subscription
    namespace: <subscription-namespace>
    name: <subscription-name>
```

Where:

- `<resetoffset-name>` is the name of the ResetOffset CRD.
- `<offset-time>` is the specified offset time. You will need to set an [RFC3339](https://datatracker.ietf.org/doc/html/rfc3339) timestamp relative to your use case, for example `"2021-06-17T17:30:00Z"`.
- `<namespace>` is the namespace where you want to create the ResetOffset CRD.
- `<subscription-namespace>` is the namespace where your Subscription exists.
- `<subscription-name>` is the name of the Subscription.
