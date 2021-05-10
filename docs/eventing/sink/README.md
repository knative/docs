---
title: "Sink"
weight: 60
type: "docs"
---

# Sink

A sink is an Addressable resource that acts as a link
between the Eventing mesh and an entity or system.

We can connect any source to a sink, such as `PingSource` and `KafkaSink` objects:

```yaml
apiVersion: sources.knative.dev/v1beta1
kind: PingSource
metadata:
  name: test-ping-source
spec:
  schedule: "*/1 * * * *"
  jsonData: '{"message": "Hello world!"}'
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: KafkaSink
      name: my-kafka-sink
```

We can connect a `Trigger` object to a sink, so that we can filter events, before sending them to a sink:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  filter:
    attributes:
      type: dev.knative.foo.bar
      myextension: my-extension-value
  subscriber:
    ref:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: KafkaSink
      name: my-kafka-sink
```

## Setting up a Custom Resource to be used as a sink
To allow a Custom Resource to act as a sink for events, there are two things needed: 

#### 1. Make the resource Addressable
To make a Custom Resource Addressable, it needs to contain a `status.address.url`. More information about [Addressable resources](https://github.com/knative/specs/blob/main/specs/eventing/interfaces.md#addressable).

#### 2. Create an addressable-resolver ClusterRole
An addressable-resolver ClusterRole is needed in order to obtain the necessary RBAC rules for the sink to receive events.

For example, we can create a `kafkasinks-addressable-resolver` ClusterRole to allow `get`, `list`, and `watch` access to `kafkasinks` and `kafkasinks/status`
```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kafkasinks-addressable-resolver
  labels:
    kafka.eventing.knative.dev/release: devel
    duck.knative.dev/addressable: "true"
# Do not use this role directly. These rules will be added to the "addressable-resolver" role.
rules:
  - apiGroups:
      - eventing.knative.dev
    resources:
      - kafkasinks
      - kafkasinks/status
    verbs:
      - get
      - list
      - watch
 ```

## Knative Sinks

| Name | Maintainer | Description |
| -- | -- | -- |
| [KafkaSink](./kafka-sink.md)  | Knative  | Send events to a Kafka topic |
| [RedisSink](https://github.com/knative-sandbox/eventing-redis/tree/main/sink)  | Knative  | Send events to a Redis Stream |
