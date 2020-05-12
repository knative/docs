---
title: "Configuring high-availability components"
linkTitle: "Configuring high-availability components"
weight: 20
type: "docs"
---

Active/passive high availability (HA) is a standard feature of Kubernetes APIs that helps to ensure that APIs stay operational if a disruption occurs. In an HA deployment, if an active controller crashes or is deleted, another controller is available to take over processing of the APIs that were being serviced by the controller that is now unavailable.

Active/passive HA in Knative is available through leader election, which can be enabled after Knative Serving control plane is installed.

When using a leader election HA pattern, instances of controllers are already scheduled and running inside the cluster before they are required. These controller instances compete to use a shared resource, known as the leader election lock. The instance of the controller that has access to the leader election lock resource at any given time is referred to as the leader.

HA functionality is available on Knative for the `autoscaler-hpa`, `controller` and `activator` components.

## Enabling leader election

1. Enable leader election for the control plane controllers:
```
$ kubectl patch configmap/config-leader-election \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"enabledComponents": "controller,hpaautoscaler,certcontroller,istiocontroller,nscontroller"}}'
```

1. Restart the controllers:
```
  $ kubectl rollout restart deployment -n knative-serving
```

  **NOTE:** You will experience temporary control plane downtime during this step.

  When your controllers come back up, they should be running as leader-elected.
  At this point, we've configured the controllers to use leader election and we
  can scale the control plane up!

1. After the controllers have been configured to use leader election, the control plane can be scaled up:
```
$ kubectl rollouts restart deployment -n knative-serving controller
```

## Scaling the control plane

The following serving controller deployments can be scaled up once leader election is enabled:

- `controller`
- `autoscaler-hpa`
- `networking-certmanager`
- `networking-istio` (if Istio is installed)
- `networking-ns-cert`

Scale up the deployment(s):
```
$ kubectl scale --replicas=2 <deployment-name>
```
