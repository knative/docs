---
audience: developer
components:
  - eventing
function: how-to
---

<span id="what-is-a-sugar-controller"></span>

# Knative Eventing Sugar Controller

Knative Eventing Sugar Controller will react to configured labels
to produce or control eventing resources in a cluster or namespace. This allows
cluster operators and developers to focus on creating fewer resources, and the
underlying eventing infrastructure is created on-demand, and cleaned up when no
longer needed.

## Prerequisites { #installing }

The Sugar Controller is `disabled` by default. A cluster administrator must enable it by configuring the `config-sugar` ConfigMap in `knative-eventing`. See [Configure Sugar Controller](../configuration/sugar-configuration.md) for administrator setup.

Example `config-sugar` ConfigMap enabling automatic Broker creation for labeled namespaces and all Triggers:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-sugar
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
data:
  # Selectively apply sugaring to namespaces matching this selector
  namespace-selector: |
    matchExpressions:
    - key: "my.custom.injection.key"
      operator: "In"
      values: ["enabled"]
  # Use an empty object to enable for all Triggers
  trigger-selector: |
    {}
```

## Automatic Broker creation { #automatic-broker-creation }

Once a cluster administrator has enabled the Sugar Controller with the selectors above:

- Labeling a Namespace with `my.custom.injection.key: enabled` creates a Broker named `default` in that namespace.
- Creating a Trigger referencing `default` creates a Broker named `default` in the Trigger's namespace.

If the `default` Broker is deleted while the matching selector still applies, the Sugar Controller recreates it. If a `default` Broker already exists, the Sugar Controller leaves it untouched and does not take ownership of it.

### Namespace Examples

Creating a "default" Broker when creating a Namespace:

1. Copy the following YAML into a file:

    ```yaml
    apiVersion: v1
    kind: Namespace
    metadata:
      name: example
      labels:
        my.custom.injection.key: enabled
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

To automatically create a Broker after a namespace exists, label the Namespace:

```bash
kubectl label namespace default my.custom.injection.key=enabled
```

If the Broker named "default" already exists in the Namespace, the Sugar
Controller will do nothing.

### Trigger Example

Assuming the `hello` namespace and an `event-display` Service already exist, create a Trigger to automatically provision a `default` Broker in `hello`:

```bash
kubectl apply -f - << EOF
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: hello-sugar
  namespace: hello
spec:
  broker: default
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: event-display
EOF
```

Verify that both the automatically created `default` Broker and the Trigger report `READY=True`:

```bash
kubectl get broker,trigger -n hello
```

If the Broker named "default" already exists in the Namespace, the Sugar Controller will do nothing and the Trigger will not own the existing Broker.
