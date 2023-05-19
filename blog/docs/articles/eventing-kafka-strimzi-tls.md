# How To: process events coming from an Apache Kafka cluster managed by Strimzi operator with TLS authentication and encryption

**Date: 2023-05-18**

***Author: [Pierangelo Di Pilato](https://twitter.com/pierDipi), Knative Eventing Working Group
Lead, Software Engineer @ Red Hat***

**Introduction**

Apache Kafka has gained immense popularity as a distributed streaming platform, allowing developers
to build scalable and fault-tolerant event-driven applications. Strimzi, an open-source project,
simplifies the management of Apache Kafka on Kubernetes by providing operators for Kafka and
ZooKeeper. In this tutorial, we will explore how to process events from an Apache Kafka cluster
managed by the Strimzi operator using Knative Eventing KafkaSource.

**Prerequisites**

To follow this tutorial, you should have the following prerequisites in place:

1. A Kubernetes cluster.
2. Strimzi operator installed, see [deploy Strimzi](https://strimzi.io/quickstarts/).
3. Knative Eventing installed on the Kubernetes cluster, see [Install Knative Eventing](https://knative.dev/docs/install/yaml-install/eventing/install-eventing-with-yaml/#install-knative-eventing).
4. Knative Eventing Kafka Source installed on the Kubernetes cluster, see [Install the KafkaSource controller](https://knative.dev/docs/eventing/sources/kafka-source/#install-the-kafkasource-controller).

**Step 1: Create a Kafka cluster**

```shell
kubectl apply -f - <<EOF
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: my-kafka-cluster
  namespace: kafka
spec:
  kafka:
    replicas: 3
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
        authentication:
          type: tls
    authorization:
      type: simple
    storage:
      type: ephemeral
    config:
      offsets.topic.replication.factor: 3
      transaction.state.log.replication.factor: 3
      transaction.state.log.min.isr: 2
  zookeeper:
    replicas: 3
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: { }
    userOperator: { }
EOF
```

Make sure to replace `my-kafka-cluster` with your desired name for the Kafka cluster. Once you apply
this updated YAML, the Kafka cluster will be provisioned with a TLS listener enabled.

After the Kafka cluster is provisioned with TLS listener, you can proceed with using Knative
Eventing KafkaSource to consume events from the Kafka topics using the TLS listener configuration.

**Step 2: Create a KafkaTopic**

Before we can start processing events from Kafka, we need to create a KafkaTopic that represents the
topic we want to consume events from. Use the following YAML to create a KafkaTopic:

```shell
kubectl apply -f - <<EOF
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: my-demo-topic
  namespace: kafka
  labels:
    strimzi.io/cluster: my-kafka-cluster
spec:
  partitions: 1
  replicas: 1
EOF
```

Replace `<your-kafka-cluster-name>` with the name of your Kafka cluster managed by the Strimzi
operator.

**Step 3: Create a KafkaUser**

```shell
kubectl apply -f - <<EOF
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaUser
metadata:
  name: my-tls-user
  namespace: kafka
  labels:
    strimzi.io/cluster: my-kafka-cluster
spec:
  authentication:
    type: tls
  authorization:
    type: simple
    acls:
      # Example ACL rules for consuming from a topic.
      - resource:
          type: topic
          name: "my-demo-topic"
          patternType: literal
        operations: 
        - Read
        - Describe
        - Write
        - Create
        host: "*"
      - resource:
          type: group
          name: "*"
          patternType: literal
        operations:
        - Create
        - Read
        - Describe
        - Delete
        - Write
        host: "*"
EOF
```

**Step 4: Create a secret for KafkaSource**

```shell
kubectl create secret generic kafka-secret \
  --from-literal=ca.crt="$(kubectl get secrets -n kafka my-kafka-cluster-cluster-ca-cert -o=jsonpath='{.data.ca\.crt}' | base64 -d)" \
  --from-literal=user.crt="$(kubectl get secrets -n kafka my-tls-user -o=jsonpath='{.data.user\.crt}' | base64 -d)" \
  --from-literal=user.key="$(kubectl get secrets -n kafka my-tls-user -o=jsonpath='{.data.user\.key}' | base64 -d)" \
  --from-literal=protocol="SSL"
```

**Step 5: Create a KafkaSource**

Next, we need to create a KafkaSource, which is a Knative Eventing resource that connects to the
Kafka cluster and consumes events from a specific topic. Use the following YAML as a starting point:

```shell
kubectl apply -f - <<EOF
apiVersion: sources.knative.dev/v1beta1
kind: KafkaSource
metadata:
  name: my-kafka-source
spec:
  topics:
  - my-demo-topic
  # Use the TLS listener port
  bootstrapServers: 
  - my-kafka-cluster-kafka-bootstrap.kafka:9093
  net:
    tls:
      enable: true
      cert:
        secretKeyRef:
          key: user.crt
          name: kafka-secret
      key:
        secretKeyRef:
          key: user.key
          name: kafka-secret
      caCert:
        secretKeyRef:
          key: ca.crt
          name: kafka-secret
  sink:
    ref:
      apiVersion: v1
      kind: Service
      name: my-event-display-service
---
apiVersion: v1
kind: Service
metadata:
  name: my-event-display-service
spec:
  selector:
    app: event-display
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: event-display
  labels:
    app: event-display
spec:
  containers:
    - name: event-display
      image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
      ports:
        - containerPort: 8080
EOF
```

**Verification**

***Step 1: Verify that KafkaSource is ready***

```shell
kubectl get kafkasource my-kafka-source
```

Example output:
```shell
NAME              TOPICS              BOOTSTRAPSERVERS                                  READY   REASON   AGE
my-kafka-source   ["my-demo-topic"]   ["my-kafka-cluster-kafka-bootstrap.kafka:9093"]   True             22m
```

***Step 2: Create a KafkaSink***

To verify that the KafkaSource works, we will use a KafkaSink for simplicity.

```shell
kubectl apply -f - <<EOF
apiVersion: eventing.knative.dev/v1alpha1
kind: KafkaSink
metadata:
   name: my-kafka-sink
spec:
   topic: my-demo-topic
   bootstrapServers:
      - my-kafka-cluster-kafka-bootstrap.kafka:9093
   auth:
     secret:
       ref:
         name: kafka-secret
EOF
```

***Step 3: Get the KafkaSink URL***

```shell
kubectl get kafkasinks
```

Example output:
```shell
NAME            URL                                                                                  AGE     READY   REASON
my-kafka-sink   http://kafka-sink-ingress.knative-eventing.svc.cluster.local/default/my-kafka-sink   2m46s   True    
```

***Step 4: Send event to KafkaSink URL***

```shell
kubectl run curl  --image=docker.io/curlimages/curl --rm=true --restart=Never -ti \
  -- -X POST -v \
  -H "content-type: application/json" \
  -H "ce-specversion: 1.0" \
  -H "ce-source: my/curl/command" \
  -H "ce-type: my.demo.event" \
  -H "ce-id: 6cf17c7b-30b1-45a6-80b0-4cf58c92b947" \
  -d '{"name":"Knative Demo"}' \
  http://kafka-sink-ingress.knative-eventing.svc.cluster.local/default/my-kafka-sink
```

Example output:
```shell
*   Trying 10.96.19.218:80...
* Connected to kafka-sink-ingress.knative-eventing.svc.cluster.local (10.96.19.218) port 80 (#0)
> POST /default/my-kafka-sink HTTP/1.1
> Host: kafka-sink-ingress.knative-eventing.svc.cluster.local
> User-Agent: curl/8.1.0-DEV
> Accept: */*
> content-type: application/json
> ce-specversion: 1.0
> ce-source: my/curl/command
> ce-type: my.demo.event
> ce-id: 6cf17c7b-30b1-45a6-80b0-4cf58c92b947
> Content-Length: 23
> 
< HTTP/1.1 202 Accepted
< content-length: 0
< 
* Connection #0 to host kafka-sink-ingress.knative-eventing.svc.cluster.local left intact
pod "curl" deleted
```

***Step 5: Viewing events sent by KafkaSink to event display***

```shell
kubectl logs event-display -f
```

Example output:
```shell
☁️  cloudevents.Event
Context Attributes,
  specversion: 1.0
  type: my.demo.event
  source: my/curl/command
  id: 6cf17c7b-30b1-45a6-80b0-4cf58c92b947
  datacontenttype: application/json
Data,
  {
    "name": "Knative Demo"
  }
```

**Conclusion**

In this tutorial, we explored how to process events coming from an Apache Kafka cluster managed by
the Strimzi operator using Knative Eventing KafkaSource. By creating a KafkaTopic and a KafkaSource,
we established a connection between the Kafka cluster and our Service. This allowed us to
consume and process events from a specific Kafka topic. Knative Eventing, in conjunction with the
Strimzi operator, provides a powerful platform for building event-driven applications on Kubernetes.

