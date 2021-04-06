---
title: "Broker classes"
weight: 02
type: "docs"
showlandingtoc: "false"
---

To configure a default broker type, or _class_, you must modify the
`eventing.knative.dev/broker.class` annotation and `spec.config` for the Broker
object. `MTChannelBasedBroker` is the broker class default.

### Procedure

1. Modify the `eventing.knative.dev/broker.class` annotation. Replace
`MTChannelBasedBroker` with the class type you want to use:

```yaml
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
```

1. Configure the `spec.config` with the details of the ConfigMap that defines
the backing channel for the broker class:

```yaml
kind: Broker
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
```

A full example combined into a fully specified resource could look like this:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
  name: default
  namespace: default
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
```
