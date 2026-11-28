---
audience: developer
components:
  - serving
function: explanation
---

# Request buffering and Activator capacity

Knative Serving uses the **Activator** to receive and buffer requests when a
Revision is scaled to zero, or when incoming traffic bursts exceed what the
Revision's pods can handle directly.

## Activator pod selection

Activator pods scale horizontally. Knative assigns a subset of Activators to
each Revision depending on its size — more Revision pods receive a larger
subset of Activators.

When the Activator is in the request path, it distributes requests to Revision
pods using:

- **Better of two random choices** when concurrency is unlimited.
- **First pod with available capacity** when `containerConcurrency` is 3 or
  less; otherwise **round-robin** respecting container concurrency.

See [Concurrency](../autoscaling/concurrency.md) for concurrency settings.

<span id="configuring-target-burst-capacity"></span>

## Target burst capacity

_Target burst capacity_ determines how large a traffic burst a Revision can
absorb without putting the Activator in the request path.

- **`0`** — Activator is only in the path while scaling from zero.
- **`-1`** — Activator is always in the path, regardless of Revision scale.
- **Positive integer** (default **`200`**) — Activator stays in the path
  whenever spare capacity across ready pods is smaller than this threshold.

<span id="setting-the-target-burst-capacity"></span>

- **Global key:** `target-burst-capacity` (in `config-autoscaler`)
- **Per-revision annotation:** `autoscaling.knative.dev/target-burst-capacity`
- **Possible values:** float (`-1`, `0`, or positive)
- **Default:** `200`

=== "Per Revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: <service-name>
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/target-burst-capacity: "200"
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-autoscaler
      namespace: knative-serving
    data:
      target-burst-capacity: "200"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          target-burst-capacity: "200"
    ```

<span id="setting-the-activator-capacity"></span>

## Activator capacity

When multiple Activators run in the cluster, Knative places enough Activators
in the request path to handle `(replicas * target + target-burst-capacity) / activator-capacity`.

- **Global key:** `activator-capacity` (in `config-autoscaler`)
- **Per-revision annotation:** none (cluster-wide administrator setting)
- **Possible values:** integer (at least `1`)
- **Default:** `100`

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-autoscaler
      namespace: knative-serving
    data:
      activator-capacity: "200"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          activator-capacity: "200"
    ```
