# Installing Knative Eventing using YAML files

This topic describes how to install Knative Eventing by applying YAML files using the `kubectl` CLI.

--8<-- "prerequisites.md"

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
        For information about the YAML files in Knative Eventing, see [Description Tables for YAML Files](eventing-installation-files.md).

## Verify the installation

!!! success "Monitor the Knative components until all of the components show a `STATUS` of `Running` or `Completed`:"

    ```{ .bash .no-copy }
    kubectl get pods --namespace knative-eventing
    ```


## Optional: Install a default channel (messaging) layer

The tabs below expand to show instructions for installing a default channel layer.
Follow the procedure for the channel of your choice:

<!-- This indentation is important for things to render properly. -->

=== "Apache Kafka Channel"

    1. First,
      [Install Apache Kafka for Kubernetes](../../../eventing/samples/kafka/README.md)

    1. Then install the Apache Kafka Channel:

        ```bash
        curl -L "{{ artifact(org="knative-sandbox",repo="eventing-kafka",file="channel-consolidated.yaml")}}" \
          | sed 's/REPLACE_WITH_CLUSTER_URL/my-cluster-kafka-bootstrap.kafka:9092/' \
          | kubectl apply -f -
        ```

        !!! tip
            To learn more, try the [Apache Kafka channel sample](../../../eventing/samples/kafka/channel/README.md).

=== "Google Cloud Pub/Sub Channel"

    1. Install the Google Cloud Pub/Sub channel:

        ```bash
        # This installs both the Channel and the GCP Sources.
        kubectl apply -f {{ artifact(org="google",repo="knative-gcp",file="cloud-run-events.yaml")}}
        ```

        !!! tip
            To learn more, try the [Google Cloud Pub/Sub channel sample](https://github.com/google/knative-gcp/blob/master/docs/examples/channel/README.md).


=== "In-Memory (standalone)"

    The following command installs an implementation of channel that runs in-memory.
    This implementation is nice because it is simple and standalone, but it is unsuitable for production use cases.

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

    For more information, see the [Kafka broker](../../../eventing/broker/kafka-broker/README.md) documentation.

=== "MT-Channel-based"

    The following command installs an implementation of broker that utilizes
    channels and runs event routing components in a System Namespace, providing a smaller and simpler installation.

    ```bash
    kubectl apply -f {{ artifact(repo="eventing",file="mt-channel-broker.yaml")}}
    ```

    To customize which broker channel implementation is used, update the following ConfigMap to specify which configurations are used for which namespaces:

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

    The referenced `imc-channel` and `kafka-channel` example ConfigMaps would look like:

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

=== "RabbitMQ Broker"

    You can install the RabbitMQ broker by following the instructions in the
    [RabbitMQ Knative Eventing Broker README](https://github.com/knative-sandbox/eventing-rabbitmq/tree/main/broker).

    For more information, see the [RabbitMQ broker](https://github.com/knative-sandbox/eventing-rabbitmq) in GitHub.

## Install optional Eventing extensions

The tabs below expand to show instructions for installing each Eventing extension.
<!-- This indentation is important for things to render properly. -->

=== "Apache Kafka Sink"

    1. Install the Kafka controller:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-controller.yaml")}}
        ```

    1. Install the Kafka Sink data plane:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-sink.yaml")}}
        ```

    For more information, see the [Kafka Sink](../../../developer/eventing/sinks/kafka-sink.md) documentation.

=== "Sugar Controller"

    <!-- Unclear when this feature came in -->

    The following command installs the Eventing Sugar Controller:

    ```bash
    kubectl apply -f {{ artifact(repo="eventing",file="eventing-sugar-controller.yaml")}}
    ```

    The Knative Eventing Sugar Controller will react to special labels and
    annotations and produce Eventing resources. For example:

    - When a Namespace is labeled with `eventing.knative.dev/injection=enabled`, the
      controller will create a default broker in that namespace.
    - When a Trigger is annotated with `eventing.knative.dev/injection=enabled`, the
      controller will create a Broker named by that Trigger in the Trigger's
      Namespace.

    The following command enables the default Broker on a namespace (here
    `default`):

    ```bash
    kubectl label namespace default eventing.knative.dev/injection=enabled
    ```

=== "Github Source"

    The following command installs the single-tenant Github source:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-github",file="github.yaml")}}
    ```

    The single-tenant GitHub source creates one Knative service per GitHub source.

    The following command installs the multi-tenant GitHub source:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-github",file="mt-github.yaml")}}
    ```

    The multi-tenant GitHub source creates only one Knative service handling all
    GitHub sources in the cluster. This source does not support logging or tracing
    configuration yet.

    To learn more, try the [Github source sample](../../../eventing/samples/github-source/README.md)

=== "Apache Kafka Source"

    The following command installs the Apache Kafka Source:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka",file="source.yaml")}}
    ```

    To learn more, try the [Apache Kafka source sample](../../../developer/eventing/sources/kafka-source/README.md).


=== "GCP Sources"

    The following command installs the GCP Sources:

    ```bash
    # This installs both the Sources and the Channel.
    kubectl apply -f {{ artifact(org="google",repo="knative-gcp",file="cloud-run-events.yaml")}}
    ```

    To learn more, try the following:

    - [Cloud Pub/Sub source sample](../../../eventing/samples/cloud-pubsub-source/README.md)
    - [Cloud Storage source sample](../../../eventing/samples/cloud-storage-source/README.md)
    - [Cloud Scheduler source sample](../../../eventing/samples/cloud-scheduler-source/README.md)
    - [Cloud Audit Logs source sample](../../../eventing/samples/cloud-audit-logs-source/README.md)


=== "Apache CouchDB Source"

    The following command installs the Apache CouchDB Source:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-couchdb",file="couchdb.yaml")}}
    ```

    To learn more, read the [Apache CouchDB source](https://github.com/knative-sandbox/eventing-couchdb/blob/main/source/README.md) documentation.

=== "VMware Sources and Bindings"

    The following command installs the VMware Sources and Bindings:

    ```bash
    kubectl apply -f {{ artifact(org="vmware-tanzu",repo="sources-for-knative",file="release.yaml")}}
    ```

    To learn more, try the [VMware sources and bindings samples](https://github.com/vmware-tanzu/sources-for-knative/tree/master/samples/README.md).
