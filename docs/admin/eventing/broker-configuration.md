# Configure Broker defaults

Knative Eventing provides a `config-br-defaults` ConfigMap that contains the configuration settings that govern default Broker creation.

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
  # Configuration for defaulting Channels that do not specify CRD implementations.
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

However, if you have installed a different Channel implementation, for example, Kafka, and would like this to be used as the default Channel implementation for any Broker that is created, you can change the `config-br-defaults` ConfigMap to look as follows:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
data:
  # Configuration for defaulting Channels that do not specify CRD implementations.
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: kafka-channel
      namespace: knative-eventing
```

Now every Broker created in the cluster that does not have a `spec.config` will be configured to use the `kafka-channel` ConfigMap.

For more information about creating a `kafka-channel` ConfigMap to use with your Broker, see the
[Kafka Channel ConfigMap](kafka-channel-configuration.md#create-a-kafka-channel-configmap) documentation.

### Changing the default Channel implementation for a namespace

You can modify the default Broker creation behavior for one or more namespaces.

For example, if you wanted to use the `kafka-channel` ConfigMap for all other Brokers created, but wanted to use `config-br-default-channel` ConfigMap for `namespace-1` and `namespace-2`, you would use the following ConfigMap settings:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
data:
  # Configuration for defaulting Channels that do not specify CRD implementations.
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

When a Broker is created without a specified `BrokerClass` annotation, the default `MTChannelBasedBroker` Broker class is used, as specified in the `config-br-defaults` ConfigMap.

The following example creates a Broker called `default` in the default namespace, and uses `MTChannelBasedBroker` as the implementation:

1. Create a YAML file for your Broker using the following example:

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


### Configuring the Broker class

To configure a Broker class, you can modify the
`eventing.knative.dev/broker.class` annotation and `spec.config` for the Broker
object. `MTChannelBasedBroker` is the Broker class default.

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
the backing Channel for the Broker class:

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
You can configure the `clusterDefault` Broker class so that any Broker created in the cluster that does not have a `BrokerClass` annotation uses this default class.

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
  # Configuration for defaulting Channels that do not specify CRD implementations.
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
```
​
### Configuring the default BrokerClass for namespaces
​
You can modify the default Broker class for one or more namespaces.

For example, if you want to use a `KafkaBroker` class for all other Brokers created on the cluster, but you want to use the `MTChannelBasedBroker` class for Brokers created in `namespace-1` and `namespace-2`, you would use the following ConfigMap settings:
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
  # Configuration for defaulting Channels that do not specify CRD implementations.
  default-br-config: |
    clusterDefault:
      brokerClass: KafkaBroker
    namespaceDefaults:
      namespace1:
        brokerClass: MTChannelBasedBroker
      namespace2:
        brokerClass: MTChannelBasedBroker
```
