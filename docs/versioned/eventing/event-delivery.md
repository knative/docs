---
audience: developer
components:
  - eventing
function: how-to
---

# Handling Delivery Failure

You can configure event delivery parameters for Knative Eventing components that are applied in cases where an event fails to be delivered

## Delivery parameters

Delivery parameters can be set on a `Broker` (`spec.delivery`), a `Trigger` (`spec.delivery`, which overrides the Broker's delivery spec for that Trigger), a `Channel` (`spec.delivery`), or a `Subscription` (`spec.delivery`).

- `deadLetterSink`: Destination (any Addressable resource such as a Knative Service, Kubernetes Service, or URI) that receives events after all delivery attempts fail. Make sure the dead-letter sink is ready before enabling it; if delivery to the dead-letter sink also fails, the event is dropped and logged.
- `retry`: Number of retry attempts after the initial delivery attempt fails (total attempts = `retry + 1`).
- `backoffPolicy`: Delay strategy between retries — `linear` (increases linearly by `backoffDelay * attempt`) or `exponential` (doubles each attempt: `backoffDelay * 2^attempt`).
- `backoffDelay`: Base delay in ISO 8601 duration format (for example, `PT1S` for 1 second).

## Subscription delivery { #configuring-subscription-event-delivery }

Add `spec.delivery` to a `Subscription`:

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
    backoffDelay: PT1S
    backoffPolicy: exponential
    retry: 5
```

## Broker delivery { #configuring-broker-event-delivery }

Add `spec.delivery` to a `Broker` (or override it per `Trigger`):

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
    backoffDelay: PT1S
    backoffPolicy: exponential
    retry: 5
```

### Verify delivery failure handling

1. Apply the Broker, Trigger, Channel, or Subscription with `spec.delivery` and confirm both the delivery owner and the dead-letter sink report `READY=True` (for example, `kubectl get broker,trigger,channel,subscription,ksvc -n <namespace>`).

1. Send a CloudEvent with a known `Ce-Id` **through the configured Broker or Channel** to a subscriber that returns HTTP `500`, then check the dead-letter sink logs to confirm the failed event arrived with the same `Ce-Id` (and, where the backing Channel implementation supports them, the error extension attributes `knativeerrordest`, `knativeerrorcode`, and `knativeerrordata`).

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

## Dead-letter error attributes { #configuring-channel-event-delivery }

Failed events may, depending on the specific Channel implementation in use, be
enhanced with extension attributes prior to forwarding to the `deadLetterSink`.
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
