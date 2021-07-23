---
title: "Brokers"
weight: 60
type: "docs"
showlandingtoc: "false"
aliases:
  - docs/eventing/broker/alternate
---

# Brokers

Brokers are Kubernetes [custom resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) that define an event mesh for collecting a pool of [CloudEvents](https://cloudevents.io/). Brokers provide a discoverable endpoint, `status.address`, for event ingress, and triggers for event delivery. Event producers can send events to a broker by POSTing the event to the `status.address.url` of the broker.

Event delivery mechanics are an implementation detail that depend on the configured [broker class](configmaps#broker-class-options). Using brokers and triggers abstracts the details of event routing from the event producer and event consumer.

<img src="images/broker-workflow.svg" width="70%">

After an event has entered a broker, it can be forwarded to subscribers by using triggers. Triggers allow events to be filtered by attributes, so that events with particular attributes can be sent to subscribers that have registered interest in events with those attributes.

A subscriber can be any URL or _Addressable_ resource. Subscribers can also reply to an active request from the broker, and can respond with a new CloudEvent that will be sent back into the broker.

For most use cases, a single broker per namespace is sufficient, but
there are several use cases where multiple brokers can simplify
architecture. For example, separate brokers for events containing Personally
Identifiable Information (PII) and non-PII events can simplify audit and access
control rules.

## Broker types

The following broker types are available for use with Knative Eventing.

### Multi-tenant channel-based broker

Knative Eventing provides a multi-tenant (MT) channel-based broker implementation that uses channels for event routing.

Before you can use the MT channel-based broker, you must install a [channel implementation](../channels/channel-types-defaults).

### Alternative broker implementations

In the Knative Eventing ecosystem, alternative broker implementations are welcome as long as they respect the [broker specifications](https://github.com/knative/specs/blob/main/specs/eventing/broker.md).

The following is a list of brokers provided by the community or vendors:

#### GCP broker

The GCP broker is optimized for running in GCP. For more details, refer to the [documentation](https://github.com/google/knative-gcp/blob/master/docs/install/install-gcp-broker.md).

#### Apache Kafka broker

For information about the Apache Kafka broker, see [link](kafka-broker).

#### RabbitMQ broker

The RabbitMQ Broker uses [RabbitMQ](https://www.rabbitmq.com/) for its underlying implementation. For more information, see the [RabbitMQ broker](https://github.com/knative-sandbox/eventing-rabbitmq) in GitHub.

## Next steps

- Create a [MT channel-based broker](create-mtbroker).
- Configure [default broker ConfigMap settings](configmaps/).
- View the [broker specifications](https://github.com/knative/specs/blob/main/specs/eventing/broker.md).
