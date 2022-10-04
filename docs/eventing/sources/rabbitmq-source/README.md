# Creating a RabbitMQSource

![stage](https://img.shields.io/badge/Stage-stable-green?style=flat-square)
![version](https://img.shields.io/badge/API_Version-v1alpha1-red?style=flat-square)

This topic describes how to create a RabbitMQSource.

## Prerequisites

1. You have installed [Knative Eventing](../../../install/yaml-install/eventing/install-eventing-with-yaml.md)
1. You have installed [CertManager v1.5.4](https://github.com/jetstack/cert-manager/releases/tag/v1.5.4) - easiest integration with RabbitMQ Messaging Topology Operator
1. You have installed [RabbitMQ Messaging Topology Operator](https://github.com/rabbitmq/messaging-topology-operator) - our recommendation is [latest release](https://github.com/rabbitmq/messaging-topology-operator/releases/latest) with CertManager
1. A working RabbitMQ Instance, we recommend to create one Using the [RabbitMQ Cluster Operator](https://github.com/rabbitmq/cluster-operator).
For more information about configuring the `RabbitmqCluster` CRD, see the [RabbitMQ website](https://www.rabbitmq.com/kubernetes/operator/using-operator.html)

## Install the RabbitMQ controller

1. Install the RabbitMQSource controller by running the command:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox", repo="eventing-rabbitmq", file="rabbitmq-source.yaml") }}
    ```

1. Verify that `rabbitmq-controller-manager` and `rabbitmq-webhook` are running:

    ```bash
    kubectl get deployments.apps -n knative-sources
    ```

    Example output:

    ```{ .bash .no-copy }
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    rabbitmq-controller-manager     1/1     1            1           3s
    rabbitmq-webhook                1/1     1            1           4s
    ```

{% include "event-display.md" %}

## Create a RabbitMQSource object

1. Create a YAML file using the following template:

    ```yaml
    apiVersion: sources.knative.dev/v1alpha1
    kind: RabbitmqSource
    metadata:
      name: <source-name>
    spec:
      rabbitmqClusterReference:
        # Configure name if a RabbitMQ Cluster Operator is being used.
        name: <cluster-name>
        # Configure connectionSecret if an external RabbitMQ cluster is being used.
        connectionSecret:
          name: rabbitmq-secret-credentials
      rabbitmqResourcesConfig:
        parallelism: 10
        exchangeName: "eventing-rabbitmq-source"
        queueName: "eventing-rabbitmq-source"
      delivery:
        retry: 5
        backoffPolicy: "linear"
        backoffDelay: "PT1S"
      sink:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: event-display
    ```
    Where:

    - `<source-name>` is the name you want for your RabbitMQSource object.
    - `<cluster-name>` is the name of the RabbitMQ cluster you created earlier.

    !!! note
        You cannot set `name` and `connectionSecret` at the same time, since `name` is for a RabbitMQ Cluster Operator instance running in the same cluster as the Source, and `connectionSecret` is for an external RabbitMQ server.

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>
    ```
    Where `<filename>` is the name of the file you created in the previous step.

### Verify

Check the event-display Service to see if it is receiving events.
It might take a while for the Source to start sending events to the Sink.

```sh
  kubectl -l='serving.knative.dev/service=event-display' logs -c user-container
  ☁️  cloudevents.Event
  Context Attributes,
    specversion: 1.0
    type: dev.knative.rabbitmq.event
    source: /apis/v1/namespaces/default/rabbitmqsources/<source-name>
    subject: f147099d-c64d-41f7-b8eb-a2e53b228349
    id: f147099d-c64d-41f7-b8eb-a2e53b228349
    time: 2021-12-16T20:11:39.052276498Z
    datacontenttype: application/json
  Data,
    {
      ...
      Random Data
      ...
    }
```

### Cleanup

1. Delete the RabbitMQSource:

    ```sh
    kubectl delete -f <source-yaml-filename>
    ```

1. Delete the RabbitMQ credentials secret:

    ```sh
    kubectl delete -f <secret-yaml-filename>
    ```

1. Delete the event display Service:

    ```sh
    kubectl delete -f <service-yaml-filename>
    ```

## Additional information

- For more samples visit the [`eventing-rabbitmq` Github repository samples directory](https://github.com/knative-sandbox/eventing-rabbitmq/tree/main/samples)
- To report a bug or request a feature, open an issue in the [`eventing-rabbitmq` Github repository](https://github.com/knative-sandbox/eventing-rabbitmq).
