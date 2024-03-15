# Available Broker types

The following broker types are available for use with Knative Eventing.

## Channel-based broker

Knative Eventing provides a [Channel based Broker](./channel-based-broker/README.md) implementation that uses Channels for event routing.

Before you can use the Channel based Broker, you must install a Channel implementation.

## Alternative broker implementations

In the Knative Eventing ecosystem, alternative Broker implementations are welcome as long as they respect the [Broker specifications](https://github.com/knative/specs/blob/main/specs/eventing/control-plane.md#broker-lifecycle).

The following is a list of Brokers provided by the community or vendors:

### Knative Broker for Apache Kafka

This Broker implementation uses [Apache Kafka](https://kafka.apache.org/) as its backing technology. For more information, see the [Knative Broker for Apache Kafka](./kafka-broker/README.md) documentation.

### RabbitMQ broker

The RabbitMQ Broker uses [RabbitMQ](https://www.rabbitmq.com/) for its underlying implementation.
For more information, see [RabbitMQ Broker](./rabbitmq-broker/README.md) or [the docs available on GitHub](https://github.com/knative-extensions/eventing-rabbitmq).
