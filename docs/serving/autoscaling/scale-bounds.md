---
title: "Configuring scale bounds"
linkTitle: "Configuring scale bounds"
weight: 50
type: "docs"
---

To apply upper and lower bounds to autoscaling behavior, you can specify scale bounds in both directions.

## Lower bound

This value controls the minimum number of replicas that each revision should have.
Knative will attempt to never have less than this number of replicas at any one point in time.

* **Global key:** n/a
* **Per-revision annotation key:** `autoscaling.knative.dev/minScale`
* **Possible values:** integer
* **Default:** `0` if scale-to-zero is enabled and class KPA is used, `1` otherwise

**NOTE:** For more information about scale-to-zero configuration, see the documentation on [Configuring scale to zero](./scale-to-zero.md).

**Example:**
{{< tabs name="min-scale" default="Per Revision" >}}
{{% tab name="Per Revision" %}}
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
{{< /tab >}}
{{< /tabs >}}

## Upper bound

This value controls the maximum number of replicas that each revision should have.
Knative will attempt to never have more than this number of replicas running, or in the process of being created, at any one point in time.

* **Global key:** n/a
* **Per-revision annotation key:** `autoscaling.knative.dev/maxScale`
* **Possible values:** integer
* **Default:** `0` which means unlimited

**Example:**
{{< tabs name="max-scale" default="Per Revision" >}}
{{% tab name="Per Revision" %}}
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
{{< /tab >}}
{{< /tabs >}}

---
