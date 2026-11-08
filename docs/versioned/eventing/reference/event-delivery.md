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

The following field definitions were rechecked against the v1.24
[`DeliverySpec` type and validation](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/apis/duck/v1/delivery_types.go).
Historical v1.23 source/runtime checks are not current-version sign-off.
The examples below set fields explicitly; they do not establish defaults for
all senders or implementations.

| Field | Type / values | Meaning and constraints |
| --- | --- | --- |
| `deadLetterSink` | Destination: object reference and/or URI | Receives an event that could not be sent to its destination. Destination support depends on the implementation; see the support tables below. |
| `retry` | Nonnegative integer (`int32`) | The API describes the minimum number of retries the sender should attempt before moving an event to the dead-letter sink. Negative values are rejected. Retries are distinct from the initial send; this field is not a universal guarantee of exactly `retry + 1` attempts. |
| `backoffPolicy` | `linear` or `exponential` | Selects the retry-delay policy. Other values are rejected. See the API and shared-sender scope below. |
| `backoffDelay` | ISO 8601 duration string | Delay parameter used by the retry policy; for example, `PT1S` represents one second. Validation parses the duration. It is not an overall delivery deadline. |
| `backoffMax` | Positive ISO 8601 duration string | In v1.24, caps normal backoff calculated from `backoffDelay` and `backoffPolicy`, not delays requested by Retry-After. Requires `delivery-backoff-max`; validation rejects zero, negative, malformed, or feature-disallowed values. The [v1.24 feature configuration](https://github.com/knative/eventing/blob/knative-v1.24.0/config/core/configmaps/features.yaml) marks this Alpha and disabled by default. API acceptance does not establish support in every implementation. |

## Effective delivery settings lookup

For an existing route, the presence or absence of a field in an example is not
its effective value. Read the live Broker and Trigger and compare their
`spec.delivery` with the owner's authoritative manifests. A stored field may
have been defaulted; an omitted field does not by itself establish zero retries,
a particular backoff policy, or which resource's policy applies.

Use the identified Broker class and installed release to choose the lookup scope:

| Scope | Configuration destination and evidence to inspect |
| --- | --- |
| Broker creation defaults | [DeliverySpec creation defaults](../configuration/broker-configuration.md#configuring-delivery-spec-defaults) documents `config-br-defaults`, including cluster and namespace entries. Ask the platform owner for the applicable configuration and, where available, the configuration used when this Broker was created. Today's ConfigMap alone is not proof of the values used by an existing route. |
| MTChannelBasedBroker | [Broker-specific configuration](../brokers/broker-types/channel-based-broker/README.md#broker-specific-configuration) identifies the ConfigMap referenced by `spec.config` and its Channel template. Obtain the actual backing Channel implementation/version and relevant generated resource delivery settings from the owner; then consult that Channel's matching-release documentation. Do not substitute the Broker class name for the backing Channel's delivery behavior. |
| Knative Broker for Apache Kafka | [Kafka Broker configuration](../brokers/broker-types/kafka-broker/README.md#configure-a-kafka-broker) identifies the referenced ConfigMap; [data-plane modes](../brokers/broker-types/kafka-broker/README.md#data-plane-isolation-vs-shared-data-plane) identifies shared versus namespace-isolated scope. These sections locate configuration, not a complete delivery-default reference. Request the installed Kafka Eventing release's delivery-default/Trigger-override documentation or source and the relevant dispatcher configuration from the platform owner. |
| RabbitMQBroker | [RabbitmqBrokerConfig reference usage](../brokers/broker-types/rabbitmq-broker/README.md#create-a-rabbitmqbroker-object) identifies the configuration resource referenced by `spec.config`; it is not a ConfigMap in that example. Request the matching extension release's configuration and delivery-default/override rules from its owner. |
| Another implementation, or unresolved class/configuration | Ask the platform owner to identify the implementation/version and configuration resources before interpreting delivery fields. The [historical support tables](#broker-support) cannot establish effective defaults. |

These destinations explain where configuration is recorded; they do not
establish universal Broker/Trigger override precedence or fallback values. For a
specific omitted or conflicting field, request this evidence from the owner:

- the field and affected Broker/Trigger names and namespace;
- installed Knative and extension versions, actual Broker class/backing Channel,
  and the explicit versus defaulted delivery blocks in live resources/manifests;
- the referenced configuration resource's kind, name, namespace, and relevant
  redacted contents, plus applicable creation/default and data-plane settings;
- the matching-release documentation or source rule for defaulting/override
  behavior, identifying which resource or sender uses it;
- observed receiver or dispatcher evidence for the same event/time window, if
  available, without treating observations as a universal default.

If that evidence is unavailable, record the effective field value or precedence
as **unknown** and escalate rather than filling in a guessed default. Kubernetes
read access may not include platform configuration or logs; ask for redacted
owner evidence instead of changing access or configuration. The linked
configuration sections are lookup destinations, not instructions to edit a
managed ConfigMap during diagnosis. For Knative Operator-managed defaults, ask
the owner for the authoritative `KnativeEventing` configuration using the
[Operator mapping reference](../../install/operator/configuration-reference.md#configmap-mapping);
do not add competing configuration entries or directly edit generated ConfigMaps.
Any change belongs in the responsible owner's deployment workflow. To investigate observations,
return to [Retries do not match expectations](../troubleshooting/delivery-failures.md#retries-do-not-match-expectations).

## Retry and backoff semantics

The v1.24 DeliverySpec comments describe linear backoff as
`backoffDelay * r` and exponential backoff as `backoffDelay * 2^(r - 1)`, where
`r` is the retry ordinal starting at 1. For the rechecked v1.24 shared sender,
[`RetryConfigFromDeliverySpec`, `linearBackoff`, and `exponentialBackoff`](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/kncloudevents/retries.go)
use the callback's zero-based index `n`: for a positive delay, linear is
`backoffDelay * (n + 1)` and exponential is `backoffDelay * 2^n`, subject to
overflow saturation and an optional `backoffMax`. For nonpositive delays, these
shared helpers return zero; parsing a `backoffDelay` duration alone does not
establish a positive interval. This is not fixed-interval linear backoff.

!!! note "Changed since the historical v1.23 check"
    v1.24's shared linear helper waits one `backoffDelay` before the first retry;
    the historical v1.23 helper multiplied directly by the zero-based callback
    index. v1.24 adds `backoffMax` and overflow-safe helpers. The exponential API
    comment now uses a one-based retry ordinal consistently with the shared
    sender. These changes were checked in the new source, not inferred by
    changing a citation's version.

`backoffMax` caps normal calculated delay but not Retry-After. When applicable,
`generateBackoffFn` returns the larger of normal backoff and the Retry-After
value after its separate `retryAfterMax` handling. Feature defaults and
validation are recorded in the
[v1.24 feature configuration](https://github.com/knative/eventing/blob/knative-v1.24.0/config/core/configmaps/features.yaml);
this is not an implementation-wide support claim.

The [shared v1.24 dispatch client](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/kncloudevents/event_dispatcher.go)
passes `RetryMax` from `retry` to
[`retryablehttp` v0.7.8](https://github.com/hashicorp/go-retryablehttp/blob/v0.7.8/client.go),
the dependency pinned by [Eventing v1.24's go.mod](https://github.com/knative/eventing/blob/knative-v1.24.0/go.mod).
That loop's callback index starts at zero; it treats `RetryMax` as a limit and
can stop early. The shared `SelectiveRetry` policy does not retry every response.
The API still describes `retry` as a minimum and rejects negative values; that
is not evidence of exactly `retry + 1` attempts for every outcome or implementation.

These are v1.24 source-level facts, not cluster-tested timing or behavior
guarantees for every Broker or Channel. Request duration, cancellation,
Retry-After handling, configuration defaults, and different senders can affect
observations. Correlate receiver records before relying on a schedule or attempt
count; no exactly-once or no-retry guarantee is established here.

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
    been revalidated across v1.24 Broker/Channel extension releases. The earlier
    v1.23 check is historical only, and the v1.24 API/shared-sender source checks
    above do **not** validate these capability claims. Treat the
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
      forwarded there. See the rechecked v1.24 shared dispatcher's
      [failure-destination handling](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/kncloudevents/event_dispatcher.go).
      Presence depends on the implementation.
    - **Examples:**
        - "http://myservice.mynamespace.svc.cluster.local:3000/mypath"
        - "http://reply-receiver.mynamespace.svc.cluster.local/failed-reply-path"

- **knativeerrorcode**
    - **Type:** Int
    - **Description:** The HTTP Response **StatusCode** from the final event
      dispatch attempt.
    - **Constraints:** An actual HTTP response supplies the status code in the
      shared sender's final-response branch. The scoped shared-sender behavior
      below also records a synthetic dispatch-error code; do not interpret
      every value as a response actually returned by the subscriber. Presence
      and no-response behavior are not universal across implementations.
    - **Examples:**
        - "500"
        - ...any HTTP StatusCode...

- **knativeerrordata**
    - **Type:** String
    - **Description:** Failure-response/error data supplied by the sender.
      The v1.24 shared dispatcher encodes this data as Base64 rather than
      exposing the response body directly as an unencoded string.
    - **Constraints:** Empty for empty supplied data. Encoding and length
      handling depend on the implementation; the long-body caveat below applies
      to the shared path.
    - **Examples for the shared dispatcher's encoding:**
        - `SW50ZXJuYWwgU2VydmVyIEVycm9y` encodes `Internal Server Error`.
        - `eyJrZXkiOiJ2YWx1ZSJ9` encodes `{"key":"value"}`.

### Shared-sender failure metadata scope

Rechecked in v1.24's
[`executeRequest` and `dispatchExecutionInfoTransformers`](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/kncloudevents/event_dispatcher.go)
and [`KnativeErrorTransformers`](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/kncloudevents/attributes/knative_error.go):

- Failed destination/reply sends with a configured dead-letter sink use these
  transformers to attach destination, code, and data extensions to the event.
- When `client.DoWithRetries` returns an error, `executeRequest` records code
  `500` and `dispatch error: ...` data. This is synthetic dispatch metadata, not
  proof that a subscriber returned HTTP 500. It does not define all failures
  occurring before the client call or other implementations' fallback values.
- For the shared `broker-filter` path, the transformer can unwrap the error
  destination/body supplied by the filter instead of reporting only that
  intermediate URL. It Base64-encodes the selected body/error data.

!!! warning "Long-body handling not validated"
    The shared helper declares a 1024-character data-extension limit, but the
    dispatcher allocates a capped output buffer before encoding the full body.
    This source review does not establish safe encoding/truncation for oversized
    bodies. Do not rely on a complete body or a guaranteed safe truncation result;
    retain receiver logs and request implementation validation.

Do not require these extensions from every Broker or Channel. The scoped
source behavior above does not validate the historical support matrix or
universal no-response metadata.

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
