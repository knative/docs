---
title: "Event delivery"
weight: 50
type: "docs"
---

## Overview

Knative Eventing provides various configuration parameters to control the delivery
of events in case of failure. For instance, you can decide to retry sending events
that failed to be consumed, and if this didn't work you can decide to forward those
events to a dead letter sink.

## Configuring Subscription Delivery

Knative Eventing offers fine-grained control on how events are delivered for each subscription by adding a `delivery` section. Consider this example:

```yaml
apiVersion: messaging.knative.dev/v1beta1
kind: Subscription
metadata:
  name: with-dead-letter-sink
spec:
  channel:
    apiVersion: messaging.knative.dev/v1beta1
    kind: InMemoryChannel
    name: default
  delivery:
    deadLetterSink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: error-handler
  subscriber:
    uri: http://doesnotexist.default.svc.cluster.local
```

The `deadLetterSink` specifies where to send events that failed be consumed by `subscriber`.

## Common Delivery Parameters

### deadLetterSink

When present, events that failed to be consumed are sent to the `deadLetterSink`.
In case of failure, the event is dropped and an error is logged into the system.

The `deadLetterSink` value must be a [Destination](https://pkg.go.dev/knative.dev/pkg/apis/duck/v1#Destination).

```yaml
spec:
  delivery:
    deadLetterSink: <Destination>
```

## Channel Support

The table below summarizes what delivery parameters are supported for each channel implementation.

| Channel Type | Supported Delivery Parameters |
| - | - |
| In-Memory | `deadLetterSink` |
| Kafka | none |
| Natss | none |
| GCP PubSub | none |
