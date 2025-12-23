---
audience: developer
components:
  - eventing
function: how-to
---

# Subscriptions

After you have created a Channel and a Sink, you can create a Subscription to enable event delivery.

The Subscription consists of a Subscription object, which specifies the Channel and the Sink (also
known as the Subscriber) to deliver events to. You can also specify some Sink-specific options, such
as how to handle failures.

For more information about Subscription objects, see
[Subscription](https://knative.dev/docs/reference/api/eventing-api/#messaging.knative.dev/v1.Subscription).

## Creating a Subscription


=== "kn"
    Create a Subscription between a Channel and a Sink by running:

    ```bash
    kn subscription create <subscription-name> \
      --channel <Group:Version:Kind>:<channel-name> \
      --sink <sink-prefix>:<sink-name> \
      --sink-reply <sink-prefix>:<sink-name> \
      --sink-dead-letter <sink-prefix>:<sink-name>
    ```

    - `--channel` specifies the source for cloud events that should be processed.
    You must provide the Channel name. If you are not using the default Channel that is backed by the
    Channel resource, you must prefix the Channel name with the `<Group:Version:Kind>` for the
    specified Channel type.
    For example, this is `messaging.knative.dev:v1beta1:KafkaChannel` for a Kafka-backed Channel.

    - `--sink` specifies the target destination to which the event should be delivered.
    By default, the `<sink-name>` is interpreted as a Knative service of this name, in the same
    namespace as the Subscription.
    You can specify the type of the Sink by using one of the following prefixes:

        - `ksvc`: A Knative service.
        - `svc`: A Kubernetes Service.
        - `channel`: A Channel that should be used as the destination. You can only reference default
        Channel types here.
        - `broker`: An Eventing Broker.
        - `--sink-reply` is an optional argument you can use to specify where the Sink reply is sent.
        It uses the same naming conventions for specifying the Sink as the `--sink` flag.
        - `--sink-dead-letter` is an optional argument you can use to specify where to send the
        CloudEvent in case of a failure. It uses the same naming conventions for specifying the Sink
        as the `--sink` flag.

            - `ksvc`: A Knative service.
            - `svc`: A Kubernetes Service.
            - `channel`: A Channel that should be used as destination. Only default Channel types can be referenced here.
            - `broker`: An Eventing Broker.
        - `--sink-reply` and `--sink-dead-letter` are optional arguments. They can be used to specify where the Sink reply is sent, and where to send the CloudEvent in case of a failure, respectively. Both use the same naming conventions for specifying the Sink as the `--sink` flag.


    This example command creates a Subscription named `mysubscription` that routes events from a Channel
    named `mychannel` to a Knative service named `myservice`.


    !!! note
        The Sink prefix is optional. You can also specify the service for `--sink` as just
        `--sink <service-name>` and omit the `ksvc` prefix.


=== "YAML"
    1. Create a YAML file for the Subscription object using the following example:

        ```yaml
        apiVersion: messaging.knative.dev/v1
        kind: Subscription
        metadata:
          name: <subscription-name>
          # Name of the Subscription.
          namespace: default
        spec:
          channel:
            apiVersion: messaging.knative.dev/v1
            kind: Channel
            name: <channel-name>
            # Name of the Channel that the Subscription connects to.
          delivery:
            # Optional delivery configuration settings for events.
            deadLetterSink:
            # When this is configured, events that failed to be consumed are sent to the deadLetterSink.
            # The event is dropped, no re-delivery of the event is attempted, and an error is logged in the system.
            # The deadLetterSink value must be a Destination.
              ref:
                apiVersion: serving.knative.dev/v1
                kind: Service
                name: <service-name>
          reply:
            # Optional configuration settings for the reply event.
            # This is the event Sink that events replied from the subscriber are delivered to.
            ref:
              apiVersion: messaging.knative.dev/v1
              kind: InMemoryChannel
              name: <service-name>
          subscriber:
            # Required configuration settings for the Subscriber. This is the event Sink that events are delivered to from the Channel.
            ref:
              apiVersion: serving.knative.dev/v1
              kind: Service
              name: <service-name>
        ```

    1. Apply the YAML file by running the command:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.


## Listing Subscriptions

You can list all existing Subscriptions by using the `kn` CLI tool.

- List all Subscriptions:

    ```bash
    kn subscription list
    ```

- List Subscriptions in YAML format:

    ```bash
    kn subscription list -o yaml
    ```

## Describing a Subscription

You can print details about a Subscription by using the `kn` CLI tool:

```bash
kn subscription describe <subscription-name>
```

**Example:**

```bash
kn subscription describe mysubscription
```

!!! Success "Expected output"
    ```{ .bash .no-copy }
    Name:            mysubscription
    Namespace:       default
    Annotations:     messaging.knative.dev/creator=user@example.com
                     messaging.knative.dev/lastModifier=user@example.com
    Age:             1h
    Channel:         Channel:mychannel (messaging.knative.dev/v1)
    Subscriber:
      URI:           http://myservice.default.svc.cluster.local
    Reply:
      Name:          myreply
      Kind:          InMemoryChannel
      API Version:   messaging.knative.dev/v1
    DeadLetterSink:
      Name:          mydlq
      Kind:          Service
      API Version:   serving.knative.dev/v1

    Conditions:
      OK TYPE                  AGE REASON
      ++ Ready                  1h
      ++ AddedToChannel         1h
      ++ ChannelReady           1h
    ```

## Updating a Subscription

You can update an existing Subscription by using the `kn` CLI tool or by applying an updated YAML file.

=== "kn"
    Use the `kn subscription update` command to modify an existing Subscription.

    **Example:**

    ```bash
    kn subscription update mysubscription \
      --sink ksvc:myservice \
      --sink-dead-letter ksvc:error-handler \
      --sink-reply channel:reply-channel
    ```

    You can update individual parameters as needed:
    - `--sink`: Change the subscriber (destination for events)
    - `--sink-dead-letter`: Add or update the dead letter sink for failed deliveries
    - `--sink-reply`: Update where reply events are sent

    !!! note
        When updating a Subscription, you must provide all the configuration parameters you want to keep. Any parameters not specified in the update command will use default values.

=== "kubectl"
    1. Get the current Subscription configuration:

        ```bash
        kubectl get subscription <subscription-name> -o yaml > subscription.yaml
        ```

    1. Edit the YAML file to make your desired changes to the `spec` section.

    1. Apply the updated YAML file:

        ```bash
        kubectl apply -f subscription.yaml
        ```

## Deleting Subscriptions

You can delete a Subscription by using the `kn` or `kubectl` CLI tools.

=== "kn"
    ```bash
    kn subscription delete <subscription-name>
    ```


=== "kubectl"
    ```bash
    kubectl subscription delete <subscription-name>
    ```

## Next steps

- [Creating a Channel using cluster or namespace defaults](create-default-channel.md)
