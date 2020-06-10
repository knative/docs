---
title: "Configuring high-availability components"
weight: 50
type: "docs"
---

Active/passive high availability (HA) is a standard feature of Kubernetes APIs that helps to ensure that APIs stay operational if a disruption occurs. In an HA deployment, if an active controller crashes or is deleted, another controller is available to take over processing of the APIs that were being serviced by the controller that is now unavailable.

Active/passive HA in Knative is available through leader election, which can be enabled after Knative Serving control plane is installed.

When using a leader election HA pattern, instances of controllers are already scheduled and running inside the cluster before they are required. These controller instances compete to use a shared resource, known as the leader election lock. The instance of the controller that has access to the leader election lock resource at any given time is referred to as the leader.

HA functionality is available on Knative for the following components:

- `autoscaler-hpa`
- `controller`
- `activator`

HA functionality is not currently available for the following components:

- `autoscaler`
- `webhook`
- `queueproxy`
- `net-kourier`

## Enabling leader election

**NOTE:** Leader election functionality is still an alpha phase feature currently in development.

1. Enable leader election for the control plane controllers:
```
$ kubectl patch configmap/config-leader-election \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"enabledComponents": "controller,hpaautoscaler,certcontroller,istiocontroller,nscontroller"}}'
```

1. Restart the controllers:
```
$ kubectl rollout restart deployment <deployment-name> -n knative-serving
```

  **NOTE:** You will experience temporary control plane downtime during this step.

  When your controllers come back up, they should be running as leader-elected.
  At this point, we've configured the controllers to use leader election and we
  can scale the control plane up!

1. After the controllers have been configured to use leader election, the control plane can be scaled up:
```
$ kubectl -n knative-serving scale deployment <deployment-name> --replicas=2
```

## Scaling the control plane

The following serving controller deployments can be scaled up once leader election is enabled.

Standard deployments:

- `controller`
- `networking-istio` (if Istio is installed)

Optionally installed deployments:

- `autoscaler-hpa`
- `networking-ns-cert`
- `networking-certmanager`

Scale up the deployment(s):
```
$ kubectl -n knative-serving scale deployment <deployment-name> --replicas=2
```

- Setting `--replicas` to a value of `2` enables HA.
- You can use a higher value if you have a use case that requires more replicas of a deployment. For example, if you require a minimum of 3 `controller` deployments, set `--replicas=3`.
- Setting `--replicas=1` disables HA.
