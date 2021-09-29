# RabbitMQ Broker

## Prerequisites

1. [Knative Eventing](../../../admin/install/eventing/install-eventing-with-yaml.md).
1. [RabbitMQ Cluster Operator](https://github.com/rabbitmq/cluster-operator)
1. [RabbitMQ Messaging Topology Operator](https://github.com/rabbitmq/messaging-topology-operator)

## Installation

1. Install the RabbitMQ controller by entering the following command:

    ```bash
    kubectl apply --filename {{ artifact(org="knative-sandbox", repo="eventing-rabbitmq", file="rabbitmq-broker.yaml") }}
    ```

1. Verify that `rabbitmq-broker-controller` and `rabbitmq-broker-webhook` are running,
by entering the following command:

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

## Create a RabbitMQ Cluster

1. Deploy a RabbitMQ Cluster:

  ```bash
  kubectl create -f - <<EOF
  apiVersion: rabbitmq.com/v1beta1
  kind: RabbitmqCluster
  metadata:
    name: hello-world
  EOF
  ```

1. Wait for our cluster to become ready:
  ```bash
  kubectl get rmq hello-world
  ```

  Example output:

  ```{ .bash .no-copy }
  NAME          ALLREPLICASREADY   RECONCILESUCCESS   AGE
  hello-world   True               True               38s
  ```

More information about configuring the RabbitmqCluster CRD are available on the [RabbitMQ website](https://www.rabbitmq.com/kubernetes/operator/using-operator.html).

## Create a RabbitMQ Broker

The full RabbitMQ Broker object looks like this:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: RabbitMQBroker
  name: hello-world
spec:
  config:
    apiVersion: rabbitmq.com/v1beta1
    kind: RabbitmqCluster
    name: hello-world
  delivery:
    deadLetterSink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: dlq-service
      uri: https://my.dlq.example.com
```

Specifying a `delivery.deadLetterSink` is optional, and can either be specified as an object reference or URI.

### Additional information

- To report a bug or request a feature, open an issue in the [eventing-rabbitmq repository](https://github.com/knative-sandbox/eventing-rabbitmq).
