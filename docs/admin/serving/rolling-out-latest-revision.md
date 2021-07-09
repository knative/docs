# Configuring gradual roll-out of traffic to Revisions

If your traffic configuration points to a Configuration target instead of a Revision target, when a new Revision is created and ready, 100% of the traffic from the target is immediately shifted to the new Revision.

This might cause requests to become backed up, either at the QP or Activator, and after a while the requests might expire or be rejected by the QP.
<!--QUESTION: QP == queue proxy?-->

Knative provides a `rollout-duration` parameter, which can be used to gradually shift traffic to the latest Revision, preventing requests from being queued or rejected. Affected Configuration targets are rolled out to 1% of traffic first, and then in equal incremental steps for the rest of the assigned traffic.

!!! note
    `rollout-duration` is time based, and does not interact with the autoscaling subsystem.

This feature is available for tagged and untagged traffic targets, configured for either Knative Services or Routes without a service.

## Procedure

You can configure the `rollout-duration` parameter per Knative Service or Route by using an annotation, by modifying the `config-network` ConfigMap, or by using the Operator.
<!--TODO: Split this up and move the per service part to dev guide-->

=== "Service or Route configuration by using an annotation"
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

=== "ConfigMap configuration"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-network
     namespace: knative-serving
    data:
      rolloutDuration: "380s"  # Value in seconds.
    ```

=== "Operator configuration"
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

## Route status updates

During a roll-out, the system updates the Route and Knative Service status. Both the `traffic` and `conditions` status parameters are affected.

For example, for the following traffic configuration:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
...
spec:
...
  traffic:
  - percent: 55
    configurationName: config # Pinned to latest ready Revision
  - percent: 45
    revisionName: config-00005 # Pinned to a specific Revision.
```

Intially 1% of the traffic is rolled out to the Revisions:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
...
spec:
...
  traffic:
  - percent: 54
    revisionName: config-00008
  - percent: 1
    revisionName: config-00009
  - percent: 45
    revisionName: config-00005 # Pinned to a specific Revision.
```

Then the rest of the traffic is rolled out in increments of 18%:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
...
spec:
...
  traffic:
  - percent: 36
    revisionName: config-00008
  - percent: 19
    revisionName: config-00009
  - percent: 45
    revisionName: config-00005 # Pinned to a specific Revision.
```

The roll-out continues until the target traffic configuration has been reached:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
...
spec:
...
  traffic:
  - percent: 55
    revisionName: config-00009
  - percent: 45
    revisionName: config-00005 # Pinned to a specific Revision.
```

During the roll-out, the Route and Knative Service status conditions are as follows:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
...
spec:
...
status:
  conditions:
  ...
  - lastTransitionTime: "..."
    message: A gradual rollout of the latest revision(s) is in progress.
    reason: RolloutInProgress
    status: Unknown
    type: Ready
```

## Multiple roll-outs

If a new revision is created while a roll-out is in progress, the system begins to shift traffic immediately to the newest Revision, and drains the incomplete roll-outs from newest to oldest.
