---
title: "Triggers"
weight: 70
type: "docs"
---

# Triggers

A Trigger represents a desire to subscribe to events from a specific Broker.

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

### Trigger Filtering

Exact match filtering on any number of CloudEvents attributes as well as
extensions are supported. If your filter sets multiple attributes, an event must
have all of the attributes for the Trigger to filter it. Note that we only
support exact matching on string values.

Example:

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

The example above filters events from the `default` Broker that are of type
`dev.knative.foo.bar` AND have the extension `myextension` with the value
`my-extension-value`.
