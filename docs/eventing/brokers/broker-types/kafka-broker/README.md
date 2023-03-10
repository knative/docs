# Knative Broker for Apache Kafka

The Knative Broker for Apache Kafka is an implementation of the Knative Broker API natively targeting Apache Kafka to reduce network hops and offering a better integration with Apache Kafka for the Broker and Trigger API model.

Notable features are:

- Control plane High Availability
- Horizontally scalable data plane
- [Extensively configurable](#kafka-producer-and-consumer-configurations)
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
    kubectl apply --filename {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-controller.yaml") }}
    ```

1. Install the Kafka Broker data plane by entering the following command:

    ```bash
    kubectl apply --filename {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-broker.yaml") }}
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

## Create a Kafka Broker

A Kafka Broker object looks like this:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    # case-sensitive
    eventing.knative.dev/broker.class: Kafka
    # Optional annotation to point to an externally managed kafka topic:
    # kafka.eventing.knative.dev/external.topic: <topic-name>
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

### Configure a Kafka Broker

The `spec.config` should reference any `ConfigMap` in any `namespace` that looks like the following:

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
  default.topic.replication.factor: "3"
  # A comma separated list of bootstrap servers. (It can be in or out the k8s cluster)
  bootstrap.servers: "my-cluster-kafka-bootstrap.kafka:9092"
```

This `ConfigMap` is installed in the Knative Eventing `SYSTEM_NAMESPACE` in the cluster. You can edit
the global configuration depending on your needs. You can also override these settings on a
per broker base, by referencing a different `ConfigMap` on a different `namespace` or with a
different `name` on your Kafka Broker's `spec.config` field.

!!! note
    The `default.topic.replication.factor` value must be less than or equal to the number of Kafka broker instances in your cluster. For example, if you only have one Kafka broker, the `default.topic.replication.factor` value should not be more than `1`.

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

## Security

Apache Kafka supports different security features, Knative supports the followings:

- [Authentication using `SASL` without encryption](#authentication-using-sasl)
- [Authentication using `SASL` and encryption using `SSL`](#authentication-using-sasl-and-encryption-using-ssl)
- [Authentication and encryption using `SSL`](#authentication-and-encryption-using-ssl)
- [Encryption using `SSL` without client authentication](#encryption-using-ssl-without-client-authentication)

To enable security features, in the `ConfigMap` referenced by `broker.spec.config`, we can reference a `Secret`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
   name: kafka-broker-config
   namespace: knative-eventing
data:
   # Other configurations
   # ...

   # Reference a Secret called my_secret
   auth.secret.ref.name: my_secret
```

The `Secret` `my_secret` must exist in the same namespace of the `ConfigMap` referenced by `broker.spec.config`,
in this case: `knative-eventing`.

!!! note
    Certificates and keys must be in [`PEM` format](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail).

### Authentication using SASL

Knative supports the following SASL mechanisms:

- `PLAIN`
- `SCRAM-SHA-256`
- `SCRAM-SHA-512`

To use a specific SASL mechanism replace `<sasl_mechanism>` with the mechanism of your choice.

### Authentication using SASL without encryption

```bash
kubectl create secret --namespace <namespace> generic <my_secret> \
  --from-literal=protocol=SASL_PLAINTEXT \
  --from-literal=sasl.mechanism=<sasl_mechanism> \
  --from-literal=user=<my_user> \
  --from-literal=password=<my_password>
```

### Authentication using SASL and encryption using SSL

```bash
kubectl create secret --namespace <namespace> generic <my_secret> \
  --from-literal=protocol=SASL_SSL \
  --from-literal=sasl.mechanism=<sasl_mechanism> \
  --from-file=ca.crt=caroot.pem \
  --from-literal=user=<my_user> \
  --from-literal=password=<my_password>
```

### Encryption using SSL without client authentication

```bash
kubectl create secret --namespace <namespace> generic <my_secret> \
  --from-literal=protocol=SSL \
  --from-file=ca.crt=<my_caroot.pem_file_path> \
  --from-literal=user.skip=true
```

### Authentication and encryption using SSL

```bash
kubectl create secret --namespace <namespace> generic <my_secret> \
  --from-literal=protocol=SSL \
  --from-file=ca.crt=<my_caroot.pem_file_path> \
  --from-file=user.crt=<my_cert.pem_file_path> \
  --from-file=user.key=<my_key.pem_file_path>
```

!!! note
    `ca.crt` can be omitted to fallback to use system's root CA set.

## Bring your own topic

By default the Knative Kafka Broker creates its own internal topic, however it is possible to point to an externally managed topic, using the `kafka.eventing.knative.dev/external.topic` annotation:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    # case-sensitive
    eventing.knative.dev/broker.class: Kafka
    kafka.eventing.knative.dev/external.topic: <my-topic-name>
  name: default
  namespace: default
spec:
  # other spec fields ...
```

!!! note
    When using an external topic, the Knative Kafka Broker does not own the topic and is not responsible for managing the topic. This includes the topic lifecycle or its general validity. Other restrictions for general access to the topic may apply. See the documentation about using [Access Control Lists (ACLs)](https://kafka.apache.org/documentation/#security_authz).

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

## Data plane Isolation vs Shared Data plane

Knative Kafka Broker implementation has 2 planes: control plane and data plane. Control plane consists of controllers that talk to Kubernetes API, watch for custom objects and manage the data plane.

Data plane is the collection of components that listen for incoming events, talk to Apache Kafka and also sends events to the event sinks. This is where the events flow. Knative Kafka Broker data plane consists of `kafka-broker-receiver` and `kafka-broker-dispatcher` deployments.

When using the Broker class `Kafka`, the Knative Kafka Broker uses a shared data plane. That means, `kafka-broker-receiver` and `kafka-broker-dispatcher` deployments in `knative-eventing` namespace is used for all Kafka Brokers in the cluster.

However, when `KafkaNamespaced` is set as the Broker class, Kafka broker controller creates a new data plane for each namespace that there is a broker exists. This data plane is used by all `KafkaNamespaced` brokers in that namespace.

That provides isolation between the data planes, which means that the `kafka-broker-receiver` and `kafka-broker-dispatcher` deployments in the user namespace are only used for the broker in that namespace.

!!! note
    As a consequence of separate data planes, this security feature creates more deployments and uses more resources. Unless you have such isolation requirements, it is recommended to go with *regular* Broker with `Kafka` class.

To create a `KafkaNamespaced` broker, you must set the `eventing.knative.dev/broker.class` annotation to `KafkaNamespaced`:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    # case-sensitive
    eventing.knative.dev/broker.class: KafkaNamespaced
  name: default
  namespace: my-namespace
spec:
  config:
     # the referenced `configmap` must be in the same namespace with the `Broker` object, in this case `my-namespace`
    apiVersion: v1
    kind: ConfigMap
    name: my-config
    # namespace: my-namespace # no need to define, defaults to Broker's namespace
```

!!! note
    The `configmap` that is specified in `spec.config` **must** be in the same namespace with the `Broker` object:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
  namespace: my-namespace
data:
  ...
```

Upon the creation of the first `Broker` with `KafkaNamespaced` class, the `kafka-broker-receiver` and `kafka-broker-dispatcher` deployments are created in the namespace. After that, all the brokers with `KafkaNamespaced` class in the same namespace use the same data plane. When there are no brokers of `KafkaNamespaced` class in the namespace, the data plane in the namespace will be deleted.

### Configuring `KafkaNamespaced` brokers

All the configuration mechanisms that are available for the `Kafka` Broker class are also available for the brokers with `KafkaNamespaced` class with these exceptions:

* [Above](#kafka-producer-and-consumer-configurations) it is described how producer and consumer configurations is done by modifying the `config-kafka-broker-data-plane` configmap in the `knative-eventing` namespace. Since Kafka Broker controller propagates this configmap into the user namespace, currently there is no way to configure producer and consumer configurations per namespace. Any value set in the `config-kafka-broker-data-plane` `ConfigMap` in the `knative-eventing` namespace will be also used in the user namespace.
* Because of the same propagation, it is also not possible to configure consumer offsets commit interval per namespace.
* A few more configmaps are propagated: `config-tracing` and `kafka-config-logging`. This means, tracing and logging are also not configurable per namespace.
* Similarly, the data plane deployments are propagated from the `knative-eventing` namespace to the user namespace. This means that the data plane deployments are not configurable per namespace and will be identical to the ones in the `knative-eventing` namespace.

## Additional information

- To report a bug or request a feature, open an issue in the [eventing-kafka-broker repository](https://github.com/knative-sandbox/eventing-kafka-broker).
