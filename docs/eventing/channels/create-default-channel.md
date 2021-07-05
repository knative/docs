---
title: "Creating a channel using cluster or namespace defaults"
linktitle: "Creating channels"
weight: 65
type: "docs"
showlandingtoc: "true"
---

# Creating a channel using cluster or namespace defaults

Developers can create channels of any supported implementation type by creating an instance of a Channel object.

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

2.  After the Channel object is created, a mutating admission webhook sets the
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
      !!! info
          The `spec.channelTemplate` property cannot be changed after creation, since it is set by the default channel mechanism, not the user.

3. The channel controller creates a backing channel instance
based on the `spec.channelTemplate`.

      When this mechanism is used, two objects are created, a generic Channel object, and an InMemoryChannel object. The generic object acts as a proxy for the InMemoryChannel object, by copying its subscriptions to and setting its status to that of the InMemoryChannel object.

!!! info
    Defaults only apply on object creation. Defaults are applied by the webhook only on Channel or Sequence creation. If the default settings change, the new defaults will only apply to newly-created channels, brokers, or sequences. Existing ones will not change.
