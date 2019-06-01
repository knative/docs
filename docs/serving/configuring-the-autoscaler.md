---
title: "Configuring the Autoscaler"
weight: 10
type: "docs"
---

Since Knative v0.2, per revision autoscalers have been replaced by a single shared autoscaler. This is, by default, the Knative Pod Autoscaler (KPA), which provides fast, request-based autoscaling capabilities out of the box.

## Configuring Knative Pod Autoscaler

To modify the autoscaler configuration, you must modify a Kubernetes ConfigMap called `config-autoscaler` in the `knative-serving` namespace.

You can view the default contents of this ConfigMap using the following command.

`kubectl -n knative-serving get cm config-autoscaler`

### Example of default ConfigMap

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

## Configuring scale to zero

To correctly configure autoscaling to zero for revisions, you must modify the following parameters in the ConfigMap.

###  scale-to-zero-grace-period

` scale-to-zero-grace-period` specifies the time an inactive revision is left running before it is scaled to zero (min: 30s).

```
scale-to-zero-grace-period: 30s
```

###  stable-window

When operating in a stable mode, the autoscaler operates on the average concurrency over the stable window.
```
stable-window: 60s
```

`stable-window` can also be configured in the Revision template as an annotation.

```
autoscaling.knative.dev/window: 60s
```

###  enable-scale-to-zero

Ensure that enable-scale-to-zero is set to `true`.

### Termination period

The termination period is the time that the pod takes to shut down after the last request is finished. The termination period of the pod is equal to the sum of the values of the `stable-window` and `scale-to-zero-grace-period` parameters. In the case of this example, the termination period would be 90s.

## Configuring concurrency

Concurrency for autoscaling can be configured using the following methods.

### target

` target` defines how many concurrent requests are wanted at a given time (soft limit) and is the recommended configuration for autoscaling in Knative.

The default value for concurrency target is specified in the ConfigMap as `100`.
```
`container-concurrency-target-default: 100`
```
This value can be configured by adding or modifying the `autoscaling.knative.dev/target` annotation value in the Revision template.

```
autoscaling.knative.dev/target: 50
```

### containerConcurrency

**NOTE:** `containerConcurrency` should only be used if there is a clear need to limit how many requests reach the app at a given time. Using `containerConcurrency` is only advised if the application needs to have an enforced constraint of concurrency.

`containerConcurrency` limits the amount of concurrent requests are allowed into the application at a given time (hard limit), and is configured in the Revision template.

```
containerConcurrency: 0 | 1 | 2-N
```
- A `containerConcurrency` value of `1` will guarantee that only one request is handled at a time by a given instance of the Revision container.
- A value of `2` or more will limit request concurrency to that value.
- A value of `0` means the system should decide.

If there is no `/target` annotation, the autoscaler is configured as if `/target` == `containerConcurrency`.

## Configuring CPU-based autoscaling

**NOTE:** You can configure Knative autoscaling to work with either the default KPA or a CPU based metric, i.e. Horizontal Pod Autoscaler (HPA), however scale-to-zero capabilities are only supported for KPA.

You can configure Knative to use CPU based autoscaling instead of the default request based metric by adding or modifying the `autoscaling.knative.dev/class` and `autoscaling.knative.dev/metric` values as annotations in the Revision template.

```
autoscaling.knative.dev/metric: cpu
autoscaling.knative.dev/class: hpa.autoscaling.knative.dev
```

## Additional resources

- [Go autoscaling sample](https://knative.dev/docs/serving/samples/autoscale-go/index.html)
- [Knative v0.3 Autoscaling  - A Love Story blog post](https://medium.com/knative/knative-v0-3-autoscaling-a-love-story-d6954279a67a)
