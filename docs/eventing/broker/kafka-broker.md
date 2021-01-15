---
title: "Apache Kafka Broker"
weight: 30
type: "docs"
---

The Apache Kafka Broker is a native Broker implementation, that reduces
network hops, supports any Kafka version, and has a better integration
with Apache Kafka for the Knative Broker and Trigger model.

Notable features are:

- Control plane High Availability
- Horizontally scalable data plane
- [Extensively configurable](#kafka-producer-and-consumer-configurations)
- Ordered delivery of events based on [CloudEvents partitioning extension](https://github.com/cloudevents/spec/blob/master/extensions/partitioning.md)
- Support any Kafka version, see [compatibility matrix](https://cwiki.apache.org/confluence/display/KAFKA/Compatibility+Matrix)

## Prerequisites

1. [Knative Eventing installation](./../../install/any-kubernetes-cluster.md#installing-the-eventing-component).
2. An Apache Kafka cluster (if you're just getting started you can follow [Strimzi Quickstart page](https://strimzi.io/quickstarts/)).

## Installation

1. Install the Kafka controller by entering the following command:

    ```bash
    kubectl apply --filename {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-controller.yaml" >}}
    ```

1. Install the Kafka Broker data plane by entering the following command:

    ```bash
    kubectl apply --filename {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-broker.yaml" >}}
    ```

2. Verify that `kafka-controller`, `kafka-broker-receiver` and `kafka-broker-dispatcher` are running,
by entering the following command:

    ```bash
    kubectl get deployments.apps -n knative-eventing
    ```

    Example output:

    ```bash
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    eventing-controller            1/1     1            1           10s
    eventing-webhook               1/1     1            1           9s
    kafka-controller               1/1     1            1           3s
    kafka-broker-dispatcher        1/1     1            1           4s
    kafka-broker-receiver          1/1     1            1           5s
    ```

## Create a Kafka Broker

A Kafka Broker object looks like this:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    # case-sensitive
    eventing.knative.dev/broker.class: Kafka
  name: default
  namespace: default
spec:
  # Configuration specific to this broker.
  config:
    apiVersion: v1
    kind: ConfigMap
    name: kafka-broker-config
    namespace: knative-eventing
  # Optional dead letter sink, you can specify either:
  #  - deadLetterSink.ref, which is a reference to a Callable
  #  - deadLetterSink.uri, which is an absolute URI to a Callable (It can potentially be out of the Kubernetes cluster)
  delivery:
    deadLetterSink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: dlq-service
```

`spec.config` should reference any `ConfigMap` that looks like the following:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-broker-config
  namespace: knative-eventing
data:
  # Number of topic partitions
  default.topic.partitions: "10"
  # Replication factor of topic messages.
  default.topic.replication.factor: "1"
  # A comma separated list of bootstrap servers. (It can be in or out the k8s cluster)
  bootstrap.servers: "my-cluster-kafka-bootstrap.kafka:9092"
```

The above `ConfigMap` is installed in the cluster. You can edit
the configuration or create a new one with the same values
depending on your needs.

## Set as default broker implementation

To set the Kafka broker as the default implementation for all brokers in the Knative deployment,
you can apply global settings by modifying the `config-br-defaults` ConfigMap in the `knative-eventing` namespace.

This allows you to avoid configuring individual or per-namespace settings for each broker,
such as `metadata.annotations.eventing.knative.dev/broker.class` or `spec.config`.

The following YAML is an example of a `config-br-defaults` ConfigMap using Kafka broker as the default implementation.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    clusterDefault:
      brokerClass: Kafka
      apiVersion: v1
      kind: ConfigMap
      name: kafka-broker-config
      namespace: knative-eventing
    namespaceDefaults:
      namespace1:
        brokerClass: Kafka
        apiVersion: v1
        kind: ConfigMap
        name: kafka-broker-config
        namespace: knative-eventing
      namespace2:
        brokerClass: Kafka
        apiVersion: v1
        kind: ConfigMap
        name: kafka-broker-config
        namespace: knative-eventing
```

## Kafka Producer and Consumer configurations

Knative exposes all available Kafka producer and consumer configurations that can be modified to suit your workloads.

You can change these configurations by modifying the `config-kafka-broker-data-plane` `ConfigMap` in
the `knative-eventing` namespace.

Documentation for the settings available in this `ConfigMap` is available on the
[Apache Kafka website](https://kafka.apache.org/documentation/),
in particular, [Producer configurations](https://kafka.apache.org/documentation/#producerconfigs)
and [Consumer configurations](https://kafka.apache.org/documentation/#consumerconfigs).

## Enable debug logging for data plane components

The following YAML shows the default logging configuration for data plane components, that is created during the
installation step:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-config-logging
  namespace: knative-eventing
data:
  config.xml: |
    <configuration>
      <appender name="jsonConsoleAppender" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
      </appender>
      <root level="INFO">
        <appender-ref ref="jsonConsoleAppender"/>
      </root>
    </configuration>
```

To change the logging level to `DEBUG`, you need to: 

1. Apply the following `kafka-config-logging` `ConfigMap` or replace `level="INFO"` with `level="DEBUG"` to the
`ConfigMap` `kafka-config-logging`:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: kafka-config-logging
      namespace: knative-eventing
    data:
      config.xml: |
        <configuration>
          <appender name="jsonConsoleAppender" class="ch.qos.logback.core.ConsoleAppender">
            <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
          </appender>
          <root level="DEBUG">
            <appender-ref ref="jsonConsoleAppender"/>
          </root>
        </configuration>
    ```

2. Restart the `kafka-broker-receiver` and the `kafka-broker-dispatcher`, by entering the following commands:

    ```bash
    kubectl rollout restart deployment -n knative-eventing kafka-broker-receiver
    kubectl rollout restart deployment -n knative-eventing kafka-broker-dispatcher
    ```

### Additional information

- To report bugs or add feature requests, open an issue in the [eventing-kafka-broker repository](https://github.com/knative-sandbox/eventing-kafka-broker).
