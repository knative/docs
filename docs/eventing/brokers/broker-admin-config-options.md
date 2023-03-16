# Administrator configuration options

If you have cluster administrator permissions for your Knative installation, you can modify ConfigMaps to change the global default configuration options for Brokers on the cluster.

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
  # Configures the default for any Broker that does not specify a spec.config or Broker class.
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

A Broker object that does not have a `spec.config` specified uses the `config-br-default-channel` ConfigMap by default because this is specified in the `config-br-defaults` ConfigMap.

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
  # Configures the default for any Broker that does not specify a spec.config or Broker class.
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
[Kafka Channel ConfigMap](../configuration/kafka-channel-configuration.md#create-a-kafka-channel-configmap) documentation.

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
  # Configures the default for any Broker that does not specify a spec.config or Broker class.
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

## Configuring delivery spec defaults

You can configure default event delivery parameters for Brokers that are applied in cases where an event fails to be delivered:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
data:
  # Configures the default for any Broker that does not specify a spec.config or Broker class.
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: config-kafka-channel
      namespace: knative-eventing
      delivery:
        retry: 10
        backoffDelay: PT0.2S
        backoffPolicy: exponential
    namespaceDefaults:
      namespace-1:
        apiVersion: v1
        kind: ConfigMap
        name: config-br-default-channel
        namespace: knative-eventing
        delivery:
          deadLetterSink:
            ref:
              kind: Service
              namespace: example-namespace
              name: example-service
              apiVersion: v1
            uri: example-uri
          retry: 10
          backoffPolicy: exponential
          backoffDelay: "PT0.2S"
```

### Dead letter sink

You can configure the `deadLetterSink` delivery parameter so that if an event fails to be delivered it is sent to the specified event sink.

### Retries

You can set a minimum number of times that the delivery must be retried before the event is sent to the dead letter sink, by configuring the `retry` delivery parameter with an integer value.

### Back off delay

You can set the `backoffDelay` delivery parameter to specify the time delay before an event delivery retry is attempted after a failure. The duration of the `backoffDelay` parameter is specified using the ISO 8601 format.

### Back off policy

The `backoffPolicy` delivery parameter can be used to specify the retry back off policy. The policy can be specified as either linear or exponential. When using the linear back off policy, the back off delay is the time interval specified between retries. When using the exponential backoff policy, the back off delay is equal to `backoffDelay*2^<numberOfRetries>`.

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
  # Configures the default for any Broker that does not specify a spec.config or Broker class.
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
```

### Configuring the default BrokerClass for namespaces

You can modify the default Broker class for one or more namespaces.

For example, if you want to use a `KafkaBroker` class for all other Brokers created on the cluster, but you want to use the `MTChannelBasedBroker` class for Brokers created in `namespace-1` and `namespace-2`, you would use the following ConfigMap settings:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
data:
  # Configures the default for any Broker that does not specify a spec.config or Broker class.
  default-br-config: |
    clusterDefault:
      brokerClass: KafkaBroker
    namespaceDefaults:
      namespace1:
        brokerClass: MTChannelBasedBroker
      namespace2:
        brokerClass: MTChannelBasedBroker
```

## Integrating Istio with Knative Brokers

### Protect a Knative Broker by using JSON Web Token (JWT) and Istio

#### Prerequisites

- You have installed Knative Eventing.
- You have installed Istio.

#### Procedure

1. Label the `knative-eventing` namespace, so that Istio can handle JWT-based user authentication, by running the command:

    ```bash
    kubectl label namespace knative-eventing istio-injection=enabled
    ```

1. Restart the broker ingress pod, so that the `istio-proxy` container can be injected as a sidecar, by running the command:

    ```bash
    kubectl delete pod <broker-ingress-pod-name> -n knative-eventing
    ```

    Where `<broker-ingress-pod-name>` is the name of your broker ingress pod.

    The pod now has two containers:

    ```{ .bash .no-copy }
    knative-eventing     <broker-ingress-pod-name>           2/2     Running   1              175m
    ```

1. Create a broker, then use get the URL of your broker by running the command:

    ```bash
    kubectl get broker <broker-name>
    ```

    Example output:

    ```{ .bash .no-copy }
    NAMESPACE   NAME        URL                                                                          AGE   READY   REASON
    default     my-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/my-broker   6s    True
    ```

1. Start a `curl` pod:

    ```bash
    kubectl -n default run curl --image=radial/busyboxplus:curl -i --tty
    ```

1. Send a CloudEvent with an HTTP POST against the broker URL:

    ```bash
    curl -X POST -v \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: my/curl/command"  \
    -H "ce-type: my.demo.event"  \
    -H "ce-id: 0815"  \
    -d '{"value":"Hello Knative"}' \
    <broker-URL>
    ```

    Where `<broker-URL>` is the URL of your broker. For example:

    ```{ .bash .no-copy }
    curl -X POST -v \
    -H "content-type: application/json"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: my/curl/command"  \
    -H "ce-type: my.demo.event"  \
    -H "ce-id: 0815"  \
    -d '{"value":"Hello Knative"}' \
    http://broker-ingress.knative-eventing.svc.cluster.local/default/my-broker
    ```

1. You will receive a `202` HTTP response code, that the broker did accept the request:

    ```{ .bash .no-copy }
    ...
    * Mark bundle as not supporting multiuse
    < HTTP/1.1 202 Accepted
    < allow: POST, OPTIONS
    < date: Tue, 15 Mar 2022 13:37:57 GMT
    < content-length: 0
    < x-envoy-upstream-service-time: 79
    < server: istio-envoy
    < x-envoy-decorator-operation: broker-ingress.knative-eventing.svc.cluster.local:80/*
    ```

1. Apply a `AuthorizationPolicy` object in the `knative-eventing` namespace to describe that the path to the Broker is restricted to a given user:

    ```yaml
    apiVersion: security.istio.io/v1beta1
    kind: AuthorizationPolicy
    metadata:
      name: require-jwt
      namespace: knative-eventing
    spec:
      action: ALLOW
      rules:
      - from:
        - source:
           requestPrincipals: ["testing@secure.istio.io/testing@secure.istio.io"]
        to:
        - operation:
            methods: ["POST"]
            paths: ["/default/my-broker"]
    ```

1. Create a `RequestAuthentication` object for the user `requestPrincipal` in the `istio-system` namespace:

    ```yaml
    apiVersion: security.istio.io/v1beta1
    kind: RequestAuthentication
    metadata:
      name: "jwt-example"
      namespace: istio-system
    spec:
      jwtRules:
      - issuer: "testing@secure.istio.io"
        jwksUri: "https://raw.githubusercontent.com/istio/istio/release-1.13/security/tools/jwt/samples/jwks.json"
    ```

1. Now retrying the `curl` command results in a `403 - Forbidden` response code from the server:

    ```{ .bash .no-copy }
    ...
    * Mark bundle as not supporting multiuse
    < HTTP/1.1 403 Forbidden
    < content-length: 19
    < content-type: text/plain
    < date: Tue, 15 Mar 2022 13:47:53 GMT
    < server: istio-envoy
    < connection: close
    < x-envoy-decorator-operation: broker-ingress.knative-eventing.svc.cluster.local:80/*
    ```

1. To access the Broker, add the Bearer JSON Web Token as part of the request:

    ```bash
    TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.13/security/tools/jwt/samples/demo.jwt -s)

    curl -X POST -v \
    -H "content-type: application/json"  \
    -H "Authorization: Bearer ${TOKEN}"  \
    -H "ce-specversion: 1.0"  \
    -H "ce-source: my/curl/command"  \
    -H "ce-type: my.demo.event"  \
    -H "ce-id: 0815"  \
    -d '{"value":"Hello Knative"}' \
    <broker-URL>
    ```

    The server now responds with a `202` response code, indicating that it has accepted the HTTP request:

    ```{ .bash .no-copy }
    * Mark bundle as not supporting multiuse
    < HTTP/1.1 202 Accepted
    < allow: POST, OPTIONS
    < date: Tue, 15 Mar 2022 14:05:09 GMT
    < content-length: 0
    < x-envoy-upstream-service-time: 40
    < server: istio-envoy
    < x-envoy-decorator-operation: broker-ingress.knative-eventing.svc.cluster.local:80/*
    ```
