---
audience: developer
components:
  - serving
function: reference
---

# Metrics

The metric configuration defines which metric type is watched by the Autoscaler.

## Setting metrics per revision

For [per-revision](autoscaler-types.md#global-versus-per-revision-settings) configuration, this is determined using the `autoscaling.knative.dev/metric` annotation.
The possible metric types that can be configured per revision depend on the type of Autoscaler implementation you are using:

* The default KPA Autoscaler supports the `concurrency` and `rps` metrics.
* The HPA Autoscaler supports the `cpu` metric.

<!-- TODO: Add details about different metrics types, how concurrency and rps differ. Explain cpu. -->

For more information about KPA and HPA, see the documentation on [Supported Autoscaler types](autoscaler-types.md).

* **Per-revision annotation key:** `autoscaling.knative.dev/metric`
* **Possible values:** `"concurrency"`, `"rps"`, `"cpu"`, `"memory"` or any custom metric name, depending on your Autoscaler type. The `"cpu"`, `"memory"`, and custom metrics are supported on revisions that use the HPA class.
* **Default:** `"concurrency"` for KPA, `"cpu"` for HPA, as selected by [v1.24 metric defaulting](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/apis/autoscaling/v1alpha1/pa_defaults.go){target=_blank}.


=== "Concurrency"

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
            autoscaling.knative.dev/metric: "concurrency"
            autoscaling.knative.dev/target-utilization-percentage: "70" 
    ```
    !!! note
        The `autoscaling.knative.dev/target-utilization-percentage` annotation for "Concurrency" specifies a percentage value. See [target utilization](concurrency.md#target-utilization) for its key, default, and interaction with concurrency limits.

=== "Requests per second"

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
            autoscaling.knative.dev/metric: "rps"
            autoscaling.knative.dev/target: "150"
    ```
    !!! note
        The `autoscaling.knative.dev/target` annotation for "Requests per second" specifies an integer value. See [Configuring targets](autoscaling-targets.md) for more details.

=== "CPU"

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
            autoscaling.knative.dev/class: "hpa.autoscaling.knative.dev"
            autoscaling.knative.dev/metric: "cpu"
            autoscaling.knative.dev/target: "100"
    ```
    !!! note
        For HPA CPU scaling, `autoscaling.knative.dev/target` specifies the target utilization percentage of requested CPU, not millicores. See [v1.24 HPA construction](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/reconciler/autoscaling/hpa/resources/hpa.go#L62-L77){target=_blank}. See [Configuring targets](autoscaling-targets.md) for more details.

=== "Memory"

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
            autoscaling.knative.dev/class: "hpa.autoscaling.knative.dev"
            autoscaling.knative.dev/metric: "memory"
            autoscaling.knative.dev/target: "75"
    ```
    !!! note
        The `autoscaling.knative.dev/target` annotation for "Memory" specifies the integer value in Mi. See [Configuring targets](autoscaling-targets.md) for more details.

=== "Custom metric"

    You can create an HPA to scale the revision by a metric that you specify.
    The HPA will be configured to use the **average value** of your metric over all the Pods of the revision.

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
            autoscaling.knative.dev/class: "hpa.autoscaling.knative.dev"
            autoscaling.knative.dev/metric: "<metric-name>"
            autoscaling.knative.dev/target: "<target>"
    ```

    Where `<metric-name>` is your custom metric.



## Next steps

* [Set and verify a concurrency target for a service](configure-concurrency.md)
* Configure [requests per second targets](rps-target.md) for replicas of an application
