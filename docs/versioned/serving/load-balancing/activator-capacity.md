---
audience: administrator
components:
  - serving
function: how-to
---

# Configuring Activator capacity

If there is more than one Activator in the system, Knative puts as many Activators on the request path as required to handle the current request load plus the target burst capacity. If the target burst capacity is 0, Knative only puts the Activator into the request path if the Revision is scaled to zero.

Knative uses at least two Activators to enable high availability if possible. The actual number of Activators is calculated taking the _Activator capacity_ into account, by using the formula `(replicas * target + target-burst-capacity)/activator-capacity`. This means that there are enough Activators in the routing path to handle the theoretical capacity of the existing application, including any additional target burst capacity.

## Setting the Activator capacity

- **Global key:** `activator-capacity`
- **Possible values:** Number at least `1`; [v1.24 autoscaler configuration](https://github.com/knative/serving/blob/knative-v1.24.0/pkg/autoscaler/config/config.go){target=_blank} parses this key as a floating-point value.
- **Default:** `100`

**Example:**

=== "Global (ConfigMap)"
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: config-autoscaler
      namespace: knative-serving
    data:
      activator-capacity: "200"
    ```

=== "Global (Operator)"
    ```yaml
    apiVersion: operator.knative.dev/v1beta1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          activator-capacity: "200"
    ```
