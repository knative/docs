---
title: "MT Channel Based Broker"
weight: 30
type: "docs"
---

Knative provides a Multi Tenant (MT) Broker implementation that uses
[channels](../channels/) for event routing.

## Before you begin

Before you can use the MT Broker, you will need to have a channel provider
installed, for example, InMemoryChannel (for development purposes), Kafka or
Nats.

For more information on which channels are available and how to install them,
see the list of [available channels](https://knative.dev/docs/eventing/channels/channels-crds/). 

After you have installed the channel provider that will be used by MT Broker,
you must create a ConfigMap which specifies how to configure the channels that
the Broker creates for routing events.

**NOTE:** This guide assumes Knative Eventing is installed in the `knative-eventing`
namespace. If you have installed Knative Eventing in a different namespace, replace
`knative-eventing` with the name of that namespace.

## Configure Channel ConfigMaps

You can define specifications for how each type of channel will be created, by
modifying the ConfigMap for each channel type.

<!-- TODO: Split these configmaps out and document them properly in a section for each channel, then just link from here-->

### Example InMemoryChannel ConfigMap

When you install the eventing release, the following YAML file is created automatically:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: knative-eventing
  name: config-br-default-channel
data:
  channelTemplateSpec: |
    apiVersion: messaging.knative.dev/v1
    kind: InMemoryChannel
```

To create a Broker that uses InMemoryChannel, you could create a Broker like
this:

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
  name: default
  namespace: default
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
EOF
```

And the broker will use InMemoryChannel for routing events.

### Example Kafka Channel ConfigMap

To use Kafka channels, you must create a YAML file that specifies how these
channels will be created. **NOTE:** You must have Kafka Channel installed.

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

**NOTE:** This example specifies two extra parameters that are specific to Kafka
Channels; `numPartitions` and `replicationFactor`. 

To create a Broker that uses Kafka underneath, you would do it like this:

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
  name: kafka-backed-broker
  namespace: default
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: kafka-channel
    namespace: knative-eventing
EOF
```
