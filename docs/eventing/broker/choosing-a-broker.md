# Choosing a broker type

- How to choose the right broker for your application? Identifying needs?
- Requirements for different broker types?
- Per namespace or per cluster?
- Delivery options?
- Integrations / event types / producers / sources - best brokers for different external systems?

For most use cases, a single broker per namespace is sufficient, but
there are several use cases where multiple brokers can simplify
architecture. For example, separate brokers for events containing Personally
Identifiable Information (PII) and non-PII events can simplify audit and access
control rules.

## Multi-tenant channel-based broker

Knative Eventing provides a multi-tenant (MT) channel-based broker implementation that uses channels for event routing.

Before you can use the MT channel-based broker, you must install a
[channel implementation](../channels/channel-types-defaults.md).

## Alternative broker implementations

In the Knative Eventing ecosystem, alternative broker implementations are welcome as long as they respect the [broker specifications](https://github.com/knative/specs/blob/main/specs/eventing/control-plane.md#broker-lifecycle).

The following is a list of brokers provided by the community or vendors:

### Apache Kafka broker

For more information, see [Apache Kafka Broker](kafka-broker/README.md).

### RabbitMQ broker

The RabbitMQ Broker uses [RabbitMQ](https://www.rabbitmq.com/) for its underlying implementation.
For more information, see [RabbitMQ Broker](rabbitmq-broker/README.md) or [the docs available on GitHub](https://github.com/knative-sandbox/eventing-rabbitmq).
