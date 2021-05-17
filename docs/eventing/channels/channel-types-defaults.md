---
title: "Channel types and defaults"
weight: 60
type: "docs"
showlandingtoc: "true"
---

Knative provides the InMemoryChannel channel implementation by default. This default implementation is useful for developers who do not want to configure a specific implementation type, such as Apache Kafka or NATSS channels.

**NOTE:** InMemoryChannel channels should not be used in production environments.

The default channel implementation is specified in the `default-ch-webhook` ConfigMap in the `knative-eventing` namespace.
For more information about modifying ConfigMaps, see [Configuring the Eventing Operator custom resource](../../../docs/install/operator/configuring-eventing-cr).

In the following example, the cluster default channel implementation is InMemoryChannel, while the namespace default channel implementation for the `example-namespace` is KafkaChannel.

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

Default channels can be configured for the cluster, a namespace on the cluster, or both.

**NOTE:** If a default channel implementation is configured for a namespace, this will overwrite the configuration for the cluster.

## Next steps

- Create an [InMemoryChannel](/create-default-channel)
