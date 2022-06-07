# Apache Kafka Channel Example

You can install and configure the Apache Kafka Channel as the
default Channel configuration for Knative Eventing.

## Prerequisites

- A Kubernetes cluster with
  [Knative Eventing](https://knative.dev/docs/install/eventing/install-eventing-with-yaml), as well as the optional Broker and Kafka Channel components.

## Creating a Kafka Channel

1. Create a Kafka Channel that contains the following YAML:

    ```yaml
    apiVersion: messaging.knative.dev/v1beta1
    kind: KafkaChannel
    metadata:
      name: my-kafka-channel
    spec:
      numPartitions: 3
      replicationFactor: 1
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

## Specifying Kafka as the default Channel implementation
<!--TODO: Move to admin guide-->

1. To configure Kafka Channel as the [default channel configuration](https://knative.dev/docs/eventing/channels/channel-types-defaults), modify the `default-ch-webhook` ConfigMap so that it contains the following YAML:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: default-ch-webhook
      namespace: knative-eventing
    data:
      # Configuration for defaulting channels that do not specify CRD implementations.
      default-ch-config: |
        clusterDefault:
          apiVersion: messaging.knative.dev/v1beta1
          kind: KafkaChannel
          spec:
            numPartitions: 3
            replicationFactor: 1
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

    Where `<filename>` is the name of the file you created in the previous step.

## Creating an Apache Kafka channel

1. After `KafkaChannel` is set as the default Channel type, you can create a Kafka Channel by creating a generic Channel object that contains the following YAML:

    ```yaml
    apiVersion: messaging.knative.dev/v1
    kind: Channel
    metadata:
      name: testchannel-one
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

    Where `<filename>` is the name of the file you created in the previous step.

1. Verify that the Channel was created properly by checking that your Kafka cluster has a `testchannel-one` Topic. If you are using Strimzi, you can run the command:

    ```bash
    kubectl -n kafka exec -it my-cluster-kafka-0 -- bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --list
    ```

    The output looks similar to the following:

    ```bash
    ...
    __consumer_offsets
    knative-messaging-kafka.default.testchannel-one
    ...
    ```

    The Kafka Topic that is created by the Channel contains the name of the namespace, `default` in this example, followed by the name of the Channel.

**Note:** The topic of a Kafka Channel is an implementation detail and records from it should not be consumed from different applications.

## Creating a Service and Trigger that use the Apache Kafka Broker

The following example uses a ApiServerSource to publish events to an existing Broker, and a Trigger that routes those events to a Knative Service.
<!--TODO: Not sure this example makes sense, why would you have an event source AND channels?-->

1. Create a Knative Service:

    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: broker-kafka-display
    spec:
      template:
        spec:
          containers:
          - image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

    Where `<filename>` is the name of the file you created in the previous step.

1. Create a ServiceAccount, ClusterRole, and ClusterRoleBinding for the ApiServerSource:

    ```yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: events-sa
      namespace: default

    ---

    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: event-watcher
    rules:
    - apiGroups:
      - ""
      resources:
      - events
      verbs:
      - get
      - list
      - watch

    ---

    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: k8s-ra-event-watcher
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: event-watcher
    subjects:
    - kind: ServiceAccount
      name: events-sa
      namespace: default
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

    Where `<filename>` is the name of the file you created in the previous step.

1. Create an ApiServerSource that sends events to the default Broker:

    ```yaml
    apiVersion: sources.knative.dev/v1
    kind: ApiServerSource
    metadata:
      name: testevents-kafka-03
      namespace: default
    spec:
      serviceAccountName: events-sa
      mode: Resource
      resources:
      - apiVersion: v1
        kind: Event
      sink:
        ref:
          apiVersion: eventing.knative.dev/v1
          kind: Broker
          name: default
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

    Where `<filename>` is the name of the file you created in the previous step.

1. Create a Trigger that filters events from the Broker to the Service:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
      name: testevents-trigger
      namespace: default
    spec:
      broker: default
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: broker-kafka-display
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

    Where `<filename>` is the name of the file you created in the previous step.

1. Verifying the Kafka Channel is working, by observing events in the log of the Service, by running the command:

    ```bash
    kubectl logs --selector='serving.knative.dev/service=broker-kafka-display' -c user-container
    ```

## Channel configuration

KafkaChannel provides various configuration options, such as:

- Authentication

- Encryption

- Kafka Topic default values (number of partitions, replication factor, and
  retention time)

- The brokers string for your Kafka connection

For detailed information on configuration options, see the
[KafkaChannel README](https://github.com/knative-sandbox/eventing-kafka-broker/blob/main/docs/channel/README.md).
