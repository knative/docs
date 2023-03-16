# From CloudEvents to Apache Kafka Records, Part I

**Authors: Daniele Zonca, Senior Principal Software Engineer @ Red Hat, Matthias Weßendorf, Principal Software Engineer @ Red Hat**

**Date: 2023-03-08**

_In this blog post you will learn how to easily store incoming CloudEvents to an Apache Kafka Topic using the KafkaSink component._


Apache Kafka is used in a lot of very different use cases but the need to adopt Kafka protocol can be a barrier especially when there are third party components with limited extension possibilities.

There are producer of events that do not support Kafka protocol and HTTP can be a more flexible option. Strimzi project has a [Bridge component](https://strimzi.io/docs/bridge/latest/) that exposes producer/consumer API via HTTP but it is specific for Kafka so it is essentially the same protocol (with consumer group, offset, etc).

Do you think CloudEvents requirement might be an issue? CloudEvents defines a [binding also for HTTP format](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/bindings/http-protocol-binding.md#31-binary-content-mode) also and especially in binary mode, most of HTTP payload are possibly already a valid CloudEvents!

The [Knative Sink for Apache Kafka](https://knative.dev/docs/eventing/sinks/kafka-sink/) is a Kafka-native implementation for a CloudEvent ingress and persisting the event as a Apache Kafka Record on a configurable topic.

### Setting up the Apache Kafka Topic

In order use the `KafkaSink` component you need to have a topic for Apache Kafka with the proper access to it. For this post we are using a local Apache Kafka installation, powered by [Strimzi](https://strimzi.io), as described [here](https://knative.dev/blog/articles/single-node-kafka-development/). Once the Apache Kafka cluster is running in your Kubernetes environment it is time to create the topic. For this, we are using the `KafkaTopic` CRD from Strimzi to create a topic in a standard declarative Kubernetes way:

```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: my-topic
  namespace: kafka
  labels:
    strimzi.io/cluster: my-cluster
spec:
  partitions: 1
  replicas: 1
```

This will create a simple topic, with `partitions` and `replicas` both set to `1`, which is **not** recommended on a production environment.

> NOTE: For a production-ready configuration of the Knative Kafka Broker see [this blog](https://developers.redhat.com/articles/2023/03/08/configuring-knative-broker-apache-kafka).

Once the manifest has been applied to the Kubernetes cluster it can be queried like:

```
kubectl get kafkatopics.kafka.strimzi.io -n kafka
NAME       CLUSTER      PARTITIONS   REPLICATION FACTOR   READY
my-topic   my-cluster   1            1                    True

```

### Setting up the KafkaSink component


The installation for the Knative Sink for Apache Kafka is described [here](https://knative.dev/docs/eventing/sinks/kafka-sink/).

Next we are going to create an instance of the `KafkaSink`, which we bind to the `my-topic` Topic on our local Strimzi-based Apache Kafka cluster:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: KafkaSink
metadata:
  name: my-kafka-sink
  namespace: default
spec:
  topic: my-topic
  bootstrapServers:
   - my-cluster-kafka-bootstrap.kafka:9092
```

The `KafkaSink` is an [`Addressable`](https://knative.dev/docs/eventing/sinks/) type, which can receive incoming CloudEvents over HTTP to an address defined in their `status.address.url` field:

```
kubectl get kafkasinks.eventing.knative.dev
NAME            URL                                                                                  AGE   READY   REASON
my-kafka-sink   http://kafka-sink-ingress.knative-eventing.svc.cluster.local/default/my-kafka-sink   13s   True
```

### Kn Event Plugin

At this point we could just use a pod inside the Kubernetes cluster with the `curl` program installed and send an event to the `URL` of the `KafkaSink`.

However, we are instead using the [`kn` client CLI](https://github.com/knative/client) with its [event plugin](https://github.com/knative-sandbox/kn-plugin-event) for managing cloud events from command line:

```
kn event send \
  --to KafkaSink:eventing.knative.dev/v1alpha1:my-kafka-sink \
  --type=dev.knative.blog.post \
  -f message="Hello"
```

With the above command we are sending a `message` as a CloudEvents with the `dev.knative.blog.post` to our `my-kafka-sink` object. The `kn event` plugin generates a valid CloudEvents from this invocation and sends it directly to the addressable URL of the referenced sink.


### Event processing with kcat

[kcat](https://github.com/edenhill/kcat) is the project formerly known as as kafkacat and offers command line modes for producing and consuming records from Apache Kafka.

This allows us to consume the Apache Kafka record (as CloudEvent) stored in the `my-topic` topic of our Apache Kafka cluster:

```
kubectl run kcat -ti --image=docker.io/edenhill/kcat:1.7.1 --rm=true --restart=Never -- -C -b my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092 -t my-topic -f '\nHeaders: %h\nMessage value: %s\n\n '
```
The above command will print all headers of the Kafka record and its value, like:

```
Headers: ce_specversion=1.0,ce_id=ce5026d0-234e-4997-975a-c005f515fedf,ce_source=kn-event/v1.9.0,ce_type=ype=dev.knative.blog.post,content-type=application/json,ce_time=2023-02-13T12:52:20.654526321Z
Message value: {"message":"Hello"}

% Reached end of topic my-topic [0] at offset 2
```

### CloudEvents Binary mode


It is important to note that the `KafkaSink` stores incoming CloudEvents as Kafka records, using the [binary content mode](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/bindings/kafka-protocol-binding.md#32-binary-content-mode) by default, because it is more efficient due to its optimizations for transport or routing, as well avoid JSON parsing. Using `binary content mode` means all CloudEvents attributes and extensions are mapped as [headers on the Kafka record](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/bindings/kafka-protocol-binding.md#323-metadata-headers), while the `data` of the CloudEvent corresponds to the actual value of the Kafka record. This is another benefit of using `binary content mode` over `structured content mode` as it is less _obstructive_ and therefore compatible with systems that do not understand CloudEvents.

### Outlook

The messages stored in the Kafka topic backed by the Knative `KafkaSink` component can be easily consunmed by any consumer application in the larger ecosystem of the Apache Kafka community. The next post in this article will show how to use the Knative Broker implementation for Apache Kafka to store incoming events and make use of the Knative Eventing tools for routing based on CloudEvents metadata as this filtering feature is not directly build into Apache Kafka itself.
