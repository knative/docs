# Broker configuration example

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
- You can set the `eventing.knative.dev/broker.class` annotation to change the class of the broker. The default broker class is `MTChannelBasedBroker`, but Knative also supports use of the `Kafka` broker class. For more information about Kafka brokers, see the [Apache Kafka Broker](../kafka-broker) documentation.
- `spec.config` is used to specify the default backing channel configuration for MT channel-based broker implementations. For more information on configuring the default channel type, see the documentation on [ConfigMaps](../configmaps).
- `spec.delivery` is used to configure event delivery options. Event delivery options specify what happens to an event that fails to be delivered to an event sink. For more information, see the documentation on [broker event delivery](../broker-event-delivery).
