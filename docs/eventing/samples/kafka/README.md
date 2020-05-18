The following examples will help you understand how to use the different Apache
Kafka components for Knative.

## Prerequisites

All examples require:

- A Kubernetes cluster with
  - Knative Eventing v0.9+
  - Knative Serving v0.9+
- An Apache Kafka cluster

### Setting up Apache Kafka

If you want to run the Apache Kafka cluster on Kubernetes, the simplest option
is to install it by using [Strimzi](https://strimzi.io).

1. Create a namespace for your Apache Kafka installation, like `kafka`:
   ```shell
   kubectl create namespace kafka
   ```
1. Install the Strimzi operator, like:
   ```shell
   curl -L "https://github.com/strimzi/strimzi-kafka-operator/releases/download/0.16.2/strimzi-cluster-operator-0.16.2.yaml" \
     | sed 's/namespace: .*/namespace: kafka/' \
     | kubectl -n kafka apply -f -
   ```
1. Describe the size of your Apache Kafka installation in `kafka.yaml`, like:
   ```yaml
   apiVersion: kafka.strimzi.io/v1beta1
   kind: Kafka
   metadata:
     name: my-cluster
   spec:
     kafka:
       version: 2.4.0
       replicas: 1
       listeners:
         plain: {}
         tls: {}
       config:
         offsets.topic.replication.factor: 1
         transaction.state.log.replication.factor: 1
         transaction.state.log.min.isr: 1
         log.message.format.version: "2.4"
       storage:
         type: ephemeral
     zookeeper:
       replicas: 3
       storage:
         type: ephemeral
     entityOperator:
       topicOperator: {}
       userOperator: {}
   ```
1. Deploy the Apache Kafka cluster
   ```
   $ kubectl apply -n kafka -f kafka.yaml
   ```

This will install a small, non-production, cluster of Apache Kafka. To verify
your installation, check if the pods for Strimzi are all up, in the `kafka`
namespace:

```shell
$ kubectl get pods -n kafka
NAME                                          READY   STATUS    RESTARTS   AGE
my-cluster-entity-operator-65995cf856-ld2zp   3/3     Running   0          102s
my-cluster-kafka-0                            2/2     Running   0          2m8s
my-cluster-zookeeper-0                        2/2     Running   0          2m39s
my-cluster-zookeeper-1                        2/2     Running   0          2m49s
my-cluster-zookeeper-2                        2/2     Running   0          2m59s
strimzi-cluster-operator-77555d4b69-sbrt4     1/1     Running   0          3m14s
```

> NOTE: For production ready installs check [Strimzi](https://strimzi.io).

### Installation script

If you want to install the latest version of Strimzi, in just one step, we have
a [script](./kafka_setup.sh) for your convenience, which does exactly the same
steps that are listed above:

```shell
$ ./kafka_setup.sh
```

## Examples of Apache Kafka and Knative

A number of different examples, showing the `KafkaSource`, `KafkaChannel` and
`KafkaBinding` can be found here:

- [`KafkaSource` to `Service`](./source/README.md)
- [`KafkaChannel` and Broker](./channel/README.md)
- [`KafkaBinding`](./binding/README.md)
