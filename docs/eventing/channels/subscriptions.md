# Subscriptions

After you have created a Channel and a Sink, you can create a Subscription to enable event delivery.

The Subscription consists of a Subscription object, which specifies the Channel and the Sink (also
known as the Subscriber) to deliver events to. You can also specify some Sink-specific options, such
as how to handle failures.

For more information about Subscription objects, see
[Subscription](https://knative.dev/docs/reference/api/eventing/#messaging.knative.dev/v1.Subscription).

## Creating a Subscription


=== "kn"
    Create a Subscription between a Channel and a Sink by running:

    ```
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


    This example command creates a Channel named `mysubscription` that routes events from a Channel
    named `mychannel` to a Knative service named `myservice`.


    !!! note
        The Sink prefix is optional. You can also specify the service for `--sink` as just
        `--sink <service-name>` and omit the `ksvc` prefix.


=== "YAML"
    Create a Subscription object in a YAML file:

    ```yaml
    kubectl apply -f <<EOF
    apiVersion: messaging.knative.dev/v1
    kind: Subscription
    metadata:
      name: <subscription-name> # Name of the Subscription.
      namespace: default
    spec:
      channel:
        apiVersion: messaging.knative.dev/v1
        kind: Channel
        name: <channel-name> # Configuration settings for the Channel that the Subscription connects to.
      delivery:
        deadLetterSink:
          ref:
            apiVersion: serving.knative.dev/v1
            kind: Service
            name: <service-name>
            # Configuration settings for event delivery.
            # This tells the Subscription what happens to events that cannot be delivered to the Subscriber.
            # When this is configured, events that failed to be consumed are sent to the deadLetterSink.
            # The event is dropped, no re-delivery of the event is attempted, and an error is logged in the system.
            # The deadLetterSink value must be a Destination.
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: <service-name> # Configuration settings for the Subscriber. This is the event Sink that events are delivered to from the Channel.
    EOF
    ```


## Listing Subscriptions

You can list all existing Subscriptions by using the `kn` CLI tool.

- List all Subscriptions:

    ```
    kn subscription list
    ```

- List Subscriptions in YAML format:

    ```
    kn subscription list -o yaml
    ```

## Describing a Subscription

You can print details about a Subscription by using the `kn` CLI tool:

```
kn subscription describe <subscription-name>
```
<!--TODO: Add an example command and output-->
<!--TODO: Add details for kn Subscription update - existing generated docs weren't clear enough, need better explained examples-->

## Deleting Subscriptions

You can delete a Subscription by using the `kn` or `kubectl` CLI tools.

=== "kn"
    ```
    kn subscription delete <subscription-name>
    ```


=== "kubectl"
    ```
    kubectl subscription delete <subscription-name>
    ```

## Next steps

- [Creating a Channel using cluster or namespace defaults](/eventing/channels/create-default-channel)
