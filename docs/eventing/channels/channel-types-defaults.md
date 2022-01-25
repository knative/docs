# Channel types and defaults

Knative uses two types of Channels:

* A generic Channel object.
* Channel implementations that each have their own custom resource definitions (CRDs), such as
InMemoryChannel and KafkaChannel. The KafkaChannel supports an ordered consumer delivery guarantee, which is a per-partition blocking consumer that waits for a successful response from the CloudEvent subscriber before it delivers the next message of the partition.

Custom Channel implementations each have their own event delivery mechanisms, such as in-memory
or Broker-based. Examples of Brokers include KafkaBroker and the GCP Pub/Sub Broker.

Knative provides the InMemoryChannel Channel implementation by default.
This default implementation is useful for developers who do not want to configure a specific
implementation type, such as Apache Kafka or NATSS Channels.

You can use the generic Channel object if you want to create a Channel without specifying which
Channel implementation CRD is used.
This is useful if you do not care about the properties a particular Channel implementation provides,
such as ordering and persistence, and you want to use the implementation selected by the cluster
administrator.


Cluster administrators can modify the default Channel implementation settings by editing the `default-ch-webhook` ConfigMap in the `knative-eventing` namespace.


For more information about modifying ConfigMaps, see
[Configuring the Eventing Operator custom resource](../../install/operator/configuring-eventing-cr.md#setting-a-default-channel).

Default Channels can be configured for the cluster, a namespace on the cluster, or both.

!!! note
    If a default Channel implementation is configured for a namespace, this will overwrite the configuration for the cluster.

In the following example, the cluster default Channel implementation is InMemoryChannel, while the
namespace default Channel implementation for the `example-namespace` is KafkaChannel.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: default-ch-webhook
  namespace: knative-eventing
data:
  default-ch-config: |
    clusterDefault:
      apiVersion: messaging.knative.dev/v1
      kind: InMemoryChannel
    namespaceDefaults:
      example-namespace:
        apiVersion: messaging.knative.dev/v1beta1
        kind: KafkaChannel
        spec:
          numPartitions: 2
          replicationFactor: 1
```


!!! note
    InMemoryChannel Channels must not be used in production environments.


## Next steps


- Create an [InMemoryChannel](create-default-channel.md)
