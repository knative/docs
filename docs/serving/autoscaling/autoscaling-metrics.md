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
* **Possible values:** `"concurrency"`, `"rps"`, `"cpu"`, `"memory"` or any custom metric name, depending on your Autoscaler type. The `"cpu"`, `"memory"`, and `"custom"` metrics are only supported on revisions that use the HPA class.
* **Default:** `"concurrency"`


=== "Per-revision concurrency configuration"

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
    ```

=== "Per-revision rps configuration"

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
    ```

=== "Per-revision cpu configuration"

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
    ```

=== "Per-revision memory configuration"

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
    ```

=== "Per-revision custom metric configuration"

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
    ```

    Where `<metric-name>` is your custom metric.



## Next steps

* Configure [concurrency targets](concurrency.md) for applications
* Configure [requests per second targets](rps-target.md) for replicas of an application
