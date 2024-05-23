# Developer configuration options

## Broker configuration example

The following is a full example of a Channel based Broker object which shows the possible configuration options that you can modify:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: default
  namespace: default
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
  delivery:
    deadLetterSink:
      ref:
        kind: Service
        namespace: example-namespace
        name: example-service
        apiVersion: v1
      uri: example-uri
    retry: 5
    backoffPolicy: exponential
    backoffDelay: "2007-03-01T13:00:00Z/P1Y2M10DT2H30M"
```

- You can specify any valid `name` for your broker. Using `default` will create a broker named `default`.
- The `namespace` must be an existing namespace in your cluster. Using `default` will create the broker in the `default` namespace.
- You can set the `eventing.knative.dev/broker.class` annotation to change the class of the broker. The default broker class is `MTChannelBasedBroker`, but Knative also supports use of the `Kafka` and `RabbitMQBroker` broker class. For more information see the [Apache Kafka Broker](../brokers/broker-types/kafka-broker/README.md) or [RabbitMQ Broker](../brokers/broker-types/rabbitmq-broker/README.md) documentation.
- `spec.config` is used to specify the default backing channel configuration for Channel based Broker implementations. For more information on configuring the default channel type, see the documentation on [Configure Broker defaults](../configuration/broker-configuration.md).
- `spec.delivery` is used to configure event delivery options. Event delivery options specify what happens to an event that fails to be delivered to an event sink. For more information, see the documentation on [Event delivery](../event-delivery.md).


## Broker class options

When a Broker is created without a specified `eventing.knative.dev/broker.class` annotation, the default `MTChannelBasedBroker` Broker class is used, as specified by default in the `config-br-defaults` ConfigMap. 

In case you have multiple Broker classes installed in your cluster and want to use a non-default Broker class for a Broker, you can modify the `eventing.knative.dev/broker.class` annotation and `spec.config` for the Broker object.

1. Set the `eventing.knative.dev/broker.class` annotation. Replace `MTChannelBasedBroker` in the following example with the class type you want to use. Be aware that the Broker class annoation is immutable and thus can't be updated after the Broker got created:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
      annotations:
        eventing.knative.dev/broker.class: MTChannelBasedBroker
      name: default
      namespace: default
    ```

1. Configure the `spec.config` with the details of the ConfigMap that defines the required configuration for the Broker class (e.g. with some Channel configurations in case of the `MTChannelBasedBroker`):

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
      annotations:
        eventing.knative.dev/broker.class: MTChannelBasedBroker
      name: default
      namespace: default
    spec:
      config:
        apiVersion: v1
        kind: ConfigMap
        name: config-br-default-channel
        namespace: knative-eventing
    ```

For further information about configuring a default Broker class cluster wide or on a per namespace basis, check the [Administrator configuration options](../configuration/broker-configuration.md#configuring-the-broker-class).
