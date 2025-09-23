# Configure Sugar Controller

This topic describes how to configure the Sugar Controller. You can configure the Sugar controller to create a Broker when a Namespace or Trigger is created with configured labels. See [Knative Eventing Sugar Controller](../sugar/README.md) for an example.


The default `config-sugar` ConfigMap disables Sugar Controller, by setting `namespace-selector` and `trigger-selector` to an empty string.

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
  namespace-selector: |
    matchExpressions:
    - key: "eventing.knative.dev/injection"
      operator: "In"
      values: ["enabled"]

  trigger-selector: |
    matchExpressions:
    - key: "eventing.knative.dev/injection"
      operator: "In"
      values: ["enabled"]
```

The Sugar Controller will only operate on Namespaces or Triggers with the label `eventing.knative.dev/injection: enabled`. This also emulates the legacy Sugar Controller behavior for Namespaces.


You can edit this ConfigMap by running the command:

```bash
kubectl edit cm config-sugar -n knative-eventing
```
