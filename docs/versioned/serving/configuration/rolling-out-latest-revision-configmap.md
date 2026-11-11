---
audience: administrator
components:
  - serving
function: how-to
---

{% include "gradual-rollout-intro.md" %}

## Procedure

You can configure the `rollout-duration` parameter through the `config-network` ConfigMap, or the Operator's authoritative custom resource. This key is an integer number of seconds encoded as a string, not a duration string such as `"380s"`; see the [v1.24 network configuration parser](https://github.com/knative/serving/blob/knative-v1.24.0/vendor/knative.dev/networking/pkg/config/config.go){target=_blank}.

For **Operator-managed Serving**, inspect `spec.config` in the live resource and authoritative manifest before using the shortened `network` fragment below. If `config-network` exists, it wins even when empty; change that entry instead of adding a shadow `network` entry or deleting the full entry to bypass precedence. Use the [ConfigMap mapping reference](../../install/operator/configuration-reference.md#configmap-mapping) to select the entry, then the [generic Serving Operator apply/verify workflow](../../install/operator/configuring-serving-cr.md#apply-and-verify-a-configuration-change), inspecting active `config-network.data.rollout-duration`. Do not follow the separate domain example's guards. Matching configuration confirms propagation, not observed rollout behavior.

For **YAML-managed Serving**, merge the value into the authoritative `config-network` manifest through your existing workflow; do not directly edit an Operator-managed ConfigMap. Preserve unrelated values in either route.

=== "ConfigMap configuration"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
     name: config-network
     namespace: knative-serving
    data:
      rollout-duration: "380"  # Value in seconds.
    ```

=== "Operator configuration"
    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        network:
           rollout-duration: "380"
    ```

{% include "route-status-updates.md" %}

{% include "multiple-rollouts.md" %}
