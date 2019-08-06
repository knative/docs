---
title: "Available Channels CRDs"
linkTitle: "Channels CRDs"
weight: 40
type: "docs"
---

<!--
This is a generated file and should not be changed manually. All changes should follow the
procedure:

1. Update the information in [`channels.yaml`](channels.yaml).

2. Run the generator tool:
    ```shell
    go run eventing/channels/generator/main.go
    ```
-->

This is a non-exhaustive list of Channels `CRD`s for Knative.

Notes:

* Inclusion in this list is not an endorsement, nor does it imply any level of
  support.

* Cluster Channel Provisioner (CCP) has been deprecated and will be
  unsupported in v0.9. You should now use the Channels CRDs.

Name | Status | Support | Description
--- | --- | --- | ---
[CCP - Apache Kafka](https://github.com/knative/eventing-contrib/tree/master/kafka/channel/config/provisioner) | Proof of Concept | None | Deprecated: Channels are backed by [Apache Kafka](http://kafka.apache.org/) topics.
[CCP - GCP PubSub](https://github.com/knative/eventing/tree/master/contrib/gcppubsub/config) | Proof of Concept | None | Deprecated: Channels are backed by [GCP PubSub](https://cloud.google.com/pubsub/).
[CCP - In-Memory](https://github.com/knative/eventing/tree/master/config/provisioners/in-memory-channel) | Proof of Concept | None | Deprecated: In-memory channels are a best effort Channel. They should NOT be used in Production. They are useful for development.
[CCP - Natss](https://github.com/knative/eventing/tree/master/contrib/natss/config/provisioner) | Proof of Concept | None | Deprecated: Channels are backed by [NATS Streaming](https://github.com/nats-io/nats-streaming-server#configuring).
[CRD - InMemoryChannel](https://github.com/knative/eventing/tree/master/config/channels/in-memory-channel) | Proof of Concept | None | In-memory channels are a best effort Channel. They should NOT be used in Production. They are useful for development.
[CRD - KafkaChannel](https://github.com/knative/eventing-contrib/tree/master/kafka/channel/config) | Proof of Concept | None | Channels are backed by [Apache Kafka](http://kafka.apache.org/) topics.
[CRD - NatssChannel](https://github.com/knative/eventing/tree/master/contrib/natss/config) | Proof of Concept | None | Channels are backed by [NATS Streaming](https://github.com/nats-io/nats-streaming-server#configuring).


