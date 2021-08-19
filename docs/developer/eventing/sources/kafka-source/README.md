# Apache Kafka Source Example

Tutorial on how to build and deploy a `KafkaSource` event source.

## Background

The `KafkaSource` reads all the messages, from all partitions, and sends those messages as CloudEvents via HTTP to its configured `sink`.

!!! note
    If need a more sophisticated Kafka Consumer, with direct access to specific partitions or offsets, you can implement a Kafka Consumer by using one of the available Apache Kafka SDKs.

<!--TODO: Check if this note is out of scope; should we not mention anything beyond the direct Knative/Kafka integration we provide?-->

## Installing the Kafka event source CRD

- A Kubernetes cluster with the Kafka event source installed. You can install the Kafka event source by using [YAML](../../../../admin/install/eventing/install-eventing-with-yaml.md#optional-install-a-default-channel-messaging-layer) or the [Knative Operator](../../../../admin/install/knative-with-operators.md/#installing-with-different-eventing-sources).

```bash
kubectl apply -f https://storage.googleapis.com/knative-nightly/eventing-kafka/latest/source.yaml
```
<!--Taken from https://github.com/knative-sandbox/eventing-kafka - not sure if there's a newer command-->

## Optional: Create a Kafka topic

1. If you are using Strimzi, create a KafkaTopic:

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

2. Deploy the `KafkaTopic` by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```

    Where `<filename>` is the name of your KafkaTopic YAML file.

    Example output:

    ```bash
    kafkatopic.kafka.strimzi.io/knative-demo-topic created
    ```

3. Ensure that the `KafkaTopic` is running, by running the command:

    ```bash
    kubectl -n kafka get kafkatopics.kafka.strimzi.io
    ```

    Example output:

    ```bash
    NAME                 AGE
    knative-demo-topic   16s
    ```

## Create a Service

1. Clone the sample code Github repository, and navigate to the local directory of the repository:

    ```bash
    git clone -b "{{ branch }}" https://github.com/knative/docs knative-docs
    ```

    ```bash
    cd knative-docs/docs/eventing/samples/kafka/source
    ```

2. Create the `event-display` Service as a YAML file:

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

    ```bash
    service.serving.knative.dev/event-display created
    ```

1. Ensure that the Service pod is running, by running the command:

    ```bash
    kubectl get pods
    ```

    The pod name is prefixed with `event-display`:

    ```bash
    NAME                                            READY     STATUS    RESTARTS   AGE
    event-display-00001-deployment-5d5df6c7-gv2j4   2/2       Running   0          72s
    ```

### Kafka event source

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

1. Deploy the event source:

    ```bash
    kubectl apply -f event-source.yaml
    ...
    kafkasource.sources.knative.dev/kafka-source created
    ```

1. Check that the event source pod is running. The pod name will be prefixed
   with `kafka-source`.

    ```bash
    kubectl get pods
    NAME                                  READY     STATUS    RESTARTS   AGE
    kafka-source-xlnhq-5544766765-dnl5s   1/1       Running   0          40m
    ```

1. Ensure the Apache Kafka Event Source started with the necessary
   configuration.

    ```bash
    kubectl logs --selector='knative-eventing-source-name=kafka-source'
    {"level":"info","ts":"2020-05-28T10:39:42.104Z","caller":"adapter/adapter.go:81","msg":"Starting with config: ","Topics":".","ConsumerGroup":"...","SinkURI":"...","Name":".","Namespace":"."}
    ```

### Verify

1. Produce a message (`{"msg": "This is a test!"}`) to the Apache Kafka topic as in the following example:

    ```bash
    kubectl -n kafka run kafka-producer -ti --image=strimzi/kafka:0.14.0-kafka-2.3.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap:9092 --topic knative-demo-topic
    If you don't see a command prompt, try pressing enter.
    >{"msg": "This is a test!"}
    ```

1. Check that the Apache Kafka Event Source consumed the message and sent it to
   its sink properly. Since these logs are captured in debug level, edit the key `level` of `config-logging` configmap in `knative-sources` namespace to look like this:

    ```bash
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

    ```bash
    kubectl logs --selector='knative-eventing-source-name=kafka-source'
    ...

    {"level":"debug","ts":"2020-05-28T10:40:29.400Z","caller":"kafka/consumer_handler.go:77","msg":"Message claimed","topic":".","value":"."}
    {"level":"debug","ts":"2020-05-28T10:40:31.722Z","caller":"kafka/consumer_handler.go:89","msg":"Message marked","topic":".","value":"."}
    ```

1. Ensure the Event Display received the message sent to it by the Event Source.

    ```bash
    kubectl logs --selector='serving.knative.dev/service=event-display' -c user-container

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

## Clean up steps

1. Delete the Kafka event source:

    ```bash
    kubectl delete -f source/source.yaml kafkasource.sources.knative.dev
    "kafka-source" deleted
    ```

2. Delete the `event-display` Service:

    ```bash
    kubectl delete -f source/event-display.yaml service.serving.knative.dev
    "event-display" deleted
    ```

3. Remove the Kafka event controller:

    ```bash
    kubectl delete -f https://storage.googleapis.com/knative-releases/eventing-contrib/latest/kafka-source.yaml
    serviceaccount "kafka-controller-manager" deleted
    clusterrole.rbac.authorization.k8s.io "eventing-sources-kafka-controller"
    deleted clusterrolebinding.rbac.authorization.k8s.io
    "eventing-sources-kafka-controller" deleted
    customresourcedefinition.apiextensions.k8s.io "kafkasources.sources.knative.dev"
    deleted service "kafka-controller" deleted statefulset.apps
    "kafka-controller-manager" deleted
    ```

4. Optional: Remove the Apache Kafka Topic

    ```bash
    kubectl delete -f kafka-topic.yaml
    kafkatopic.kafka.strimzi.io "knative-demo-topic" deleted
    ```

## Optional: Specify the key deserializer

When `KafkaSource` receives a message from Kafka, it dumps the key in the Event
extension called `Key` and dumps Kafka message headers in the extensions
starting with `kafkaheader`.

You can specify the key deserializer among four types:

* `string` (default) for UTF-8 encoded strings
* `int` for 32-bit & 64-bit signed integers
* `float` for 32-bit & 64-bit floating points
* `byte-array` for a Base64 encoded byte array

To specify the key deserializer, add the label `kafkasources.sources.knative.dev/key-type` to the `KafkaSource` definition, as shown in the following example:

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

<<<<<<< HEAD
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
=======
## Connecting to a TLS-enabled Kafka broker
>>>>>>> 82d4022c... remove link, add command instead

The KafkaSource supports TLS and SASL authentication methods. To enable TLS authentication, you must have the following files:

* CA Certificate
* Client Certificate and Key

KafkaSource expects these files to be in pem format, if it is in other format like jks, please convert to pem.

1. Create the certificate files as secrets in the namespace where KafkaSource is going to be set up, by running the commands:

    ```bash
    kubectl create secret generic cacert --from-file=caroot.pem
    secret/cacert created
    ```

    ```bash
    kubectl create secret tls kafka-secret --cert=certificate.pem --key=key.pem
    secret/key created
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
