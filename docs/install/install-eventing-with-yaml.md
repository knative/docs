---
title: "Installing Knative Eventing using YAML files"
linkTitle: "Install Eventing using YAML"
weight: 03
type: "docs"
showlandingtoc: "false"
---

This topic describes how to install Knative Eventing by applying YAML files using the `kubectl` CLI.

When installing Knative, you can install the Serving component, Eventing component, or both on your cluster.
For how to install the Serving component, see [Installing Serving using YAML files](./install-serving-with-yaml.md)

## Prerequisites

Before installation, you must meet the prerequisites.
See [Knative Prerequisites](./prerequisites.md).


## Install the Eventing component

To install the Eventing component:

1. Install the required custom resource definitions (CRDs):

   ```bash
   kubectl apply -f {{< artifact repo="eventing" file="eventing-crds.yaml" >}}
   ```

1. Install the core components of Eventing:

   ```bash
   kubectl apply -f {{< artifact repo="eventing" file="eventing-core.yaml" >}}
   ```


## Verify the installation

Monitor the Knative components until all of the components show a `STATUS` of `Running`:

```bash
kubectl get pods --namespace knative-eventing
```


## Optional: Install a default channel (messaging) layer

The tabs below expand to show instructions for installing a default channel layer.
Follow the procedure for the channel of your choice:

<!-- This indentation is important for things to render properly. -->

   {{< tabs name="eventing_channels" default="In-Memory (standalone)" >}}
   {{% tab name="Apache Kafka Channel" %}}

1. First,
   [Install Apache Kafka for Kubernetes](../eventing/samples/kafka/README.md)

1. Then install the Apache Kafka channel:

   ```bash
   curl -L "{{< artifact org="knative-sandbox" repo="eventing-kafka" file="channel-consolidated.yaml" >}}" \
    | sed 's/REPLACE_WITH_CLUSTER_URL/my-cluster-kafka-bootstrap.kafka:9092/' \
    | kubectl apply -f -
   ```

To learn more about the Apache Kafka channel, try
[our sample](../eventing/samples/kafka/channel/README.md)

{{< /tab >}}

{{% tab name="Google Cloud Pub/Sub Channel" %}}

1. Install the Google Cloud Pub/Sub channel:

   ```bash
   # This installs both the Channel and the GCP Sources.
   kubectl apply -f {{< artifact org="google" repo="knative-gcp" file="cloud-run-events.yaml" >}}
   ```

To learn more about the Google Cloud Pub/Sub channel, try
[our sample](https://github.com/google/knative-gcp/blob/master/docs/examples/channel/README.md)

{{< /tab >}}

{{% tab name="In-Memory (standalone)" %}}

The following command installs an implementation of channel that runs in-memory.
This implementation is nice because it is simple and standalone, but it is
unsuitable for production use cases.

```bash
kubectl apply -f {{< artifact repo="eventing" file="in-memory-channel.yaml" >}}
```

{{< /tab >}}

{{% tab name="NATS Channel" %}}

1. First, [Install NATS Streaming for
   Kubernetes](https://github.com/knative-sandbox/eventing-natss/tree/main/config)

1. Then install the NATS Streaming channel:

   ```bash
   kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-natss" file="300-natss-channel.yaml" >}}
   ```

{{< /tab >}}

<!-- TODO(https://github.com/knative/docs/issues/2153): Add more Channels here -->

{{< /tabs >}}


## Optional: Install a broker layer:

The tabs below expand to show instructions for installing the broker layer.
Follow the procedure for the broker of your choice:

<!-- This indentation is important for things to render properly. -->
   {{< tabs name="eventing_brokers" default="MT-Channel-based" >}}
   {{% tab name="Apache Kafka Broker" %}}

The following commands install the Apache Kafka broker, and run event routing in a system namespace,
`knative-eventing`, by default.

1. Install the Kafka controller by entering the following command:

    ```bash
    kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-controller.yaml" >}}
    ```

1. Install the Kafka broker data plane by entering the following command:

    ```bash
    kubectl apply -f {{< artifact org="knative-sandbox" repo="eventing-kafka-broker" file="eventing-kafka-broker.yaml" >}}
    ```

For more information, see the [Kafka broker](./../eventing/broker/kafka-broker.md) documentation.
{{< /tab >}}

   {{% tab name="MT-Channel-based" %}}

The following command installs an implementation of broker that utilizes
channels and runs event routing components in a System Namespace, providing a
smaller and simpler installation.

```bash
kubectl apply -f {{< artifact repo="eventing" file="mt-channel-broker.yaml" >}}
```

To customize which broker channel implementation is used, update the following
ConfigMap to specify which configurations are used for which namespaces:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    # This is the cluster-wide default broker channel.
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: imc-channel
      namespace: knative-eventing
    # This allows you to specify different defaults per-namespace,
    # in this case the "some-namespace" namespace will use the Kafka
    # channel ConfigMap by default (only for example, you will need
    # to install kafka also to make use of this).
    namespaceDefaults:
      some-namespace:
        brokerClass: MTChannelBasedBroker
        apiVersion: v1
        kind: ConfigMap
        name: kafka-channel
        namespace: knative-eventing
```

The referenced `imc-channel` and `kafka-channel` example ConfigMaps would look
like:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: imc-channel
  namespace: knative-eventing
data:
  channelTemplateSpec: |
    apiVersion: messaging.knative.dev/v1
    kind: InMemoryChannel
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-channel
  namespace: knative-eventing
data:
  channelTemplateSpec: |
    apiVersion: messaging.knative.dev/v1alpha1
    kind: KafkaChannel
    spec:
      numPartitions: 3
      replicationFactor: 1
```

**NOTE:** In order to use the KafkaChannel make sure it is installed on the cluster as discussed above.

{{< /tab >}}

{{< /tabs >}}


## Next steps

After installing Knative Eventing:

- If you want to add extra features to your installation, see [Installing optional extensions](./install-extensions.md).
- If you want to install the Knative Serving component, see [Installing Serving using YAML files](./install-serving-with-yaml.md)
