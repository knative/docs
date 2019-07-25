---
title: "Default channels"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 2
type: "docs"
---

The default channel configuration allows channels to be created without
specifying an underlying implementation. This leaves the selection of the channel implementation 
and properties up to the operator. The operator controls the default settings via a
`ConfigMap`.

## Creating a default channel

To create a default channel, create a `Channel` custom object.
For example, this is a valid default channel:

```yaml
apiVersion: messaging.knative.dev/v1alpha1
kind: Channel
metadata:
  name: default-channel
  namespace: default
```

When the above `Channel` is created, a mutating admission webhook sets `spec.channelTemplate` based on the default channel 
implementation chosen by the operator. The `Channel` controller will then create the backing channel instance based on 
that `spec.channelTemplate`. The `spec.channelTemplate` property cannot be changed after creation, and it will be normally 
set by the default channel mechanism instead of the user.

For example, this is the output when the default channel is set to `InMemoryChannel`:

```yaml
apiVersion: messaging.knative.dev/v1alpha1
kind: Channel
metadata:
  name: default-channel
  namespace: default
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1alpha1
￼    kind: InMemoryChannel
```

When this mechanism is used, two objects are created, a generic `Channel` and an `InMemoryChannel` channel. 
The former acts as a proxy of the latter: it copies its subscriptions to the `InMemoryChannel` one and sets its `status`
with the backing `InMemoryChannel` `status`. 


## Setting the default channel configuration

The default channel configuration is specified in the `ConfigMap` named
`default-ch-webhook` in the `knative-eventing` namespace. This `ConfigMap`
may specify a cluster-wide default channel and namespace-specific
channel implementations.

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
      apiVersion: messaging.knative.dev/v1alpha1
      kind: InMemoryChannel
    namespaceDefaults:
      some-namespace:
        apiVersion: messaging.knative.dev/v1alpha1
        kind: KafkaChannel
        spec:
          numPartitions: 2
          replicationFactor: 1
```

Namespace-specific defaults take precedence when matched. In the above example, a
`Channel` created in the `some-namespace` namespace will be backed by an underlying `KafkaChannel`, 
not an `InMemoryChannel`.

## Defaults only apply on channel creation

Defaults are applied by the webhook on `Channel` creation only. If the default
settings change, the new defaults will apply to newly-created channels only.
Existing channels will not change.
