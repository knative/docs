---
title: "ConfigMaps"
weight: 05
type: "docs"
showlandingtoc: "false"
aliases:
  - /docs/eventing/broker/config-br-defaults
---

# ConfigMaps

Knative Eventing provides a `config-br-defaults` ConfigMap that contains the configuration settings that govern default broker creation.
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

## Channel implementation options

The following example shows a Broker object where the `spec.config` configuration is specified in a `config-br-default-channel` ConfigMap:

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

A Broker object that does not have a `spec.config` specified uses the `config-br-default-channel` ConfigMap dy default because this is specified in the `config-br-defaults` ConfigMap.

However, if you have installed a different channel implementation, for example, Kafka, and would like this to be used as the default channel implementation for any broker that is created, you can change the `config-br-defaults` ConfigMap to look like this:

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
      name: kafka-channel
      namespace: knative-eventing
```

Now every broker created in the cluster that does not have a `spec.config` will be configured to use the `kafka-channel` ConfigMap.

For more information about creating a `kafka-channel` ConfigMap to use with your broker, see the [Kafka Channel ConfigMap](../kafka-broker/kafka-configmap/) documentation.

### Changing the default channel implementation for a namespace

You can modify the default broker creation behavior for one or more namespaces.

For example, if you wanted to use the `kafka-channel` ConfigMap for all other brokers created, but wanted to use `config-br-default-channel` ConfigMap for `namespace-1` and `namespace-2`, you would use the following ConfigMap settings:

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
      namespace-1:
        apiVersion: v1
        kind: ConfigMap
        name: config-br-default-channel
        namespace: knative-eventing
      namespace-2:
        apiVersion: v1
        kind: ConfigMap
        name: config-br-default-channel
        namespace: knative-eventing
```

## Broker class options

When a broker is created without a specified `BrokerClass` annotation, the default `MTChannelBasedBroker` broker class is used, as specified in the `config-br-defaults` ConfigMap.

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

### Configuring the broker class

To configure a broker class, you can modify the
`eventing.knative.dev/broker.class` annotation and `spec.config` for the Broker
object. `MTChannelBasedBroker` is the broker class default.

1. Modify the `eventing.knative.dev/broker.class` annotation. Replace
`MTChannelBasedBroker` with the class type you want to use:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Broker
    metadata:
      annotations:
        eventing.knative.dev/broker.class: MTChannelBasedBroker
      name: default
      namespace: default
    ```

1. Configure the `spec.config` with the details of the ConfigMap that defines
the backing channel for the broker class:

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

### Configuring the default BrokerClass for the cluster
​
You can configure the `clusterDefault` broker class so that any broker created in the cluster that does not have a `BrokerClass` annotation uses this default class.

#### Example

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
```
​
### Configuring the default BrokerClass for namespaces
​
You can modify the default broker class for one or more namespaces.

For example, if you want to use a `KafkaBroker` class for all other brokers created on the cluster, but you want to use the `MTChannelBasedBroker` class for brokers created in `namespace-1` and `namespace-2`, you would use the following ConfigMap settings:
​
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
      brokerClass: KafkaBroker
    namespaceDefaults:
      namespace1:
        brokerClass: MTChannelBasedBroker
      namespace2:
        brokerClass: MTChannelBasedBroker
```
