---
audience: administrator
components:
  - eventing
function: explanation
---

# Creating a RabbitMQ Broker

This topic describes how to install the RabbitMQ Broker onto your cluster.

## Prerequisites

1. You have installed Knative Eventing.
1. You have installed [CertManager v1.5.4](https://github.com/jetstack/cert-manager/releases/tag/v1.5.4) - easiest integration with RabbitMQ Messaging Topology Operator
1. You have installed [RabbitMQ Messaging Topology Operator](https://github.com/rabbitmq/messaging-topology-operator) - our recommendation is [latest release](https://github.com/rabbitmq/messaging-topology-operator/releases/latest) with CertManager
1. You have access to a working RabbitMQ instance. You can create a RabbitMQ instance by using the [RabbitMQ Cluster Kubernetes Operator](https://github.com/rabbitmq/cluster-operator). For more information see the [RabbitMQ website](https://www.rabbitmq.com/kubernetes/operator/using-operator.html).

## Install the RabbitMQ controller

1. Install the RabbitMQ controller by running the command:

    ```bash
    kubectl apply -f {{ artifact(org="knative-extensions", repo="eventing-rabbitmq", file="rabbitmq-broker.yaml") }}
    ```

1. Verify that `rabbitmq-broker-controller` and `rabbitmq-broker-webhook` are running:

    ```bash
    kubectl get deployments.apps -n knative-eventing
    ```

    Example output:

    ```{ .bash .no-copy }
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    eventing-controller            1/1     1            1           10s
    eventing-webhook               1/1     1            1           9s
    rabbitmq-broker-controller     1/1     1            1           3s
    rabbitmq-broker-webhook        1/1     1            1           4s
    ```

## Additional information

- For more samples visit the [`eventing-rabbitmq` Github repository samples directory](https://github.com/knative-extensions/eventing-rabbitmq/tree/main/samples)
- To report a bug or request a feature, open an issue in the [`eventing-rabbitmq` Github repository](https://github.com/knative-extensions/eventing-rabbitmq).
