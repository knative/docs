---
title: "Kafka Channel ConfigMap"
weight: 30
type: "docs"
---

# Kafka Channel ConfigMap

**NOTE:** This guide assumes Knative Eventing is installed in the `knative-eventing`
namespace. If you have installed Knative Eventing in a different namespace, replace
`knative-eventing` with the name of that namespace.

To use Kafka channels, you must create a YAML file that specifies how these
channels will be created.

**NOTE:** You must install the Kafka Channel first.

You can copy the following sample code into your `kafka-channel` ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-channel
  namespace: knative-eventing
data:
  channelTemplateSpec: |
    apiVersion: messaging.knative.dev/v1beta1
    kind: KafkaChannel
    spec:
      numPartitions: 3
      replicationFactor: 1
```

**NOTE:** This example specifies two extra parameters that are specific to Kafka
Channels; `numPartitions` and `replicationFactor`.

To create a Broker that uses the KafkaChannel, specify the `kafka-channel` ConfigMap:

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
