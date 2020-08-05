---
title: "Configuring scale bounds"
linkTitle: "Configuring scale bounds"
weight: 50
type: "docs"
---

To apply upper and lower bounds to autoscaling behavior, you can specify scale bounds in both directions.

You can also specify the initial scale a revision is scaled to immediately after creation, either as a default for all revisions, or for a specific revision using an annotation.

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

## Initial scale

This value controls the initial target scale of a revision after creation. This is the target scale a revision must reach, immediately after creation, before being marked Ready. Once the revision has reached this scale once, this value is ignored (e.g. the revision will scale down after the initial target scale is reached if the traffic received only needs a smaller scale).

During the creation of the revision, the larger of initial scale and lower bound is picked as the target scale.

* **Global key:** `initial-scale` in combination with `allow-zero-initial-scale`
* **Per-revision annotation key:** `autoscaling.knative.dev/initialScale`
* **Possible values:** integer
* **Default:** `1`

**Example:**
{{< tabs name="initial-scale" default="Per Revision" >}}
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
        autoscaling.knative.dev/initialScale: "0"
    spec:
      containers:
        - image: gcr.io/knative-samples/helloworld-go
```
{{< /tab >}}
{{% tab name="Global (ConfigMap)" %}}
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
{{< /tab >}}
{{% tab name="Global (Operator)" %}}
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

{{< /tab >}}
{{< /tabs >}}

---
