---
title: "Configuring scale bounds"
linkTitle: "Configuring scale bounds"
weight: 50
type: "docs"
---

# Configuring scale bounds

You can configure upper and lower bounds to control autoscaling behavior.

You can also specify the initial scale that a Revision is scaled to immediately after creation.
This can be a default configuration for all Revisions, or for a specific Revision using an annotation.

## Lower bound

This value controls the minimum number of replicas that each Revision should have.
Knative will attempt to never have less than this number of replicas at any one point in time.

* **Global key:** n/a
* **Per-revision annotation key:** `autoscaling.knative.dev/minScale`
* **Possible values:** integer
* **Default:** `0` if scale-to-zero is enabled and class KPA is used, `1` otherwise

**NOTE:** For more information about scale-to-zero configuration, see the documentation on [Configuring scale to zero](./scale-to-zero.md).

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
            autoscaling.knative.dev/minScale: "3"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
    ```




## Upper bound

This value controls the maximum number of replicas that each revision should have.
Knative will attempt to never have more than this number of replicas running, or in the process of being created, at any one point in time.

If the `max-scale-limit` global key is set, Knative ensures that neither the global max scale nor the per-revision max scale for new revisions exceed this value.
When `max-scale-limit` is set to a positive value, a revision with a max scale above that value (including 0, which means unlimited) is disallowed.

* **Global key:** `max-scale`
* **Per-revision annotation key:** `autoscaling.knative.dev/maxScale`
* **Possible values:** integer
* **Default:** `0` which means unlimited

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
            autoscaling.knative.dev/maxScale: "3"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
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
    apiVersion: operator.knative.dev/v1alpha1
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
* **Per-revision annotation key:** `autoscaling.knative.dev/initialScale`
* **Possible values:** integer
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
            autoscaling.knative.dev/initialScale: "0"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
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
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          initial-scale: "0"
          allow-zero-initial-scale: "true"
    ```





## Scale Down Delay

Scale Down Delay specifies a time window which must pass at reduced concurrency
before a scale-down decision is applied. This can be useful, for example, to
keep containers around for a configurable duration to avoid a cold start
penalty if new requests come in. Unlike setting a lower bound, the revision
will eventually be scaled down if reduced concurrency is maintained for the
delay period.

* **Global key:** `scale-down-delay`
* **Per-revision annotation key:** `autoscaling.knative.dev/scaleDownDelay`
* **Possible values:** Duration, `0s` <= value <= `1h`
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
            autoscaling.knative.dev/scaleDownDelay: "15m"
        spec:
          containers:
            - image: gcr.io/knative-samples/helloworld-go
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
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          scale-down-delay: "15m"
    ```





---
