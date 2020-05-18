KafkaBinding is responsible for injecting Kafka bootstrap connection information
into a Kubernetes resource that embed a PodSpec (as `spec.template.spec`). This
enables easy bootstrapping of a Kafka client.

## Create a Job that uses KafkaBinding

In the below example a Kubernetes Job will be using the KafkaBinding to produce
messages on a Kafka Topic, which will be received by the Event Display service
via Kafka Source

### Prerequisites

1. You must ensure that you meet the
   [prerequisites listed in the Apache Kafka overview](../README.md).
2. This feature is available from Knative Eventing 0.15+

### Creating a `KafkaSource` source CRD

1. Install the `KafkaSource` sub-component to your Knative cluster:

   ```
   kubectl apply -f https://storage.googleapis.com/knative-releases/eventing-contrib/latest/kafka-source.yaml

   ```

1. Check that the `kafka-controller-manager-0` pod is running.
   ```
   kubectl get pods --namespace knative-sources
   NAME                         READY     STATUS    RESTARTS   AGE
   kafka-controller-manager-0   1/1       Running   0          42m
   ```

### Create the Event Display service

1. (Optional) Source code for Event Display service

   Get the source code of Event Display container image from
   [here](https://github.com/knative/eventing-contrib/blob/master/cmd/event_display/main.go)

1. Deploy the Event Display Service via kubectl:

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: event-display
   spec:
     template:
       spec:
         containers:
           - image: gcr.io/knative-releases/github.com/knative/eventing-contrib/cmd/event_display
   ```

   ```
   $ kubectl apply --filename event-display.yaml
   ...
   service.serving.knative.dev/event-display created
   ```

1. (Optional) Deploy the Event Display Service via kn cli:

   Alternatively, you can create the knative service using the `kn` cli like
   below

   ```
   kn service create event-display --image=gcr.io/knative-releases/github.com/knative/eventing-contrib/cmd/event_display
   ```

1. Ensure that the Service pod is running. The pod name will be prefixed with
   `event-display`.
   ```
   $ kubectl get pods
   NAME                                            READY     STATUS    RESTARTS   AGE
   event-display-00001-deployment-5d5df6c7-gv2j4   2/2       Running   0          72s
   ...
   ```

### Apache Kafka Event Source

1. Modify `event-source.yaml` accordingly with bootstrap servers, topics,
   etc...:

   ```yaml
   apiVersion: sources.knative.dev/v1alpha1
   kind: KafkaSource
   metadata:
     name: kafka-source
   spec:
     consumerGroup: knative-group
     bootstrapServers:
       - my-cluster-kafka-bootstrap.kafka:9092 #note the kafka namespace
     topics:
       - logs
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

### Kafka Binding Resource

Create the KafkaBinding that will inject kafka bootstrap information into select
`Jobs`:

1. Modify `kafka-binding.yaml` accordingly with bootstrap servers etc...:

   ```yaml
   apiVersion: bindings.knative.dev/v1alpha1
   kind: KafkaBinding
   metadata:
     name: kafka-binding-test
   spec:
     subject:
       apiVersion: batch/v1
       kind: Job
       selector:
         matchLabels:
           kafka.topic: "logs"
     bootstrapServers:
       - my-cluster-kafka-bootstrap.kafka:9092
   ```

In this case, we will bind any `Job` with the labels `kafka.topic: "logs"`.

### Create Kubernetes Job

1. Source code for kafka-publisher service

   Get the source code of kafka-publisher container image from
   [here](https://github.com/knative/eventing-contrib/blob/master/test/test_images/kafka-publisher/main.go)

1. Now we will use the kafka-publisher container to send events to kafka topic
   when the Job runs.

   ```yaml
   apiVersion: batch/v1
   kind: Job
   metadata:
     labels:
       kafka.topic: "logs"
     name: kafka-publisher-job
     namespace: test-alpha
   spec:
     backoffLimit: 1
     completions: 1
     parallelism: 1
     template:
       metadata:
         annotations:
           sidecar.istio.io/inject: "false"
       spec:
         restartPolicy: Never
         containers:
           - image: docker.io/murugappans/kafka-publisher-1974f83e2ff7c8994707b5e8731528e8@sha256:fd79490514053c643617dc72a43097251fed139c966fd5d131134a0e424882de
             env:
               - name: KAFKA_TOPIC
                 value: "logs"
               - name: KAFKA_KEY
                 value: "0"
               - name: KAFKA_HEADERS
                 value: "content-type:application/json"
               - name: KAFKA_VALUE
                 value: '{"msg":"This is a test!"}'
             name: kafka-publisher
   ```

### Verify

1. Ensure the Event Display received the message sent to it by the Event Source.

   ```
   $ kubectl logs --selector='serving.knative.dev/service=event-display' -c user-container

   ☁️  cloudevents.Event
   Validation: valid
   Context Attributes,
     specversion: 1.0
     type: dev.knative.kafka.event
     source: /apis/v1/namespaces/default/kafkasources/kafka-source#logs
     subject: partition:0#1
     id: partition:0/offset:1
     time: 2020-05-17T19:45:02.7Z
     datacontenttype: application/json
   Extensions,
     kafkaheadercontenttype: application/json
     key: 0
     traceparent: 00-f383b779f512358b24ffbf6556a6d6da-cacdbe78ef9b5ad3-00
   Data,
     {
       "msg": "This is a test!"
     }

   ```

## Connecting to a TLS enabled Kafka broker

The KafkaBinding supports TLS and SASL authentication methods. For injecting TLS
authentication, please have the below files

- CA Certificate
- Client Certificate and Key

These files are expected to be in pem format, if it is in other format like jks
, please convert to pem.

1. Create the certificate files as secrets in the namespace where KafkaBinding
   is going to be set up

   ```
   $ kubectl create secret generic cacert --from-file=caroot.pem
   secret/cacert created

   $ kubectl create secret tls kafka-secret --cert=certificate.pem --key=key.pem
   secret/key created

   ```

2. Apply the kafkabinding-tls.yaml, change bootstrapServers accordingly.
   ```yaml
   apiVersion: sources.knative.dev/v1alpha1
   kind: KafkaBinding
   metadata:
    name: kafka-source-with-tls
   spec:
    subject:
      apiVersion: batch/v1
       kind: Job
       selector:
         matchLabels:
           kafka.topic: "logs"
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
   ```
