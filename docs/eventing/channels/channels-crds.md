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

!!! note
    Inclusion in this list is not an endorsement, nor does it imply any level of support.

Name | Status | Maintainer | Description
--- | --- | --- | ---
[InMemoryChannel](https://github.com/knative/eventing/tree/{{ branch }}/config/channels/in-memory-channel/README.md) | Stable | Knative | In-memory channels are a best effort Channel. They should NOT be used in Production. They are useful for development.
[KafkaChannel](https://github.com/knative-sandbox/eventing-kafka-broker/tree/{{ branch }}/README.md) | Beta | Knative | Channels are backed by [Apache Kafka](http://kafka.apache.org/) topics.
[NatssChannel](https://github.com/knative-sandbox/eventing-natss/tree/{{ branch }}/config/README.md) | Alpha | Knative | Channels are backed by [NATS Streaming](https://github.com/nats-io/nats-streaming-server#configuring).


