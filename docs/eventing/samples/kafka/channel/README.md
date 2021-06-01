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
  [prerequisites listed in the Apache Kafka overview](../).
- A Kubernetes cluster with
  [Knative Kafka Channel installed](../../../../admin/install/).

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
[default channel configuration](../../../channels/channel-types-defaults), edit the
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
kubectl -n kafka exec -it my-cluster-kafka-0 -- bin/kafka-topics.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --list
```

The result is:

```
...
__consumer_offsets
knative-messaging-kafka.default.my-kafka-channel
knative-messaging-kafka.default.testchannel-one
...
```

The Apache Kafka topic that is created by the channel implementation contains
the name of the namespace, `default` in this example, followed by the actual
name of the channel.  In the consolidated channel implementation, it is also
prefixed with `knative-messaging-kafka` to indicate that it is an Apache Kafka
channel from Knative.

**NOTE:** The topic of a Kafka channel is an implementation detail and records from it should not be consumed from different applications.

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

**NOTE:** The topic of a Kafka channel is an implementation detail and records from it should not be consumed from different applications.

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

In production environments it is common that the Apache Kafka cluster is secured using [TLS](http://kafka.apache.org/documentation/#security_ssl) or [SASL](http://kafka.apache.org/documentation/#security_sasl). This section shows how to configure the `KafkaChannel` to work against a protected Apache Kafka cluster, with the two supported TLS and SASL authentication methods.

### TLS authentication

To use TLS authentication you must create:

* A CA certificate
* A client certificate and key

!!! note
    Kafka channels require these files to be in `.pem` format. If your files are in a different format, you must convert them to `.pem`.

1. For the consolidated channel type, create the certificate files as secret
fields in your chosen namespace:
```
$ kubectl create secret --namespace <namespace> generic <kafka-auth-secret> \
  --from-file=ca.crt=caroot.pem \
  --from-file=user.crt=certificate.pem \
  --from-file=user.key=key.pem
 ```

*NOTE:* It is important to use the same keys (`ca.crt`, `user.crt` and `user.key`).

For the distributed channel type, place the certificate into your
`config-kafka` ConfigMap and set the TLS.Enable field to `true`, for example:

```
...
data:
  sarama: |
    config: |
      Net:
        TLS:
          Enable: true
          Config:
            RootPEMs: # Array of Root Certificate PEM Files (Use '|-' Syntax To Preserve Linefeeds & Avoiding Terminating \n)
            - |-
              -----BEGIN CERTIFICATE-----
              MIIGDzCCA/egAwIBAgIUWq6j7u/25wPQiNMPZqL6Vy0rkvQwDQYJKoZIhvcNAQEL
              ...
              771uezZAFqd1GLLL8ZYRmCsAMg==
              -----END CERTIFICATE-----
...
```


### SASL authentication

To use SASL authentication, you will need the following information:

* A username and password.
* The type of SASL mechanism you wish to use. For example; `PLAIN`, `SCRAM-SHA-256` or `SCRAM-SHA-512`.

!!! note
    It is recommended to also enable TLS. If you enable this, you will also need the `ca.crt` certificate as described in the previous section.

#### SASL secret

The SASL secret is different depending on whether you are using the
consolidated or distributed channel implementation. For the
consolidated channel, create a secret with a `ca.crt` field if using
a custom CA certificate, for example:

```
$ kubectl create secret --namespace <namespace> generic <kafka-auth-secret> \
  --from-file=ca.crt=caroot.pem \
  --from-literal=password="SecretPassword" \
  --from-literal=saslType="SCRAM-SHA-512" \
  --from-literal=user="my-sasl-user"
```

or, if you want to use public CA certificates, you must use the
`tls.enabled=true` flag, rather than the `ca.crt` argument, for example:

```
$ kubectl create secret --namespace <namespace> generic <kafka-auth-secret> \
  --from-literal=tls.enabled=true \
  --from-literal=password="SecretPassword" \
  --from-literal=saslType="SCRAM-SHA-512" \
  --from-literal=user="my-sasl-user"
```

!!! note
    It is important to use the same keys; `user`, `password` and `saslType`.

For the distributed channel type, do not place the certificate into the secret;
instead place the root certificate data (if using a custom CA cert) directly
into your `config-kafka` ConfigMap and set SASL.Enable to `true`. For example:

```
$ kubectl create secret --namespace <namespace> generic <kafka-auth-secret> \
    --from-literal=password="SecretPassword" \
    --from-literal=saslType="PLAIN" \
    --from-literal=username="my-sasl-user"
```

Example of adding a certificate to the `config-kafka` ConfigMap and enabling
TLS and SASL:

```
...
data:
  sarama: |
    config: |
      Net:
        TLS:
          Enable: true
          Config:
            RootPEMs: # Array of Root Certificate PEM Files (Use '|-' Syntax To Preserve Linefeeds & Avoiding Terminating \n)
            - |-
              -----BEGIN CERTIFICATE-----
              MIIGDzCCA/egAwIBAgIUWq6j7u/25wPQiNMPZqL6Vy0rkvQwDQYJKoZIhvcNAQEL
              ...
              771uezZAFqd1GLLL8ZYRmCsAMg==
              -----END CERTIFICATE-----
        SASL:
          Enable: true
...
```

### All authentication methods

After you have created the secret for your desired authentication type by using the previous
steps, reference the secret and the namespace of the secret in the `config-kafka` ConfigMap:

```
...
data:
  eventing-kafka: |
    kafka:
      authSecretName: <kafka-auth-secret>
      authSecretNamespace: <namespace>
...
 ```

!!! note
    The default secret name and namespace are `kafka-cluster` and
    `knative-eventing` respectively. If you reference a secret in a different
    namespace, be sure your roles and bindings are configured so that the
    knative-eventing pods can access it.

## Channel configuration

The `config-kafka` ConfigMap allows for a variety of channel options such as:
- CPU and Memory requests and limits for the dispatcher (and receiver for
  the distributed channel type) deployments created by the controller
- Kafka topic default values (number of partitions, replication factor, and
  retention time)
- Maximum idle connections/connections per host for Knative cloudevents
- The brokers string for your Kafka connection
- The name and namespace of your TLS/SASL authentication secret
- The Kafka admin type (distributed channel only)
- Nearly all the settings exposed in a [Sarama Config Struct](https://github.com/Shopify/sarama/blob/master/config.go)
- Sarama debugging assistance (via sarama.enableLogging)

For detailed information (particularly for the distributed channel), see the
[Distributed Channel README](https://github.com/knative-sandbox/eventing-kafka/blob/main/config/channel/distributed/README.md)
