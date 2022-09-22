# Creating a RabbitMQ Broker

This topic describes how to create a RabbitMQ Broker.

## Prerequisites

1. You have installed Knative Eventing.
1. You have installed [CertManager v1.5.4](https://github.com/jetstack/cert-manager/releases/tag/v1.5.4) - easiest integration with RabbitMQ Messaging Topology Operator
1. You have installed [RabbitMQ Messaging Topology Operator](https://github.com/rabbitmq/messaging-topology-operator) - our recommendation is [latest release](https://github.com/rabbitmq/messaging-topology-operator/releases/latest) with CertManager
1. You have access to a working RabbitMQ instance. You can create a RabbitMQ instance by using the [RabbitMQ Cluster Kubernetes Operator](https://github.com/rabbitmq/cluster-operator). For more information see the [RabbitMQ website](https://www.rabbitmq.com/kubernetes/operator/using-operator.html).

## Install the RabbitMQ controller

1. Install the RabbitMQ controller by running the command:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox", repo="eventing-rabbitmq", file="rabbitmq-broker.yaml") }}
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

## Create a RabbitMQBrokerConfig object

1. Create a YAML file using the following template:
    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: RabbitmqBrokerConfig
    metadata:
      name: <rabbitmq-broker-config-name>
    spec:
      rabbitmqClusterReference:
        # Configure name if a RabbitMQ Cluster Operator is being used.
        name: <cluster-name>
        # Configure connectionSecret if an external RabbitMQ cluster is being used.
        connectionSecret:
          name: rabbitmq-secret-credentials
      queueType: quorum
    ```
    Where:

    - <rabbitmq-broker-config-name> is the name you want for your RabbitMQBrokerConfig object.
    - <cluster-name> is the name of the RabbitMQ cluster you created earlier.

    !!! note
        You cannot set `name` and `connectionSecret` at the same time, since `name` is for a RabbitMQ Cluster Operator instance running in the same cluster as the Broker, and `connectionSecret` is for an external RabbitMQ server.

1. Apply the YAML file by running the command:

    ```bash
    kubectl create -f <filename>
    ```
   Where `<filename>` is the name of the file you created in the previous step.

## Create a RabbitMQBroker object

1. Create a YAML file using the following template:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
      annotations:
        eventing.knative.dev/broker.class: RabbitMQBroker
      name: <broker-name>
    spec:
      config:
        apiVersion: rabbitmq.com/v1beta1
        kind: RabbitmqBrokerConfig
        name: <rabbitmq-broker-config-name>
    ```
    Where `<rabbitmq-broker-config-name>` is the name you gave your RabbitMQBrokerConfig in the step above.

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>
    ```
    Where `<filename>` is the name of the file you created in the previous step.

## Configure message ordering

By default, Triggers will consume messages one at a time to preserve ordering. If ordering of events isn't important and higher performance is desired, you can configure this by using the
`parallelism` annotation. Setting `parallelism` to `n` creates `n` workers for the Trigger that will all consume messages in parallel.

The following YAML shows an example of a Trigger with parallelism set to `10`:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: high-throughput-trigger
  annotations:
    rabbitmq.eventing.knative.dev/parallelism: "10"
...
```

## Additional information

- For more samples visit the [`eventing-rabbitmq` Github repository samples directory](https://github.com/knative-sandbox/eventing-rabbitmq/tree/main/samples)
- To report a bug or request a feature, open an issue in the [`eventing-rabbitmq` Github repository](https://github.com/knative-sandbox/eventing-rabbitmq).
