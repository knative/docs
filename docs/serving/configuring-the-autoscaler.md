---
title: "Configuring the Autoscaler"
weight: 10
type: "docs"
markup: "mmark"
---

Since Knative v0.2, per revision autoscalers have been replaced by a single
shared autoscaler. This is, by default, the Knative Pod Autoscaler (KPA), which
provides fast, request-based autoscaling capabilities out of the box.

# Configuring Knative Pod Autoscaler

To modify the Knative Pod Autoscaler (KPA) configuration, you must modify a
Kubernetes ConfigMap called `config-autoscaler` in the `knative-serving`
namespace.

You can view the default contents of this ConfigMap using the following command.

`kubectl -n knative-serving get cm config-autoscaler`

## Example of default ConfigMap

```
apiVersion: v1
kind: ConfigMap
metadata:
 name: config-autoscaler
 namespace: knative-serving
data:
 container-concurrency-target-default: 100
 container-concurrency-target-percentage: 1.0
 enable-scale-to-zero: true
 enable-vertical-pod-autoscaling: false
 max-scale-up-rate: 10
 panic-window: 6s
 scale-to-zero-grace-period: 30s
 stable-window: 60s
 tick-interval: 2s
```

# Configuring scale to zero for KPA

To correctly configure autoscaling to zero for revisions, you must modify the
following parameters in the ConfigMap.

## scale-to-zero-grace-period

`scale-to-zero-grace-period` specifies the time an inactive revision is left
running before it is scaled to zero (min: 6s).

```
scale-to-zero-grace-period: 30s
```

## stable-window

When operating in a stable mode, the autoscaler operates on the average
concurrency over the stable window (min: 6s).

```
stable-window: 60s
```

`stable-window` can also be configured in the Revision template as an
annotation.

```
autoscaling.knative.dev/window: 60s
```

## enable-scale-to-zero

Ensure that enable-scale-to-zero is set to `true`, if scale to zero is desired.

## Termination period

The termination period is the time that the pod takes to shut down after the
last request is finished. The termination period of the pod is equal to the sum
of the values of the `stable-window` and `scale-to-zero-grace-period`
parameters. In the case of this example, the termination period would be 90s.

## Configuring concurrency

Concurrency for autoscaling can be configured using the following methods.

## Configuring concurrent request limits

### target

`target` defines how many concurrent requests are wanted at a given time (soft
limit) and is the recommended configuration for autoscaling in Knative.

The default value for concurrency target is specified in the ConfigMap as `100`.

```
`container-concurrency-target-default: 100`
```

This value can be configured by adding or modifying the
`autoscaling.knative.dev/target` annotation value in the revision template.

```
autoscaling.knative.dev/target: 50
```

### containerConcurrency

**NOTE:** `containerConcurrency` should only be used if there is a clear need to
limit how many requests reach the app at a given time. Using
`containerConcurrency` is only advised if the application needs to have an
enforced constraint of concurrency.

`containerConcurrency` limits the amount of concurrent requests are allowed into
the application at a given time (hard limit), and is configured in the revision
template.

```
containerConcurrency: 0 | 1 | 2-N
```

- A `containerConcurrency` value of `1` will guarantee that only one request is
  handled at a time by a given instance of the revision container, though requests
  might be queued, waiting to be served.
- A value of `2` or more will limit request concurrency to that value.
- A value of `0` means the system should decide.

If there is no `/target` annotation, the autoscaler is configured as if
`/target` == `containerConcurrency`.

## Configuring scale bounds (minScale and maxScale)

The `minScale` and `maxScale` annotations can be used to configure the minimum
and maximum number of pods that can serve applications. These annotations can be
used to prevent cold starts or to help control computing costs.

`minScale` and `maxScale` can be configured as follows in the revision template;

```
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/minScale: "2"
        autoscaling.knative.dev/maxScale: "10"
```

Using these annotations in the revision template will propagate this to
`PodAutoscaler` objects. `PodAutoscaler` objects are mutable and can be further
modified later without modifying anything else in the Knative Serving system.

```
kubectl edit podautoscaler <revision-name>
```

**NOTE:** These annotations apply for the full lifetime of a revision. Even when
a revision is not referenced by any route, the minimal pod count specified by
`minScale` will still be provided. Keep in mind that non-routeable revisions may
be garbage collected, which enables Knative to reclaim the resources.

### Default behavior

If the `minScale` annotation is not set, pods will scale to zero (or to 1 if
`enable-scale-to-zero` is `false` per the ConfigMap mentioned above).

If the `maxScale` annotation is not set, there will be no upper limit for the
number of pods created.

## Configuring CPU-based autoscaling

**NOTE:** You can configure Knative autoscaling to work with either the default
KPA or a CPU based metric, i.e. Horizontal Pod Autoscaler (HPA).

You can configure Knative to use CPU based autoscaling instead of the default
request based metric by adding or modifying the `autoscaling.knative.dev/class`
and `autoscaling.knative.dev/metric` values as annotations in the revision
template.

```
spec:
  template:
    metadata:
      autoscaling.knative.dev/metric: concurrency
      autoscaling.knative.dev/class: hpa.autoscaling.knative.dev
```

## Additional resources

- [Go autoscaling sample](https://knative.dev/docs/serving/samples/autoscale-go/index.html)
- ["Knative v0.3 Autoscaling  - A Love Story" blog post](https://knative.dev/blog/2019/03/27/knative-v0.3-autoscaling-a-love-story/)
- [Kubernetes Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
