The following examples will help you understand how to use the different Apache
Kafka components for Knative.

## Prerequisites

All examples require:

- A Kubernetes cluster with
  - Knative Eventing v0.9+
  - Knative Serving v0.9+
- An Apache Kafka cluster

If you want to run the Apache Kafka cluster on Kubernetes, the simplest option
is to install it by using Strimzi. Check out the
[Quickstart](https://strimzi.io/quickstarts/) guides for both Minikube and
Openshift. You can also install Kafka on the host.

## Examples

A number of different examples, showing the `KafkaSource` and the `KafkaChannel`
can be found here:

- [`KafkaSource` to `Service`](./source/README.md)
- [`KafkaChannel` and Broker](./channel/README.md)
