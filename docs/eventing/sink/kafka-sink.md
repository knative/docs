---
title: "Apache Kafka Sink"
weight: 30
type: "docs"
---

# Apache Kafka Sink

This page shows how to install and configure Apache Kafka Sink.

## Prerequisites

You must have a Kubernetes cluster with [Knative Eventing installed](../../../admin/install/).

## Installation

1. Install the Kafka controller:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-controller.yaml") }}
    ```

1. Install the Kafka Sink data plane:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-sink.yaml") }}
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

A `KafkaSink` object looks like this:

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

## Security

Apache Kafka supports different security features, Knative supports the followings:

- [Authentication using `SASL` without encryption](#authentication-using-sasl)
- [Authentication using `SASL` and encryption using `SSL`](#authentication-using-sasl-and-encryption-using-ssl)
- [Authentication and encryption using `SSL`](#authentication-and-encryption-using-ssl)
- [Encryption using `SSL` without client authentication](#encryption-using-ssl-without-client-authentication)

To enable security features, in the `KafkaSink` spec, we can reference a `Secret`:

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

The `Secret` `my_secret` must exist in the same namespace of the `KafkaSink`, in this case: `default`.

_Note: Certificates and keys must be in [`PEM` format](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail)._

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

_NOTE: `ca.crt` can be omitted to fallback to use system's root CA set._

## Kafka Producer configurations

A Kafka Producer is the component responsible for sending events to the Apache Kafka cluster.
Knative exposes all available Kafka Producer configurations that can be modified to suit your workloads.

You can change these configurations by modifying the `config-kafka-sink-data-plane` config map in
the `knative-eventing` namespace.

Documentation for the settings available in this config map is available on the
[Apache Kafka website](https://kafka.apache.org/documentation/),
in particular, [Producer configurations](https://kafka.apache.org/documentation/#producerconfigs).

## Enable debug logging for data plane components

To enable debug logging for data plane components change the logging level to `DEBUG` in the `kafka-config-logging` config map.

1. Apply the following `kafka-config-logging` config map:

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
