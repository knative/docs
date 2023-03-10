# Available Broker types

The following broker types are available for use with Knative Eventing.

## Multi-tenant channel-based broker

Knative Eventing provides a multi-tenant (MT) channel-based broker implementation that uses channels for event routing.

Before you can use the MT channel-based broker, you must install a channel implementation.

## Alternative broker implementations

In the Knative Eventing ecosystem, alternative broker implementations are welcome as long as they respect the [broker specifications](https://github.com/knative/specs/blob/main/specs/eventing/control-plane.md#broker-lifecycle).

The following is a list of brokers provided by the community or vendors:

### Knative Broker for Apache Kafka

This broker implementation uses [Apache Kafka](https://kafka.apache.org/) as its backing technology. For more information, see [here](kafka-broker/README.md).

### RabbitMQ broker

The RabbitMQ Broker uses [RabbitMQ](https://www.rabbitmq.com/) for its underlying implementation.
For more information, see [RabbitMQ Broker](rabbitmq-broker/README.md) or [the docs available on GitHub](https://github.com/knative-sandbox/eventing-rabbitmq).
