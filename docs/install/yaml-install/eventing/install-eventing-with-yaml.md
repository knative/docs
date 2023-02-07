# Installing Knative Eventing using YAML files

This topic describes how to install Knative Eventing by applying YAML files using the `kubectl` CLI.

--8<-- "prerequisites.md"
--8<-- "security-prereqs-images.md"

## Install Knative Eventing

To install Knative Eventing:

1. Install the required custom resource definitions (CRDs) by running the command:

    ```bash
    kubectl apply -f {{ artifact(repo="eventing",file="eventing-crds.yaml")}}
    ```

1. Install the core components of Eventing by running the command:

    ```bash
    kubectl apply -f {{ artifact(repo="eventing",file="eventing-core.yaml")}}
    ```

    !!! info
        For information about the YAML files in Knative Eventing, see [Description Tables for YAML Files](eventing-installation-files.md).

## Verify the installation

!!! success
    Monitor the Knative components until all of the components show a `STATUS` of `Running` or `Completed`.
    You can do this by running the following command and inspecting the output:

    ```bash
    kubectl get pods -n knative-eventing
    ```

    Example output:

    ```{ .bash .no-copy }
    NAME                                   READY   STATUS    RESTARTS   AGE
    eventing-controller-7995d654c7-qg895   1/1     Running   0          2m18s
    eventing-webhook-fff97b47c-8hmt8       1/1     Running   0          2m17s
    ```

## Optional: Install a default Channel (messaging) layer

The following tabs expand to show instructions for installing a default Channel layer.
Follow the procedure for the Channel of your choice:

<!-- This indentation is important for things to render properly. -->

=== "Apache Kafka Channel"

    The following commands install the KafkaChannel and run event routing in a system
    namespace. The `knative-eventing` namespace is used by default.

    1. Install the Kafka controller by running the following command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-controller.yaml")}}
        ```

    1. Install the KafkaChannel data plane by running the following command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-channel.yaml")}}
        ```

    1. If you're upgrading from the previous version, run the following command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-post-install.yaml")}}
        ```

=== "In-Memory (standalone)"

    !!! warning
        This simple standalone implementation runs in-memory and is not suitable for production use cases.

    * Install an in-memory implementation of Channel by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="eventing",file="in-memory-channel.yaml")}}
        ```

=== "NATS Channel"

    1. [Install NATS Streaming for Kubernetes](https://github.com/knative-sandbox/eventing-natss/tree/main/config).

    1. Install the NATS Streaming Channel by running the command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-natss",file="eventing-natss.yaml")}}
        ```

        <!-- TODO(https://github.com/knative/docs/issues/2153): Add more Channels here -->

You can change the default channel implementation by following the instructions described in the [Configure Channel defaults](../../../eventing/configuration/channel-configuration.md) section.

## Optional: Install a Broker layer

The following tabs expand to show instructions for installing the Broker layer.
Follow the procedure for the Broker of your choice:

<!-- This indentation is important for things to render properly. -->
=== "Apache Kafka Broker"

    The following commands install the Apache Kafka Broker and run event routing in a system
    namespace. The `knative-eventing` namespace is used by default.

    1. Install the Kafka controller by running the following command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-controller.yaml")}}
        ```

    1. Install the Kafka Broker data plane by running the following command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-broker.yaml")}}
        ```

    1. If you're upgrading from the previous version, run the following command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-post-install.yaml")}}
        ```

    For more information, see the [Kafka Broker](../../../eventing/brokers/broker-types/kafka-broker/README.md) documentation.

=== "MT-Channel-based"

    This implementation of Broker uses Channels and runs event routing components in a system
    namespace, providing a smaller and simpler installation.

    * Install this implementation of Broker by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="eventing",file="mt-channel-broker.yaml")}}
        ```

        To customize which Broker Channel implementation is used, update the following ConfigMap to
        specify which configurations are used for which namespaces:

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
          channel-template-spec: |
            apiVersion: messaging.knative.dev/v1
            kind: InMemoryChannel
        ---
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: kafka-channel
          namespace: knative-eventing
        data:
          channel-template-spec: |
            apiVersion: messaging.knative.dev/v1alpha1
            kind: KafkaChannel
            spec:
              numPartitions: 3
              replicationFactor: 1
        ```

    !!! warning
        In order to use the KafkaChannel, ensure that it is installed on your cluster, as mentioned previously in this topic.

=== "RabbitMQ Broker"

    * Install the RabbitMQ Broker by following the instructions in the
    [RabbitMQ Knative Eventing Broker README](https://github.com/knative-sandbox/eventing-rabbitmq/tree/main/broker).

    For more information, see the [RabbitMQ Broker](https://github.com/knative-sandbox/eventing-rabbitmq) in GitHub.

## Install optional Eventing extensions

The following tabs expand to show instructions for installing each Eventing extension.
<!-- This indentation is important for things to render properly. -->

=== "Apache Kafka Sink"

    1. Install the Kafka controller by running the command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-controller.yaml")}}
        ```

    1. Install the Kafka Sink data plane by running the command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-sink.yaml")}}
        ```

    For more information, see the [Kafka Sink](../../../eventing/sinks/kafka-sink.md) documentation.

=== "Sugar Controller"

    <!-- Unclear when this feature came in -->

    1. Install the Eventing Sugar Controller by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="eventing",file="eventing-sugar-controller.yaml")}}
        ```

        The Knative Eventing Sugar Controller reacts to special labels and
        annotations and produce Eventing resources. For example:

        - When a namespace is labeled with `eventing.knative.dev/injection=enabled`, the
          controller creates a default Broker in that namespace.
        - When a Trigger is annotated with `eventing.knative.dev/injection=enabled`, the
          controller creates a Broker named by that Trigger in the Trigger's namespace.

    1. Enable the default Broker on a namespace (here `default`) by running the command:

        ```bash
        kubectl label namespace <namespace-name> eventing.knative.dev/injection=enabled
        ```
        Where `<namespace-name>` is the name of the namespace.

=== "GitHub Source"

    A single-tenant GitHub source creates one Knative service per GitHub source.

    A multi-tenant GitHub source only creates one Knative Service, which handles all GitHub sources in the
    cluster. This source does not support logging or tracing configuration.

    * To install a single-tenant GitHub source run the command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-github",file="github.yaml")}}
        ```

    * To install a multi-tenant GitHub source run the command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-github",file="mt-github.yaml")}}
        ```

    To learn more, try the [GitHub source sample](https://github.com/knative/docs/tree/main/code-samples/eventing/github-source)

=== "Apache Kafka Source"

    1. Install the Apache Kafka Source by running the command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-source.yaml")}}
        ```

    1. If you're upgrading from the previous version, run the following command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-post-install.yaml")}}
        ```

    To learn more, try the [Apache Kafka source sample](../../../eventing/sources/kafka-source/README.md).

=== "Apache CouchDB Source"

    * Install the Apache CouchDB Source by running the command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-couchdb",file="couchdb.yaml")}}
        ```

    To learn more, read the [Apache CouchDB source](https://github.com/knative-sandbox/eventing-couchdb/blob/main/source/README.md) documentation.

=== "VMware Sources and Bindings"

    * Install VMware Sources and Bindings by running the command:

        ```bash
        kubectl apply -f {{ artifact(org="vmware-tanzu",repo="sources-for-knative",file="release.yaml")}}
        ```

    To learn more, try the [VMware sources and bindings samples](https://github.com/vmware-tanzu/sources-for-knative/tree/master/samples/README.md).
