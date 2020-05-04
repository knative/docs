---
title: "Default channels"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 2
type: "docs"
---

A channel provides an event delivery mechanism that can fan-out received events
to multiple destinations. The default channel configuration allows channels to
be created without specifying an underlying implementation. This is useful for
users that do not care about the properties a particular channel provides (e.g.,
ordering, persistence, etc.), but are rather fine with using the  
implementation selected by the the operator. The operator controls the default
settings via a `ConfigMap`. For example, an operator can configure which channels
to use  when `Channel Based Brokers` or `Sequences` are created.

Even though this default channel mechanism aims to ease the usability of the
system, users can still create their own channels directly by instantiating one
of the supported channel objects (e.g., `InMemoryChannel`, `KafkaChannel`,
etc.).

## Setting the default channel configuration for messaging layer

The default channel configuration is specified in the `ConfigMap` named
`default-ch-webhook` in the `knative-eventing` namespace. This `ConfigMap` may
specify a cluster-wide default channel and namespace-specific channel
implementations.

_The namespace-specific defaults override the cluster default for channels
created in the specified namespace._

_Note that default channel spec fields can also be specified._

The default options are specified like this:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: default-ch-webhook
  namespace: knative-eventing
data:
  default-ch-config: |
    clusterDefault:
      apiVersion: messaging.knative.dev/v1beta1
      kind: InMemoryChannel
    namespaceDefaults:
      some-namespace:
        apiVersion: messaging.knative.dev/v1alpha1
        kind: KafkaChannel
        spec:
          numPartitions: 2
          replicationFactor: 1
```

Namespace-specific defaults take precedence over cluster defaults when matched.

## Creating a channel with cluster or namespace defaults

To create a channel using the cluster or namespace defaults set by the operator,
create a generic `Channel` custom object. This is typically useful if you do not
care what kind of channel it is, and if you are comfortable using the ones that
the operator has selected for you.

For example, this is a valid `Channel` object:

```yaml
apiVersion: messaging.knative.dev/v1beta1
kind: Channel
metadata:
  name: my-channel
  namespace: default
```

When the above `Channel` is created, a mutating admission webhook sets
`spec.channelTemplate` based on the default channel implementation chosen by the
operator. The `Channel` controller will then create the backing channel instance
based on that `spec.channelTemplate`. The `spec.channelTemplate` property cannot
be changed after creation, and it will be normally set by the default channel
mechanism instead of the user.

For example, this is the output when the default channel is set using the above
`ConfigMap` configuration:

```yaml
apiVersion: messaging.knative.dev/v1beta1
kind: Channel
metadata:
  name: my-channel
  namespace: default
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1beta1
￼    kind: InMemoryChannel
```

When this mechanism is used, two objects are created, a generic `Channel` and an
`InMemoryChannel` channel. The former acts as a proxy of the latter: it copies
its subscriptions to the `InMemoryChannel` one and sets its `status` with the
backing `InMemoryChannel` `status`.

Further, note that as the `Channel` was created in the `default` namespace, it
uses the cluster defaults, i.e., `InMemoryChannel`. If the `Channel` would have
been created in the `some-namespace` namespace, it would have been backed by an
underlying `KafkaChannel` instead (i.e., the default for that namespace).

## Defaults only apply on object creation

Defaults are applied by the webhook only on `Channel`, or `Sequence`
creation. If the default settings change, the new defaults will only apply to
newly-created channels, brokers, or sequences. Existing ones will not change.
