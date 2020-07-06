---
title: "defaults-br-config"
weight: 30
type: "docs"
---

Knative provides a `ConfigMap` which makes it easier to create Brokers by
providing default values when Brokers are created. You can control which Broker
implementations are used and how they are configured by modifying this file. You
have the flexibility to control the defaults both at the cluster level (each
Broker created in the cluster) as well as at the namespace level (override the
behaviour for certain namespaces).

## Format of the file

Let's look at the `ConfigMap` that comes out of the box when you install a
release (v0.16.0 in this example):

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

This means that any Broker created without a specific BrokerClass annotation or
`spec.config` will use a `MTChannelBasedBroker` implementation and the Broker
will have spec.config like so:

```
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
```

## Changing the default BrokerClass

### Changing the default BrokerClass for the cluster

If you have installed a different Broker, or multiple, you can change the
default Broker used at the cluster level and by namespace. If you for example
have installed MT Channel Based Broker as well as `YourBroker` and would prefer
that by default any Broker created uses `YourBroker` you could modify the
configmap to look like this:

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
      brokerClass: YourBroker
```

Now every Broker created in the cluster without the BrokerClass annotation will
be using `YourBroker` as the Broker implementation. Note that you can always use
a different implementation by explicity specifying the BrokerClass annotation
when you create a Broker.

### Changing the default BrokerClass for namespaces

As mentioned, you can also control the defaulting behaviour for some set of
namespaces. So, if for example, you wanted to use YourBroker for all the other
Brokers created, but wanted to use MTChannelBasedBroker for the following
namespaces: namespace1 and namespace2. You would modify the config map like
this:

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
      brokerClass: YourBroker
    namespaceDefaults:
      namespace1:
        brokerClass: MTChannelBasedBroker
      namespace2:
        brokerClass: MTChannelBasedBroker
```


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
to use `config-kafka-channel` ConfigMap. Note that you can always still
explicitly specify a different configuration for any given Broker by specifying
it in the `spec.config`.


### Changing the default configuration for namespaces

As mentioned, you can also control the defaulting behaviour for some set of
namespaces. So, if for example, you wanted to use config-kafka-channel for all
the other Brokers created, but wanted to use config-br-default-channel config the
following namespaces: namespace3 and namespace4. You would modify the config map like
this:


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
