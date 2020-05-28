---
title: "Configuring autoscaling "
weight: 10
type: "docs"
aliases:
- /docs/serving/configuring-the-autoscaler/
---

One of the main properties of serverless platforms is their ability to scale an application to closely match its incoming demand. That requires watching load as it flows into the application and adjusting the scale based on the respective metrics. It's the job of the autoscaling component of Knative Serving to do exactly that.

Knative Serving comes with its own autoscaler, the **KPA** (Knative Pod Autoscaler) but can also be configured to use Kubernetes' **HPA** (Horizontal Pod Autoscaler) or even a custom third-party autoscaler.

Knative Serving Revisions come with autoscaling preconfigured to defaults that have been proven to work for a variety of use-cases. However, some workloads call for a more fine-tuned approach. This document describes the knobs you can turn to adjust the autoscaler to fit the requirements of your workload.

## Global vs. per-revision settings

Some of the following settings can be configured as a global default and/or overridden per revision.

Global settings are done in the **config-autoscaler** ConfigMap in the namespace of your Knative Serving installation (*knative-serving* by default) if you're manually installing the system with the YAML manifests. If you're using the operator, the settings are done as part of the `spec.config.autoscaler` map on the **KnativeServing CR**. The keys for both the ConfigMap and the CR are the same.

Per-revision settings are done by setting annotations on the revision. When you're creating revisions through a Service or a Configuration, that means the annotations must be set on the respective Revision `template`. All per-revision annotation keys are prefixed with `autoscaling.knative.dev/`. Per-revision settings override global settings where both settings are available. If no per-revision setting is specified, the respective global setting is used.

**Note:** It's important that the annotation is set inside the template key so that it will appear on each revision as they are created. Setting it in the top-level metadata will not propagate them to the revision and thus will not have any effect on autoscaling.

**Example:**
{{< tabs name="example" default="Per Revision" >}}
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
        autoscaling.knative.dev/target: "70"
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
 container-concurrency-target-default: "100"
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
      container-concurrency-target-default: "100"
```
{{< /tab >}}
{{< /tabs >}}

## Class

As mentioned above, there are multiple potential implementations of an autoscaler. Knative Serving supports the Knative Pod Autoscaler (KPA) and Kubernetes' Horizontal Pod Autoscaler (HPA). The HPA needs to be enabled during installation and is not part of the Knative Serving core.

The KPA is the default and is tailored for serverless workloads. It has performance optimizations that the HPA currently does not have and, unlike the HPA, it supports scale to zero. The HPA on the other hand supports CPU based autoscaling, which the KPA does not support.

* **Global key:** `pod-autoscaler-class`
* **Per-revision annotation key:** `autoscaling.knative.dev/class`
* **Possible values:** `"kpa.autoscaling.knative.dev"` or `"hpa.autoscaling.knative.dev"`
* **Default:** `"kpa.autoscaling.knative.dev"`

**Example:**
{{< tabs name="class" default="Per Revision" >}}
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
        autoscaling.knative.dev/class: "kpa.autoscaling.knative.dev"
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
 pod-autoscaler-class: "kpa.autoscaling.knative.dev"
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
      pod-autoscaler-class: "kpa.autoscaling.knative.dev"
```
{{< /tab >}}
{{< /tabs >}}

## Metric

The metric specifies which value is looked at and compared against the respective target. The KPA supports two metrics: **concurrency** and **requests-per-seconds** (rps). The HPA currently only supports **cpu** in Knative Serving.

* **Global key:** n/a
* **Per-revision annotation key:** `autoscaling.knative.dev/metric`
* **Possible values:** `"concurrency"`, `"rps"` or `"cpu"`
* **Default:** `"concurrency"`

**Note:** `"cpu"` is only supported on revisions with the HPA class.

**Example:**
{{< tabs name="metric" default="Per Revision" >}}
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
        autoscaling.knative.dev/metric: "rps"
    spec:
      containers:
        - image: gcr.io/knative-samples/helloworld-go
```
{{< /tab >}}
{{< /tabs >}}

## Targets

The autoscaling target is the value the autoscaler tries to maintain per replica of the application. If we, for example, specify a "concurrency target" of "10", the autoscaler will try to make sure that every replica receives on average 10 requests at a time. A target is always evaluated against a specified metric.

**Note:** The per-revision annotation keys for specifying a target are always the same while the global keys specify the metric they correspond to. Globally, the distinction is needed as there can be revision using different metrics in the system. On the revision itself though, that'd be redundant information as the metric is defined separately (see above), hence the target annotation key is metric agnostic and can be used for all of the supported metrics.

### Concurrency Targets/Limits

When "Metric" is set to "concurrency", Knative Serving revisions are scaled on observed **concurrency**. As in the example above, it tries to maintain a stable amount of concurrent requests being worked on by each replica.

Configuring a concurrency target is a little special because Knative Serving has a **soft** and a **hard** concurrency limit. As the name suggests, the hard limit is an enforced upper bound. If concurrency ever hits that bound, additional requests will be buffered and wait until enough capacity is free to execute the requests. The soft limit is only a target for the autoscaler. In some situations and especially on bursts this value can be exceeded by a given replica.

**Note:** It is recommended to only use the hard limit if your application has a clear need for it. Low hard limit values can have an impact on the throughput and latency of the application.\
**Note:** If both a soft and a hard limit are specified, the smaller of the two values will be used as to not have the autoscaler target a value that's not even allowed into the replica by the hard limit.

#### Soft Limit (target)

* **Global key:** `container-concurrency-target-default`
* **Per-revision annotation key:** `autoscaling.knative.dev/target`
* **Possible values:** integer
* **Default:** `100`

**Example:**
{{< tabs name="target-concurrency" default="Per Revision" >}}
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
        autoscaling.knative.dev/target: "200"
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
 container-concurrency-target-default: "200"
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
      container-concurrency-target-default: "200"
```
{{< /tab >}}
{{< /tabs >}}

#### Hard Limit (containerConcurrency)

The hard limit has its global setting in the `config-defaults` config map and can also be specified per-revision. Its per-revision setting is not an annotation but is actually present on the revision's spec itself as `containerConcurrency`. Its default value is "0", which means an unlimited number of requests are allowed to flow into the replica. A value above "0" specifies the exact amount of requests allowed to the replica at a time.

* **Global key:** `container-concurrency` (`config-defaults` config map)
* **Per-revision spec key:** `containerConcurrency`
* **Possible values:** integer
* **Default:** `0`, which means unlimited

**Example:**
{{< tabs name="container-concurrency" default="Per Revision" >}}
{{% tab name="Per Revision" %}}
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
      containers:
        - image: gcr.io/knative-samples/helloworld-go
```
{{< /tab >}}
{{% tab name="Global (ConfigMap)" %}}
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: config-defaults
 namespace: knative-serving
data:
 container-concurrency: "50"
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
    defaults:
      container-concurrency: "50"
```
{{< /tab >}}
{{< /tabs >}}

#### Target Utilization

In addition to the literal settings explained above, the concurrency values can further be adjusted via a target utilization value. This value specifies a percentage of the target to actually be targeted by the autoscaler. In effect, this specifies the “hotness” at which a replica runs, which causes the autoscaler to scale up before the total limit is reached.

* **Global key:** `container-concurrency-target-percentage`
* **Per-revision annotation key:** `autoscaling.knative.dev/targetUtilizationPercentage`
* **Possible values:** float
* **Default:** `70`

**Note:** Target Utilization is only applied to the autoscaling as a suggestion. It is not applied to the hard limit enforcement itself. For example, if containerConcurrency is set to 10 and the utilization to "70" (percent), the autoscaler will create a new replica when the average number of concurrent requests across all replicas reaches "7". Note that requests numbered 7 through 10 will still be sent to the existing replicas, but this allows for additional replicas to be started in anticipation of it being needed when the containerConcurrency limit is reached.

**Note:** If the activator is in the routing path, it will fully load all replicas up to `containerConcurrency`. It currently does not take target utilization into account.

**Example:**
{{< tabs name="target-utilization" default="Per Revision" >}}
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
        autoscaling.knative.dev/targetUtilizationPercentage: "80"
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
 container-concurrency-target-percentage: "80"
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
      container-concurrency-target-percentage: "80"
```
{{< /tab >}}
{{< /tabs >}}

### Requests-per-second Target

As the name suggests, this specifies a target requests-per-second per replica.

* **Global key:** `requests-per-second-target-default`
* **Per-revision annotation key:** `autoscaling.knative.dev/target`
* **Possible values:** integer
* **Default:** `200`

**Example:**
{{< tabs name="rps-target" default="Per Revision" >}}
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
        autoscaling.knative.dev/target: "150"
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
 requests-per-second-target-default: "150"
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
      requests-per-second-target-default: "150"
```
{{< /tab >}}
{{< /tabs >}}

## Scale Bounds

To apply upper and lower bounds to the scaling behavior, one can specify scale bounds in both directions.

### Lower bound

This value controls the minimum number of replicas each revision should have. Knative will attempt to never have less than this number of replicas at any one point in time.

* **Global key:** n/a
* **Per-revision annotation key:** `autoscaling.knative.dev/minScale`
* **Possible values:** integer
* **Default:** `0` if scale-to-zero is enabled and class KPA is used, `1` otherwise

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

### Upper bound

This value controls the maximum number of replicas each revision should have. Knative will attempt to never have more than this number of replicas running, or in the process of being created, at any one point in time.

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

# Knative Pod Autoscaler (KPA) Behavior

The following settings are specific to the KPA.

## Scale To Zero

The scale-to-zero values control whether Knative allows revisions to scale down to zero, or stops at "1".

### Enablement

* **Global key:** `enable-scale-to-zero`
* **Per-revision annotation key:** n/a
* **Possible values:** boolean
* **Default:** `true`

**Note:** If this is set to `false`, the behavior of the lower Scale Bounds configuration changes as described above.

**Example:**
{{< tabs name="scale-to-zero" default="Global (ConfigMap)" >}}
{{% tab name="Global (ConfigMap)" %}}
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: config-autoscaler
 namespace: knative-serving
data:
 enable-scale-to-zero: "false"
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
      enable-scale-to-zero: "false"
```
{{< /tab >}}
{{< /tabs >}}

### Scale To Zero Grace Period

This period is an upper bound amount of time the system waits internally for the scale-from-zero machinery to be in place before the last replica is actually removed. This is an implementation detail and does not adjust how long the last replica will be kept after traffic ends as it's not guaranteed that the will actually keep the replica for this time. This is a value that controls how long internal network programming is allowed to take and should only be adjusted if there have been issues with requests being dropped when a revision was scaling to zero.

* **Global key:** `scale-to-zero-grace-period`
* **Per-revision annotation key:** n/a
* **Possible values:** Duration (must be at least 6s).
* **Default:** `30s`

**Example:**
{{< tabs name="scale-to-zero-grace" default="Global (ConfigMap)" >}}
{{% tab name="Global (ConfigMap)" %}}
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: config-autoscaler
 namespace: knative-serving
data:
 scale-to-zero-grace-period: "40s"
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
      scale-to-zero-grace-period: "40s"
```
{{< /tab >}}
{{< /tabs >}}


### Scale To Zero Last Pod Retention Period

The `scale-to-zero-pod-retention-period` flag determines the **minimum** amount of time that the last pod will remain active after the Autoscaler has decided to scale pods to zero.

This contrasts with the `scale-to-zero-grace-period` flag, which determines the **maximum** amount of time that the last pod will remain active after the Autoscaler has decided to scale pods to zero.

* **Global key:** `scale-to-zero-pod-retention-period`
* **Per-revision annotation key:** `autoscaling.knative.dev/scaleToZeroPodRetentionPeriod`
* **Possible values:** Non-negative duration string
* **Default:** `0s`

**Example:**
{{< tabs name="scale-to-zero-grace" default="Global (ConfigMap)" >}}
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
        autoscaling.knative.dev/scaleToZeroPodRetentionPeriod: "1m5s"
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
 scale-to-zero-pod-retention-period: "42s"
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
      scale-to-zero-pod-retention-period: "42s"
```
{{< /tab >}}
{{< /tabs >}}

## Modes: Stable and Panic

The KPA acts on the respective metrics (concurrency or RPS) aggregated over time-based windows. These windows define the amount of historical data the autoscaler takes into account and are used to smooth the data over the specified amount of time. The shorter these windows are, the more quickly the autoscaler will react but the more hysterically it will react as well.

The KPA's implementation has two modes: **stable** and **panic**. The stable mode is for general operation while the panic mode has, by default, a much shorter window and will be used to quickly scale a revision up if a burst of traffic comes in. As the panic window is a lot shorter, it will react more quickly to load. The revision will not scale down while in panic mode to avoid a lot of churn.

### Stable Window

* **Global key:** `stable-window`
* **Per-revision annotation key:** `autoscaling.knative.dev/window`
* **Possible values:** Duration, `6s` <= value <= `1h`
* **Default:** `60s`

**Note:** During scale-down, the final replica will only be removed after the revision hasn't seen any traffic for the entire duration of the stable window.\
**Note:** The autoscaler will leave panic mode only after not seeing a reason to panic for the stable window's timeframe.

**Example:**
{{< tabs name="stable-window" default="Per Revision" >}}
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
        autoscaling.knative.dev/window: "40s"
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
 stable-window: "40s"
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
      stable-window: "40s"
```
{{< /tab >}}
{{< /tabs >}}

### Panic Window

The panic window is defined as a percentage of the stable window to assure they are both in a workable relation to each other. This value indicates how the window over which historical data is evaluated will be shrunk upon entering panic mode. In other words, a value of "10" means that in panic mode the window will be 10% of the stable window size.

* **Global key:** `panic-window-percentage`
* **Per-revision annotation key:** `autoscaling.knative.dev/panicWindowPercentage`
* **Possible values:** float, `1.0` <= value <= `100.0`
* **Default:** `10.0`

**Example:**
{{< tabs name="panic-window" default="Per Revision" >}}
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
        autoscaling.knative.dev/panicWindowPercentage: "20.0"
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
 panic-window-percentage: "20.0"
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
      panic-window-percentage: "20.0"
```
{{< /tab >}}
{{< /tabs >}}

### Panic Mode Threshold

This threshold defines when the autoscaler will move from stable mode into panic mode. It's a multiple of the traffic that the current amount of replicas can (or cannot) handle. 100 percent would mean that the autoscaler is always in panic mode, hence the minimum is somewhat higher than that. The default of 200 means that panic mode will be entered if traffic is twice as high as the current replica population can handle.

* **Global key:** `panic-threshold-percentage`
* **Per-revision annotation key:** `autoscaling.knative.dev/panicThresholdPercentage`
* **Possible values:** float, `110.0` <= value <= `1000.0`
* **Default:** `200.0`

**Example:**
{{< tabs name="panic-threshold" default="Per Revision" >}}
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
        autoscaling.knative.dev/panicThresholdPercentage: "150.0"
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
 panic-threshold-percentage: "150.0"
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
      panic-threshold-percentage: "150.0"
```
{{< /tab >}}
{{< /tabs >}}

## Scale Rates

These settings control by how much the revision's population can scale up or down in a single evaluation cycle. A minimal change of one in each direction is always allowed, i.e. the autoscaler can always scale up or down by at least one, regardless of this rate.

### Scale Up Rate

Maximum ratio of desired vs. observed pods, i.e. with a value of `2.0`, the revision can only go from `N` to `2*N` pods in one evaluation cycle.

* **Global key:** `max-scale-up-rate`
* **Per-revision annotation key:** n/a
* **Possible values:** float
* **Default:** `1000.0`

**Example:**
{{< tabs name="scale-up-rate" default="Global (ConfigMap)" >}}
{{% tab name="Global (ConfigMap)" %}}
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: config-autoscaler
 namespace: knative-serving
data:
 max-scale-up-rate: "500.0"
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
      max-scale-up-rate: "500.0"
```
{{< /tab >}}
{{< /tabs >}}

### Scale Down Rate

Maximum ratio of observed vs. desired pods, i.e. with a value of `2.0`, the revision can only go from `N` to `N/2` pods in one evaluation cycle.

* **Global key:** `max-scale-down-rate`
* **Per-revision annotation key:** n/a
* **Possible values:** float
* **Default:** `2.0`

**Example:**
{{< tabs name="scale-down-rate" default="Global (ConfigMap)" >}}
{{% tab name="Global (ConfigMap)" %}}
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: config-autoscaler
 namespace: knative-serving
data:
 max-scale-down-rate: "4.0"
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
      max-scale-down-rate: "4.0"
```
{{< /tab >}}
{{< /tabs >}}
