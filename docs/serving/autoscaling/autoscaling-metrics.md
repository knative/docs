---
title: "Metrics"
linkTitle: "Metrics"
weight: 03
type: "docs"
---

The metric configuration defines which metric type is watched by the Autoscaler.

## Setting metrics per revision

For [per-revision](./autoscaling-concepts.md) configuration, this is determined using the `autoscaling.knative.dev/metric` annotation.
The possible metric types that can be configured per revision depend on the type of Autoscaler implementation you are using:

* The default KPA Autoscaler supports the `concurrency` and `rps` metrics.
* The HPA Autoscaler supports the `cpu` metric.

<!-- TODO: Add details about different metrics types, how concurrency and rps differ. Explain cpu. -->

For more information about KPA and HPA, see the documentation on [Supported Autoscaler types](./autoscaling-concepts.md).

* **Per-revision annotation key:** `autoscaling.knative.dev/metric`
* **Possible values:** `"concurrency"`, `"rps"` or `"cpu"`, depending on your Autoscaler type. The `cpu` metric is only supported on revisions with the HPA class.
* **Default:** `"concurrency"`

{{< tabs name="Examples of configuring metric types per revision" default="Per-revision concurrency configuration" >}}
{{% tab name="Per-revision concurrency configuration" %}}
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
{{< /tab >}}
{{% tab name="Per-revision rps configuration" %}}
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
{{< /tab >}}
{{% tab name="Per-revision cpu configuration" %}}
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
        autoscaling.knative.dev/metric: "cpu"
```
{{< /tab >}}
{{< /tabs >}}

## Next steps

* Configure [concurrency targets](./concurrency.md) for applications
* Configure [requests per second targets](./rps-target.md) for replicas of an application
