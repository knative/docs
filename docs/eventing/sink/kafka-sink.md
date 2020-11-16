---
title: "Apache Kafka Sink"
weight: 30
type: "docs"
---

This page shows how to install and configure Apache Kafka Sink.

## Prerequisites

[Knative Eventing installation](./../../install/any-kubernetes-cluster.md#installing-the-eventing-component).

## Installation

1. Install the Kafka controller:

    ```bash
    kubectl apply --filename {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-controller.yaml" >}}
    ```

1. Install the Kafka Sink data plane:

    ```bash
    kubectl apply --filename {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-sink.yaml" >}}
    ```

1. Verify that `kafka-controller` and `kafka-sink-receiver` are running:

    ```bash
    kubectl get deployments.apps -n knative-eventing
    ```

    Example output:

    ```bash
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    eventing-controller            1/1     1            1           10s
    eventing-webhook               1/1     1            1           9s
    kafka-controller               1/1     1            1           3s
    kafka-sink-receiver            1/1     1            1           5s
    ```

## Kafka Sink

A Kafka Sink object looks like this:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: KafkaSink
metadata:
  name: my-kafka-sink
  namespace: default
spec:
  topic: mytopic
  bootstrapServers:
   - my-cluster-kafka-bootstrap.kafka:9092
```

## Kafka Producer configurations

A Kafka Producer is the component responsible for sending events to the Apache Kafka cluster.
Knative exposes all available Kafka Producer configurations that can be modified to suit your workloads.

You can change these configurations by modifying the `config-kafka-sink-data-plane` `ConfigMap` in
the `knative-eventing` namespace.

Documentation for the settings available in this `ConfigMap` is available on the
[Apache Kafka website](https://kafka.apache.org/documentation/),
in particular, [Producer configurations](https://kafka.apache.org/documentation/#producerconfigs).

## Enable debug logging for data plane components

To enable debug logging for data plane components change the logging level to `DEBUG` in the `kafka-config-logging` ConfigMap.

1. Apply the following `kafka-config-logging` ConfigMap:

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

2. Restart the `kafka-sink-receiver`:

    ```bash
    kubectl rollout restart deployment -n knative-eventing kafka-sink-receiver
    ```

### Additional information

- To report bugs or add feature requests, open an issue in the [eventing-kafka-broker repository](https://github.com/knative-sandbox/eventing-kafka-broker).
