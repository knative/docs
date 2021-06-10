# Using Apache Kafka with Knative

If you want to use Apache Kafka with Knative, you can either install Apache Kafka directly, use an existing Kafka cluster, or use [Strimzi](https://strimzi.io/docs/operators/in-development/full/overview.html) to create a simplified Kafka deployment on Kubernetes.

## Prerequisites

- You will need a Kubernetes cluster with [Knative Eventing installed](../../../../admin/install).

    !!! tip
        You can use a `kind` cluster for local development and follow the [Getting Started](../../../../getting-started) documentation to install Knative by using the `konk` script.

- If you do not have an existing Kafka cluster:
    - [Install Strimzi](https://strimzi.io/docs/operators/in-development/quickstart.html#proc-install-product-str).
    - [Create a Kafka cluster](https://strimzi.io/docs/operators/in-development/quickstart.html#proc-kafka-cluster-str).
    - You can also use the [Strimzi Quickstart guide](https://strimzi.io/quickstarts/) to complete these tasks.
