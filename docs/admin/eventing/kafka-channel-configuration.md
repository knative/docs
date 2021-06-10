# Configure Kafka Channels

!!! note
    This guide assumes Knative Eventing is installed in the `knative-eventing` namespace. If you have installed Knative Eventing in a different namespace, replace `knative-eventing` with the name of that namespace.

To use Kafka Channels, you must:

1. Install the KafkaChannel custom resource definition (CRD).
1. Create a ConfigMap that specifies default configurations for how KafkaChannel instances are created.

## Create a `kafka-channel` ConfigMap

1. Create a `kafka-channel` ConfigMap by running the command:

    ```yaml
    kubectl apply -f - <<EOF
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
    EOF
    ```

    !!! note
        This example specifies two extra parameters that are specific to Kafka Channels; `numPartitions` and `replicationFactor`.

1. Optional. To create a Broker that uses Kafka Channels, specify the `kafka-channel` ConfigMap in the Broker spec. You can do this by running the command:

    ```yaml
    kubectl apply -f - <<EOF
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
