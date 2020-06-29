---
title: "MT Channel Based Broker"
weight: 30
type: "docs"
---

Knative provides a Multi Tenant (MT) Broker implementation that uses [channels](../channels/) for
event routing.

## Before you begin

Before you can use the MT Broker, you will need to have a channel provider installed, for example, InMemoryChannel (for development purposes), Kafka or Nats.

For more information on which channels are available, see the list of [available channels](https://knative.dev/docs/eventing/channels/channels-crds/).

After you have installed the channel provider that you will use in your broker implementation, you must configure the ConfigMap for each channel type.

**NOTE:** This guide assumes Knative Eventing is installed in the `knative-eventing`
namespace. If you have installed Knative Eventing in a different namespace, replace
`knative-eventing` with the name of that namespace.

## Configure Channel ConfigMaps

You can define specifications for how each type of channel will be created, by modifying the ConfigMap for each channel type.

<!-- TODO: Split these configmaps out and document them properly in a section for each channel, then just link from here-->

### Example InMemoryChannel ConfigMap

When you install the InMemoryChannel Channel provider, the following YAML file is created automatically:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: knative-eventing
  name: imc-channel
data:
  channelTemplateSpec: |
    apiVersion: messaging.knative.dev/v1beta1
    kind: InMemoryChannel
```

### Example Kafka Channel ConfigMap

To use Kafka channels, you must create a YAML file that specifies how these channels will be created.

You can copy the following sample code into your Kafka channel ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-channel
  namespace: knative-eventing
data:
  channelTemplateSpec: |
    apiVersion: messaging.knative.dev/v1alpha1
    kind: KafkaChannel
    spec:
      numPartitions: 3
      replicationFactor: 1
```

**NOTE:** This example specifies two extra parameters that are specific to Kafka Channels; `numPartitions` and `replicationFactor`.

## Configuring the MT broker

After you have configured the ConfigMap for each Channel provider type, you can configure the MT Broker.

Channels can be configured as a cluster level default, by namespace, or for a specific broker.

The channels used by the MT broker can be configured in the `config-br-defaults` ConfigMap in the `knative-eventing` namespace.

The following example ConfigMap uses a Kafka channel for all brokers, except for the `example-ns` namespace, which uses InMemoryChannel.

### Example `config-br-defaults` ConfigMap

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: imc-channel
      namespace: knative-eventing
    namespaceDefaults:
      brokerClass: MTChannelBasedBroker
      example-ns:
        apiVersion: v1
        kind: ConfigMap
        name: kafka-channel
        namespace: knative-eventing
```

## Creating the MT broker using default configurations

To create the MT broker using the default configuration, use the command:

```shell
kubectl apply -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: mybroker
EOF
```

This creates a broker named `mybroker`,  which is configured to use
InMemoryChannel, in the `default`
namespace.

```shell
kubectl -n default get broker mybroker
```

## Creating a custom MT broker using custom configurations

You can construct a custom broker object to suit your use case, without using the default configurations.

For example, to create a broker that has a different Kafka configuration, you can create a custom configuration as shown in the example.
In this example, the number of partitions has been increased to 10.

```shell
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-kafka-channel
  namespace: my-namespace
data:
  channelTemplateSpec: |
    apiVersion: messaging.knative.dev/v1alpha1
    kind: KafkaChannel
    spec:
      numPartitions: 10
      replicationFactor: 1
EOF
```

```shell
kubectl apply -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: my-other-broker
  namespace: my-namespace
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: my-kafka-channel
    namespace: my-namespace
EOF
```
