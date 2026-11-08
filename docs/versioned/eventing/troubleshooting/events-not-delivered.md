---
audience: developer
components:
  - eventing
function: how-to
---

# Events do not reach a subscriber

Investigate an **existing Broker/Trigger route** without installing a sample
application. Start with readiness, then follow one known event from its producer
to the subscriber. For a confirmed HTTP delivery error, go to
[Events repeatedly fail delivery](delivery-failures.md).

## Identify the affected route

You need `kubectl` access to read the Broker, Trigger, subscriber, and relevant
logs. Permission to inspect Eventing system Pods may require an administrator.
Read access is sufficient for the investigation and evidence-gathering path.
Changing a manifest, application, or network/security configuration requires the
responsible workload or platform owner's approval and write permissions through
its normal deployment workflow. Publishing test events also requires producer
access and approval; ask the producer owner if you do not have them. A read-only
responder should hand off the diagnosis and [evidence](#gather-evidence-for-escalation)
to those owners, then observe their recovery results rather than changing the
workload or generating traffic.
Set these values to the affected workload, not to demonstration resource names:

```bash
NAMESPACE=<workload-namespace>
BROKER=<broker-name>
TRIGGER=<trigger-name>
kubectl -n "$NAMESPACE" get broker "$BROKER" -o yaml
kubectl -n "$NAMESPACE" get trigger "$TRIGGER" -o yaml
kubectl -n "$NAMESPACE" get events --sort-by=.metadata.creationTimestamp
```

Check that `spec.broker` on the Trigger is the Broker you inspected. Record the
Broker class (`eventing.knative.dev/broker.class`, if present), its configuration,
and the installed implementation/version. Do not infer the class solely from a
shared ingress hostname. For an MTChannelBasedBroker, identify the backing
Channel implementation too. Use [Available Broker types](../brokers/broker-types/README.md)
and your cluster administrator if these are unclear.

## Broker or Trigger is not Ready

Inspect `status.conditions` on both resources. Record each failing condition's
`type`, `reason`, and `message` rather than treating all Not Ready states alike.

| Evidence | Next action |
| --- | --- |
| Broker is absent or Trigger names a different Broker | Confirm namespace/name, then ask the workload owner to update the intended manifest through its deployment workflow. See [Creating a Broker](../brokers/create-broker.md) and [Using Triggers](../triggers/README.md). |
| Subscriber resolution fails | Inspect `spec.subscriber` and confirm its kind, API version, name, namespace, and optional path. Inspect that resource's status; for a Kubernetes Service inspect its endpoints. |
| A dependency is not Ready | Inspect the named dependency; see [Trigger annotations](../triggers/reference.md#trigger-annotations). |
| Broker configuration or backing resources fail | Check the referenced configuration and implementation-specific controller logs. For Channel-based Brokers, check the backing Channel's conditions too. |
| Conditions are absent or do not explain the failure | Ask an administrator to inspect the relevant controller and webhook logs for this resource/namespace. Use the evidence checklist below. |

After the responsible owner fixes the confirmed cause, recheck readiness:

```bash
kubectl -n "$NAMESPACE" wait --for=condition=Ready "broker/$BROKER" --timeout=60s
kubectl -n "$NAMESPACE" wait --for=condition=Ready "trigger/$TRIGGER" --timeout=60s
```

A timeout is a prompt to inspect conditions again, not to recreate the workload.
Ready status confirms reconciliation; it does not prove event receipt.

## Resources are Ready but no event arrives

### Confirm the producer reaches the intended Broker

```bash
kubectl -n "$NAMESPACE" get broker "$BROKER" -o jsonpath='{.status.address.url}'
```

Compare that URL with the producer's configured destination or the source's
resolved sink. Inspect producer/source status and logs for one event ID and a
timestamp. An HTTP rejection, connection error, or timeout at ingress points to
producer-to-Broker connectivity or access requirements, not yet a filter issue.
Check the requirements actually enabled in your cluster, such as
[transport encryption](../features/transport-encryption.md) and
[authorization](../features/authorization.md); do not disable them as a debugging
shortcut. A successful ingress response alone is not evidence of subscriber
receipt.

If no event was produced, investigate the source using its
[source documentation](../sources/README.md) before changing the Trigger.

### Compare the event attributes with the effective filter

Read both `spec.filters` and `spec.filter` in the Trigger. The plural field takes
precedence when both are present. Compare the actual CloudEvent attributes and
extensions, not just fields inside `data`, with the
[filter dialect reference](../triggers/reference.md#trigger-filtering). Check
case and the Broker's support for the dialect. Multiple `filters` must all
match. Use the event as received by the Broker where that evidence is available,
not only the application's intended event shape.

Do not remove a filter from a production Trigger merely to test delivery: that
can send unrelated events to the subscriber. Have the authorized producer owner
send a controlled event matching the existing filter, or have the workload owner
reproduce the route in an isolated namespace. Without those permissions, retain
the read-only evidence-gathering path. If receipt
is being attributed to a particular Trigger, check for other Triggers routing to
the same subscriber:

```bash
kubectl -n "$NAMESPACE" get triggers -o yaml
```

### Check the resolved subscriber and delivery path

Inspect the Trigger's status for its resolved subscriber destination and compare
it with `spec.subscriber`, including any custom URI path. Read the subscriber's
logs or receipt records for the event ID. For a Kubernetes Service, check its
selector, endpoints, and port mapping. For a Knative Service, inspect its status
and application logs with the appropriate permissions.

If implementation logs or metrics show a dispatch error, follow
[Events repeatedly fail delivery](delivery-failures.md). If there is no evidence
of dispatch despite a matching event reaching ingress, have an administrator
inspect the Broker's data plane using the implementation identified above.
Controller logs alone do not establish what happened to an event after ingress.

## Verify recovery

Have the authorized producer owner publish a new matching event with a distinct
ID through the original producer, preserving filtering and security requirements.
As a read-only responder, correlate the owner's production record with the same
ID in the subscriber's receipt record. If you cannot access those records, ask
the owner to supply redacted evidence. If production and receipt cannot both be
shown, keep the investigation open rather than declaring success from Ready
status.

## Gather evidence for escalation

Collect resource manifests/status, namespace, Broker class/backing Channel,
implementation and Knative versions, failing condition messages, event ID and
time window, producer response, effective filters, resolved destination, and
relevant controller/data-plane/subscriber logs. Redact credentials and event
payloads containing sensitive data before sharing.

- [Collecting Eventing logs](../observability/logging/collecting-logs.md)
- [Eventing metrics reference](../observability/metrics/eventing-metrics.md)
- [Accessing traces](../observability/accessing-traces.md), if tracing is available
- [Channel/Subscription debugging demonstration](README.md#example), for learning
  resource-by-resource inspection on a sample topology rather than repairing this route
