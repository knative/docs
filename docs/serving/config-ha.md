---
title: "Configuring high-availability components"
weight: 50
type: "docs"
---

Active/passive high availability (HA) is a standard feature of Kubernetes APIs that helps to ensure that APIs stay operational if a disruption occurs. In an HA deployment, if an active controller crashes or is deleted, another controller is available to take over processing of the APIs that were being serviced by the controller that is now unavailable.

Active/passive HA in Knative is available through leader election, which can be enabled after Knative Serving control plane is installed.

When using a leader election HA pattern, instances of controllers are already scheduled and running inside the cluster before they are required. These controller instances compete to use a shared resource, known as the leader election lock. The instance of the controller that has access to the leader election lock resource at any given time is referred to as the leader.

HA functionality is enabled by default for all Knative Serving components except `autoscaler`.

## Disabling leader election

For components leveraging leader election to achieve HA, this capability can be disabled by passing the flag: `--disable-ha`.  This option will go away when HA graduates to "stable".

## Scaling the control plane

With the notable exception of the `autoscaler` you can scale up any deployment running in `knative-serving` (or `kourier-system`) with a command like:

```
$ kubectl -n knative-serving scale deployment <deployment-name> --replicas=2
```

- Setting `--replicas` to a value of `2` enables HA.
- You can use a higher value if you have a use case that requires more replicas of a deployment. For example, if you require a minimum of 3 `controller` deployments, set `--replicas=3`.
- Setting `--replicas=1` disables HA.
- Passing `--disable-ha` to the controller process disables leader election.
