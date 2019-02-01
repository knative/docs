<!--
This is a generated file and should not be changed manually. All changes should follow the
procedure:

1. Update the information in [`channels.yaml`](channels.yaml).

2. Run the generator tool:
    ```shell
    go run eventing/channels/generator/main.go
    ```
-->

Channels are Kubernetes Custom Resources which define a single event forwarding and persistence layer.
Messaging implementations may provide implementations of Channels via the
[ClusterChannelProvisioner](https://github.com/knative/eventing/blob/master/pkg/apis/eventing/v1alpha1/cluster_channel_provisioner_types.go#L35)
object, supporting different technologies, such as Apache Kafka or NATS Streaming.

This is a non-exhaustive list of Channels for Knative.


### Inclusion in this list is not an endorsement, nor does it imply any level of support.


## Channels

These are the channels `CRD`s.

Name | Status | Support | Description
--- | --- | --- | ---
[Apache Kafka](https://github.com/knative/eventing/tree/master/contrib/kafka/config) | Proof of Concept | None | Channels are backed by [Apache Kafka](http://kafka.apache.org/) topics
[GCP PubSub](https://github.com/knative/eventing/tree/master/contrib/gcppubsub/config) | Proof of Concept | None | Channels are backed by [GCP PubSub](https://cloud.google.com/pubsub/).
[In-Memory](https://github.com/knative/eventing/tree/master/config/provisioners/in-memory-channel) | Proof of Concept | None | In-memory channels are a best effort Channel. They should NOT be used in Production. They are useful for development.
[Natss](https://github.com/knative/eventing/tree/master/contrib/natss/config) | Proof of Concept | None | Channels are backed by [NATS Streaming](https://github.com/nats-io/nats-streaming-server#configuring).


