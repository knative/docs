---
title: "Apache Kafka Channel Example"
linkTitle: "Channel Example"
weight: 20
type: "docs"
---

# Apache Kafka Channel Example

You can install and configure the Apache Kafka CRD (`KafkaChannel`) as the
default channel configuration in Knative Eventing.

## Prerequisites

- Ensure that you meet the
  [prerequisites listed in the Apache Kafka overview](../README.md).
- A Kubernetes cluster with
  [Knative Kafka Channel installed](../../../../install/README.md).

## Creating a `KafkaChannel` channel CRD

Create a new object by configuring the YAML file as follows:

```
cat <<-EOF | kubectl apply -f -
---
apiVersion: messaging.knative.dev/v1beta1
kind: KafkaChannel
metadata:
  name: my-kafka-channel
spec:
  numPartitions: 3
  replicationFactor: 1
EOF
```

## Specifying the default channel configuration

To configure the usage of the `KafkaChannel` CRD as the
[default channel configuration](../../../channels/default-channels.md), edit the
`default-ch-webhook` ConfigMap as follows:

```
cat <<-EOF | kubectl apply -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: default-ch-webhook
  namespace: knative-eventing
data:
  # Configuration for defaulting channels that do not specify CRD implementations.
  default-ch-config: |
    clusterDefault:
      apiVersion: messaging.knative.dev/v1beta1
      kind: KafkaChannel
      spec:
        numPartitions: 3
        replicationFactor: 1
EOF
```

## Creating an Apache Kafka channel using the default channel configuration

Now that `KafkaChannel` is set as the default channel configuration, you can use
the `channels.messaging.knative.dev` CRD to create a new Apache Kafka channel,
using the generic `Channel`:

```
cat <<-EOF | kubectl apply -f -
---
apiVersion: messaging.knative.dev/v1
kind: Channel
metadata:
  name: testchannel-one
EOF
```

Check Kafka for a `testchannel` topic. With Strimzi this can be done by using
the command:

```
kubectl -n kafka exec -it my-cluster-kafka-0 -- bin/kafka-topics.sh --zookeeper localhost:2181 --list
```

The result is:

```
...
knative-messaging-kafka.default.testchannel-one
...
```

The Apache Kafka topic that is created by the channel implementation is prefixed
with `knative-messaging-kafka`. This indicates it is an Apache Kafka channel
from Knative. It contains the name of the namespace, `default` in this example,
followed by the actual name of the channel.

## Configuring the Knative broker for Apache Kafka channels

To setup a broker that will use the new default Kafka channels, you must create
a new _default_ broker, using the command:

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
 name: default
EOF
```

This will give you two pods, such as:

```
default-broker-filter-64658fc79f-nf596                            1/1     Running     0          15m
default-broker-ingress-ff79755b6-vj9jt                            1/1     Running     0          15m

```

Inside the Apache Kafka cluster you should see two new topics, such as:

```
...
knative-messaging-kafka.default.default-kn2-ingress
knative-messaging-kafka.default.default-kn2-trigger
...
```

## Creating a service and trigger to use the Apache Kafka broker

To use the Apache Kafka based broker, let's take a look at a simple demo. Use
the`ApiServerSource` to publish events to the broker as well as the `Trigger`
API, which then routes events to a Knative `Service`.

1. Install `ksvc`, using the command:
   ```
   kubectl apply -f 000-ksvc.yaml
   ```
2. Install a source that publishes to the default broker

   ```
   kubectl apply -f 020-k8s-events.yaml
   ```

3. Create a trigger that routes the events to the `ksvc`:
   ```
   kubectl apply -f 030-trigger.yaml
   ```

## Verifying your Apache Kafka channel and broker

Now that your Eventing cluster is configured for Apache Kafka, you can verify
your configuration with the following options.

### Receive events via Knative

Now you can see the events in the log of the `ksvc` using the command:

```
kubectl logs --selector='serving.knative.dev/service=broker-kafka-display' -c user-container
```

## Authentication against an Apache Kafka

In production environments it is common that the Apache Kafka cluster is secured using [TLS](http://kafka.apache.org/documentation/#security_ssl) or [SASL](http://kafka.apache.org/documentation/#security_sasl). This section shows how to confiugure the `KafkaChannel` to work against a protected Apache Kafka cluster, with the two supported TLS and SASL authentication methods.

### TLS authentication

To use TLS authentication you must create:

* A CA certificate
* A client certificate and key

**NOTE:** Kafka channels require these files to be in `.pem` format. If your files are in a different format, you must convert them to `.pem`.


1. Create the certificate files as secrets in your chosen namespace:
```
$ kubectl create secret --namespace <namespace> generic <kafka-auth-secret> \
  --from-file=ca.crt=caroot.pem \
  --from-file=user.crt=certificate.pem \
  --from-file=user.key=key.pem
 ```

*NOTE:* It is important to use the same keys (`ca.crt`, `user.crt` and `user.key`).

Reference your secret and the namespace of the secret in the `config-kafka` ConfigMap:
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-kafka
  namespace: knative-eventing
data:
  bootstrapServers: <bootstrap-servers>
  authSecretName: <kafka-auth-secret>
  authSecretNamespace: <namespace>
 ```

### SASL authentication

To use SASL authentication, you will need the following information:

* A username and password.
* The type of SASL mechanism you wish to use. For example; `PLAIN`, `SCRAM-SHA-256` or `SCRAM-SHA-512`.

**NOTE:** It is recommended to also enable TLS. If you enable this, you will also need the `ca.crt` certificate as described in the previous section.

1. Create the certificate files as secrets in your chosen namespace:
```
$ kubectl create secret --namespace <namespace> generic <kafka-auth-secret> \
  --from-file=ca.crt=caroot.pem \
  --from-literal=password="SecretPassword" \
  --from-literal=saslType="SCRAM-SHA-512" \
  --from-literal=user="my-sasl-user"
```

*NOTE:* It is important to use the same keys; `user`, `password` and `saslType`.

### SASL authentication using public CA certificates

If you want to use SASL with public CA certificates, you must use the `tls.enabled=true` flag, rather than the `ca.crt` argument, when creating the secret. For example:

```
$ kubectl create secret --namespace <namespace> generic <kafka-auth-secret> \
    --from-literal=tls.enabled=true \
  --from-literal=password="SecretPassword" \
  --from-literal=saslType="SCRAM-SHA-512" \
  --from-literal=user="my-sasl-user"
```

Reference your secret and the namespace of the secret in the `config-kafka` ConfigMap:
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-kafka
  namespace: knative-eventing
data:
  bootstrapServers: <bootstrap-servers>
  authSecretName: <kafka-auth-Secret>
  authSecretNamespace: <namespace>
```
