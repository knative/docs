# Configuring Broker Defaults

## Overview

Knative Eventing allows you to configure default Broker classes at both the cluster and namespace levels. This feature provides flexibility in managing Broker configurations across your Knative installation. This document explains how to set up and use default Broker classes using the `config-br-defaults` ConfigMap.

## The `config-br-defaults` ConfigMap

The `config-br-defaults` ConfigMap in the `knative-eventing` namespace contains the configuration settings that govern default Broker creation. Here's an example of its structure:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: config-br-default-channel
      namespace: knative-eventing
      brokerClasses:
        MTChannelBasedBroker:
          # Configuration for MTChannelBasedBroker
        KafkaBroker:
          # Configuration for KafkaBroker
    namespaceDefaults:
      namespace-1:
        brokerClass: KafkaBroker
        brokerClasses:
          KafkaBroker:
            # Configuration for KafkaBroker in namespace-1
      namespace-2:
        brokerClass: MTChannelBasedBroker
        brokerClasses:
          MTChannelBasedBroker:
            # Configuration for MTChannelBasedBroker in namespace-2
```



## Configuration Decision Flow

The following flow chart illustrates the decision-making process for determining the broker class and configuration:

![Configuration Decision Flow](images/default-hierarchy-flowchart.png)

This flow chart demonstrates the priority and fallback mechanisms in place when determining the broker class and configuration. It visually represents the process described in the Configuration Hierarchy section.


## Configuration Hierarchy

The system uses the following priority order to determine the Broker class and configuration:

If a specific Broker class **is provided** for a Broker:

   1. Check namespace-specific configuration for the given Broker class
   2. If not found, check cluster-wide configuration for the given Broker class
   3. If still not found, use the cluster-wide default configuration

---
If **no specific Broker class** is provided:

   1. Check namespace-specific default Broker class
   2. If found, use its configuration
   3. If not found, use cluster-wide default Broker class and configuration

## Configuring Cluster-wide Defaults

To set a cluster-wide default Broker class and its configuration:

```yaml
clusterDefault:
  brokerClass: MTChannelBasedBroker
  brokerClasses:
    MTChannelBasedBroker:
      apiVersion: v1
      kind: ConfigMap
      name: config-br-default-channel
      namespace: knative-eventing
```

This configuration sets `MTChannelBasedBroker` as the default Broker class for the entire cluster and specifies its configuration.

!!! note
    Be aware that different Broker classes usually require different configuration ConfigMaps. See the configuration options of the different [Broker implementations](../brokers/broker-types/README.md) on how their referenced ConfigMaps have to look like (e.g. for [MTChannelBasedBroker](../brokers/broker-types/channel-based-broker/README.md#configuration-configmap) or [Knative Broker for Apache Kafka](../brokers/broker-types/kafka-broker/README.md#configure-a-kafka-broker)).

## Configuring Namespace-specific Defaults

To set default Broker classes and configurations for specific namespaces:

```yaml
namespaceDefaults:
  namespace-1:
    brokerClass: KafkaBroker
    brokerClasses:
      KafkaBroker:
        apiVersion: v1
        kind: ConfigMap
        name: kafka-broker-config
        namespace: knative-eventing
  namespace-2:
    brokerClass: MTChannelBasedBroker
    brokerClasses:
      MTChannelBasedBroker:
        apiVersion: v1
        kind: ConfigMap
        name: mt-channel-broker-config
        namespace: knative-eventing
```

This configuration sets different default Broker classes and configurations for `namespace-1` and `namespace-2`.


## Configuring delivery spec defaults

You can configure default event delivery parameters for Brokers that are applied in cases where an event fails to be delivered:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
data:
  # Configures the default for any Broker that does not specify a spec.config or Broker class.
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      brokerClasses:
        MTChannelBasedBroker:
          apiVersion: v1
          kind: ConfigMap
          name: kafka-channel
          namespace: knative-eventing
          delivery:
            retry: 10
            backoffDelay: PT0.2S
            backoffPolicy: exponential
    namespaceDefaults:
      namespace-1:
        brokerClass: MTChannelBasedBroker
        brokerClasses:
          MTChannelBasedBroker:
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

   Where `<broker-ingress-pod-name>` is the name of your Broker ingress pod.

   The pod now has two containers:

    ```{ .bash .no-copy }
    knative-eventing     <broker-ingress-pod-name>           2/2     Running   1              175m
    ```

1. Create a broker, then use get the URL of your Broker by running the command:

    ```bash
    kubectl get broker <broker-name>
    ```

   Where `<broker-name>` is the name of your Broker.

   Example output:

    ```{ .bash .no-copy }
    NAMESPACE   NAME        URL                                                                          AGE   READY   REASON
    default     my-broker   http://broker-ingress.knative-eventing.svc.cluster.local/default/my-broker   6s    True
    ```

1. Start a `curl` pod by running the following command:

    ```bash
    kubectl -n default run curl --image=radial/busyboxplus:curl -i --tty
    ```

1. Send a CloudEvent with an HTTP POST against the Broker URL by running the following command:

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

   Where `<broker-URL>` is the URL of your Broker. For example:

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


## Best Practices and Considerations

1. **Consistency**: Ensure that the `brokerClass` specified matches a key in the `brokerClasses` map to maintain consistency.

2. **Namespace Isolation**: Use namespace-specific defaults to isolate Broker configurations between different namespaces.

3. **Fallback Mechanism**: The system will fall back to cluster-wide defaults if namespace-specific configurations are not found.

4. **Configuration Updates**: When updating the ConfigMap, be aware that changes may affect newly created Brokers but will not automatically update existing ones.

5. **Validation**: Always validate your ConfigMap changes before applying them to avoid potential misconfigurations.

## Conclusion

The default Broker classes feature in Knative Eventing offers a flexible way to manage Broker configurations across your cluster and individual namespaces. By properly configuring the `config-br-defaults` ConfigMap, you can ensure that your Brokers are created with the desired settings, promoting consistency and reducing manual configuration efforts.