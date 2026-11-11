---
audience: developer
components:
  - serving
function: reference
---

# Targets

A target is the value the Autoscaler tries to maintain for the configured metric on a Revision. The `autoscaling.knative.dev/target` annotation is shared by the metric types; its meaning and units depend on the selected [metric](autoscaling-metrics.md).

For a configuration procedure, use [Set a concurrency target for a service](configure-concurrency.md). For concurrency-specific defaults and interactions with hard limits and utilization, use the [concurrency settings reference](concurrency.md).

## Configuring targets

* **Per-revision annotation key:** `autoscaling.knative.dev/target`
* **Location:** `spec.template.metadata.annotations` on a Service or Configuration
* **Possible values:** A number encoded as a string, at least `0.01`; interpretation depends on the metric. See the [v1.24 annotation validation source](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/apis/autoscaling/annotation_validation.go){target=_blank}; check the matching release for another installation.
* **Default:** The annotation is unset. For KPA concurrency, a nonzero `containerConcurrency` supplies the target; otherwise the cluster concurrency default supplies it. An explicit target annotation overrides that selection but is capped by a nonzero `containerConcurrency`. Target utilization is applied afterward; see the [three concurrency target-resolution cases](concurrency.md#soft-limit). For KPA requests per second, the cluster RPS default supplies the target when the annotation is absent.

Global defaults are metric-specific, not a global version of the `target` annotation. See [concurrency settings](concurrency.md#soft-limit) for `container-concurrency-target-default`, and [requests-per-second settings](rps-target.md) for the RPS default. The example below is a revision-template fragment.


=== "Target annotation - Per-revision"
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
            autoscaling.knative.dev/target: "50"
    ```

Cluster-default configuration fragments are maintained in the [concurrency settings reference](concurrency.md#soft-limit).
