# Creating a channel using cluster or namespace defaults

Developers can create channels of any supported implementation type by creating an instance of a
Channel object.

To create a channel:

* Create a [Channel object](https://knative.dev/docs/reference/api/eventing/#messaging.knative.dev/v1.Channel) by running:

    ```yaml
    kubectl apply -f <<EOF
    apiVersion: messaging.knative.dev/v1
    kind: Channel
    metadata:
      name: <example-channel>
      namespace: <namespace>
    EOF
    ```
    Where:

    * `<example-channel>` is the name of the channel you want to create.
    * `<namespace>` is the name of your target namespace.

If you create this object in the `default` namespace, according to the default ConfigMap
example in [Channel types and defaults](./channel-types-defaults), it is an InMemoryChannel
channel implementation.

<!-- TODO: Add tabs for kn etc-->

After the Channel object is created, a mutating admission webhook sets the `spec.channelTemplate` based on the default channel implementation:

```yaml
apiVersion: messaging.knative.dev/v1
kind: Channel
metadata:
  name: <example-channel>
  namespace: <namespace>
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1
    kind: <channel-template-kind>
```
Where:

* `<example-channel>` is the name of the channel you want to create.
* `<namespace>` is the name of your target namespace.
* `<channel-template-kind>` is the kind of channel, such as InMemoryChannel or KafkaChannel,
based on the default ConfigMap. See an example in [Channel types and defaults](./channel-types-defaults).

!!! note
    The `spec.channelTemplate` property cannot be changed after creation, because it is
    set by the default channel mechanism, not the user.


The channel controller creates a backing channel instance based on the `spec.channelTemplate`.

When this mechanism is used two objects are created; a generic Channel object and an
InMemoryChannel object. The generic object acts as a proxy for the InMemoryChannel object
by copying its subscriptions to, and setting its status to, that of the InMemoryChannel
object.

!!! note
    Defaults only apply when objects are created.
    Defaults are applied by the webhook only when a channel or sequence is created.
    If the default settings change, the new defaults only apply to newly created channels,
    brokers, or sequences. Existing ones do not change.
