# How Knative brokers work - a deep dive

![An event enters a Broker. The Broker uses Triggers to forward the event to the appropriate Subscriber.](images/broker-workflow.svg)

After an event has entered a broker, it can be forwarded to subscribers by using triggers. Triggers allow events to be filtered by attributes, so that events with particular attributes can be sent to subscribers that have registered interest in events with those attributes.

A subscriber can be any URL or _Addressable_ resource. Subscribers can also reply to an active request from the broker, and can respond with a new CloudEvent that is sent back into the broker.

## Default brokers

Knative Eventing provides a `config-br-defaults` ConfigMap that contains the configuration settings that govern default Broker creation.

The default `config-br-defaults` ConfigMap is as follows:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
data:
  # Configures the default for any Broker that does not specify a spec.config or Broker class.
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: config-br-default-channel
      namespace: knative-eventing
```

### Default broker configuration example

The following is a full example of a multi-tenant (MT) channel-based Broker object which shows the possible configuration options that you can modify:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
   name: default
   namespace: default
   annotations:
     eventing.knative.dev/broker.class: MTChannelBasedBroker
 spec:
   config:
     apiVersion: v1
     kind: ConfigMap
     name: config-br-default-channel
     namespace: knative-eventing
   delivery:
     deadLetterSink:
       ref:
         kind: Service
         namespace: example-namespace
         name: example-service
         apiVersion: v1
       uri: example-uri
     retry: 5
     backoffPolicy: exponential
     backoffDelay: "2007-03-01T13:00:00Z/P1Y2M10DT2H30M"
```

- You can specify any valid `name` for your broker. Using `default` will create a broker named `default`.
- The `namespace` must be an existing namespace in your cluster. Using `default` will create the broker in the current namespace.
- You can set the `eventing.knative.dev/broker.class` annotation to change the class of the broker. The default broker class is `MTChannelBasedBroker`, but Knative also supports use of the `Kafka` broker class. For more information about Kafka brokers, see the [Apache Kafka Broker](kafka-broker/README.md) documentation.
- `spec.config` is used to specify the default backing channel configuration for MT channel-based broker implementations.
- `spec.delivery` is used to configure event delivery options. Event delivery options specify what happens to an event that fails to be delivered to an event sink. For more information, see the documentation on [Event delivery](../event-delivery.md).
