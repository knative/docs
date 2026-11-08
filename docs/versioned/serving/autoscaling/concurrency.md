---
audience: developer
components:
  - serving
function: reference
---

<span id="configuring-concurrency"></span>

# Concurrency settings

This reference lists concurrency settings for Knative Serving. Autoscaling targets described here apply to the Knative Pod Autoscaler (KPA) with the `concurrency` metric. The `containerConcurrency` field also controls request admission independently of the autoscaling metric.

- To change a service, use [Set a concurrency target for a service](configure-concurrency.md).
- For behavior and trade-offs, read [How concurrency affects autoscaling](concurrency-behavior.md).
- For other metrics, see the [metrics reference](autoscaling-metrics.md).

Per-revision annotations belong in `spec.template.metadata.annotations` of a Service or Configuration; `containerConcurrency` belongs in `spec.template.spec`. Updating a Service's revision template creates a new Revision. Examples below are configuration fragments, not complete deployable Services.

Global autoscaling keys belong in the `config-autoscaler` ConfigMap in `knative-serving`. For Operator-managed installations, use `spec.config.autoscaler` in the `KnativeServing` resource instead. The hard-limit default uses `config-defaults` or `spec.config.defaults`.

Operator examples below use `operator.knative.dev/v1beta1`, matching the [documented Operator configuration API](../../install/operator/configuration-reference.md). Check the CRD installed by your Operator release before applying configuration.

## Soft versus hard concurrency limits

A soft limit is an autoscaling target, not an enforced maximum. A hard limit caps concurrent requests admitted to each replica.

If a soft target and a nonzero hard limit are both set, the smaller value is used as the concurrency target before applying [target utilization](#target-utilization).

### Soft limit

* **Global key:** `container-concurrency-target-default`
* **Per-revision annotation key:** `autoscaling.knative.dev/target`, with `autoscaling.knative.dev/metric: "concurrency"` (the default metric)
* **Possible values:** The per-revision annotation accepts a number encoded as a string, at least `0.01`. The global key also accepts a number; its product with the global utilization fraction must be at least `0.01`.
* **Default:** `"100"` for the global key. The per-revision annotation is unset by default; the target is resolved using the cases below.

For the KPA concurrency metric, resolve the concurrency target in this order:

1. **Target annotation absent, `containerConcurrency` greater than `0`:** use `containerConcurrency` as the target, even if it exceeds the cluster's `container-concurrency-target-default`.
2. **Target annotation absent, `containerConcurrency` equal to `0`:** use the cluster's `container-concurrency-target-default`.
3. **Target annotation present:** use the annotation value, capped by `containerConcurrency` if that hard limit is greater than `0`. A hard limit of `0` does not cap the annotation value.

Then apply [target utilization](#target-utilization) to the resolved target. The effective autoscaling target is the resolved target multiplied by the utilization fraction, with a minimum of `0.01`. Utilization does not change the hard limit.

This resolution is implemented by [`ResolveMetricTarget` in Serving v1.24.0](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/reconciler/autoscaling/resources/target.go#L31-L63){target=_blank}.

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
            autoscaling.knative.dev/target: "200"
    ```

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-autoscaler
     namespace: knative-serving
    data:
     container-concurrency-target-default: "200"
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
          container-concurrency-target-default: "200"
    ```




### Hard limit

The hard limit is specified [per Revision](autoscaler-types.md#global-versus-per-revision-settings) using the `containerConcurrency` field on the Revision spec. This setting is not an annotation.

There is no global setting for the hard limit in the autoscaling ConfigMap, because `containerConcurrency` has implications outside of autoscaling, such as on buffering and queuing of requests. However, a default value can be set for the Revision's `containerConcurrency` field in `config-defaults.yaml`.

The default value is `0`, meaning that this field imposes no limit on concurrent requests admitted to each replica.
A value greater than `0` specifies the maximum number of concurrent requests admitted to each replica.

* **Global key:** `container-concurrency` (in `config-defaults.yaml`)
* **Per-revision spec key:** `containerConcurrency`
* **Possible values:** Integer from `0` to the cluster's `container-concurrency-max-limit` (default `1000`). If `allow-container-concurrency-zero` is `false`, the minimum is `1` instead.
* **Default:** `0`, meaning no limit, unless the cluster sets another `container-concurrency` default.

These defaults and constraints are defined by [v1.24 default configuration](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/apis/config/defaults.go){target=_blank} and [`ValidateContainerConcurrency`](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/apis/serving/metadata_validation.go#L91-L107){target=_blank}.


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
        spec:
          containerConcurrency: 50
    ```

=== "Global (Defaults ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-defaults
     namespace: knative-serving
    data:
     container-concurrency: "50"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        defaults:
          container-concurrency: "50"
    ```




## Target utilization

Target utilization specifies the percentage of the concurrency target used by the Autoscaler. It does not change the hard limit. See [target utilization and spare capacity](concurrency-behavior.md#target-utilization-and-spare-capacity) for an example and its implications.

* **Global key:** `container-concurrency-target-percentage`
* **Per-revision annotation key:** `autoscaling.knative.dev/target-utilization-percentage`
* **Possible values:** The per-revision annotation accepts a percentage from `1` to `100`, encoded as a string; fractional percentages are supported.
* **Default:** `70` percent for the global setting. The annotation is unset by default and uses the cluster setting.

The global setting accepts either a fraction in `(0, 1]` or a percentage greater than `1` and at most `100`. For example, `"0.7"` and `"70"` both mean 70 percent; `"1"` means 100 percent globally, so use `"0.01"` for 1 percent. The per-revision annotation always uses percentage notation: `"1"` means 1 percent there.

Annotation constraints are defined in v1.24 [autoscaling annotation validation](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/apis/autoscaling/annotation_validation.go){target=_blank} and [annotation constants](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/apis/autoscaling/register.go){target=_blank}. Global defaults, fraction conversion, and validation are defined in the [autoscaler configuration parser](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/autoscaler/config/config.go){target=_blank}. These citations describe v1.24.0 source behavior; check the matching release for another installation.

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
            autoscaling.knative.dev/target-utilization-percentage: "80"
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
     container-concurrency-target-percentage: "80"
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
          container-concurrency-target-percentage: "80"
    ```
