---
title: "Custom-metrics API"
weight: 10
type: "docs"
---

The `custom-metrics` API is installed by default when you install Knative Serving, and allows users to configure concurrency based scaling when using the Horizontal Pod Autoscaler (HPA).

>**IMPORTANT:** If you already have an existing `custom-metrics` API implementation in your cluster, you must delete this so that Knative Serving can use the default Knative Serving installation of the `custom-metrics` API. Enabling both implementations can cause issues.
>
>If you intend to use an existing `custom-metrics` API implementation in your cluster, you will not be able to use custom metrics or HPA concurrency metrics on that cluster. These features require the Knative Serving `custom-metrics` API implementation.

# Checking for existing custom-metrics API implementations

To check if your cluster has an existing `custom-metrics` API implementation, use the following command.

```
kubectl get apiservice | grep v1beta1.custom.metrics.k8s.io
```

# Deleting existing custom-metrics API installations

If you have an existing `custom-metrics` API implementation in your cluster, you must delete this using the following command.

```
kubectl delete apiservice v1beta1.custom.metrics.k8s.io
```

**IMPORTANT:** This step is not required for inexperienced users, as it is possible to break consumers of a custom-metrics API by deleting this. Only delete API implementations if you are sure that it is safe to do so.
