# Knative Source for Apache Kafka

![stage](https://img.shields.io/badge/Stage-stable-green?style=flat-square)
![version](https://img.shields.io/badge/API_Version-v1beta1-yellow?style=flat-square)


The `KafkaSource` reads messages stored in existing [Apache Kafka](https://kafka.apache.org) topics, and sends those messages as CloudEvents through HTTP to its configured `sink`. The `KafkaSource` preserves the order of the messages
stored in the topic partitions. It does this by waiting for a successful response from the `sink` before it delivers the next message in the same partition.
## Install the KafkaSource controller

1. Install the `KafkaSource` controller by entering the following command:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-controller.yaml") }}
    ```

1. Install the Kafka Source data plane by entering the following command:

    ```bash
    kubectl apply -f {{ artifact(org="knative-sandbox", repo="eventing-kafka-broker", file="eventing-kafka-source.yaml") }}
    ```

1. Verify that `kafka-controller` and `kafka-source-dispatcher` are running,
   by entering the following command:

    ```bash
    kubectl get deployments.apps -n knative-eventing
    ```

    Example output:
    ```{ .bash .no-copy }
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    kafka-controller               1/1     1            1           3s
    kafka-source-dispatcher        1/1     1            1           4s
    ```

## Optional: Create a Kafka topic

!!! note
    The create a Kafka topic section assumes you're using Strimzi to operate Apache Kafka, however equivalent operations can be replicated using the Apache Kafka CLI or any other tool.

If you are using Strimzi:

1. Create a `KafkaTopic` YAML file:

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

2. Deploy the `KafkaTopic` YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of your `KafkaTopic` YAML file.

    Example output:
    ```{ .bash .no-copy }
    kafkatopic.kafka.strimzi.io/knative-demo-topic created
    ```

3. Ensure that the `KafkaTopic` is running by running the command:

    ```bash
    kubectl -n kafka get kafkatopics.kafka.strimzi.io
    ```

    Example output:
    ```{ .bash .no-copy }
    NAME                 CLUSTER      PARTITIONS   REPLICATION FACTOR
    knative-demo-topic   my-cluster   3            1
    ```

## Create a Service

1. Create the `event-display` Service as a YAML file:

     ```yaml
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
     ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

    Example output:
    ```{ .bash .no-copy }
    service.serving.knative.dev/event-display created
    ```

1. Ensure that the Service Pod is running, by running the command:

    ```bash
    kubectl get pods
    ```

    The Pod name is prefixed with `event-display`:
    ```{ .bash .no-copy }
    NAME                                            READY     STATUS    RESTARTS   AGE
    event-display-00001-deployment-5d5df6c7-gv2j4   2/2       Running   0          72s
    ```

### Kafka event source

1. Modify `source/event-source.yaml` accordingly with bootstrap servers, topics, and so on:

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

1. Deploy the event source:

    ```bash
    kubectl apply -f event-source.yaml
    ```

    Example output:
    ```{ .bash .no-copy }
    kafkasource.sources.knative.dev/kafka-source created
    ```

1. Verify that the KafkaSource is ready:

    ```bash
    kubectl get kafkasource kafka-source
    ```

    Example output:
    ```{ .bash .no-copy }
    NAME           TOPICS                   BOOTSTRAPSERVERS                            READY   REASON   AGE
    kafka-source   ["knative-demo-topic"]   ["my-cluster-kafka-bootstrap.kafka:9092"]   True             26h
    ```

### Scaling 

To schedule more or fewer consumers, a KafkaSource can be scaled, and they can be allocated to different dispatcher pods. The kafkasource status displays such allocation under the status.placements key.

You can scale a KafkaSource with kubectl by using the following notation:

```bash
kubectl scale kafkasource -n <ns> <kafkasource-name> --replicas=<number-of-replicas> # e.g. 12 replicas for a topic with 12 partitions
```

Alternatively, if you are using a GitOps approach, you can add the `consumers` key as shown in the example below and commit it to your repository:

```yaml

    apiVersion: sources.knative.dev/v1beta1
    kind: KafkaSource
    metadata:
      name: kafka-source
    spec:
      consumerGroup: knative-group
      bootstrapServers:
      - my-cluster-kafka-bootstrap.kafka:9092 
      consumers: 12    # Number of replicas
      topics:
      - knative-demo-topic
      sink:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: event-display

```


### Verify

1. Produce a message (`{"msg": "This is a test!"}`) to the Apache Kafka topic as in the following example:

    ```bash
    kubectl -n kafka run kafka-producer -ti --image=strimzi/kafka:0.14.0-kafka-2.3.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap:9092 --topic knative-demo-topic
    ```

    !!! tip
        If you don't see a command prompt, try pressing **Enter**.

1. Verify that the Service received the message from the event source:

    ```bash
    kubectl logs --selector='serving.knative.dev/service=event-display' -c user-container
    ```

    Example output:
    ```{ .bash .no-copy }
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

## Optional: Specify the key deserializer

When `KafkaSource` receives a message from Kafka, it dumps the key in the Event extension called
`Key` and dumps Kafka message headers in the extensions starting with `kafkaheader`.

You can specify the key deserializer among four types:

* `string` (default) for UTF-8 encoded strings
* `int` for 32-bit & 64-bit signed integers
* `float` for 32-bit & 64-bit floating points
* `byte-array` for a Base64 encoded byte array

To specify the key deserializer, add the label `kafkasources.sources.knative.dev/key-type` to the
`KafkaSource` definition, as shown in the following example:

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

## Optional: Specify the initial offset

By default the `KafkaSource` starts consuming from the latest offset in each partition. If you want
to consume from the earliest offset, set the initialOffset field to `earliest`, for example:

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

!!! note
    The valid values for `initialOffset` are `earliest` and `latest`. Any other value results in a
    validation error. This field is honored only if there are no committed offsets for that
    consumer group.

## Connecting to a TLS-enabled Kafka Broker

The KafkaSource supports TLS and SASL authentication methods. To enable TLS authentication, you must have the following files:

* CA Certificate
* Client Certificate and Key

KafkaSource expects these files to be in PEM format. If they are in another format, such as JKS, convert them to PEM.

1. Create the certificate files as secrets in the namespace where KafkaSource is going to be set up, by running the commands:

    ```bash
    kubectl create secret generic cacert --from-file=caroot.pem
    ```

    ```bash
    kubectl create secret tls kafka-secret --cert=certificate.pem --key=key.pem
    ```

2. Apply the KafkaSource. Modify the `bootstrapServers` and `topics` fields accordingly.

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

## Enabling SASL for KafkaSources

Simple Authentication and Security Layer (SASL) is used by Apache Kafka for authentication. If you use SASL authentication on your cluster, users must provide credentials to Knative for communicating with the Kafka cluster, otherwise events cannot be produced or consumed.

### Prerequisites

- You have access to a Kafka cluster that has Simple Authentication and Security Layer (SASL).

### Procedure

1. Create a secret that uses the Kafka cluster's SASL information, by running the following commands:

    ```bash
    {% raw %}STRIMZI_CRT=$(kubectl -n kafka get secret example-cluster-cluster-ca-cert --template='{{index.data "ca.crt"}}' | base64 --decode ){% endraw %}
    ```

    ```bash
    {% raw %}SASL_PASSWD=$(kubectl -n kafka get secret example-user --template='{{index.data "password"}}' | base64 --decode ){% endraw %}
    ```

    ```bash
    kubectl create secret -n default generic <secret_name> \
        --from-literal=ca.crt="$STRIMZI_CRT" \
        --from-literal=password="$SASL_PASSWD" \
        --from-literal=saslType="SCRAM-SHA-512" \
        --from-literal=user="example-user"
    ```

1. Create or modify a KafkaSource so that it contains the following spec options:

    ```yaml
    apiVersion: sources.knative.dev/v1beta1
    kind: KafkaSource
    metadata:
      name: example-source
    spec:
    ...
      net:
        sasl:
          enable: true
          user:
            secretKeyRef:
              name: <secret_name>
              key: user
          password:
            secretKeyRef:
              name: <secret_name>
              key: password
          type:
            secretKeyRef:
              name: <secret_name>
              key: saslType
        tls:
          enable: true
          caCert:
            secretKeyRef:
              name: <secret_name>
              key: ca.crt
    ...
    ```

    Where `<secret_name>` is the name of the secret generated in the previous step.

## Clean up steps

1. Delete the Kafka event source:

    ```bash
    kubectl delete -f source/source.yaml kafkasource.sources.knative.dev
    ```

    Example output:
    ```{ .bash .no-copy }
    "kafka-source" deleted
    ```

2. Delete the `event-display` Service:

    ```bash
    kubectl delete -f source/event-display.yaml service.serving.knative.dev
    ```

    Example output:
    ```{ .bash .no-copy }
    "event-display" deleted
    ```

4. Optional: Remove the Apache Kafka Topic

    ```bash
    kubectl delete -f kafka-topic.yaml
    ```

    Example output:
    ```{ .bash .no-copy }
    kafkatopic.kafka.strimzi.io "knative-demo-topic" deleted
    ```
