# Knative Sink for Apache Kafka

The `KafkaSink` is an Apache Kafka-native [Sink implementation](https://knative.dev/docs/eventing/sinks/) persisting the incoming CloudEvent to a configurable Apache Kafka Topic. This page shows how to install and configure the Knative `KafkaSink`.

## Prerequisites

You must have access to a Kubernetes cluster with [Knative Eventing installed](../../install/yaml-install/eventing/install-eventing-with-yaml.md).

## Installation

1. Install the Kafka controller:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-controller.yaml") }}
    ```

1. Install the KafkaSink data plane:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-sink.yaml") }}
    ```

1. Verify that `kafka-controller` and `kafka-sink-receiver` Deployments are running:

    ```bash
    kubectl get deployments.apps -n knative-eventing
    ```

    Example output:

    ```{ .bash .no-copy }
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    eventing-controller            1/1     1            1           10s
    eventing-webhook               1/1     1            1           9s
    kafka-controller               1/1     1            1           3s
    kafka-sink-receiver            1/1     1            1           5s
    ```

## KafkaSink example

A KafkaSink object looks similar to the following:

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

## Output Topic Content Mode

The CloudEvent specification defines 2 modes to transport a CloudEvent: structured and binary.

> A "structured-mode message" is one where the event is fully encoded using a stand-alone event
> format and stored in the message body.
>
> The structured content mode keeps event metadata and data together in the payload, allowing
> simple forwarding of the same event across multiple routing hops, and across multiple protocols.
>
> A "binary-mode message" is one where the event data is stored in the message body, and event
> attributes are stored as part of message meta-data.
>
> The binary content mode accommodates any shape of event data, and allows for efficient transfer
> and without transcoding effort.

A KafkaSink object with a specified `contentMode` looks similar to the following:

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

  # CloudEvent content mode of Kafka messages sent to the topic.
  # Possible values:
  # - structured
  # - binary
  #
  # default: binary.
  #
  # CloudEvent spec references:
  # - https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#message
  #	- https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/bindings/kafka-protocol-binding.md#33-structured-content-mode
  #	- https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/bindings/kafka-protocol-binding.md#32-binary-content-mode
  contentMode: binary # or structured
```

## Security

Knative supports the following Apache Kafka security features:

- [Authentication using `SASL` without encryption](#authentication-using-sasl)
- [Authentication using `SASL` and encryption using `SSL`](#authentication-using-sasl-and-encryption-using-ssl)
- [Authentication and encryption using `SSL`](#authentication-and-encryption-using-ssl)
- [Encryption using `SSL` without client authentication](#encryption-using-ssl-without-client-authentication)

## Enabling security features

To enable security features, in the KafkaSink spec, you can reference a secret:

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
   auth:
     secret:
       ref:
         name: my_secret
```

!!! note
    The secret `my_secret` must exist in the same namespace of the KafkaSink. Certificates and keys must be in [`PEM` format](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail)._

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
    The `ca.crt` can be omitted to enable fallback and use the system's root CA set.

## Kafka Producer configurations

A Kafka Producer is the component responsible for sending events to the Apache Kafka cluster. You can change the configuration for Kafka Producers in your cluster by modifying the `config-kafka-sink-data-plane` ConfigMap in the `knative-eventing` namespace.

Documentation for the settings available in this ConfigMap is available on the
[Apache Kafka website](https://kafka.apache.org/documentation/),
in particular, [Producer configurations](https://kafka.apache.org/documentation/#producerconfigs).

<!--TODO: move the configmap info to admin guide?-->

## Enable debug logging for data plane components

To enable debug logging for data plane components change the logging level to `DEBUG` in the `kafka-config-logging` ConfigMap.

1. Create the `kafka-config-logging` ConfigMap as a YAML file that contains the following:

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

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

2. Restart the `kafka-sink-receiver`:

    ```bash
    kubectl rollout restart deployment -n knative-eventing kafka-sink-receiver
    ```
