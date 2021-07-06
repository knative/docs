# Creating a Channel using cluster or namespace defaults

Developers can create Channels of any supported implementation type by creating an instance of a
Channel object.

To create a Channel:

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

    * `<example-channel>` is the name of the Channel you want to create.
    * `<namespace>` is the name of your target namespace.

If you create this object in the `default` namespace, according to the default ConfigMap
example in [Channel types and defaults](/eventing/channels/channel-types-defaults), it is an
InMemoryChannel Channel implementation.

<!-- TODO: Add tabs for kn etc-->

After the Channel object is created, a mutating admission webhook sets the `spec.channelTemplate`
based on the default Channel implementation:

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

* `<example-channel>` is the name of the Channel you want to create.
* `<namespace>` is the name of your target namespace.
* `<channel-template-kind>` is the kind of Channel, such as InMemoryChannel or KafkaChannel,
based on the default ConfigMap. See an example in [Channel types and defaults](/eventing/channels/channel-types-defaults).

!!! note
    The `spec.channelTemplate` property cannot be changed after creation, because it is
    set by the default Channel mechanism, not the user.


The Channel controller creates a backing Channel instance based on the `spec.channelTemplate`.

When this mechanism is used two objects are created; a generic Channel object and an
InMemoryChannel object. The generic object acts as a proxy for the InMemoryChannel object
by copying its Subscriptions to, and setting its status to, that of the InMemoryChannel
object.

!!! note
    Defaults are only applied by the webhook when a Channel or Sequence is initially created.
    If the default settings are changed, the new defaults will only be applied to newly created
    Channels, Brokers, or Sequences. Existing resources are not updated automatically to use the new
    configuration.
