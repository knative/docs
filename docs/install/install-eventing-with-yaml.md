---
title: "Installing Knative Eventing using YAML files"
linkTitle: "Install Eventing using YAML"
weight: 03
type: "docs"
showlandingtoc: "false"
---

# Installing Knative Eventing using YAML files

{% macro artifact(repo, file='', org='knative') -%}
    http://github.com/{{org}}/{{repo}}/releases/download/{{knative_version}}/{{file}}
{%- endmacro %}

# Install Knative Eventing using YAML files

This topic describes how to install Knative Eventing by applying YAML files using the `kubectl` CLI.

## Prerequisites

Before installation, you must meet the prerequisites.
See [Knative Prerequisites](./prerequisites.md).

## Install the Eventing component

To install the Eventing component:

1. Install the required custom resource definitions (CRDs):

    ```bash
    kubectl apply -f {{ artifact(repo="eventing",file="eventing-crds.yaml")}}
    ```

1. Install the core components of Eventing:

    ```bash
    kubectl apply -f {{ artifact(repo="eventing",file="eventing-core.yaml")}}
    ```

    !!! info
        For information about the YAML files in the Knative Serving and Eventing releases, see
        [Installation files](./installation-files.md).


## Verify the installation

Monitor the Knative components until all of the components show a `STATUS` of `Running`:

```bash
kubectl get pods --namespace knative-eventing
```


## Optional: Install a default channel (messaging) layer

The tabs below expand to show instructions for installing a default channel layer.
Follow the procedure for the channel of your choice:

<!-- This indentation is important for things to render properly. -->

=== "Apache Kafka Channel"

    1. First,
      [Install Apache Kafka for Kubernetes](../eventing/samples/kafka/README.md)

    1. Then install the Apache Kafka channel:

        ```bash
        curl -L "{{ artifact(org="knative-sandbox",repo="eventing-kafka",file="channel-consolidated.yaml")}}" \
          | sed 's/REPLACE_WITH_CLUSTER_URL/my-cluster-kafka-bootstrap.kafka:9092/' \
          | kubectl apply -f -
        ```

        !!! tip
            To learn more about the Apache Kafka channel, try
            [our sample](../eventing/samples/kafka/channel/README.md)


=== "Google Cloud Pub/Sub Channel"

    1. Install the Google Cloud Pub/Sub channel:

        ```bash
        # This installs both the Channel and the GCP Sources.
        kubectl apply -f {{ artifact(org="google",repo="knative-gcp",file="cloud-run-events.yaml")}}
        ```

        !!! tip
            To learn more about the Google Cloud Pub/Sub channel, try
            [our sample](https://github.com/google/knative-gcp/blob/master/docs/examples/channel/README.md)


=== "In-Memory (standalone)"

    The following command installs an implementation of channel that runs in-memory.
    This implementation is nice because it is simple and standalone, but it is

    ```bash
    kubectl apply -f {{ artifact(repo="eventing",file="in-memory-channel.yaml")}}
    ```

=== "NATS Channel"

    1. First, [Install NATS Streaming for
      Kubernetes](https://github.com/knative-sandbox/eventing-natss/tree/main/config)

    1. Then install the NATS Streaming channel:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-natss",file="300-natss-channel.yaml")}}
        ```

        <!-- TODO(https://github.com/knative/docs/issues/2153): Add more Channels here -->



## Optional: Install a broker layer:

The tabs below expand to show instructions for installing the broker layer.
Follow the procedure for the broker of your choice:

<!-- This indentation is important for things to render properly. -->
=== "Apache Kafka Broker"

    The following commands install the Apache Kafka broker, and run event routing in a system namespace,
    `knative-eventing`, by default.

    1. Install the Kafka controller by entering the following command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-controller.yaml")}}
        ```

    1. Install the Kafka broker data plane by entering the following command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-broker.yaml")}}
        ```

    For more information, see the [Kafka broker](./../eventing/broker/kafka-broker.md) documentation.

=== "MT-Channel-based"

    The following command installs an implementation of broker that utilizes
    channels and runs event routing components in a System Namespace, providing a
    smaller and simpler installation.

    ```bash
    kubectl apply -f {{ artifact(repo="eventing",file="mt-channel-broker.yaml")}}
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

    !!! warning
        In order to use the KafkaChannel make sure it is installed on the cluster as discussed above.


## Next steps

After installing Knative Eventing:

- To easily interact with Knative Eventing components, [install the `kn` CLI](/docs/client/install-kn.md)

- To add optional enhancements to your installation, see [Installing optional extensions](./install-extensions.md)

- [Installing Knative Serving using YAML files](./install-serving-with-yaml.md)
