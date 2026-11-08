---
audience: developer
components:
  - eventing
function: reference
---

# Event delivery reference

DeliverySpec fields describe retries and dead-letter destinations for Eventing
resources. Use [Handling Delivery Failure](../event-delivery.md) to configure
and test a Broker dead-letter route. For implementation-dependent routing
behavior, see [Brokers](../brokers/README.md#event-delivery).

## Delivery fields

The following field definitions are checked against the v1.23
[`DeliverySpec` type and validation](https://github.com/knative/eventing/blob/knative-v1.23.0/pkg/apis/duck/v1/delivery_types.go).
The examples below set fields explicitly; they do not establish defaults for
all senders or implementations.

| Field | Type / values | Meaning and constraints |
| --- | --- | --- |
| `deadLetterSink` | Destination: object reference and/or URI | Receives an event that could not be sent to its destination. Destination support depends on the implementation; see the support tables below. |
| `retry` | Nonnegative integer (`int32`) | The API describes the minimum number of retries the sender should attempt before moving an event to the dead-letter sink. Negative values are rejected. Retries are distinct from the initial send; this field is not a universal guarantee of exactly `retry + 1` attempts. |
| `backoffPolicy` | `linear` or `exponential` | Selects the retry-delay policy. Other values are rejected. See the API and shared-sender scope below. |
| `backoffDelay` | ISO 8601 duration string | Delay parameter used by the retry policy; for example, `PT1S` represents one second. Validation parses the duration. It is not an overall delivery deadline. |

## Retry and backoff semantics

The v1.23 DeliverySpec comments describe linear backoff as
`backoffDelay * <numberOfRetries>` and exponential backoff as
`backoffDelay * 2^<numberOfRetries>`, not linear backoff as a fixed interval.

For senders using v1.23's shared HTTP retry code,
[`RetryConfigFromDeliverySpec`](https://github.com/knative/eventing/blob/knative-v1.23.0/pkg/kncloudevents/retries.go)
sets `RetryMax` from `retry` and implements those formulas using the retry
callback's `attemptNum`. The
[shared dispatch client](https://github.com/knative/eventing/blob/knative-v1.23.0/pkg/kncloudevents/event_dispatcher.go)
passes this configuration to
[`retryablehttp`](https://github.com/knative/eventing/blob/knative-v1.23.0/vendor/github.com/hashicorp/go-retryablehttp/client.go),
whose backoff callback index starts at zero. That retry loop treats `RetryMax`
as a limit and can stop early; the shared `SelectiveRetry` policy does not retry
every response. Thus the API's minimum-retry description is not evidence of an
exact attempt count for every outcome or implementation.

These are source-level facts for v1.23's shared sender, not cluster-tested timing
or behavior guarantees for every Broker or Channel. Request duration,
cancellation, Retry-After handling, implementation defaults, and implementations
using other senders can affect observations. Check your installed implementation
and correlate receiver records before relying on a schedule or attempt count.

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

This fragment shows the delivery fields, not a complete Subscription manifest.
The dead-letter destination is the Knative Service `example-sink`; a URI can
also be used where supported. Check the underlying [Channel support](#channel-support)
and the common [delivery field definitions](#delivery-fields).

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

The dead-letter destination in this example is the Knative Service
`example-sink`. A Broker dead-letter destination can be an Addressable object
conforming to the Eventing sink contract, such as a Knative Service, Kubernetes
Service, or URI, subject to the implementation's requirements below. The common
[delivery field definitions](#delivery-fields) and
[retry/backoff scope](#retry-and-backoff-semantics) apply; this example does not
promise an exact number of attempts.

### Broker support

!!! warning "Historical support tables; implementation freshness unverified"
    The Broker and Channel tables below were extracted from this repository's
    existing `event-delivery.md` at the experiment baseline `c250e7f7`. Their
    implementation/version provenance was not recorded there. They have not
    been revalidated against v1.23 or current extension releases; the v1.23 API
    source checks above do **not** validate these capability claims. Treat the
    tables and the `googlecloud` destination note as historical starting points,
    not a current compatibility guarantee. Confirm each needed field and
    destination with your installed implementation's release-specific
    documentation and an isolated test before changing a workload.

The retained table records these Broker delivery-support claims:

| Broker Class | Supported Delivery Parameters |
| - | - |
| googlecloud | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| Kafka | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| MTChannelBasedBroker | depends on the underlying Channel |
| RabbitMQBroker | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |

!!! note
    `deadLetterSink` must be a GCP Pub/Sub topic URI.
    `googlecloud` Broker only supports the `exponential` back off policy.

The preceding note is specific to the `googlecloud` Broker. For an
MTChannelBasedBroker, consult the underlying [Channel support](#channel-support),
not just the Broker class name. These tables do not establish support for
additional DeliverySpec fields or Trigger-level overrides.

## Configuring Channel event delivery

Failed events may, depending on the specific Channel implementation in use, be
enhanced with extension attributes prior to forwarding to the`deadLetterSink`.
These extension attributes are as follows:

- **knativeerrordest**
    - **Type:** String
    - **Description:** The original destination URL to which the failed event
      was sent.  This could be either a `delivery` or `reply` URL based on
      which operation encountered the failed event.
    - **Constraints:** When emitted, identifies the destination of the failed
      delivery or reply, not the dead-letter sink merely because the event is
      forwarded there. See the v1.23 shared dispatcher's
      [failure-destination handling](https://github.com/knative/eventing/blob/knative-v1.23.0/pkg/kncloudevents/event_dispatcher.go).
      Presence depends on the implementation.
    - **Examples:**
        - "http://myservice.mynamespace.svc.cluster.local:3000/mypath"
        - "http://reply-receiver.mynamespace.svc.cluster.local/failed-reply-path"

- **knativeerrorcode**
    - **Type:** Int
    - **Description:** The HTTP Response **StatusCode** from the final event
      dispatch attempt.
    - **Constraints:** For implementations emitting this extension, an actual
      HTTP response from the final attempt provides the **StatusCode** described
      here. This page does not establish the field's presence or value for a
      connection failure or timeout with no HTTP response; consult that
      implementation's failure-metadata behavior. No fallback value is specified
      here.
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

!!! note "Implementation-dependent failure metadata"
    Do not require these extensions from every Broker or Channel when diagnosing
    failures. In particular, the `knativeerrorcode` definition above is scoped
    to an actual HTTP response; no-response failure metadata remains outside
    this page's validated scope.

### Channel support

The retained table records these Channel delivery-support claims. The
[historical-provenance warning](#broker-support) applies to this table too.

| Channel Type | Supported Delivery Parameters |
| - | - |
| GCP PubSub | none |
| In-Memory | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| Kafka | `deadLetterSink`, `retry`, `backoffPolicy`, `backoffDelay` |
| Natss | none |

## Additional delivery fields

- [`timeout`](../features/delivery-timeout.md): per-request timeout, including
  the feature stage, flag, and example. This is not an overall retry deadline.
- [`retryAfterMax`](../features/delivery-retryafter.md): handling of HTTP
  Retry-After headers, feature requirements, and implementation caveats.
- [Eventing API reference](eventing-api.md): release-specific resource schema.

For a failed existing workload, start with
[Events repeatedly fail delivery](../troubleshooting/delivery-failures.md).
