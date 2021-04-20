---
title: "Broker configuration example"
weight: 04
type: "docs"
showlandingtoc: "false"
---

The following is a full example of a Broker object that shows the possible configurations that you can modify:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
   name: example-broker
   namespace: example-namespace
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

- You can set the `eventing.knative.dev/broker.class` annotation to change the class of the broker. The default broker class is `MTChannelBasedBroker`, but Knative also supports use of the `KafkaBroker` class. For more information about Kafka brokers, see the [Apache Kafka Broker](./kafka-broker) documentation.
