# Channel based Broker

The Channel based Broker (`MTChannelBasedBroker`) uses [Channels](../../../channels) for event routing. It is shipped by default with Knative Eventing.
Users should prefer native Broker implementations (like [Knative Broker for Apache Kafka](../kafka-broker/README.md) or [RabbitMQ Broker](../rabbitmq-broker/README.md)) over the MTChannelBasedBroker and Channel combination because it is usually more efficient as they reduce network hops for example. 
## Prerequisites

* You have Knative Eventing installed.
* You have a Channel implementation installed.

  As the MTChannelBasedBroker is based on Channels, you need to install a Channel implementation. Check out the [available Channels](../../../channels/channels-crds.md) for a (non-exhaustive) list of the available Channels for Knative Eventing.

  You can install for example the InMemory Channel by running the following command:
  
  ```bash
  kubectl apply -f {{ artifact(repo="eventing",file="in-memory-channel.yaml")}}
  ```

## Create a MTChannelBasedBroker

You can create a MTChannelBasedBroker by using the `kn` CLI or by applying YAML files using `kubectl`.

=== "kn"

    You can create a MTChannelBasedBroker by entering the following command:

    ```bash
    kn broker create <broker-name> --class MTChannelBasedBroker
    ```
    Where `<broker-name>` is the name of your Broker.

=== "kubectl"

    The YAML in the following example creates a Broker.

    1. Create a MTChannelBasedBroker by creating a YAML file using the following template:

        ```yaml
        apiVersion: eventing.knative.dev/v1
        kind: Broker
        metadata:
          annotations:
            eventing.knative.dev/broker.class: MTChannelBasedBroker
          name: <broker-name>
        ```
        Where `<broker-name>` is the name of your Broker.
  
        !!! note
            Note, that the Broker class is specified via the `eventing.knative.dev/broker.class` annotation.

    1. Apply the YAML file:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

## Configuration

You configure the Broker object itself, or you can define cluster or namespace default values.

### Broker specific configuration

It is possible to configure each Broker individually by referencing a ConfigMap in the `spec.config`:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
  name: default
spec:
  # Configuration specific to this broker.
  config:
    apiVersion: v1
    kind: ConfigMap
    name: my-broker-specific-configuration
    namespace: default
```

<a name="configuration-configmap"></a>The referenced ConfigMap must contain a `channel-template-spec` that defines the underlining Channel implementation for this Broker, as well as some Channel specific configurations. For example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-broker-specific-configuration
  namespace: default
data:
  channel-template-spec: |
    apiVersion: messaging.knative.dev/v1
    kind: InMemoryChannel
```

[Kafka Channel](../../../configuration/kafka-channel-configuration.md) configuration example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-channel
  namespace: knative-eventing
data:
  channel-template-spec: |
    apiVersion: messaging.knative.dev/v1beta1
    kind: KafkaChannel
    spec:
      numPartitions: 3
      replicationFactor: 1
```

### Broker default configuration

The `config-br-defaults` ConfigMap defines default values for any Broker that does not specify a `spec.config` or a Broker class. It is possible to define these defaults cluser wide or on a per namespace basis. Check the [Administrator configuration options](../../../configuration/broker-configuration.md) on how to set Broker defaults cluster wide or on a namespace basis.

## Developer documentation

For more information about `MTChannelBasedBroker`, see the [MTChannelBasedBroker developer documentation](https://github.com/knative/eventing/blob/main/docs/mt-channel-based-broker/README.md).
