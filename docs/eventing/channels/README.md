
Channels are Kubernetes Custom Resources that define a single event forwarding
and persistence layer in Knative.
Messaging implementations provide implementations of Channels via the
[ClusterChannelProvisioner](https://github.com/knative/eventing/blob/master/pkg/apis/eventing/v1alpha1/cluster_channel_provisioner_types.go#L35)
object, and support different technologies, such as Apache Kafka or NATS
Streaming.

Note: Cluster Channel Provisioner (CCP) has been deprecated and will be
unsupported in v0.9. You should now use the Channels CRDs.
