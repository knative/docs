---
title: "Knative Eventing Sugar Controller"
linkTitle: "Sugar Controller"
weight: 40
type: "docs"
showlandingtoc: "true"
---

# Knative Eventing Sugar Controller

Knative Eventing Sugar Controller will react to special labels and annotations
to produce or control eventing resources in a cluster or namespace. This allows
cluster operators and developers to focus on creating fewer resources, and the
underlying eventing infrastructure is created on-demand, and cleaned up when no
longer needed.

## Installing

The following command installs the Eventing Sugar Controller:

```bash
kubectl apply --filename {{ artifact( repo="eventing", file="eventing-sugar-controller.yaml") }}
```

## Automatic Broker Creation

One way to create a Broker is to manually apply a resource to a cluster using
the default settings:

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: default
  namespace: default
EOF
```

There might be cases where automated Broker creation is desirable, such as on
namespace creation, or on Trigger creation. The Sugar controller enables those
use-cases:

- When a Namespace is labeled with `eventing.knative.dev/injection=enabled`, the
  sugar controller will create a default Broker named "default" in that
  namespace.
- When a Trigger is annotated with `eventing.knative.dev/injection=enabled`, the
  controller will create a Broker named by that Trigger in the Trigger's
  Namespace.

When a Broker is deleted and the above labels or annotations are in-use, the
Sugar Controller will automatically recreate a default Broker.

### Namespace Examples

Creating a "default" Broker when creating a Namespace:

```shell
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: example
  labels:
    eventing.knative.dev/injection: enabled
EOF
```

To automatically create a Broker after a namespace exists, label the Namespace:

```shell
kubectl label namespace default eventing.knative.dev/injection=enabled
```

If the Broker named "default" already exists in the Namespace, the Sugar
Controller will do nothing.

### Trigger Examples

Create a Broker named by a Trigger (`spec.broker`) in the Trigger's Namespace:

```shell
kubectl apply -f - << EOF
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: hello-sugar
  namespace: hello
  annotations:
    eventing.knative.dev/injection: enabled
spec:
  broker: sugar
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: event-display
EOF
```

> _Note_: If the named Broker already exists, the Sugar controller will do
> nothing, and the Trigger will not own the existing Broker.

This will make a Broker called "sugar" in the Namespace "hello", and attempt to
send events to the "event-display" service.

If the Broker of the given name already exists in the Namespace, the Sugar
Controller will do nothing.
