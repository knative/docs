The following examples will help you understand how to use the different Apache Kafka components for Knative.

## Prerequisites

All examples require:

- A Kubernetes cluster with
  - Knative Eventing v0.9+
  - Knative Serving v0.9+
- An Apache Kafka cluster

### Setting up Apache Kafka

If you want to run the Apache Kafka cluster on Kubernetes, the simplest option is to install it by using [Strimzi](https://strimzi.io),
using the following script:

   ```shell
   $ ./kafka_setup.sh
   ```

This will install a small, non-production, cluster of Apache Kafka, using one node for Apache Zookeeper and one node for Apache Kafka.
To verify your installation, check if the pods for Strimzi are all up, in the `kafka` namespace:

   ```shell
   $ kubectl get pods -n kafka
   NAME                                          READY   STATUS    RESTARTS   AGE
   my-cluster-entity-operator-65995cf856-ld2zp   3/3     Running   0          102s
   my-cluster-kafka-0                            2/2     Running   0          2m8s
   my-cluster-zookeeper-0                        2/2     Running   0          2m39s
   strimzi-cluster-operator-77555d4b69-sbrt4     1/1     Running   0          3m14s
   ```

## Examples

A number of different examples, showing the `KafkaSource` and the `KafkaChannel` can be found here:

- [`KafkaSource` to `Service`](./source/README.md)
- [`KafkaChannel` and Broker](./channel/README.md)
