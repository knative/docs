# Configure Sugar Controller

This topic describes how to configure the Sugar Controller. You can configure the Sugar controller to create a Broker when a Namespace or Trigger is created with configured labels. See [Knative Eventing Sugar Controller](../sugar/README.md) for an example.


The default `config-sugar` ConfigMap disables Sugar Controller.

To enable the Sugar Controller

* for Namespaces, the LabelSelector `namespace-selector` can be configured.
* for Triggers, the LabelSelector `trigger-selector` can be configured.


Sample configuration to enable Sugar Controller on selected Namespaces and Triggers

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
    name: config-sugar
    namespace: knative-eventing
    labels:
        eventing.knative.dev/release: devel
    data:
      # Use an empty object to enable for selected namespaces
      namespace-selector: |
        matchExpressions:
        - key: "eventing.knative.dev/injection"
          operator: "In"
          values: ["enabled"]

      # Use an empty object to enable for selected triggers
      trigger-selector: |
        matchExpressions:
        - key: "eventing.knative.dev/injection"
          operator: "In"
          values: ["enabled"]
    ```

The Sugar Controller will only operate on Namespaces or Triggers with the label `eventing.knative.dev/injection: enabled`. This also emulates the legacy Sugar Controller behavior for Namespaces.


You can edit this ConfigMap by running the command:

```
kubectl edit cm config-sugar -n knative-eventing
```
