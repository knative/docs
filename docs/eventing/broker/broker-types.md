---
title: "Broker types"
weight: 02
type: "docs"
showlandingtoc: "false"
aliases:
  - docs/eventing/broker/alternate
---

The following broker types are supported for use with Knative Eventing.

## Multi-tenant channel-based broker

Knative provides a default multi-tenant, channel-based broker implementation that uses channels for event routing.
<!--TODO: explain how channels are used for routing-->

Before you can use the Knative Channel-based Broker, you must install a channel provider, such as InMemoryChannel, Kafka or Nats.

**NOTE:** InMemoryChannel channels are for development use only and must not be used in a production deployment.

For more information on which channels are available and how to install them,
see the list of [available channels](https://knative.dev/docs/eventing/channels/channels-crds/).

## Alternative broker implementations

In the Knative Eventing ecosystem, alternate Broker implementations are welcome as long as they
respect the [Broker Conformance Spec](https://github.com/knative/eventing/blob/main/docs/spec/broker.md).

Below is a list of brokers provided by the community or vendors in addition to the default broker
implementations provided by Knative Eventing.

### GCP Broker

The GCP Broker is optimized for running in GCP. For more details, refer to the [doc](https://github.com/google/knative-gcp/blob/master/docs/install/install-gcp-broker.md).

### Apache Kafka Broker

For information about the Apache Kafka broker, see [link](../kafka-broker.md).
