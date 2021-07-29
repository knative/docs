---
title: "Apache Kafka Source Example"
linkTitle: "Source Example"
weight: 20
type: "docs"
---

# Apache Kafka Source Example

Tutorial on how to build and deploy a `KafkaSource` event source.

## Background

The `KafkaSource` reads all the messages, from all partitions, and sends those messages as CloudEvents via HTTP to its configured `sink`.

*NOTE:* In case you need a more sophisticated Kafka Consumer, with direct access to specific partitions or offsets you might want to implement a _Kafka Consumer_, using one of the available Apache Kafka SDKs, to handle the messages yourself, rather than using the Knative `KafkaSource`.

## Prerequisites

- A Kubernetes cluster with [Knative Kafka Source installed](../../../admin/install/).

## Apache Kafka Topic (Optional)

1. If using Strimzi, you can set a topic modifying `source/kafka-topic.yaml`
   with your desired:

- Topic
- Cluster Name
- Partitions
- Replicas

  ```yaml
  apiVersion: kafka.strimzi.io/v1beta2
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

   ```bash
   $ kubectl apply -f strimzi-topic.yaml
   kafkatopic.kafka.strimzi.io/knative-demo-topic created
   ```

3. Ensure the `KafkaTopic` is running.

   ```bash
   $ kubectl -n kafka get kafkatopics.kafka.strimzi.io
   NAME                 AGE
   knative-demo-topic   16s
   ```

## Create the Event Display service

1. Download a copy of the code:

   ```bash
   git clone -b "{{ branch }}" https://github.com/knative/docs knative-docs
   cd knative-docs/docs/eventing/samples/kafka/source
   ```

2. Build the Event Display Service (`event-display.yaml`)

   ```yaml
   kubectl apply -f - <<EOF
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: event-display
     namespace: default
   spec:
     template:
       spec:
         containers:
           - # This corresponds to
             # https://github.com/knative/eventing/tree/main/cmd/event_display/main.go
             image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
    EOF
   ```
   Example output:
   ```
   service.serving.knative.dev/event-display created
   ```

1. Ensure that the Service pod is running. The pod name will be prefixed with
   `event-display`.

   ```bash
   $ kubectl get pods
   NAME                                            READY     STATUS    RESTARTS   AGE
   event-display-00001-deployment-5d5df6c7-gv2j4   2/2       Running   0          72s
   ```

### Apache Kafka Event Source

1. Modify `source/event-source.yaml` accordingly with bootstrap servers, topics,
   etc...:

   ```yaml
   apiVersion: sources.knative.dev/v1beta1
   kind: KafkaSource
   metadata:
     name: kafka-source
   spec:
     consumerGroup: knative-group
     bootstrapServers:
     - my-cluster-kafka-bootstrap.kafka:9092 # note the kafka namespace
     topics:
     - knative-demo-topic
     sink:
       ref:
         apiVersion: serving.knative.dev/v1
         kind: Service
         name: event-display
   ```

1. Deploy the event source.
   ```
   $ kubectl apply -f event-source.yaml
   ...
   kafkasource.sources.knative.dev/kafka-source created
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
   {"level":"info","ts":"2020-05-28T10:39:42.104Z","caller":"adapter/adapter.go:81","msg":"Starting with config: ","Topics":".","ConsumerGroup":"...","SinkURI":"...","Name":".","Namespace":"."}
   ```

### Verify

1. Produce a message (`{"msg": "This is a test!"}`) to the Apache Kafka topic,
   like shown below:
   ```
   kubectl -n kafka run kafka-producer -ti --image=strimzi/kafka:0.14.0-kafka-2.3.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap:9092 --topic knative-demo-topic
   If you don't see a command prompt, try pressing enter.
   >{"msg": "This is a test!"}
   ```
1. Check that the Apache Kafka Event Source consumed the message and sent it to
   its sink properly. Since these logs are captured in debug level, edit the key `level` of `config-logging` configmap in `knative-sources` namespace to look like this:
   ```
   data:
     loglevel.controller: info
     loglevel.webhook: info
     zap-logger-config: |
       {
         "level": "debug",
         "development": false,
         "outputPaths": ["stdout"],
         "errorOutputPaths": ["stderr"],
         "encoding": "json",
         "encoderConfig": {
           "timeKey": "ts",
           "levelKey": "level",
           "nameKey": "logger",
           "callerKey": "caller",
           "messageKey": "msg",
           "stacktraceKey": "stacktrace",
           "lineEnding": "",
           "levelEncoder": "",
           "timeEncoder": "iso8601",
           "durationEncoder": "",
           "callerEncoder": ""
         }
       }

   ```
   Now manually delete the kafkasource deployment and allow the `kafka-controller-manager` deployment running in `knative-sources` namespace to redeploy it. Debug level logs should be visible now.

   ```
   $ kubectl logs --selector='knative-eventing-source-name=kafka-source'
   ...

   {"level":"debug","ts":"2020-05-28T10:40:29.400Z","caller":"kafka/consumer_handler.go:77","msg":"Message claimed","topic":".","value":"."}
   {"level":"debug","ts":"2020-05-28T10:40:31.722Z","caller":"kafka/consumer_handler.go:89","msg":"Message marked","topic":".","value":"."}
   ```

1. Ensure the Event Display received the message sent to it by the Event Source.

   ```
   $ kubectl logs --selector='serving.knative.dev/service=event-display' -c user-container

   ☁️ cloudevents.Event
   Validation: valid
   Context Attributes,
     specversion: 1.0
     type: dev.knative.kafka.event
     source: /apis/v1/namespaces/default/kafkasources/kafka-source#my-topic
     subject: partition:0#564
     id: partition:0/offset:564
     time: 2020-02-10T18:10:23.861866615Z
     datacontenttype: application/json
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

   $ kubectl delete -f source/source.yaml kafkasource.sources.knative.dev
   "kafka-source" deleted

   ```
   2. Remove the Event Display
   ```

   $ kubectl delete -f source/event-display.yaml service.serving.knative.dev
   "event-display" deleted

   ```
   3. Remove the Apache Kafka Event Controller
   ```

   $ kubectl delete -f https://storage.googleapis.com/knative-releases/eventing-contrib/latest/kafka-source.yaml
   serviceaccount "kafka-controller-manager" deleted
   clusterrole.rbac.authorization.k8s.io "eventing-sources-kafka-controller"
   deleted clusterrolebinding.rbac.authorization.k8s.io
   "eventing-sources-kafka-controller" deleted
   customresourcedefinition.apiextensions.k8s.io "kafkasources.sources.knative.dev"
   deleted service "kafka-controller" deleted statefulset.apps
   "kafka-controller-manager" deleted

   ```
4. (Optional) Remove the Apache Kafka Topic

   ```bash
   $ kubectl delete -f kafka-topic.yaml
   kafkatopic.kafka.strimzi.io "knative-demo-topic" deleted
   ```

## (Optional) Specify the key deserializer

When `KafkaSource` receives a message from Kafka, it dumps the key in the Event
extension called `Key` and dumps Kafka message headers in the extensions
starting with `kafkaheader`.

You can specify the key deserializer among four types:

* `string` (default) for UTF-8 encoded strings
* `int` for 32-bit & 64-bit signed integers
* `float` for 32-bit & 64-bit floating points
* `byte-array` for a Base64 encoded byte array

To specify it, add the label `kafkasources.sources.knative.dev/key-type` to the `KafkaSource` definition like:
   ```yaml
   apiVersion: sources.knative.dev/v1beta1
   kind: KafkaSource
   metadata:
    name: kafka-source
    labels:
      kafkasources.sources.knative.dev/key-type: int
   spec:
    consumerGroup: knative-group
    bootstrapServers:
    - my-cluster-kafka-bootstrap.kafka:9092 # note the kafka namespace
    topics:
    - knative-demo-topic
    sink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: event-display
   ```

## (Optional) Specify the initial offset

By default the `KafkaSource` starts consuming from the `latest` offset in each partition. In case you want to consume from the earliest offset, set the initialOffset field to `earliest`.

   ```yaml
   apiVersion: sources.knative.dev/v1beta1
   kind: KafkaSource
   metadata:
    name: kafka-source
   spec:
    consumerGroup: knative-group
    initialOffset: earliest
    bootstrapServers:
    - my-cluster-kafka-bootstrap.kafka:9092 # note the kafka namespace
    topics:
    - knative-demo-topic
    sink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: event-display
   ```

*NOTE:* valid values for `initialOffset` is `earliest` or `latest`, any other value would result in a validation error. This field will be honored only if there are no prior committed offsets for that consumer group.

## Connecting to a TLS enabled Kafka broker

The KafkaSource supports TLS and SASL authentication methods. For enabling TLS authentication, please have the below files

* CA Certificate
* Client Certificate and Key

KafkaSource expects these files to be in pem format, if it is in other format like jks, please convert to pem.

1. Create the certificate files as secrets in the namespace where KafkaSource is going to be set up
   ```

   $ kubectl create secret generic cacert --from-file=caroot.pem
   secret/cacert created

   $ kubectl create secret tls kafka-secret --cert=certificate.pem --key=key.pem
   secret/key created


   ```

2. Apply the KafkaSource, change bootstrapServers and topics accordingly.
   ```yaml
   apiVersion: sources.knative.dev/v1beta1
   kind: KafkaSource
   metadata:
    name: kafka-source-with-tls
   spec:
    net:
      tls:
        enable: true
        cert:
          secretKeyRef:
            key: tls.crt
            name: kafka-secret
        key:
          secretKeyRef:
            key: tls.key
            name: kafka-secret
        caCert:
          secretKeyRef:
            key: caroot.pem
            name: cacert
    consumerGroup: knative-group
    bootstrapServers:
    - my-secure-kafka-bootstrap.kafka:443
    topics:
    - knative-demo-topic
    sink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: event-display
   ```
