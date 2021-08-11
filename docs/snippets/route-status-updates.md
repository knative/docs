## Route status updates

During a rollout, the system updates the Route and Knative Service status conditions. Both the `traffic` and `conditions` status parameters are affected.

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

Initially 1% of the traffic is rolled out to the Revisions:

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

The rollout continues until the target traffic configuration is reached:

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

During the rollout, the Route and Knative Service status conditions are as follows:

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
