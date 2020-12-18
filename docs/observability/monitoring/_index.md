---
title: "Monitoring"
linkTitle: "Monitoring"
weight: 10
type: "docs"
---

After you have installed Knative Serving or Eventing, you can monitor your deployment to see information about different Knative components, such as readiness status and resource consumption.

## Monitoring Knative Serving

You can monitor the `STATUS` of components in the `knative-serving` namespace:

```
kubectl get pods --namespace knative-serving
```

Working pods show a status of `Running` or `Completed`.

## Monitoring Knative Eventing

You can monitor the `STATUS` of components in the `knative-eventing` namespace:

```
kubectl get pods --namespace knative-eventing
```

Working pods show a status of `Running` or `Completed`.
