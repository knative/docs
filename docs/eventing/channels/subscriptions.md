---
title: "Subscriptions"
weight: 100
type: "docs"
showlandingtoc: "false"
---

After you have created a channel and a sink, you can create a subscription to enable event delivery.

## Creating a subscription

{{< tabs name="Creating a subscription" default="kn" >}}
{{% tab name="kn" %}}

Create a subscription between a channel and a sink:

```
kn subscription create <subscription_name> \
  --channel <Group:Version:Kind>:<channel_name> \
  --sink <sink_prefix>:<sink_name> \
  --sink-reply <sink_prefix>:<sink_name> \
  --sink-dead-letter <sink_prefix>:<sink_name>
```


- `--channel` specifies the source for cloud events that should be processed. You must provide the channel name. If you are not using the default channel that is backed by the Channel resource, you must prefix the channel name with the `<Group:Version:Kind>` for the specified channel type. For example, this will be `messaging.knative.dev:v1beta1:KafkaChannel` for a Kafka backed channel.

- `--sink` specifies the target destination to which the event should be delivered. By default, the `<sink_name>` is interpreted as a Knative service of this name, in the same namespace as the subscription. You can specify the type of the sink by using one of the following prefixes:

    - `ksvc`: A Knative service.
    - `svc`: A Kubernetes Service.
    - `channel`: A channel that should be used as destination. Only default channel types can be referenced here.
    - `broker`: An Eventing broker.
\
&nbsp;
- `--sink-reply` and `--sink-dead-letter` are optional arguments. They can be used to specify where the sink reply will be sent to, and where to send the cloud event in case of a failure, respectively. Both use the same naming conventions for specifying the sink as the `--sink` flag.

Example command:
```
kn subscription create mysubscription --channel mychannel --sink ksvc:myservice
```

This example command creates a channel named `mysubscription`, that routes events from a channel named `mychannel` to a Knative service named `myservice`.

**NOTE:** The sink prefix is optional. It is also possible to specify the service for `--sink` as just `--sink <service_name>` and omit the `ksvc` prefix.

{{< /tab >}}

{{% tab name="YAML" %}}

1. Create a Subscription object in a YAML file:

    ```yaml
    apiVersion: messaging.knative.dev/v1beta1
    kind: Subscription
    metadata:
      name: <subscription_name> # Name of the subscription.
      namespace: default
    spec:
      channel:
        apiVersion: messaging.knative.dev/v1
        kind: Channel
        name: <channel_name> # Configuration settings for the channel that the subscription connects to.
      delivery:
        deadLetterSink:
          ref:
            apiVersion: serving.knative.dev/v1
            kind: Service
            name: <service_name>
            # Configuration settings for event delivery.
            # This tells the subscription what happens to events that cannot be delivered to the subscriber.
            # When this is configured, events that failed to be consumed are sent to the deadLetterSink.
            # The event is dropped, no re-delivery of the event is attempted, and an error is logged in the system.
            # The deadLetterSink value must be a Destination.
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: <service_name> # Configuration settings for the subscriber. This is the event sink that events are delivered to from the channel.
    ```

1. Apply the YAML file:

    ```
    kubectl apply -f <filename>
    ```

{{< /tab >}} {{< /tabs >}}

## Listing subscriptions

You can list all existing subscriptions by using the `kn` CLI tool.

- List all subscriptions:

    ```
    kn subscription list
    ```
- List subscriptions in YAML format:

    ```
    kn subscription list -o yaml
    ```

## Describing a subscription

You can print details about a subscription by using the `kn` CLI tool:

```
kn subscription describe <subscription_name>
```
<!--TODO: Add an example command and output-->
<!--TODO: Add details for kn subscription update - existing generated docs weren't clear enough, need better explained examples-->

## Deleting subscriptions

You can delete a subscription by using the `kn` or `kubectl` CLI tools.

{{< tabs name="Deleting a subscription" default="kn" >}}
{{% tab name="kn" %}}

```
kn subscription delete <subscription_name>
```

{{< /tab >}}

{{% tab name="kubectl" %}}

```
kubectl subscription delete <subscription_name>
```

{{< /tab >}} {{< /tabs >}}
