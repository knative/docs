{% include "gradual-rollout-intro.md" %}

## Procedure

You can configure the `rollout-duration` parameter by modifying the `config-network` ConfigMap, or by using the Operator.

=== "ConfigMap configuration"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-network
     namespace: knative-serving
    data:
      rollout-duration: "380s"  # Value in seconds.
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
           rollout-duration: "380s"
    ```

{% include "route-status-updates.md" %}

{% include "multiple-rollouts.md" %}
