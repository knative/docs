# Knative Eventing Sugar Controller

Knative Eventing Sugar Controller will react to configured labels
to produce or control eventing resources in a cluster or namespace. This allows
cluster operators and developers to focus on creating fewer resources, and the
underlying eventing infrastructure is created on-demand, and cleaned up when no
longer needed.

## Installing

The Sugar Controller is `disabled` by default and can be enabled by configuring `config-sugar` ConfigMap.
See below for a simple example and [Configure Sugar Controller](../configuration/sugar-configuration.md) for more details.

## Automatic Broker Creation

One way to create a Broker is to manually apply a resource to a cluster using
the default settings:

1. Copy the following YAML into a file:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
      name: default
      namespace: default
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

There might be cases where automated Broker creation is desirable, such as on
namespace creation, or on Trigger creation. The Sugar controller enables those
use-cases. The following sample configuration of the `sugar-config` ConfigMap
enables Sugar Controller for select Namespaces & all Triggers.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: config-sugar
namespace: knative-eventing
labels:
    eventing.knative.dev/release: devel
data:
  # Specify a label selector to selectively apply sugaring to certain namespaces
  namespace-selector: |
    matchExpressions:
    - key: "my.custom.injection.key"
      operator: "In"
      values: ["enabled"]
  # Use an empty object to enable for all triggers
  trigger-selector: |
    {}
```

- When a Namespace is created with label `my.custom.injection.key: enabled` , the Sugar controller will create a Broker named "default" in that
  namespace.
- When a Trigger is created, the Sugar controller will create a Broker named "default" in the
  Trigger's namespace.

When a Broker is deleted and but the referenced label selectors are in use, the
Sugar Controller will automatically recreate a default Broker.

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

Create a "default" Broker in the Trigger's Namespace when creating a Trigger:

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

This will make a Broker called "default" in the Namespace "hello", and attempt to send events to the "event-display" service.

If the Broker named "default" already exists in the Namespace, the Sugar Controller will do nothing and the Trigger will not own the existing Broker.
