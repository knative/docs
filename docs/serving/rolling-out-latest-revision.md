---
title: "Gradually rolling out latest Revisions"
weight: 20
type: "docs"
---

# Gradually rolling out latest Revisions

If your traffic configuration points to a Configuration target, rather than revision target, it means that when a new Revision is created and ready 100% of that target's traffic will be immediately shifted to the new revision, which might not be ready to accept that scale with a single pod and with cold starts taking some time it is possible to end up in a situation where a lot of requests are backed up either at QP or Activator and after a while they might expire or QP might outright reject the requests.

To mitigate this problem Knative as of 0.20 release Knative provides users with a possibility to gradually shift the traffic to the latest revision.
This is governed by a single parameter which denotes `rollout-duration`.

The affected Configuration targets will be rolled out to 1% of traffic first and then in equal incremental steps for the rest of the assigned traffic. Note, that the rollout is purely time based and does not interact with the Autoscaling subsystem.


This feature is available to untagged and tagged traffic targets configured for both  Kservices and Kservice-less Routes.


## Configuring gradual Rollout

This value currently can be configured on the cluster level (starting v0.20) via a setting in the `config-network` ConfigMap or per Kservice or Route using an annotation (staring v.0.21).

=== "Per-revision"
    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: helloworld-go
      namespace: default
      annotations:
        serving.knative.dev/rolloutDuration: "380s"
    ...
    ```
=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
    name: config-network
    namespace: knative-serving
    data:
      rolloutDuration: "380s"  # Value in seconds.
    ```
=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        network:
          rolloutDuration: "380s"
    ```

## Route Status updates

During the rollout the system will update the Route and Kservice status. Both `traffic` and `conditions` status fields will be affected.

For example, a possible rollout of the following traffic configuration

```yaml
traffic:
- percent: 55
  configurationName: config # Pinned to latest ready Revision
- percent: 45
  revisionName: config-00005 # Pinned to a specific Revision.
```

would be (if inspecting the route status):
```yaml
traffic:
- percent: 54
  revisionName: config-00008
- percent: 1
  revisionName: config-00009
- percent: 45
  revisionName: config-00005 # Pinned to a specific Revision.
```

and then, presuming steps of 18%:

```yaml
traffic:
- percent: 36
  revisionName: config-00008
- percent: 19
  revisionName: config-00009
- percent: 45
  revisionName: config-00005 # Pinned to a specific Revision.
```

and so on until final state is achieved:

```yaml
traffic:
- percent: 55
  revisionName: config-00009
- percent: 45
  revisionName: config-00005 # Pinned to a specific Revision.
```

During the rollout the Route and (Kservice, if present) status conditions will be the following:

```yaml
...
status:
  conditions:
  ...
  - lastTransitionTime: "..."
    message: A gradual rollout of the latest revision(s) is in progress.
    reason: RolloutInProgress
    status: Unknown
    type: Ready
...
```

## Multiple Rollouts

If a new revision is created while the rollout is in progress then the system would start shifting the traffic immediately to the newest revision and it will drain the incomplete rollouts from newest to the oldest.
