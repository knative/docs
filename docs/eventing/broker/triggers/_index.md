---
title: "Triggers"
weight: 02
type: "docs"
showlandingtoc: "false"
aliases:
  - docs/eventing/triggers
---

A trigger represents a desire to subscribe to events from a specific broker.

The `subscriber` value must be a [Destination](https://pkg.go.dev/knative.dev/pkg/apis/duck/v1#Destination).

Simple example which will receive all the events from the given (`default`) broker and
deliver them to Knative Serving service `my-service`:

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
EOF
```

Simple example which will receive all the events from the given (`default`) broker and
deliver them to the custom path `/my-custom-path` for the Kubernetes service `my-service`:

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: my-service
    uri: /my-custom-path
EOF
```

### Trigger filtering

Exact match filtering on any number of CloudEvents attributes as well as
extensions are supported. If your filter sets multiple attributes, an event must
have all of the attributes for the trigger to filter it. Note that we only
support exact matching on string values.

#### Example

This example filters events from the `default` broker that are of type
`dev.knative.foo.bar` and have the extension `myextension` with the value
`my-extension-value`.

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  filter:
    attributes:
      type: dev.knative.foo.bar
      myextension: my-extension-value
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
EOF
```
