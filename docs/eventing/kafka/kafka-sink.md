# KafkaSink

This page shows how to install and configure a KafkaSink.

**KafkaSink example:**

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
# ...
```

## Prerequisites

- You have installed Knative Eventing.
- You have installed Knative Kafka.

## Installation

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
