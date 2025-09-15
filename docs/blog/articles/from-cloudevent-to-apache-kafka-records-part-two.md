# From CloudEvents to Apache Kafka Records, Part II

**Authors: Daniele Zonca, Senior Principal Software Engineer @ Red Hat, Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

_In this blog post you will learn how to easily store incoming CloudEvents to an Apache Kafka Topic and using Knative Broker and Trigger APIs for content-based event routing._


The [first part](https://knative.dev/blog/articles/from-cloudevent-to-apach-kafka-records-part-one/) of this post explained how Knative helps to ingest CloudEvents to an Apache Kafka topic for further processing. The article showed the processing of the CloudEvents Kafka Record with a standard tool from the Apache Kafka ecosystem, like the [`kcat`](https://github.com/edenhill/kcat) CLI. In addition, the post also explained the **benefits** of the [binary content mode](https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/bindings/kafka-protocol-binding.md#32-binary-content-mode) of CloudEvents, which Knative defaults to. Now, in this article we show a different approach to process the ingested CloudEvents, by leveraging the Knative Broker and Trigger APIs for the event routing.


### Setting up Apache Kafka and the Knative Broker

In order to use the Knative Broker for Apache Kafka you need to install Apache Kafka first. For this post we are using a local Apache Kafka installation, powered by [Strimzi](https://strimzi.io), as described [here](https://knative.dev/blog/articles/single-node-kafka-development/). The article also discusses how to install the Knative Broker for Apache Kafka for a [local development environment](https://knative.dev/blog/articles/single-node-kafka-development/#installing-knative-eventing-and-the-knative-broker-for-apache-kafka).


!!! note
    For a production-ready configuration of the Knative Broker for Apache Kafka see [this blog](https://developers.redhat.com/articles/2023/03/08/configuring-knative-broker-apache-kafka).


### Setting up the Knative Broker component

The above-mentioned article configures all Knative `Broker`s to be in shape of the `Kafka` class, therefore creating a new broker for Apache Kafka is pretty straightforward: 

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: my-demo-kafka-broker
  annotations:
    eventing.knative.dev/broker.class: Kafka
spec: {}
```

The `Broker` is an [`Addressable`](https://knative.dev/docs/eventing/sinks/) type, which can receive incoming CloudEvents over HTTP to an address defined in their `status.address.url` field:

```
kubectl get brokers.eventing.knative.dev
NAME                   URL                                                                                           AGE   READY   REASON
my-demo-kafka-broker   http://kafka-broker-ingress.knative-eventing.svc.cluster.local/default/my-demo-kafka-broker   7s    True    
```

!!! note
    The Broker is reachable at the mentioned URL, inside the cluster. It is possible to create (and also [secure](https://knative.dev/docs/eventing/brokers/broker-admin-config-options/#protect-a-knative-broker-by-using-json-web-token-jwt-and-istio)) an `Ingress` to do it. For development, you can also directly use `kn` command line to send events, see [Kn Event Plugin](#kn-event-plugin) section.

But we do not see any information about the Apache Kafka Topic. The reason is that the topic used by the Broker implementation is considered an implementation detail. Let us have a look at the actual broker object:

```
kubectl get brokers.eventing.knative.dev my-demo-kafka-broker -o yaml 
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: Kafka
  name: my-demo-kafka-broker
  namespace: default
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: kafka-broker-config
    namespace: knative-eventing
status:
  address:
    url: http://kafka-broker-ingress.knative-eventing.svc.cluster.local/default/my-demo-kafka-broker
  annotations:
    bootstrap.servers: my-cluster-kafka-bootstrap.kafka:9092
    default.topic: knative-broker-default-my-demo-kafka-broker
    default.topic.partitions: "10"
    default.topic.replication.factor: "1"
```

The above gives a simplified version of the YAML representation, but note the `spec.config`: It points to the default configuration for all Kafka-enabled Knative Brokers in the cluster. The `kafka-broker-config` ConfigMap configures the notion of the underlying topics, by defining knobs like `partition` or `replication factor`. However, in the `status` of the broker you see the name of the topic: `knative-broker-default-my-demo-kafka-broker`. The name is following the convention `knative-broker-<namespace>-<broker-name>`.

!!! note
    By default the Knative Kafka Broker creates its own internal topic, however this action might be restricted in some environments. For this and any other similar use cases, it is possible to [bring your own topic](https://knative.dev/docs/eventing/brokers/broker-types/kafka-broker/#bring-your-own-topic). 

### Setting up the Consumer application

Now that we have the `Broker`, which will act as the HTTP endpoint for ingesting the CloudEvents, it is time to define an application that is receiving _and_ processing the CloudEvents:


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: log-receiver
  labels:
    app: log-receiver
spec:
  containers:
  - name: log-receiver
    image: gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
    imagePullPolicy: Always
    ports:
    - containerPort: 8080
      protocol: TCP
      name: log-receiver
---
apiVersion: v1
kind: Service
metadata:
  name: log-receiver
spec:
  selector:
    app: log-receiver
  ports:
    - port: 80
      protocol: TCP
      targetPort: log-receiver
      name: http
```

Here we define a simple `Pod` and its `Service`, which points to an HTTP-Server, that receives the CloudEvents. As you can see, this is **not** a Kafka specific consumer, _any_ HTTP Webserver, in any language, can be used for processing the CloudEvents coming from an Apache Kafka Topic.

The developers of the consumer applications do not need to know any detail about how to program a Kafka consumer application. Knative with its Broker implementation for Apache Kafka abstracts this away, by acting as an HTTP proxy for the consumer applications. This does dramatically simplify the engineering efforts for these focused and self-contained consumer applications.

### Defining rules for message routing with Apache Kafka

It is quite common that a Topic in Apache Kafka is used to contain different types of events that maybe refer to the same [Bounded Context](https://martinfowler.com/bliki/BoundedContext.html) (if you are applying Domain-Driven Design principles). This means that each consumer is going to receive all the events only to filter and process a subset of them.

This is one of the downsides of the Apache Kafka protocol: there is no direct filter API for routing of the Records. In order to process or filter events and route them to a different destination, or other Kafka topic, a fully fledged Kafka consumer client needs to be implemented. Or the usage of additional libraries like [Kafka Streams](https://kafka.apache.org/documentation/streams/) is required.

As you can imagine this is a quite common pattern and Knative Eventing makes it part of the API. The `Trigger` API defines a [powerful set of filters](https://knative.dev/docs/eventing/triggers/) to route CloudEvents based on their metadata:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: log-trigger
spec:
  broker: my-demo-kafka-broker
  filter:
    attributes:
      type: <cloud-event-type>
      <ce-extension>: <ce-extension-value>
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: log-receiver
```

We see a Trigger that defines a set of `filter` rules, if those are matching, the CloudEvent from the Kafka topic is routed, using HTTP, to our referenced webserver application. There is also an [_experimental feature_ in Knative](https://knative.dev/docs/eventing/experimental-features/new-trigger-filters/) which enables a new SQL-like filtering using the `filters` field on the `Trigger` API that implements [CloudEvents Subscriptions API](https://github.com/cloudevents/spec/blob/main/subscriptions/spec.md#324-filters).

!!! note
    It is highly recommended applying filter attributes on the `Trigger`s for the CloudEvents metadata attributes and extensions. If **no** filter is provided, all occurring CloudEvents are routed to the referenced subscriber, which is a bad application design, expect if you explicitly want to have a logger for all events in the broker.

For `Trigger`s that are executed by a Knative Broker for Apache Kafka it is also possible to [configure the order of delivered events](https://knative.dev/docs/eventing/brokers/broker-types/kafka-broker/#configuring-the-order-of-delivered-events), using the `kafka.eventing.knative.dev/delivery.order` annotation on the `Trigger`.

### Kn Event Plugin

For sending an event we also do not need to make use of the Apache Kafka Producer API, since we are ingesting CloudEvents to the Broker, using HTTP. As one option we could use a `Pod` inside the Kubernetes cluster with the `curl` program installed and send an event to the `URL` of the `Broker`. However, instead we are using the [`kn` client CLI](https://github.com/knative/client) with its [event plugin](https://github.com/knative-extensions/kn-plugin-event) for managing cloud events from command line:

```
kn event send \
  --to Broker:eventing.knative.dev/v1:my-demo-kafka-broker \
  --type=dev.knative.blog.post \
  -f message="Hello"
```

With the above command we are sending a `message` as a CloudEvents with the `dev.knative.blog.post` type to our `my-demo-kafka-broker` object. The `kn event` plugin generates a valid CloudEvent from this invocation and sends it directly to the addressable URL of the referenced component, in this example our `Broker`.

### Conclusion

The example showed a simple flow from sending events to receiving them. The messages are persistent on the Kafka Topic behind the Knative Broker. From there it could be also consumed by any standard Apache Kafka API. However the abstraction that Knative offers simplifies the development process of event-driven applications. Without too much extra configuration it is also possible to filter and route events on their metadata.

In addition, the adoption of `Trigger`/`Filter` is not just a way to avoid to reimplement the same pattern in all consumers, but it also makes the whole message processing more efficient because the consumer is _only_ invoked when necessary, and it can even scale to zero if it is a Knative Service!
