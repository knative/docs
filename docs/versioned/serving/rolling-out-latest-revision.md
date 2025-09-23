{% include "gradual-rollout-intro.md" %}

## Procedure

You can configure the `rollout-duration` parameter per Knative Service or Route by using an annotation.

!!! tip
    For information about global, ConfigMap configurations for rollout durations, see the [Administration guide](configuration/rolling-out-latest-revision-configmap.md).

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-go
  namespace: default
  annotations:
    serving.knative.dev/rollout-duration: "380s"
```

{% include "route-status-updates.md" %}

{% include "multiple-rollouts.md" %}
