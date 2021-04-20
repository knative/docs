---
title: "Broker types"
weight: 100
type: "docs"
showlandingtoc: "false"
aliases:
  - docs/eventing/broker/alternate
---

The following broker types are available for use with Knative Eventing.

## Multi-tenant channel-based broker

Knative Eventing provides a multi-tenant (MT) channel-based broker implementation that uses channels for event routing.

Before you can use the multi-tenant (MT) channel-based broker, you must install a [channel implementation](../channels/channel-types-defaults).

**NOTE:** InMemoryChannel channels are for development use only and must not be used in a production deployment.

## Alternative broker implementations

In the Knative Eventing ecosystem, alternative broker implementations are welcome as long as they respect the [broker specifications](https://github.com/knative/specs/blob/main/specs/eventing/broker.md).

The following is a list of brokers provided by the community or vendors:

### GCP broker

The GCP broker is optimized for running in GCP. For more details, refer to the [documentation](https://github.com/google/knative-gcp/blob/master/docs/install/install-gcp-broker.md).

### Apache Kafka broker

For information about the Apache Kafka broker, see [link](./kafka-broker).
