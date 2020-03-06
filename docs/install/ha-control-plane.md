---
title: "Running a highly-available Knative control plane"
weight: 10
type: "docs"
---

Learn how to run an highly-available (HA) control plane using leader election.

It is important to be able to provide an HA control plane that is resilient in
the face of a controller instance unexpectedly dying. Beginning in release 0.13,
Knative provides the ability to leader elect some controllers. 

To enable leader election, you will edit the leader election config and then
scale up the controller replica count.

Note:

- HA control plane is still under development
- Not all components can be run in an HA fashion yet

## Before you begin

You need:

- A Kubernetes cluster with [Knative Serving installed](README.md).

This doc assumes that you are starting from a fresh installation where the
leader-election configuration has not been modified.

## Enabling leader election

1. Enable leader election for the control plane controllers:

    ```shell
    kubectl patch configmap/config-leader-election \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"enabledComponents": "controller,hpaautoscaler,certcontroller,istiocontroller,nscontroller"}}'
    ```

1. Restart the controllers:

    Note: you will take a brief amount of control plane downtime during this step.

    ```shell
    kubectl rollout restart deployment -n knative-serving
    ```

    When your controllers come back up, they should be running leader-elected.

At this point, we've configured the controllers to use leader election and we
can scale the control plane up!

1. Now, you can scale the control plane up. 

    ```bash
    kubectl rollouts restart deployment -n knative-serving controller 
    ```

## Scaling the control plane

The following serving controller deployments can be scaled up as of serving 0.13:

- `controller`
- `autoscaler-hpa`
- `networking-certmanager`
- `networking-istio`
- `networking-ns-cert`

Any of these deployments can be scaled up once leader election is enabled.

```shell
kubectl scale --replicas=2 controller autoscaler-hpa networking-certmanager networking-ns-cert
```

Note: include `networking-istio` if Istio is installed.

## Next steps

You can follow the [feature track](https://github.com/knative/pkg/issues/1007)
to monitor progress as we continue to develop this feature.