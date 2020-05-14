---
title: "MT Channel Based Broker"
weight: 30
type: "docs"
---

NOTE: This doc assume the shared Knative Eventing components are installed in the `knative-eventing`
namespace. If you installed the shared Knative Eventing components in a different namespace, replace
`knative-eventing` with the name of that namespace. Furthermore, you have to install the
Multi Tenant Channel Based Broker.

Knative provides a Multi Tenant `Broker` implementation that uses
[Channels](../channels/) for event routing. You will need to have a Channel provider
installed, for example InMemoryChannel (for development purposes), Kafka, Nats, etc. You can choose from
list of [available channels](https://knative.dev/docs/eventing/channels/channels-crds/)

Once you have decided which Channel(s) you want to use and have installed them, you
can configure the Broker by controlling which Channel(s) are used. You can choose
this as a cluster level default, by namespace or by a specific Broker. These are
configured by a `config-br-defaults` `ConfigMap` in knative-eventing namespace.

Here's an example of a configuration that uses Kafka channel for all the
Brokers except namespace `test-broker-6` which uses InMemoryChannels. First
define the `ConfigMap`s to describe how the Channels of each type are created:

```yaml
# Define how InMemoryChannels are created
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

```yaml
# Define how Kafka channels are created. Note we specify
# extra parameters that are particular to Kakfa Channels, namely
# numPartitions as well as replicationFactor.
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
      test-broker-6:
        apiVersion: v1
        kind: ConfigMap
        name: kafka-channel
        namespace: knative-eventing
```


## Creating Broker using defaults

To create the Broker assuming above mentioned default configuration.

```shell
kubectl apply -f - <<EOF
apiVersion: eventing.knative.dev/v1beta1
kind: Broker
metadata:
  name: mybroker
EOF
```

This creates a `Broker` named `mybroker` in the `default`
namespace. As per above configuration, it would be configured to use
InMemoryChannel.

```shell
kubectl -n default get broker mybroker
```

## Creating Broker without defaults

You can also configure all aspects of your Broker by not relying on
default behaviours, and just construct the entire object. For example,
say you wanted to create a Broker that has a different Kafka configuration.
You would first create the configuration you'd like to use, for example
let's increase the number of partitions to 10:

```shell
kubectl apply -f - <<EOF
# Define how Kafka channels are created. Note we specify
# extra parameters that are particular to Kakfa Channels, namely
# numPartitions as well as replicationFactor.
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
apiVersion: eventing.knative.dev/v1beta1
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

You can find out more about delivery spec details [here](https://knative.dev/docs/eventing/event-delivery/).
