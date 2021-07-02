---
title: "Configuring Activator capacity"
linkTitle: "Configuring Activator capacity"
weight: 50
type: "docs"
---

# Configuring Activator capacity

If there's more than one Activator in the system, Knative will put as many of them on the request path as it thinks is necessary to handle the current request load plus the target burst capacity. If the target burst capacity is 0, Knative only puts the Activator into the request path if the Revision is scaled to zero.

If available, Knative will pick at least two Activators for high availability reasons. The actual number of Activators is calculated via a given _Activator capacity_ using the formula: `(replicas * target + targetBurstCapacity)/activatorCapacity`. That means, there are enough Activators in the routing path to handle the theoretical capacity of the existing application, including any additional target burst capacity.

## Setting the Activator capacity

- **Global key:** `activator-capacity`
- **Possible values:** int (at least 1)
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
    apiVersion: operator.knative.dev/v1alpha1
    kind: KnativeServing
    metadata:
      name: knative-serving
    spec:
      config:
        autoscaler:
          activator-capacity: "200"
    ```
