# Configuring Kafka Features

There are many different configuration options for how Knative Eventing and the Kafka Broker interact with Apache Kafka.

## Configure Knative Eventing Kafka features

There are various kafka features/default values the Knative Kafka Broker uses when interacting with Kafka.

### Dispatcher rate limiter

By default, there will be no rate limiting applied as events are dispatched from the data-plane. However, if you would like to enable rate limiting based on the number of
virtual replicas, you can set `dispatcher.rate-limiter: "enabled"` in the config map below.

### Dispatcher ordered execution metrics

By default, only a subset of availabe metrics are collected from the data-plane event dispatcher. If you would like to enable additional metrics to track the ordered execution,
you can set `dispatcher.ordered-executor-metrics: "enabled"` in the config map below.

### Controller autoscaler

By default, the controller will not autoscale the resources being used by the Kafka consumers within the data-plane. If you would like to enable autoscaling of these
resources with [KEDA](https://keda.sh/), then you can set `controller.autoscaler: "enabled"` in the config map below.

### Consumer Group ID

By default, the consumer group ID of each Kafka consumer created in the data-plane from a trigger will be made from the template `{% raw %}"knative-trigger-{{ .Namespace }}-{{ .Name }}{% endraw %}`.
If you want to assign consumer group IDs to your triggers in a different way, you can set use any valid [go text/template](https://pkg.go.dev/text/template) text template
to generate the consumer group IDs by setting `triggers.consumergroup.template: "your-text-template-here"` in the config map below.

### Broker topic template

By default, the topic created by a Kafka Broker is named from the template `{% raw %}knative-broker-{{ .Namespace }}-{{ .Name }}{% endraw %}`. If you want to change the template
used to name Broker topics, you can set `brokers.topic.template: "your-text-template-here"`, where `"your-text-template-here"` is any valid [go text/template](https://pkg.go.dev/text/template)
in the config map below.

## Channel topic template

By default, the topic created by a Kafka Channel is named from the template `{% raw %}messaging-kafka.{{ .Namespace }}.{{ .Name }}"`. If you want to change the template
used to name Channel topics, you can set `channels.topic.template: "your-text-template-here"`, where `"your-text-template-here"` is any valid [go text/template](https://pkg.go.dev/text/template)
in the config map below.


```yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: config-kafka-features
    namespace: knative-eventing
    data:
        # Controls whether the dispatcher should use the rate limiter based on the number of virtual replicas.
        # 1. Enabled: The rate limiter is applied.
        # 2. Disabled: The rate limiter is not applied.
        dispatcher.rate-limiter: "disabled"
        
        # Controls whether the dispatcher should record additional metrics.
        # 1. Enabled: The metrics are recorded.
        # 2. Disabled: The metrics are not recorded.
        dispatcher.ordered-executor-metrics: "disabled"
        
        # Controls whether the controller should autoscale consumer resources with KEDA
        # 1. Enabled: KEDA autoscaling of consumers will be setup.
        # 2. Disabled: KEDA autoscaling of consumers will not be setup.
        controller.autoscaler: "disabled"{% raw %}
        
        # The Go text/template used to generate consumergroup ID for triggers.
        # The template can reference the trigger Kubernetes metadata only.
        triggers.consumergroup.template: "knative-trigger-{{ .Namespace }}-{{ .Name }}"
        
        # The Go text/template used to generate topics for Brokers.
        # The template can reference the broker Kubernetes metadata only.
        brokers.topic.template: "knative-broker-{{ .Namespace }}-{{ .Name }}"
        
        # The Go text/template used to generate topics for Channels.
        # The template can reference the channel Kubernetes metadata only.
        channels.topic.template: "messaging-kafka.{{ .Namespace }}.{{ .Name }}"
        {% endraw %}
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

## Configuring the order of delivered events

When dispatching events, the Kafka broker can be configured to support different delivery ordering guarantees.

You can configure the delivery order of events using the `kafka.eventing.knative.dev/delivery.order` annotation on the `Trigger` object:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
  annotations:
     kafka.eventing.knative.dev/delivery.order: ordered
spec:
  broker: my-kafka-broker
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

The supported consumer delivery guarantees are:

* `unordered`:  An unordered consumer is a non-blocking consumer that delivers messages unordered, while preserving proper offset management. Useful when there is a high demand of parallel consumption and no need for explicit ordering. One example could be processing of click analytics.
* `ordered`: An ordered consumer is a per-partition blocking consumer that waits for a successful response from the CloudEvent subscriber before it delivers the next message of the partition. Useful when there is a need for more strict ordering or if there is a relationship or grouping between events. One example could be processing of customer orders.

The `unordered` delivery is the default ordering guarantee.
