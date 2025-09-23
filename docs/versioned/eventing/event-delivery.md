# Handling Delivery Failure

You can configure event delivery parameters for Knative Eventing components that are applied in cases where an event fails to be delivered

## Configuring Subscription event delivery

You can configure how events are delivered for each Subscription by adding a `delivery` spec to the `Subscription` object, as shown in the following example:

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

- The `deadLetterSink` spec contains configuration settings to enable using a dead letter sink. This tells the Subscription what happens to events that cannot be delivered to the subscriber. When this is configured, events that fail to be delivered are sent to the dead letter sink destination. The destination can be a Knative Service or a URI. In the example, the destination is a `Service` object, or Knative Service, named `example-sink`.
- The `backoffDelay` delivery parameter specifies the time delay before an event delivery retry is attempted after a failure. The duration of the `backoffDelay` parameter is specified using the ISO 8601 format. For example, `PT1S` specifies a 1 second delay.
- The `backoffPolicy` delivery parameter can be used to specify the retry back off policy. The policy can be specified as either `linear` or `exponential`. When using the `linear` back off policy, the back off delay is the time interval specified between retries. When using the `exponential` back off policy, the back off delay is equal to `backoffDelay*2^<numberOfRetries>`.
- `retry` specifies the number of times that event delivery is retried before the event is sent to the dead letter sink.

## Configuring Broker event delivery

You can configure how events are delivered for each Broker by adding a `delivery` spec, as shown in the following example:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: with-dead-letter-sink
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

- The `deadLetterSink` spec contains configuration settings to enable using a dead letter sink. This tells the Subscription what happens to events that cannot be delivered to the subscriber. When this is configured, events that fail to be delivered are sent to the dead letter sink destination. The destination can be any Addressable object that conforms to the Knative Eventing sink contract, such as a Knative Service, a Kubernetes Service, or a URI. In the example, the destination is a `Service` object, or Knative Service, named `example-sink`.
- The `backoffDelay` delivery parameter specifies the time delay before an event delivery retry is attempted after a failure. The duration of the `backoffDelay` parameter is specified using the ISO 8601 format. For example, `PT1S` specifies a 1 second delay.
- The `backoffPolicy` delivery parameter can be used to specify the retry back off policy. The policy can be specified as either `linear` or `exponential`. When using the `linear` back off policy, the back off delay is the time interval specified between retries. This is a linearly increasing delay, which means that the back off delay increases by the given interval for each retry. When using the `exponential` back off policy, the back off delay increases by a multiplier of the given interval for each retry.
- `retry` specifies the number of times that event delivery is retried before the event is sent to the dead letter sink. The initial delivery attempt is not included in the retry count, so the total number of delivery attempts is equal to the `retry` value +1.

### Broker support

The following table summarizes which delivery parameters are supported for each Broker implementation type:

| Broker Class | Supported Delivery Parameters |
| - | - |
| googlecloud | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| Kafka | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| MTChannelBasedBroker | depends on the underlying Channel |
| RabbitMQBroker | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |

!!! note
    `deadLetterSink` must be a GCP Pub/Sub topic URI.
    `googlecloud` Broker only supports the `exponential` back off policy.

## Configuring Channel event delivery

Failed events may, depending on the specific Channel implementation in use, be
enhanced with extension attributes prior to forwarding to the`deadLetterSink`.
These extension attributes are as follows:

- **knativeerrordest**
    - **Type:** String
    - **Description:** The original destination URL to which the failed event
      was sent.  This could be either a `delivery` or `reply` URL based on
      which operation encountered the failed event.
    - **Constraints:** Always present because every HTTP Request has a
      destination URL.
    - **Examples:**
        - "http://myservice.mynamespace.svc.cluster.local:3000/mypath"
        - ...any `deadLetterSink` URL...

- **knativeerrorcode**
    - **Type:** Int
    - **Description:** The HTTP Response **StatusCode** from the final event
      dispatch attempt.
    - **Constraints:** Always present because every HTTP Response contains
      a **StatusCode**.
    - **Examples:**
        - "500"
        - ...any HTTP StatusCode...

- **knativeerrordata**
    - **Type:** String
    - **Description:** The HTTP Response **Body** from the final event dispatch
      attempt.
    - **Constraints:** Empty if the HTTP Response **Body** is empty,
      and may be truncated if the length is excessive.
    - **Examples:**
        - 'Internal Server Error: Failed to process event.'
        - '{"key": "value"}'
        - ...any HTTP Response Body...

### Channel support

The following table summarizes which delivery parameters are supported for each Channel implementation.

| Channel Type | Supported Delivery Parameters |
| - | - |
| GCP PubSub | none |
| In-Memory | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| Kafka | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| Natss | none |
