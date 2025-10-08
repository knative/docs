---
audience: administrator
components:
  - eventing
function: how-to
---

# Knative Broker for Apache Kafka

The Knative Broker for Apache Kafka is an implementation of the Knative Broker API natively targeting Apache Kafka to reduce network hops and offering a better integration with Apache Kafka for the Broker and Trigger API model.

Notable features are:

- Control plane High Availability
- Horizontally scalable data plane
- [Extensively configurable](./configuring-kafka-features)
- Ordered delivery of events based on [CloudEvents partitioning extension](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/extensions/partitioning.md)
- Support any Kafka version, see [compatibility matrix](https://cwiki.apache.org/confluence/display/KAFKA/Compatibility+Matrix)
- Supports 2 [data plane modes](#data-plane-isolation-vs-shared-data-plane): data plane isolation per-namespace or shared data plane

The Knative Kafka Broker stores incoming CloudEvents as Kafka records, using the [binary content mode](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/bindings/kafka-protocol-binding.md#32-binary-content-mode), because it is more efficient due to its optimizations for transport or routing, as well avoid JSON parsing. Using `binary content mode` means all CloudEvent attributes and extensions are mapped as [headers on the Kafka record](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/bindings/kafka-protocol-binding.md#323-metadata-headers), while the `data` of the CloudEvent corresponds to the actual value of the Kafka record. This is another benefit of using `binary content mode` over `structured content mode` as it is less _obstructive_ and therefore compatible with systems that do not understand CloudEvents.

## Prerequisites

1. You have installed Knative Eventing.
2. You have access to an Apache Kafka cluster.

!!! tip
    If you need to set up a Kafka cluster, you can do this by following the instructions on the [Strimzi Quickstart page](https://strimzi.io/quickstarts/).

## Installation

1. Install the Kafka controller by entering the following command:

    ```bash
    kubectl apply --filename {{ artifact(org="knative-extensions", repo="eventing-kafka-broker", file="eventing-kafka-controller.yaml") }}
    ```

1. Install the Kafka Broker data plane by entering the following command:

    ```bash
    kubectl apply --filename {{ artifact(org="knative-extensions", repo="eventing-kafka-broker", file="eventing-kafka-broker.yaml") }}
    ```

1. Verify that `kafka-controller`, `kafka-broker-receiver` and `kafka-broker-dispatcher` are running,
by entering the following command:

    ```bash
    kubectl get deployments.apps -n knative-eventing
    ```

    Example output:

    ```{ .bash .no-copy }
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    eventing-controller            1/1     1            1           10s
    eventing-webhook               1/1     1            1           9s
    kafka-controller               1/1     1            1           3s
    kafka-broker-dispatcher        1/1     1            1           4s
    kafka-broker-receiver          1/1     1            1           5s
    ```

## Consumer Offsets Commit Interval

Kafka consumers keep track of the last successfully sent events by committing offsets.

Knative Kafka Broker commits the offset every `auto.commit.interval.ms` milliseconds.

!!! note
    To prevent negative impacts to performance, it is not recommended committing
    offsets every time an event is successfully sent to a subscriber.

The interval can be changed by changing the `config-kafka-broker-data-plane` `ConfigMap`
in the `knative-eventing` namespace by modifying the parameter `auto.commit.interval.ms` as follows:

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: config-kafka-broker-data-plane
  namespace: knative-eventing
data:
  # Some configurations omitted ...
  config-kafka-broker-consumer.properties: |
    # Some configurations omitted ...

    # Commit the offset every 5000 millisecods (5 seconds)
    auto.commit.interval.ms=5000
```

!!! note
    Knative Kafka Broker guarantees at least once delivery, which means that your applications may
    receive duplicate events. A higher commit interval means that there is a higher probability of
    receiving duplicate events, because when a Consumer restarts, it restarts from the last
    committed offset.

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

To change the logging level to `DEBUG`, you must:

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

### Enabling and configuring autoscaling of triggers with KEDA

To enable and configreu autoscaling of triggers referencing Kafka Brokers with KEDA, follow [the instructions here](../../eventing/configuration/keda-configuration.md).

## Additional information

- To report a bug or request a feature, open an issue in the [eventing-kafka-broker repository](https://github.com/knative-extensions/eventing-kafka-broker).
