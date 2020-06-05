---
title: "MT Channel Based Broker"
weight: 30
type: "docs"
---

Knative provides a Multi Tenant (MT) Broker implementation that uses [Channels](../channels/) for
event routing.

**NOTE:** This guide assumes Knative Eventing is installed in the `knative-eventing`
namespace. If you have installed Knative Eventing in a different namespace, replace
`knative-eventing` with the name of that namespace.

## Before you begin

Before you can use the MT Broker, you will need to have a Channel provider installed, for example, InMemoryChannel (for development purposes), Kafka or Nats.
For more information on which Channels are available, see the list of [available Channels](https://knative.dev/docs/eventing/channels/channels-crds/).

After you have installed the Channel provider that you will use in your Broker implementation, you must configure the ConfigMap for each Channel type.

## Configure Channel ConfigMaps

In the ConfigMap for each type of Channel that you will use, you must define the specifications for how each type of Channel will be created.

### Example InMemoryChannel ConfigMap

When you install the InMemoryChannel Channel provider, the following YAML file will be created automatically:

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

To use Kafka Channels, you must create a YAML file that specifies how these Channels will be created.
You can copy the following sample code into your Kafka Channel ConfigMap:

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

**NOTE:** This example specifies two extra parameters that are specific to Kakfa Channels; `numPartitions` and `replicationFactor`.

## Configuring the MT Broker

After you have configured the ConfigMap for each Channel provider type, you can configure the MT Broker.
You can configure which Channels are used as a cluster level default, by namespace or for a specific Broker.
The Channels used are configured by a `config-br-defaults` ConfigMap in the `knative-eventing` namespace.

The following example ConfigMap uses a Kafka channel for all Brokers, except for the `test-broker-6` namespace,  which uses InMemoryChannel.

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

## Creating Broker by Annotation

## Installing Broker by Annotation

The easiest way to get Broker installed, is to annotate your namespace
(replace `default` with the desired namespace):

```shell
kubectl label namespace default knative-eventing-injection=enabled
```

This will automatically create a `Broker` named `default` in the `default`
namespace. As per above configuration, it would be configured to use Kafka
channels.

```shell
kubectl -n default get broker default
```

_NOTE_ `Broker`s created due to annotation will not be removed if you remove the
annotation. For example, if you annotate the namespace, which will then create
the `Broker` as described above. If you now remove the annotation, the `Broker`
will not be removed, you have to manually delete it.

For example, to delete the injected Broker from the foo namespace:

```shell
kubectl -n foo delete broker default
```

## Creating Broker by Trigger Annotation

Besides the annotation of the namespace, there is an alternative approach to annotate
one of the Triggers, with `knative-eventing-injection: enabled`:

```yaml
apiVersion: eventing.knative.dev/v1beta1
kind: Trigger
metadata:
  annotations:
    knative-eventing-injection: enabled
  name: testevents-trigger0
  namespace: default
spec:
  broker: default
  filter:
    attributes:
      type: dev.knative.sources.ping
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: broker-display
```

However, this approach only works _if_ the `Trigger` is coupled to the default `Broker`, and takes only effect
when there is no default `Broker` already present.

Deleting the `Trigger` does not delete the `Broker`. With this approach the same rules from the
[namespace annotation](./#installing-broker-by-annotation) apply here.


You can find out more about delivery spec details [here](https://knative.dev/docs/eventing/event-delivery/).
