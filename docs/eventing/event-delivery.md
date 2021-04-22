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
apiVersion: messaging.knative.dev/v1
kind: Subscription
metadata:
  name: with-dead-letter-sink
spec:
  channel:
    apiVersion: messaging.knative.dev/v1
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

## Configuring Broker Delivery

Knative Eventing offers fine-grained control on how events are delivered for each broker by adding a `delivery` section. Consider this example:

```yaml
apiVersion: messaging.knative.dev/v1
kind: Subscription
metadata:
  name: with-dead-letter-sink
spec:
  channel:
    apiVersion: messaging.knative.dev/v1
    kind: InMemoryChannel
    name: default
  delivery:
    retry: 5
    backoffPolicy: exponential # or linear
    backoffDelay: "PT0.5S"     # or ISO8601 duration
    deadLetterSink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: error-handler
  subscriber:
    uri: http://doesnotexist.default.svc.cluster.local
```

The Broker will retry sending events 5 times with a backoff delay of 500 milliseconds
and exponential backoff policy.

The `deadLetterSink` specifies where to send events that failed to be consumed by `subscriber`
after the specified number of retries.

## Common Delivery Parameters

The `delivery` value must be a Delivery Spec, which is a partial schema that is embedded in resources like `Broker`, `Trigger` and `Subscription`.

```yaml
# DeadLetterSink is the sink receiving event that could not be sent to
# a destination.
deadLetterSink:
  ref:
    apiVersion: v1
    kind: Service
    name: my-service
  uri: /my-path

# Retry is the minimum number of retries the sender should attempt when
# sending an event before moving it to the dead letter sink.
retry: 5

// BackoffPolicy is the retry backoff policy (linear, exponential).
backoffPolicy: exponential

# BackoffDelay is the delay before retrying.
# More information on Duration format:
#  - https://www.iso.org/iso-8601-date-and-time-format.html
#  - https://en.wikipedia.org/wiki/ISO_8601
#
# For linear policy, backoff delay is backoffDelay*<numberOfRetries>.
# For exponential policy, backoff delay is backoffDelay*2^<numberOfRetries>.
backoffDelay: PT2S
```

### deadLetterSink

When present, events that failed to be consumed are sent to the `deadLetterSink`.
In case of failure, the event is dropped and an error is logged into the system.

The `deadLetterSink` value must be a Destination.

```yaml
# DeadLetterSink is the sink receiving event that could not be sent to
# a destination.
deadLetterSink:
  ref:
    apiVersion: v1
    kind: Service
    name: my-service
  uri: /my-path
```

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

## Channel Support

The table below summarizes what delivery parameters are supported for each channel implementation.

| Channel Type | Supported Delivery Parameters |
| - | - |
| GCP PubSub | none |
| In-Memory | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| Kafka | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| Natss | none |

## Broker Support

The table below summarizes what delivery parameters are supported for each Broker implementation.

| Broker Class | Supported Delivery Parameters |
| - | - |
| googlecloud | `deadLetterSink` [^1], `retry`, `backoffPolicy`, `backoffDelay` [^2] |
| Kafka | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| MTChannelBasedBroker | depends on the underlying channel |
| RabbitMQBroker | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |

[^1]: deadLetterSink must be a GCP Pub/Sub topic uri:
    ```yaml
    deadLetterSink:
      uri: pubsub://dead-letter-topic
    ```

    Please see the
    [config-br-delivery](https://github.com/google/knative-gcp/blob/master/config/core/configmaps/br-delivery.yaml)
    ConfigMap for a complete example.

[^2]: The googlecloud broker only supports the `exponential` backoffPolicy.
