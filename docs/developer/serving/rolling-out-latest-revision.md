{% include "gradual-rollout-intro.md" %}

## Procedure

You can configure the `rollout-duration` parameter per Knative Service or Route by using an annotation.

!!! tip
    For information about global, ConfigMap configurations for roll-out durations, see the [Administration guide](../../../admin/serving/rolling-out-latest-revision-configmap)

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-go
  namespace: default
  annotations:
    serving.knative.dev/rolloutDuration: "380s"
```

{% include "route-status-updates.md" %}

{% include "multiple-rollouts.md" %}
