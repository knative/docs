---
title: "Available Channels"
#linkTitle: "Channels"
weight: 100
type: "docs"
---

# Available Channels

<!--
This is a generated file and should not be changed manually. All changes should follow the
procedure:

1. Update the information in [`channels.yaml`](channels.yaml).

2. Run the generator tool:
    ```bash
    go run eventing/channels/generator/main.go
    ```
-->

This is a non-exhaustive list of the available Channels for Knative Eventing.

Notes:

* Inclusion in this list is not an endorsement, nor does it imply any level of
  support.

Name | Status | Support | Description
--- | --- | --- | ---
[GCP PubSub](https://github.com/google/knative-gcp) | Proof of Concept | None | Channels are backed by [GCP PubSub](https://cloud.google.com/pubsub/).
[InMemoryChannel](https://github.com/knative/eventing/tree/{{ branch }}/config/channels/in-memory-channel/README.md) | Proof of Concept | None | In-memory channels are a best effort Channel. They should NOT be used in Production. They are useful for development.
[KafkaChannel - Consolidated](https://github.com/knative-sandbox/eventing-kafka/tree/{{ branch }}/pkg/channel/consolidated/README.md) | Proof of Concept | None | Channels are backed by [Apache Kafka](http://kafka.apache.org/) topics. The original Knative KafkaChannel implementation which utilizes a single combined Kafka Producer / Consumer deployment.
[KafkaChannel - Distributed](https://github.com/knative-sandbox/eventing-kafka/tree/{{ branch }}/pkg/channel/distributed/README.md) | Proof of Concept | None | Channels are backed by [Apache Kafka](http://kafka.apache.org/) topics. An alternate KafkaChannel implementation, contributed by SAP's [Kyma](https://kyma-project.io/) project, which provides a more granular deployment of Producers / Consumers.
[NatssChannel](https://github.com/knative-sandbox/eventing-natss/tree/{{ branch }}/config/README.md) | Proof of Concept | None | Channels are backed by [NATS Streaming](https://github.com/nats-io/nats-streaming-server#configuring).
