---
audience: developer
components:
  - eventing
function: how-to
---

# Using Triggers

Route events from a Broker to a subscriber, then confirm that the subscriber
receives an event with the attributes you selected. A Trigger represents a
desire to subscribe to events from a specific Broker.

For how the route works, read [Brokers](../brokers/README.md). For exact filter
syntax, compatibility, and annotations, use the
[Trigger filtering reference](reference.md).

## Prerequisites

- Knative Eventing and a Broker implementation are installed.
- A [Broker](../brokers/create-broker.md) named `default` is Ready in your namespace.
- An HTTP subscriber exists in that namespace. The examples use a Knative
  Serving Service named `my-service`; the custom-path alternative uses a
  Kubernetes Service of the same name.
- You have the workload owner's approval and permission to create or update the
  intended Trigger. Use its normal deployment workflow; the commands below
  assume direct `kubectl` application is approved.
- You can arrange publication of a known CloudEvent to the Broker and inspect
  the subscriber's logs or another receipt record.

## Check the namespace and Trigger name

Set `NAMESPACE` to the namespace containing the Broker and subscriber:

```bash
NAMESPACE=<namespace>
kubectl -n "$NAMESPACE" get broker default
kubectl -n "$NAMESPACE" get trigger my-service-trigger -o yaml
```

Check that the Broker's `READY` is `True`. If it is not, use
[Events do not reach a subscriber](../troubleshooting/events-not-delivered.md).

For the Trigger lookup, distinguish `NotFound` from permission or connection
errors. Do not proceed on an unreadable resource:

- **NotFound:** you can create a new Trigger with the example name.
- **An unrelated Trigger already exists:** choose a different name and use it
  consistently in the manifest and all commands below. Do not overwrite it.
- **You intend to update this existing Trigger:** obtain its authoritative
  deployment manifest and edit that instead of replacing it with an example.
  Retain its Broker, subscriber, annotations, delivery settings, and other fields
  unless the owner has approved changing them. If it is managed by GitOps or
  another controller, make the change through that workflow.

## Example Triggers

Choose **one independent goal** and prepare its complete manifest before any
apply command:

- [Route only matching events](#trigger-filtering). This does **not** require
  creating an all-events Trigger first.
- [Route all events to a Knative Service](#route-all-events-to-a-knative-service),
  only when the subscriber is intended to receive every event from this Broker.
- [Route all events to a custom Kubernetes Service path](#alternative-route-to-a-custom-kubernetes-service-path).

Do not apply the all-events alternative while working toward the filtered goal.
For an existing workload, edit the approved manifest rather than copying any of
these new-resource templates over it.

## Trigger filtering

### Example

This independent example routes events with `type: dev.knative.foo.bar` and
extension `myextension: my-extension-value`. The legacy attributes syntax is used
for compatibility; check your Broker's support before choosing other dialects in
the [Trigger filtering reference](reference.md#trigger-filtering).

For a new Trigger, save this **already filtered** manifest as
`my-service-trigger.yaml`:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  filter:
    attributes:
      type: dev.knative.foo.bar
      myextension: my-extension-value
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

For an existing Trigger, edit its effective filter in the authoritative manifest.
If it already has `spec.filters`, do not just add `spec.filter`:
[the plural field takes precedence](reference.md#legacy-attributes-filter).
Edit the existing filters, or remove the plural field only if the owner intends
to switch to the legacy syntax. Review the effective predicates so you do not
unintentionally broaden the route. Continue to [apply the chosen manifest](#apply-the-chosen-manifest).

## Route all events to a Knative Service

This is a separate goal, **not a step in configuring a filtered route**. The
subscriber must be intended to receive all events from `default`. For a new
Trigger, save this manifest as `my-service-trigger.yaml`:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

Continue to [apply the chosen manifest](#apply-the-chosen-manifest). Do not use
this template to remove an existing workload's filters without owner approval.

## Alternative: route to a custom Kubernetes Service path

For the **all-events** goal with a Kubernetes Service rather than a Knative
Service, use this manifest instead. It sends events to `/my-custom-path`.
The `subscriber` value must be a
[Destination](https://pkg.go.dev/knative.dev/pkg/apis/duck/v1#Destination).

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: my-service
    uri: /my-custom-path
```

Save it as `my-service-trigger.yaml` and continue below. If you need a **filtered**
custom-path route, start from the filtered manifest and change only its
`subscriber` to this destination before first applying it.

## Apply the chosen manifest

Review the full manifest and diff, including the intended name, namespace,
subscriber, and effective filter. Use the authoritative file's actual path if
updating an existing workload:

```bash
kubectl -n "$NAMESPACE" diff -f my-service-trigger.yaml
```

`kubectl diff` returns exit code 1 for differences; that is not an apply failure.
Resolve any errors and approve the diff before applying:

```bash
kubectl -n "$NAMESPACE" apply -f my-service-trigger.yaml
```

If another deployment workflow owns the resource, use that workflow instead.

## Verify the route

1. Wait for the Trigger to be Ready, then inspect its resolved destination.
   Substitute the chosen name if you did not use `my-service-trigger`:

    ```bash
    kubectl -n "$NAMESPACE" wait --for=condition=Ready trigger/my-service-trigger --timeout=60s
    kubectl -n "$NAMESPACE" get trigger my-service-trigger -o yaml
    kubectl -n "$NAMESPACE" get broker default -o jsonpath='{.status.address.url}'
    ```

    If the wait times out, inspect `status.conditions` and use the
    [existing-workload troubleshooting guide](../troubleshooting/events-not-delivered.md#broker-or-trigger-is-not-ready).
    Ready status is a configuration check, not proof of event receipt.

1. Arrange publication of a CloudEvent to the returned Broker URL through the
   existing producer or an approved HTTP client. For the filtered example,
   include `type: dev.knative.foo.bar` and the extension
   `myextension: my-extension-value`. Use a distinct event ID and record it.
   Respect your cluster's authentication and transport requirements.

1. Confirm that event ID appears in the subscriber's logs or receipt record.
   **For the filtered goal only**, arrange a second event with a different
   `type`; it should not arrive through this filtered Trigger. If other Triggers
   also route to the subscriber, account for those routes before attributing
   receipt to this one.

If receipt cannot be confirmed, follow
[Events do not reach a subscriber](../troubleshooting/events-not-delivered.md).
To handle confirmed delivery failures, use
[Handling Delivery Failure](../event-delivery.md).

## Supported filter dialects

The dialect catalog now lives in the reference:

### `exact`

[Exact matching](reference.md#exact).

### `prefix`

[Prefix matching](reference.md#prefix).

### `suffix`

[Suffix matching](reference.md#suffix).

### `all`

[All nested expressions](reference.md#all).

### `any`

[Any nested expression](reference.md#any).

### `not`

[Negating an expression](reference.md#not).

### `cesql`

[CloudEvents SQL and version requirements](reference.md#cesql).

### Legacy attributes filter

[Legacy syntax and field precedence](reference.md#legacy-attributes-filter).

## Trigger annotations

[Trigger annotations reference](reference.md#trigger-annotations) covers Broker
injection and dependencies. These links retain entry points for older URLs;
configure annotations only when your workload needs those behaviors.
