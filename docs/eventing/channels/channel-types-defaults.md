# Channel types and defaults
Knative uses two types of channels:


* A generic Channel object.
* Channel implementations that each have their own custom resource definitions (CRDs), such as
`InMemoryChannel` and `KafkaChannel`.

Custom Channel implementations each have their own event delivery mechanisms, such as in-memory
or broker-based. Examples of Brokers include KafkaBroker and the GCP Pub/Sub Broker.

Knative provides the InMemoryChannel Channel implementation by default.
This default implementation is useful for developers who do not want to configure a specific
implementation type, such as Apache Kafka or NATSS channels.

You can use the generic Channel object if you want to create a channel without specifying which channel implementation CRD is used. This is useful if you do not care about the properties a particular Channel implementation provides, such as ordering and persistence, and you want to use the implementation selected by the cluster administrator.

Cluster administrators can modify the default Channel implementation settings by editing the `default-ch-webhook` ConfigMap in the `knative-eventing` namespace.

For more information about modifying ConfigMaps, see
[Configuring the Eventing Operator custom resource](/admin/install/operator/configuring-eventing-cr).

Default channels can be configured for the cluster, a namespace on the cluster, or both.

!!! note
    If a default channel implementation is configured for a namespace, this will overwrite the configuration for the cluster.

In the following example, the cluster default channel implementation is `InMemoryChannel`, while the
namespace default channel implementation for the `example-namespace` is `KafkaChannel`.

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

- [Creating a channel using cluster or namespace defaults](/eventing/channels/create-default-channel)
