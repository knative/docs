---
title: "Knative Eventing channels"
linkTitle: "Channels"
weight: 40
type: "docs"
showlandingtoc: "true"
aliases:
  - /docs/eventing/channels/default-channels
---

Channels are Kubernetes [custom resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) that define a single event forwarding and persistence layer.
A channel provides an event delivery mechanism that can fan-out received events to multiple destinations, or _event_sinks_.

![Channel workflow diagram](././eventing/images/channel-workflow.png)

Knative provides the InMemoryChannel implementation by default. This default implementation is useful for developers who do not want to configure a specific implementation type, such as Apache Kafka or NATSS channels.

Developers can create channels of any supported implementation type by creating an instance of a Channel object, whether the object is the default channel type or not.

## Configuring default channel types

The default channel implementation is specified in the `default-ch-webhook` ConfigMap in the `knative-eventing` namespace.
For more information about configuring ConfigMaps, see [Configuring the Eventing Operator Custom Resource](././docs/install/configuring-eventing-cr).

In the following example, the cluster default channel implementation is InMemoryChannel, while the namespace default channel implementation for the `example-namespace` is KafkaChannel.

**Default ConfigMap example**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: default-ch-webhook
  namespace: knative-eventing
data:
  default-ch-config: |
    clusterDefault:
      apiVersion: messaging.knative.dev/v1
      kind: InMemoryChannel
    namespaceDefaults:
      example-namespace:
        apiVersion: messaging.knative.dev/v1beta1
        kind: KafkaChannel
        spec:
          numPartitions: 2
          replicationFactor: 1
```

Default channels can be configured for the cluster, a namespace on the cluster, or both.
If a default channel implementation is configured for a namespace, this will overwrite the configuration for the cluster.

## Creating a channel using cluster or namespace defaults

1. Create a Channel object:

  ```yaml
  apiVersion: messaging.knative.dev/v1
  kind: Channel
  metadata:
    name: my-channel
    namespace: default
  ```

  Since this object is created in the `default` namespace, according to the default ConfigMap example in the previous section, it will be an InMemoryChannel channel implementation.
<!--TODO: Add tabs for kn etc-->

1.  After the Channel object is created, a mutating admission webhook sets the
  `spec.channelTemplate` based on the default channel implementation:

  ```yaml
  apiVersion: messaging.knative.dev/v1
  kind: Channel
  metadata:
    name: my-channel
    namespace: default
  spec:
    channelTemplate:
      apiVersion: messaging.knative.dev/v1
      kind: InMemoryChannel
  ```
  **NOTE:** The `spec.channelTemplate` property cannot be changed after creation, since it is set by the default channel mechanism, not the user.

1. The channel controller creates a backing channel instance
based on the `spec.channelTemplate`.

  When this mechanism is used, two objects are created, a generic Channel object, and an
  InMemoryChannel object. The generic object acts as a proxy for the InMemoryChannel object, by copying its subscriptions to and setting its status to that of the InMemoryChannel object.

## Defaults only apply on object creation

Defaults are applied by the webhook only on `Channel`, or `Sequence`
creation. If the default settings change, the new defaults will only apply to
newly-created channels, brokers, or sequences. Existing ones will not change.
