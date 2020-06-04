---
title: "Targets"
linkTitle: "Targets"
weight: 04
type: "docs"
---

Configuring a target provide the Autoscaler with a value that it tries to maintain for the configured metric for a revision.
See the [metrics](./autoscaling-metrics.md) documentation for more information about configurable metric types.

The `target` annotation, used to configure per-revision targets,  is _metric agnostic_. This means the target is simply an integer value, which can be applied for any metric type.

## Configuring targets

* **Global settings key:** `container-concurrency-target-default` for setting a concurrency target, and `requests-per-second-target-default` for setting a requests-per-second (RPS) target. For more information, see the documentation on [metrics](./autoscaling-metrics.md).
* **Per-revision annotation key:** `autoscaling.knative.dev/target`
* **Possible values:** An integer (metric agnostic).
* **Default:** `"100"` for `container-concurrency-target-default`, and `"200"` for `requests-per-second-target-default`. There is no default value set for the `target` annotation.

{{< tabs name="Configuring targets" default="Target annotation - Per-revision" >}}
{{% tab name="Target annotation - Per-revision" %}}
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
{{< /tab >}}
{{% tab name="Concurrency target - Global (ConfigMap)" %}}
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: config-autoscaler
 namespace: knative-serving
data:
 container-concurrency-target-default: "200"
```
{{< /tab >}}
{{% tab name="Concurrency target - Container Global (Operator)" %}}
```yaml
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
spec:
  config:
    autoscaler:
      container-concurrency-target-default: "200"
```
{{< /tab >}}
{{% tab name="Requests per second (RPS) target - Global (ConfigMap)" %}}
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: config-autoscaler
 namespace: knative-serving
data:
 requests-per-second-target-default: "150"
```
{{< /tab >}}
{{% tab name="Requests per second (RPS) target - Global (Operator)" %}}
```yaml
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
spec:
  config:
    autoscaler:
      requests-per-second-target-default: "150"
```
{{< /tab >}}
{{< /tabs >}}
