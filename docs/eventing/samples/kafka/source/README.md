---
title: "Apache Kafka Source Example"
linkTitle: "Source Example"
weight: 20
type: "docs"
---

Tutorial on how to build and deploy a `KafkaSource` [Eventing source](../../../sources/README.md) using a Knative Serving `Service`.


## Prerequisites

You must ensure that you meet the [prerequisites listed in the Apache Kafka overview](../README.md).

## Creating a `KafkaSource` source CRD

1. Install the `KafkaSource` sub-component to your Knative cluster:
   ```
   kubectl apply -f https://storage.googleapis.com/knative-releases/eventing-contrib/latest/kafka-source.yaml

   ```
2. Check that the `kafka-controller-manager-0` pod is running.
   ```
   kubectl get pods --namespace knative-sources
   NAME                         READY     STATUS    RESTARTS   AGE
   kafka-controller-manager-0   1/1       Running   0          42m
   ```
3. Check the `kafka-controller-manager-0` pod logs.
   ```
   $ kubectl logs kafka-controller-manager-0 -n knative-sources
   2019/03/19 22:25:54 Registering Components.
   2019/03/19 22:25:54 Setting up Controller.
   2019/03/19 22:25:54 Adding the Apache Kafka Source controller.
   2019/03/19 22:25:54 Starting Apache Kafka controller.
   ```

### Apache Kafka Topic (Optional)

1. If using Strimzi, you can set a topic modifying
   `source/kafka-topic.yaml` with your desired:

- Topic
- Cluster Name
- Partitions
- Replicas

  ```yaml
  apiVersion: kafka.strimzi.io/v1beta1
  kind: KafkaTopic
  metadata:
    name: knative-demo-topic
    namespace: kafka
    labels:
      strimzi.io/cluster: my-cluster
  spec:
    partitions: 3
    replicas: 1
    config:
      retention.ms: 7200000
      segment.bytes: 1073741824
  ```

2. Deploy the `KafkaTopic`

   ```shell
   $ kubectl apply -f kafka/source/samples/strimzi-topic.yaml
   kafkatopic.kafka.strimzi.io/knative-demo-topic created
   ```

3. Ensure the `KafkaTopic` is running.

   ```shell
   $ kubectl -n kafka get kafkatopics.kafka.strimzi.io
   NAME                 AGE
   knative-demo-topic   16s
   ```

### Create the Event Display service

1. Build and deploy the Event Display Service.
   ```
   $ kubectl apply --filename source/samples/event-display.yaml
   ...
   service.serving.knative.dev/event-display created
   ```
1. Ensure that the Service pod is running. The pod name will be prefixed with
   `event-display`.
   ```
   $ kubectl get pods
   NAME                                            READY     STATUS    RESTARTS   AGE
   event-display-00001-deployment-5d5df6c7-gv2j4   2/2       Running   0          72s
   ...
   ```

#### Apache Kafka Event Source

1. Modify `source/event-source.yaml` accordingly with bootstrap
   servers, topics, etc...:

   ```yaml
   apiVersion: sources.eventing.knative.dev/v1alpha1
   kind: KafkaSource
   metadata:
     name: kafka-source
   spec:
     consumerGroup: knative-group
     bootstrapServers: my-cluster-kafka-bootstrap.kafka:9092 #note the kafka namespace
     topics: knative-demo-topic
     sink:
       ref:
         apiVersion: serving.knative.dev/v1
         kind: Service
         name: event-display
   ```

1. Deploy the event source.
   ```
   $ kubectl apply -f kafka/source/samples/event-source.yaml
   ...
   kafkasource.sources.eventing.knative.dev/kafka-source created
   ```
1. Check that the event source pod is running. The pod name will be prefixed
   with `kafka-source`.
   ```
   $ kubectl get pods
   NAME                                  READY     STATUS    RESTARTS   AGE
   kafka-source-xlnhq-5544766765-dnl5s   1/1       Running   0          40m
   ```
1. Ensure the Apache Kafka Event Source started with the necessary
   configuration.
   ```
   $ kubectl logs --selector='knative-eventing-source-name=kafka-source'
   {"level":"info","ts":"2019-04-01T19:09:32.164Z","caller":"receive_adapter/main.go:97","msg":"Starting Apache Kafka Receive Adapter...","Bootstrap Server":"...","Topics":".","ConsumerGroup":"...","SinkURI":"...","TLS":false}
   ```

### Verify

1. Produce a message (`{"msg": "This is a test!"}`) to the Apache Kafka topic, like shown below:
   ```
   kubectl -n kafka run kafka-producer -ti --image=strimzi/kafka:0.14.0-kafka-2.3.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap:9092 --topic knative-demo-topic
   If you don't see a command prompt, try pressing enter.
   >{"msg": "This is a test!"}
   ```
1. Check that the Apache Kafka Event Source consumed the message and sent it to
   its sink properly.

   ```
   $ kubectl logs --selector='knative-eventing-source-name=kafka-source'
   ...
   {"level":"info","ts":"2019-04-15T20:37:24.702Z","caller":"receive_adapter/main.go:99","msg":"Starting Apache Kafka Receive Adapter...","bootstrap_server":"...","Topics":"knative-demo-topic","ConsumerGroup":"knative-group","SinkURI":"...","TLS":false}
   {"level":"info","ts":"2019-04-15T20:37:24.702Z","caller":"adapter/adapter.go:100","msg":"Starting with config: ","bootstrap_server":"...","Topics":"knative-demo-topic","ConsumerGroup":"knative-group","SinkURI":"...","TLS":false}
   {"level":"info","ts":1553034726.546107,"caller":"adapter/adapter.go:154","msg":"Successfully sent event to sink"}
   ```

1. Ensure the Event Display received the message sent to it by the Event Source.

   ```
   $ kubectl logs --selector='serving.knative.dev/service=event-display' -c user-container

    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 0.3
      type: dev.knative.kafka.event
      source: dubee
      id: partition:0/offset:333
      time: 2019-10-18T15:23:20.809775386Z
      contenttype: application/json
    Extensions,
      key:
    Data,
      {
        "msg": "This is a test!"
      }
   ```

## Teardown Steps

1. Remove the Apache Kafka Event Source
   ```
   $ kubectl delete -f source/source.yaml
   kafkasource.sources.eventing.knative.dev "kafka-source" deleted
   ```
2. Remove the Event Display
   ```
   $ kubectl delete -f source/event-display.yaml
   service.serving.knative.dev "event-display" deleted
   ```
3. Remove the Apache Kafka Event Controller
   ```
   $ kubectl delete -f https://storage.googleapis.com/knative-releases/eventing-contrib/latest/kafka-source.yaml
   serviceaccount "kafka-controller-manager" deleted
   clusterrole.rbac.authorization.k8s.io "eventing-sources-kafka-controller" deleted
   clusterrolebinding.rbac.authorization.k8s.io "eventing-sources-kafka-controller" deleted
   customresourcedefinition.apiextensions.k8s.io "kafkasources.sources.eventing.knative.dev" deleted
   service "kafka-controller" deleted
   statefulset.apps "kafka-controller-manager" deleted
   ```
4. (Optional) Remove the Apache Kafka Topic

   ```shell
   $ kubectl delete -f kafka/source/samples/kafka-topic.yaml
   kafkatopic.kafka.strimzi.io "knative-demo-topic" deleted
   ```
