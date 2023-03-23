# Multi-tenant channel based Broker

The Multi-tenant channel based Broker (MTChannelBasedBroker) uses [channels](../../../channels) for event routing. It is shipped by default with Knative Eventing.

## Prerequisites

You need to have Knative Eventing installed.

## Install a channel implementation

As the MTChannelBasedBroker is based on Channels, you need to install a Channel implementation. Check out the [available Channels](../../../channels/channels-crds.md) for a (non-exhaustive) list of the available Channels for Knative Eventing.

You can install e.g. the in-memory channel via:

```bash
kubectl apply -f {{ artifact(repo="eventing",file="in-memory-channel.yaml")}}
```

## Create a MTChannelBasedBroker

You can create a MTChannelBasedBroker by using the `kn` CLI or by applying YAML files using `kubectl`.

=== "kn"

    1. You can create a MTChannelBasedBroker by entering the following command:

        ```bash
        kn broker create <broker-name> -n <namespace> --class MTChannelBasedBroker
        ```

        !!! note
            If you choose not to specify a namespace, the broker will be created in the current namespace

    1. Optional: Verify that the broker was created by listing existing brokers:

        ```bash
        kn broker list
        ```

    1. Optional: You can also verify the broker exists by describing the broker you have created:

        ```bash
        kn broker describe <broker-name>
        ```

=== "kubectl"

    The YAML in the following example creates a broker named `default`.

    1. Create a MTChannelBasedBroker by creating a YAML file using the following template:

        ```yaml
        apiVersion: eventing.knative.dev/v1
        kind: Broker
        metadata:
          annotations:
            eventing.knative.dev/broker.class: MTChannelBasedBroker
          name: <broker-name>
          namespace: <namespace>
        ```

        !!! note
            Note, that the broker class is specified via the `eventing.knative.dev/broker.class` annotation (as for all Broker types).

    1. Apply the YAML file:

        ```bash
        kubectl apply -f <filename>.yaml
        ```
        Where `<filename>` is the name of the file you created in the previous step.

    1. Optional: Verify that the broker is working correctly:

        ```bash
        kubectl -n <namespace> get broker <broker-name>
        ```

        This shows information about your broker. If the broker is working correctly, it shows a `READY` status of `True`:

        ```bash
        NAME      READY   REASON   URL                                                                        AGE
        default   True             http://broker-ingress.knative-eventing.svc.cluster.local/default/default   1m
        ```

        If the `READY` status is `False`, wait a few moments and then run the command again.

## Configuration

There are multiple ways to configure a Broker. You either can do the configuration on the Broker object itself or you can define some cluster and namespace default values.

### Broker specific configuration

It is possible to configure each Broker individually. This is done, by referencing a ConfigMap in the Brokers `.spec.config`:

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

This referenced ConfigMap must contain a `channel-template-spec`, defining the underlining channel implementation for this Broker and eventually some channel specific configuration. For example:

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

Or for a [Kafka Channel](../configuration/kafka-channel-configuration.md):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-kafka-channel
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

The `config-br-defaults` ConfigMap defines default values for any Broker that does not specify a `spec.config` or a Broker class. It is possible to define these defaults cluser wide or on a per namespace basis. Check the [Administrator configuration options](../../broker-admin-config-options.md) on how to set broker defaults cluster wide or on a namespace basis.

## Developer Documentation

For further information about the internals of the `MTChannelBasedBroker` and the interactions of its components, check out the [MTChannelBasedBroker developer docs](https://github.com/knative/eventing/blob/main/docs/mt-channel-based-broker/README.md)
