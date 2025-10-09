---
audience: developer
components:
  - eventing
function: explanation
---

# Creating a RabbitMQ Broker

This topic describes how to create a RabbitMQ Broker.

## Prerequisites

These directions assume your cluster administrator has [installed the Knative RabbitMQ broker](../../../../install/eventing/rabbitmq-install.md).

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
        apiVersion: eventing.knative.dev/v1alpha1
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

- For more samples visit the [`eventing-rabbitmq` Github repository samples directory](https://github.com/knative-extensions/eventing-rabbitmq/tree/main/samples)
- To report a bug or request a feature, open an issue in the [`eventing-rabbitmq` Github repository](https://github.com/knative-extensions/eventing-rabbitmq).
