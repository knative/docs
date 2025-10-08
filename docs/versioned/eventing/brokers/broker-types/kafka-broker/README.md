---
audience: developer
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

These directions assume your cluster administrator has [installed the Knative Kafka broker](../../../../install/eventing/kafka-install.md).

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
  namespace: your-namespace
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

Knative supports the [full set of topic config options that your version of Kafka supports](https://kafka.apache.org/documentation/#topicconfigs). To set any of these, you need to add a key to the configmap with the `default.topic.config.` prefix.
For example, to set the `retention.ms` value you would modify the `ConfigMap` to look like the following:

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
  # Here is our retention.ms config
  default.topic.config.retention.ms: "3600"
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
- `OAUTHBEARER` for AWS MSK IAM

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

!!! note
    `ca.crt` can be omitted to fallback to use system's root CA set.

### Authentication and encryption using SSL

```bash
kubectl create secret --namespace <namespace> generic <my_secret> \
  --from-literal=protocol=SSL \
  --from-file=ca.crt=<my_caroot.pem_file_path> \
  --from-file=user.crt=<my_cert.pem_file_path> \
  --from-file=user.key=<my_key.pem_file_path>
```

### Authentication for AWS MSK IAM
AWS MSK IAM authentication requires creation of a secret and java properties configuration.

In the following ConfigMaps append the following to the listed property values. If using an assumed IAM role, add `awsRoleArn="<role_arn>"` to the `sasl.jaas.config` value.

- config-kafka-broker-data-plane
  - config-kafka-broker-producer.properties
  - config-kafka-broker-consumer.properties
- config-kafka-channel-data-plane
  - config-kafka-channel-producer.properties
  - config-kafka-channel-consumer.properties

```
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required awsStsRegion="<region>";
sasl.login.callback.handler.class=software.amazon.msk.auth.iam.IAMOAuthBearerLoginCallbackHandler
sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMOAuthBearerLoginCallbackHandler
```

Create a secret for using the default AWS credentials:

```bash
kubectl create secret --namespace <namespace> generic <my_secret> \
  --from-literal=protocol=SASL_SSL \
  --from-literal=sasl.mechanism=OAUTHBEARER \
  --from-literal=type=OAUTHBEARER \
  --from-literal=tokenProvider=MSKAccessTokenProvider
```

Or create a secret for using an assumed role:

```bash
kubectl create secret --namespace <namespace> generic <my_secret> \
  --from-literal=protocol=SASL_SSL \
  --from-literal=sasl.mechanism=OAUTHBEARER \
  --from-literal=type=OAUTHBEARER \
  --from-literal=tokenProvider=MSKRoleAccessTokenProvider \
  --from-literal=roleARN=<role_arn>
```

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

* [This page](./configuring-kafka-features) describes how producer and consumer configurations is done by modifying the `config-kafka-broker-data-plane` configmap in the `knative-eventing` namespace. Since Kafka Broker controller propagates this configmap into the user namespace, currently there is no way to configure producer and consumer configurations per namespace. Any value set in the `config-kafka-broker-data-plane` `ConfigMap` in the `knative-eventing` namespace will be also used in the user namespace.
* Because of the same propagation, it is also not possible to configure consumer offsets commit interval per namespace.
* A few more configmaps are propagated: `config-tracing` and `kafka-config-logging`. This means, tracing and logging are also not configurable per namespace.
* Similarly, the data plane deployments are propagated from the `knative-eventing` namespace to the user namespace. This means that the data plane deployments are not configurable per namespace and will be identical to the ones in the `knative-eventing` namespace.

### Enabling and configuring autoscaling of triggers with KEDA

To enable and configreu autoscaling of triggers referencing Kafka Brokers with KEDA, follow [the instructions here](../../../configuration/keda-configuration.md).

## Additional information

- To report a bug or request a feature, open an issue in the [eventing-kafka-broker repository](https://github.com/knative-extensions/eventing-kafka-broker).
