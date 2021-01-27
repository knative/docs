---
title: "Configuring high-availability components"
weight: 50
type: "docs"
---

Active/passive high availability (HA) is a standard feature of Kubernetes APIs that helps to ensure that APIs stay operational if a disruption occurs. In an HA deployment, if an active controller crashes or is deleted, another controller is available to take over processing of the APIs that were being serviced by the controller that is now unavailable.

Active/passive HA in Knative is available through leader election, which can be enabled after Knative Serving control plane is installed.

When using a leader election HA pattern, instances of controllers are already scheduled and running inside the cluster before they are required. These controller instances compete to use a shared resource, known as the leader election lock. The instance of the controller that has access to the leader election lock resource at any given time is referred to as the leader.

Leader election is enabled but HA functionanlity is disabled with 1 replica by default for all Knative Serving components.

## Disabling leader election

For components leveraging leader election to achieve HA, this capability can be disabled by passing the flag: `--disable-ha`.  This option will go away when HA graduates to "stable".

## Scaling the control plane

With the exception of the `activator` component you can scale up any deployment running in `knative-serving` (or `kourier-system`) with a command like:

```
$ kubectl -n knative-serving scale deployment <deployment-name> --replicas=2
```

- Setting `--replicas` to a value of `2` enables HA.
- You can use a higher value if you have a use case that requires more replicas of a deployment. For example, if you require a minimum of 3 `controller` deployments, set `--replicas=3`.
- Setting `--replicas=1` disables HA.

NOTE: if you scale down the `autoscaler` component, you may get inaccurate autoscaling results for a subset of your Revisions for a period, which can
be up to the `stable-window` time. This is because when an `autoscaler` pod is terminating, the ownership of the currently owned Revisions will be acquired by
other standby `autoscaler` pods. The new leader `autoscaler` pods will need the `stable-window` time to build the scaling metrics state for those Revisions.

## Scaling the data plane

The scale of the `activator` component is governed by the Kubernetes HPA component. You can see the current HPA scale limits and the current scale by running:

```
$ kubectl get hpa activator -n knative-serving
```

The possible output will be something like:

```
NAME        REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
activator   Deployment/activator   2%/100%   5         15        11         346d
```

By default `minReplicas` and `maxReplicas` are set to `1` and `20`, correspondingly. If those values are not desirable for some reason, then, for example, you can change those values to `minScale=9` and `maxScale=19` using the following command:

```
$ kubectl patch hpa activator -n knative-serving -p '{"spec":{"minReplicas":9,"maxReplicas":19}}'
```

To set the activator scale to a particular value, just set `minScale` and `maxScale` to the same desired value.

It is recommended for production deployments to run at least 3 `activator` instances for redundancy and avoiding single point of failure if a Knative service needs to be scaled from 0.
