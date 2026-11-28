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

## Create a RabbitMQBrokerConfig { #create-a-rabbitmqbrokerconfig-object }

Choose either an in-cluster RabbitMQ Cluster Operator instance (`name`) or an external RabbitMQ server (`connectionSecret`). Do not set both fields in the same `RabbitmqBrokerConfig`.

=== "In-cluster (RabbitMQ Cluster Operator)"
    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: RabbitmqBrokerConfig
    metadata:
      name: <rabbitmq-broker-config-name>
    spec:
      rabbitmqClusterReference:
        name: <cluster-name>
      queueType: quorum
    ```

=== "External RabbitMQ server"
    ```yaml
    apiVersion: eventing.knative.dev/v1alpha1
    kind: RabbitmqBrokerConfig
    metadata:
      name: <rabbitmq-broker-config-name>
    spec:
      rabbitmqClusterReference:
        connectionSecret:
          name: rabbitmq-secret-credentials
      queueType: quorum
    ```

Apply the YAML file:

```bash
kubectl apply -f <filename>.yaml
```

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
