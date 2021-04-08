---
title: "Configuring brokers"
weight: 100
type: "docs"
showlandingtoc: "false"
---


The following example is more complex, and demonstrates the use of `deadLetterSink` configuration to send failed events to Knative Service called `dlq-service`:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
  name: default
spec:
  # Configuration specific to this broker.
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
  # Where to deliver Events that failed to be processed.
  delivery:
    deadLetterSink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: dlq-service
```

See also: [Delivery Parameters](../event-delivery.md#configuring-broker-delivery)
