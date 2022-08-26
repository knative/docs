# About Brokers

--8<-- "about-brokers.md"

## Event delivery

Event delivery mechanics are an implementation detail that depend on the configured
[broker class](../configuration/broker-configuration.md#broker-class-options).
Using brokers and triggers abstracts the details of event routing from the event producer and event consumer.

## Advanced use cases

For most use cases, a single broker per namespace is sufficient, but
there are several use cases where multiple brokers can simplify
architecture. For example, separate brokers for events containing Personally
Identifiable Information (PII) and non-PII events can simplify audit and access
control rules.

## Broker types

The following broker types are available for use with Knative Eventing.

### Multi-tenant channel-based broker

Knative Eventing provides a multi-tenant (MT) channel-based broker implementation that uses channels for event routing.

Before you can use the MT channel-based broker, you must install a
[channel implementation](../channels/channel-types-defaults.md).

### Alternative broker implementations

In the Knative Eventing ecosystem, alternative broker implementations are welcome as long as they respect the [broker specifications](https://github.com/knative/specs/blob/main/specs/eventing/control-plane.md#broker-lifecycle).

The following is a list of brokers provided by the community or vendors:

#### GCP broker

The GCP broker is optimized for running in GCP. For more details, refer to the [documentation](https://github.com/google/knative-gcp/blob/master/docs/install/install-gcp-broker.md).

#### Apache Kafka broker

For more information, see [Apache Kafka Broker](kafka-broker/README.md).

#### RabbitMQ broker

The RabbitMQ Broker uses [RabbitMQ](https://www.rabbitmq.com/) for its underlying implementation.
For more information, see [RabbitMQ Broker](rabbitmq-broker/README.md) or [the docs available on GitHub](https://github.com/knative-sandbox/eventing-rabbitmq).

## Additional resources

- [Brokers concept documentation](../../concepts/eventing-resources/brokers.md){target=_blank}

## Next steps

- Create an [MT channel-based broker](create-mtbroker.md).
- Configure [default broker ConfigMap settings](../configuration/broker-configuration.md).
- View the [broker specifications](https://github.com/knative/specs/blob/main/specs/eventing/overview.md#broker).
