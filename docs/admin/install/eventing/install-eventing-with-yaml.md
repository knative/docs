# Installing Knative Eventing using YAML files

This topic describes how to install Knative Eventing by applying YAML files using the `kubectl` CLI.

--8<-- "prerequisites.md"

## Install Knative Eventing

To install the Knative Eventing component:

1. Install the required custom resource definitions (CRDs) by running the command:

    ```bash
    kubectl apply -f {{ artifact(repo="eventing",file="eventing-crds.yaml")}}
    ```

1. Install the core components of Eventing by running the command:

    ```bash
    kubectl apply -f {{ artifact(repo="eventing",file="eventing-core.yaml")}}
    ```

    !!! info
        For information about the YAML files in Knative Eventing, see [Description Tables for YAML Files](./eventing-installation-files.md).

## Verify the installation

!!! success "Monitor the Knative components until all of the components show a `STATUS` of `Running` or `Completed`:"

    ```{ .bash .no-copy }
    kubectl get pods --namespace knative-eventing
    ```


## Optional: Install a default Channel (messaging) layer

The tabs below expand to show instructions for installing a default Channel layer.
Follow the procedure for the Channel of your choice:

<!-- This indentation is important for things to render properly. -->

=== "Apache Kafka Channel"

    1. [Install Apache Kafka for Kubernetes](../../../eventing/samples/kafka/README.md).

    1. Install the Apache Kafka Channel by running the command:

        ```bash
        curl -L "{{ artifact(org="knative-sandbox",repo="eventing-kafka",file="channel-consolidated.yaml")}}" \
          | sed 's/REPLACE_WITH_CLUSTER_URL/my-cluster-kafka-bootstrap.kafka:9092/' \
          | kubectl apply -f -
        ```

        !!! tip
            To learn more, try the [Apache Kafka Channel sample](../../../eventing/samples/kafka/channel/README.md).

=== "Google Cloud Pub/Sub Channel"

    * Install the Google Cloud Pub/Sub Channel by running the command:

        ```bash
        kubectl apply -f {{ artifact(org="google",repo="knative-gcp",file="cloud-run-events.yaml")}}
        ```

        This command installs both the Channel and the GCP Sources.

        !!! tip
            To learn more, try the [Google Cloud Pub/Sub channel sample](https://github.com/google/knative-gcp/blob/master/docs/examples/channel/README.md).


=== "In-Memory (standalone)"

    !!! warning
        This simple standalone implementation runs in-memory and is unsuitable for production-use cases.

    * Install an in-memory implementation of Channel by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="eventing",file="in-memory-channel.yaml")}}
        ```

=== "NATS Channel"

    1. [Install NATS Streaming for Kubernetes](https://github.com/knative-sandbox/eventing-natss/tree/main/config).

    1. Install the NATS Streaming Channel by running the command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-natss",file="300-natss-channel.yaml")}}
        ```

        <!-- TODO(https://github.com/knative/docs/issues/2153): Add more Channels here -->

## Optional: Install a Broker layer:

The tabs below expand to show instructions for installing the Broker layer.
Follow the procedure for the Broker of your choice:

<!-- This indentation is important for things to render properly. -->
=== "Apache Kafka Broker"

    The following commands install the Apache Kafka Broker and run event routing in a system
    namespace. The namespace `knative-eventing` is used by default.

    1. Install the Kafka controller by running the following command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-controller.yaml")}}
        ```

    1. Install the Kafka Broker data plane by running the following command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka-broker",file="eventing-kafka-broker.yaml")}}
        ```

    For more information, see the [Kafka Broker](../../../eventing/broker/kafka-broker/README.md) documentation.

=== "MT-Channel-based"

    This implementation of Broker utilizes Channels and runs event routing components in a system
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
        In order to use the KafkaChannel ensure it is installed on the cluster as discussed above.

=== "RabbitMQ Broker"

    * Install the RabbitMQ Broker by following the instructions in the
    [RabbitMQ Knative Eventing Broker README](https://github.com/knative-sandbox/eventing-rabbitmq/tree/main/broker).

    For more information, see the [RabbitMQ Broker](https://github.com/knative-sandbox/eventing-rabbitmq) in GitHub.

## Install optional Eventing extensions

The tabs below expand to show instructions for installing each Eventing extension.
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

    For more information, see the [Kafka Sink](../../../developer/eventing/sinks/kafka-sink.md) documentation.

=== "Sugar Controller"

    <!-- Unclear when this feature came in -->

    1. Install the Eventing Sugar Controller by running the command:

        ```bash
        kubectl apply -f {{ artifact(repo="eventing",file="eventing-sugar-controller.yaml")}}
        ```

        The Knative Eventing Sugar Controller reacts to special labels and
        annotations and produce Eventing resources. For example:

        - When a Namespace is labeled with `eventing.knative.dev/injection=enabled`, the
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

    A multi-tenant GitHub source creates only one Knative service handling all GitHub sources in the
    cluster. This source does not support logging or tracing configuration yet.

    * To install a single-tenant GitHub source run the command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-github",file="github.yaml")}}
        ```

    * To install a multi-tenant GitHub source run the command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-github",file="mt-github.yaml")}}
        ```

    To learn more, try the [GitHub source sample](../../../eventing/samples/github-source/README.md)

=== "Apache Kafka Source"

    * Install the Apache Kafka Source by running the command:

        ```bash
        kubectl apply -f {{ artifact(org="knative-sandbox",repo="eventing-kafka",file="source.yaml")}}
        ```

    To learn more, try the [Apache Kafka source sample](../../../developer/eventing/sources/kafka-source/README.md).


=== "GCP Sources"

    * Install the GCP Sources by running the command:

        ```bash
        kubectl apply -f {{ artifact(org="google",repo="knative-gcp",file="cloud-run-events.yaml")}}
        ```

        This command installs both the Sources and the Channel.

    To learn more, try the following samples:

    - [Cloud Pub/Sub source sample](../../../eventing/samples/cloud-pubsub-source/README.md)
    - [Cloud Storage source sample](../../../eventing/samples/cloud-storage-source/README.md)
    - [Cloud Scheduler source sample](../../../eventing/samples/cloud-scheduler-source/README.md)
    - [Cloud Audit Logs source sample](../../../eventing/samples/cloud-audit-logs-source/README.md)


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
