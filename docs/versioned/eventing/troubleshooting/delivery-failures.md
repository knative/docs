---
audience: developer
components:
  - eventing
function: how-to
---

# Events repeatedly fail delivery

Use this guide when an existing Broker/Trigger workload shows delivery errors,
retries, or events arriving at a dead-letter sink instead of the subscriber.
If you have no evidence that events reach the Broker or match a Trigger, start
with [Events do not reach a subscriber](events-not-delivered.md).

You need read access to the workload resources and receiver records. An
administrator may need to collect implementation controller and data-plane logs.
Read access is sufficient to investigate and gather evidence. Application,
resource, delivery-policy, or security changes require the responsible workload
or platform owner's approval and write permissions through its deployment
workflow. Sending test events or replaying failed events requires the authorized
producer/application owner. If you are a read-only responder, hand off the
findings and [evidence checklist](events-not-delivered.md#gather-evidence-for-escalation),
then correlate the owners' recovery records; do not change resources or resend
events yourself. Do not deliberately break a production subscriber to reproduce
the error.

## Capture one failed event

Set the affected namespace and resource names:

```bash
NAMESPACE=<workload-namespace>
BROKER=<broker-name>
TRIGGER=<trigger-name>
kubectl -n "$NAMESPACE" get broker "$BROKER" -o yaml
kubectl -n "$NAMESPACE" get trigger "$TRIGGER" -o yaml
kubectl -n "$NAMESPACE" get events --sort-by=.metadata.creationTimestamp
```

Record one event ID and time window, the resolved subscriber URL, the final
observed response or transport error, and any dead-letter receipt. Inspect
`status.conditions`; if a resource is Not Ready, resolve that with the
[readiness checks](events-not-delivered.md#broker-or-trigger-is-not-ready) first.
Identify the Broker class and, for an MTChannelBasedBroker, the backing Channel.
Do not use the Channel demonstration's Pod selectors for a different implementation.

## Branch on the observed failure

| Symptom in receiver or implementation evidence | Next action |
| --- | --- |
| HTTP error response | Correlate the event ID with subscriber logs. Check the path and whether the receiver accepts the event. Hand the confirmed application error or access mismatch to its owner for correction before considering retry changes. |
| Subscriber records receipt, but MTChannelBasedBroker v1.23 reports a non-empty response not recognized as CloudEvent | Inspect the subscriber's response status, headers, and body. In this pinned path, successful acknowledgment requires a 2xx response with an empty body or a valid CloudEvent reply; the [v1.23 Broker filter rejects unrecognized non-empty or malformed replies](https://github.com/knative/eventing/blob/knative-v1.23.0/pkg/broker/filter/filter_handler.go#L551-L583). Receipt alone does not prove acknowledgment success. Have the application owner correct the response contract, then correlate a fresh event's receipt with successful delivery evidence; do not merely increase retries. |
| Connection failure, name resolution failure, or timeout | Check the resolved destination, Kubernetes Service endpoints/ports or Knative Service status, and applicable network/security policy. Determine whether the request reached the receiver before treating it as an application error. |
| HTTP 429 or 503 with Retry-After | Check the configured retries and the [`retryAfterMax` feature requirements and implementation caveats](../features/delivery-retryafter.md). Header presence alone does not establish that the implementation honors it. |
| Receiver takes longer than a configured timeout | Inspect the configured [`timeout`](../features/delivery-timeout.md) and receiver latency. This field is per HTTP request; do not assume it bounds the entire retry sequence. |
| No receiver evidence and no dispatch error | Return to [ingress and filter checks](events-not-delivered.md#resources-are-ready-but-no-event-arrives). |

Retrieve logs already available from the identified implementation and
subscriber using [Read existing workload logs](../observability/logging/collecting-logs.md#read-existing-workload-logs).
Use an existing provider or an owner-identified Pod/container; installing a
collector is separate platform-owner work, not a prerequisite for this check.
Keep the same event ID and time window across these checks. An error seen by the sender
does not always establish whether the receiver processed the event; preserve
receiver evidence before deciding to resend it.

## Retries do not match expectations

Inspect `spec.delivery` on the Broker and any Trigger-level delivery settings.
Use the historical [Broker support](../reference/event-delivery.md#broker-support)
and [Channel support](../reference/event-delivery.md#channel-support) tables as
starting points only. Confirm field support with your installed implementation's
release-specific documentation. For omitted fields or override/default behavior,
use [Effective delivery settings lookup](../reference/event-delivery.md#effective-delivery-settings-lookup)
to locate configuration references and request the responsible owner's evidence.
This guide does not establish universal Trigger/Broker precedence or defaults.

Compare the explicit retry settings with observed attempts. The API describes
`retry` as a minimum, while v1.23's shared HTTP sender uses it as `RetryMax` and
can stop early based on the outcome or cancellation. See the
[API and shared-sender scope](../reference/event-delivery.md#retry-and-backoff-semantics);
this is not a universal exact-attempt guarantee. Do not confuse the producer
retrying ingress with the Broker retrying delivery to the subscriber. Feature
validation accepting a field does not necessarily prove an extension
implementation supports it.

## Events do not reach the dead-letter sink

1. Confirm that a dead-letter sink is configured on the resource whose delivery
   policy the implementation uses. If none is configured, there is no configured
   destination to inspect; ask the authorized workload owner to use
   [Handling Delivery Failure](../event-delivery.md) to test one in isolation
   before changing the workload. A read-only responder records this configuration
   gap rather than creating a sink.
1. Inspect resource status for the resolved dead-letter destination, if exposed,
   and compare it with the configured reference or URI. Confirm the referenced
   sink exists, is Ready where applicable, accepts event POSTs, and records
   event IDs.
1. Confirm the subscriber attempts have failed and retries have completed using
   implementation evidence. Do not infer completion from an arbitrary sleep or
   a single ingress response.
1. Inspect implementation logs for errors delivering to the dead-letter sink
   itself. A dead-letter destination is another delivery path that can fail.
1. Check destination requirements and support in your implementation's
   release-specific documentation. The historical reference records a Pub/Sub
   topic URI requirement for `googlecloud`, but that entry's freshness has not
   been verified. For an MTChannelBasedBroker, check its backing Channel too.

When an event does arrive at the dead-letter sink, correlate its ID with the
subscriber failure. The [failure extensions](../reference/event-delivery.md#configuring-channel-event-delivery)
are Channel-implementation-dependent, so missing extensions alone do not prove
that dead-letter delivery failed.

## Verify recovery and decide what to do with failed events

After the responsible owner fixes the confirmed cause, have the authorized
producer owner send a new matching event with a distinct ID through the original
producer. Confirm subscriber receipt and check that the new event no longer
follows the failure path. A read-only responder can correlate the owners' records
and observe relevant error/retry metrics; request redacted evidence for records
outside your permissions.

A dead-letter sink stores or receives failed events according to the sink's own
behavior; configuring it is not a replay procedure. Before replaying old events,
have the application owner use its recovery process to assess whether any were
already processed and whether resubmission is safe. This guide does not prescribe an
automatic replay mechanism.

If the cause remains unclear, use the
[evidence checklist](events-not-delivered.md#gather-evidence-for-escalation),
including subscriber and dead-letter errors and all relevant delivery settings.
