---
audience: developer
components:
  - serving
function: reference
---

# Configuring scale bounds

This reference lists scale bounds and related autoscaling settings. Examples illustrate the settings; they are not an installation or configuration workflow.

Operator fragments use `operator.knative.dev/v1beta1`, the served API in the [Operator v1.24.0 KnativeServing CRD](https://github.com/knative/operator/blob/knative-v1.24.0/config/crd/bases/operator.knative.dev_knativeservings.yaml){target=_blank}. Merge the intended fields into your existing resource in its actual namespace, using the [ConfigMap mapping reference](../../install/operator/configuration-reference.md#configmap-mapping) to select the entry and the [generic Serving Operator apply/verify workflow](../../install/operator/configuring-serving-cr.md#apply-and-verify-a-configuration-change) to apply it and inspect `config-autoscaler`, not the separate domain example. Check the installed CRD for other Operator releases.

You can also specify the initial scale that a Revision is scaled to immediately after creation.
This can be a default configuration for all Revisions, or for a specific Revision using an annotation.

Defaults below are upstream defaults, not a measurement of your cluster's active configuration. Global parsing is defined in [v1.24 autoscaler configuration](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/autoscaler/config/config.go){target=_blank}; per-revision constraints are defined in [annotation validation](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/apis/autoscaling/annotation_validation.go){target=_blank}.

## Lower bound

This value controls the minimum replica count for a reachable Revision. The Autoscaler ignores the lower bound for a Revision marked unreachable; it is not a guarantee that every historical Revision retains replicas. See [`ScaleBounds` in v1.24](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/apis/autoscaling/v1alpha1/pa_lifecycle.go#L86-L105){target=_blank}.

* **Global key:** `min-scale`
* **Per-revision annotation key:** `autoscaling.knative.dev/min-scale`
* **Possible values:** Nonnegative integer. Per-revision bounds use 32-bit integers; a nonzero upper bound must be at least the lower bound.
* **Default:** The cluster `min-scale` default is `0`; an absent annotation uses that setting. With upstream defaults, KPA can scale to zero. Disabling scale to zero prevents KPA from applying a zero scale; HPA defaults to a minimum of one replica. Explicit lower bounds and cluster overrides still apply.

!!! note
    For more information about scale-to-zero configuration, see the documentation on [Configuring scale to zero](scale-to-zero.md).

**Example:**

=== "Per Revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/min-scale: "3"
        spec:
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-autoscaler
      namespace: knative-serving
    data:
      min-scale: "3"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          min-scale: "3"
    ```





## Upper bound

This value controls the maximum number of replicas that each revision should have.
Knative will attempt to never have more than this number of replicas running, or in the process of being created, at any one point in time.

If the `max-scale-limit` global key is set, Knative ensures that neither the global max scale nor the per-revision max scale for new revisions exceed this value.
When `max-scale-limit` is set to a positive value, a revision with a max scale above that value (including 0, which means unlimited) is disallowed.

* **Global key:** `max-scale`
* **Per-revision annotation key:** `autoscaling.knative.dev/max-scale`
* **Possible values:** Nonnegative integer. Per-revision bounds use 32-bit integers; `0` means no upper bound. A positive global `max-scale-limit` requires a positive `max-scale` no greater than that limit and rejects per-revision unlimited or over-limit values.
* **Default:** `0`, meaning no upper bound

**Example:**

=== "Per Revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/max-scale: "3"
        spec:
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
    ```


=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-autoscaler
      namespace: knative-serving
    data:
      max-scale: "3"
      max-scale-limit: "100"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          max-scale: "3"
          max-scale-limit: "100"
    ```





## Initial scale

This value controls the initial target scale a Revision must reach immediately after it is created before it is marked as `Ready`.
After the Revision has reached this scale one time, this value is ignored. This means that the Revision will scale down after the initial target scale is reached if the actual traffic received only needs a smaller scale.

When the Revision is created, the larger of initial scale and lower bound is automatically chosen as the initial target scale.

* **Global key:** `initial-scale` in combination with `allow-zero-initial-scale`
* **Per-revision annotation key:** `autoscaling.knative.dev/initial-scale`
* **Possible values:** Nonnegative integer; `0` requires global `allow-zero-initial-scale: "true"`.
* **Default:** `1`

**Example:**

=== "Per Revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/initial-scale: "0"
        spec:
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-autoscaler
      namespace: knative-serving
    data:
      initial-scale: "0"
      allow-zero-initial-scale: "true"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          initial-scale: "0"
          allow-zero-initial-scale: "true"
    ```

## Scale Up Minimum

This value sets a floor on positive desired replica counts in KPA, while preserving the ability to scale to zero when demand disappears. It is not a one-time initial scale: v1.24 applies it on scaling evaluations with a positive computed count. Lower and upper scale bounds are applied afterward. See the [activation-scale logic](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/autoscaler/scaling/autoscaler.go#L209-L219){target=_blank} and [bounds application](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/reconciler/autoscaling/kpa/scaler.go#L341-L363){target=_blank}.

* **Global key:** n/a
* **Per-revision annotation key:** `autoscaling.knative.dev/activation-scale`
* **Possible values:** An explicitly set value must be at least `2`, no smaller than the annotated lower bound, and no larger than a nonzero annotated upper bound.
* **Default:** The annotation is unset, so no extra activation floor is applied; positive computed demand normally yields at least one replica before other bounds.

=== "Per Revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/activation-scale: "5"
        spec:
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
    ```

## Scale Down Delay

Scale Down Delay specifies a time window which must pass at reduced concurrency
before a scale-down decision is applied. This can be useful, for example, to
keep containers around for a configurable duration to avoid a cold start
penalty if new requests come in. Unlike setting a lower bound, the revision
will eventually be scaled down if reduced concurrency is maintained for the
delay period. 
!!! note 
    Only supported for the default KPA autoscaler class.

* **Global key:** `scale-down-delay`
* **Per-revision annotation key:** `autoscaling.knative.dev/scale-down-delay`
* **Possible values:** Per-revision duration from `0s` to `1h`, in whole seconds. The global duration must be nonnegative and in whole seconds; the v1.24 global parser does not impose the annotation's one-hour maximum.
* **Default:** `0s` (no delay)

**Example:**

=== "Per Revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/scale-down-delay: "15m"
        spec:
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-autoscaler
      namespace: knative-serving
    data:
      scale-down-delay: "15m"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          scale-down-delay: "15m"
    ```
## Stable window

The stable window defines the sliding time window over which metrics are averaged to provide the input for scaling decisions when the autoscaler is not in [Panic mode](kpa-specific.md).

* **Global key:** `stable-window`
* **Per-revision annotation key:** `autoscaling.knative.dev/window`
* **Possible values:** Duration from `6s` to `1h`, in whole seconds, for both the global setting and per-revision annotation.
* **Default:** `60s`

!!! note
    During scale down, in most cases the last Replica is removed after there has been no traffic to the Revision for the entire duration of the stable window.

**Example:**

=== "Per Revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
    spec:
      template:
        metadata:
          annotations:
            autoscaling.knative.dev/window: "40s"
        spec:
          containers:
            - image: ghcr.io/knative/helloworld-go:latest
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-autoscaler
     namespace: knative-serving
    data:
     stable-window: "40s"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          stable-window: "40s"
    ```

---
