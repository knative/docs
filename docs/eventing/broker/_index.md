---
title: "Brokers"
weight: 01
type: "docs"
showlandingtoc: "false"
---

Brokers are Kubernetes [custom resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) that define an event mesh for collecting a pool of events, and provide a discoverable endpoint, `status.address`, for event delivery.

<img src="images/broker-workflow.png" width="80%">

Once an event has entered a broker, it can be forwarded to subscribers or sinks by using triggers.

Triggers allow events to be filtered by class, so that events of a particular class can be sent to subscribers that have registered interest in that class of events. A subscriber or sink can be any URL or Addressable endpoint. This event delivery mechanism hides details of event routing from the event producer and event consumer.

## Next steps

- Learn about [supported broker types](broker-types)
- Create a [broker](create-broker)
- Create a [trigger](create-triggers)

## Default Broker configuration

Knative Eventing provides a `config-br-defaults` ConfigMap, which lives in the
`knative-eventing` namespace, and provides default configuration settings to
enable the creation of Brokers and Channels by using defaults.
For more information, see the [`config-br-defaults`](./config-br-defaults.md) ConfigMap documentation.

Create a Broker using the default settings:

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: default
  namespace: default
EOF
```




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
