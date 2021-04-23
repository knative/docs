---
title: "Event delivery"
weight: 50
type: "docs"
---

You can configure event delivery parameters for Knative Eventing components that are applied in cases where an event fails to be delivered

## Configuring subscription event delivery

You can configure how events are delivered for each subscription by adding a `delivery` spec to the `Subscription` object, as shown in the following example:

```yaml
apiVersion: messaging.knative.dev/v1
kind: Subscription
metadata:
  name: example-subscription
  namespace: example-namespace
spec:
  delivery:
    deadLetterSink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: example-sink
    backoffDelay: <duration>
    backoffPolicy: <policy-type>
    retry: <integer>
```

Where

- The `deadLetterSink` spec contains configuration settings to enable using a dead letter sink. This tells the subscription what happens to events that cannot be delivered to the subscriber. When this is configured, events that fail to be delivered are sent to the dead letter sink destination. The destination can be a Knative service or a URI. In the example, the destination is a `Service` object, or Knative service, named `example-sink`.
- The `backoffDelay` delivery parameter specifies the time delay before an event delivery retry is attempted after a failure. The duration of the `backoffDelay` parameter is specified using the ISO 8601 format. For example, `PT1S` specifies a 1 second delay.
- The `backoffPolicy` delivery parameter can be used to specify the retry back off policy. The policy can be specified as either `linear` or `exponential`. When using the `linear` back off policy, the back off delay is the time interval specified between retries. When using the `exponential` back off policy, the back off delay is equal to `backoffDelay*2^<numberOfRetries>`.
- `retry` specifies the number of times that event delivery is retried before the event is sent to the dead letter sink.

## Broker event delivery

See the [broker](./broker/broker-event-delivery) documentation.

## Channel event delivery

Failed events may, depending on the specific Channel implementation in use, be
enhanced with extension attributes prior to forwarding to the`deadLetterSink`.
These extension attributes are as follows:

- **knativeerrorcode**
    - **Type:** Int
    - **Description:** The HTTP Response **StatusCode** from the final event
      dispatch attempt.
    - **Constraints:** Should always be present as every HTTP Response contains
      a **StatusCode**.
    - **Examples:**
        - "500"
        - ...any HTTP StatusCode...

- **knativeerrordata**
    - **Type:** String
    - **Description:** The HTTP Response **Body** from the final event dispatch
      attempt.
    - **Constraints:** Will be empty if the HTTP Response **Body** was empty,
      and might be truncated if the length is excessive.
    - **Examples:**
        - 'Internal Server Error: Failed to process event.'
        - '{"key": "value"}'
        - ...any HTTP Response Body...

### Channel Support

The table below summarizes what delivery parameters are supported for each channel implementation.

| Channel Type | Supported Delivery Parameters |
| - | - |
| GCP PubSub | none |
| In-Memory | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| Kafka | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| Natss | none |
