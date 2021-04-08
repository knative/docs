---
title: "Configuring broker defaults"
weight: 60
type: "docs"
showlandingtoc: "false"
aliases:
  - /docs/eventing/broker/config-br-defaults
---

Knative Eventing provides a `config-br-defaults` ConfigMap that contains the configuration settings that enable broker creation.
<!--TODO: Create a version of this doc for the channels doc section-->
The default `config-br-defaults` ConfigMap is as follows:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
data:
  # Configuration for defaulting channels that do not specify CRD implementations.
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: config-br-default-channel
      namespace: knative-eventing
```

When a broker is created without a specified `BrokerClass` annotation, the default `MTChannelBasedBroker` broker class is used, as specified in this ConfigMap.

The following example creates a broker called `default` in the default namespace, and uses `MTChannelBasedBroker` as the implementation:

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: default
  namespace: default
EOF
```

## Changing the default broker class for a cluster
## Changing the default broker class for a namespace




The following example shows a broker where the configuration is specified in a ConfigMap `config-br-default-channel`:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
  name: default
spec:
  # Configuration specific to this broker.
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
```
<!--This is confusing, we don't really explain much about this other ConfigMap vs the one mentioned above-->

## Changing the default configuration of the Broker

### Changing the default configuration for the cluster

You can also control Broker configuration defaulting behaviour by specifying
what gets defaulted into a broker.spec.config if left empty when being created.

If you have installed a different Channel implementation (for example Kafka),
and by default would like to use that for any Broker created you could change
the ConfigMap to look like this:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
data:
  # Configuration for defaulting channels that do not specify CRD implementations.
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: config-kafka-channel
      namespace: knative-eventing
```

Now every Broker created in the cluster without spec.config will be configured
to use `config-kafka-channel` `ConfigMap`. Note that you can always still
explicitly specify a different configuration for any given Broker by specifying
it in the `spec.config`.


### Changing the default configuration for namespaces

As mentioned, you can also control the defaulting behaviour for some set of
namespaces. So, if for example, you wanted to use `config-kafka-channel` for all
the other Brokers created, but wanted to use `config-br-default-channel` config
the following namespaces: `namespace3` and `namespace4`. You would modify the
`ConfigMap` like this:


```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
data:
  # Configuration for defaulting channels that do not specify CRD implementations.
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: config-kafka-channel
      namespace: knative-eventing
    namespaceDefaults:
      namespace3:
        apiVersion: v1
        kind: ConfigMap
        name: config-br-default-channel
        namespace: knative-eventing
      namespace4:
        apiVersion: v1
        kind: ConfigMap
        name: config-br-default-channel
        namespace: knative-eventing
```

Note that we do not override the brokerClass for these namespaces. The
brokerClass and config are independently configurable.
