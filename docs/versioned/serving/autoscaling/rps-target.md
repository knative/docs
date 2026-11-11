---
audience: developer
components:
  - serving
function: reference
---

# Configuring the requests per second (RPS) target

This setting specifies a target for requests-per-second per replica of an application. Your revision must also be configured to use the `rps` [metric annotation](autoscaling-metrics.md).

* **Global key:** `requests-per-second-target-default`
* **Per-revision annotation key:** `autoscaling.knative.dev/target`
* **Possible values:** Number at least `0.01`, encoded as a string, for both the global key and target annotation.
* **Default:** `"200"` for the global key. The annotation is unset by default. KPA applies target utilization after selecting the RPS target; `containerConcurrency` does not cap an RPS target.

See the [v1.24 configuration parser](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/autoscaler/config/config.go){target=_blank}, [annotation validation](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/apis/autoscaling/annotation_validation.go){target=_blank}, and [target resolution](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/reconciler/autoscaling/resources/target.go){target=_blank} for these constraints and interactions.

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
            autoscaling.knative.dev/target: "150"
            autoscaling.knative.dev/metric: "rps"
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
     requests-per-second-target-default: "150"
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
          requests-per-second-target-default: "150"
    ```
