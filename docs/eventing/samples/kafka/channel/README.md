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

1. Create a new object by configuring the YAML file as follows:
   ```shell
   kubectl apply -f - <<EOF
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

1. To configure the usage of the `KafkaChannel` CRD as the
   [default channel configuration](../../../channels/channel-types-defaults), 
   edit the `default-ch-webhook` ConfigMap as follows:
   ```shell
   kubectl apply -f - <<EOF
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

1. Now that `KafkaChannel` is set as the default channel configuration,
   use the `channels.messaging.knative.dev` CRD to create a new Apache Kafka
   channel, using the generic `Channel`:
   ```shell
   kubectl apply -f - <<EOF
   ---
   apiVersion: messaging.knative.dev/v1
   kind: Channel
   metadata:
     name: testchannel-one
   EOF
   ```
2. Check Kafka for a `testchannel-one` topic. With Strimzi this can be done by
   using the command:
   ```shell
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

!!! note
    The topic of a Kafka channel is an implementation detail and records from it should not be consumed from different applications.

## Configuring the Knative broker for Apache Kafka channels

1. To setup a broker that will use the new default Kafka channels, you must
   create a new _default_ broker, using the command:
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
default-broker-ingress-ff79755b6-vj9jt                            1/1     Running     0          15
```
Inside the Apache Kafka cluster you should see two new topics, such as:
```
...
knative-messaging-kafka.default.default-kn2-ingress
knative-messaging-kafka.default.default-kn2-trigger
...
```

!!! note
    The topic of a Kafka channel is an implementation detail and records from it should not be consumed from different applications.

## Creating a service and trigger to use the Apache Kafka broker

To use the Apache Kafka based broker, let's take a look at a simple demo. Use
the`ApiServerSource` to publish events to the broker as well as the `Trigger`
API, which then routes events to a Knative `Service`.

1. Install `ksvc`, using the command:
   ```shell
   kubectl apply -f 000-ksvc.yaml
   ```
2. Install a source that publishes to the default broker
   ```shell
   kubectl apply -f 020-k8s-events.yaml
   ```
3. Create a trigger that routes the events to the `ksvc`:
   ```shell
   kubectl apply -f 030-trigger.yaml
   ```

## Verifying your Apache Kafka channel and broker

Now that your Eventing cluster is configured for Apache Kafka, you can verify
your configuration with the following options.

### Receive events via Knative

1. Observe the events in the log of the `ksvc` using the command:
   ```shell
   kubectl logs --selector='serving.knative.dev/service=broker-kafka-display' -c user-container
   ```

## Authentication against an Apache Kafka cluster

In production environments it is common that the Apache Kafka cluster is
secured using [TLS](http://kafka.apache.org/documentation/#security_ssl)
or [SASL](http://kafka.apache.org/documentation/#security_sasl). This section
shows how to configure the `KafkaChannel` to work against a protected Apache
Kafka cluster, with the two supported TLS and SASL authentication methods.

!!! note
Kafka channels require certificates to be in `.pem` format. If your files
are in a different format, you must convert them to `.pem`.

Follow the section corresponding to the channel type that you used
(consolidated or distributed) when installing eventing-kafka:

### Consolidated channel authentication

#### TLS authentication

To use TLS authentication you must create:

* A CA certificate
* A client certificate and key

1. Create the certificate files as secret fields in your chosen namespace:
   ```shell
   kubectl create secret --namespace <namespace> generic <kafka-auth-secret> \
     --from-file=ca.crt=caroot.pem \
     --from-file=user.crt=certificate.pem \
     --from-file=user.key=key.pem
   ```

   !!! note
   It is important to use the same keys (`ca.crt`, `user.crt` and `user.key`).

#### SASL authentication

To use SASL authentication, you will need the following information:

* A username and password.
* The type of SASL mechanism you wish to use. For example; `PLAIN`, `SCRAM-SHA-256` or `SCRAM-SHA-512`.

!!! note
    It is recommended to also enable TLS. If you enable this, you will also
    need the `ca.crt` certificate as described in the previous section.

1. Create a secret with a `ca.crt` field if using a custom CA certificate,
   for example:
   ```shell
   kubectl create secret --namespace <namespace> generic <kafka-auth-secret> \
     --from-file=ca.crt=caroot.pem \
     --from-literal=password="SecretPassword" \
     --from-literal=saslType="SCRAM-SHA-512" \
     --from-literal=user="my-sasl-user"
   ```
2. Optional. If you want to use public CA certificates, you must use the
   `tls.enabled=true` flag, rather than the `ca.crt` argument, for example:
   ```shell
   kubectl create secret --namespace <namespace> generic <kafka-auth-secret> \
     --from-literal=tls.enabled=true \
     --from-literal=password="SecretPassword" \
     --from-literal=saslType="SCRAM-SHA-512" \
     --from-literal=user="my-sasl-user"
   ```

!!! note
    It is important to use the same keys; `user`, `password` and `saslType`.

### Distributed channel authentication

#### TLS authentication

1. Edit your config-kafka ConfigMap:
   ```shell
   kubectl -n knative-eventing edit configmap config-kafka
   ```
2. Set the TLS.Enable field to `true`, for example
   ```
   ...
   data:
     sarama: |
       config: |
         Net:
           TLS:
             Enable: true
   ...
   ```
3. Optional. If using a custom CA certificate, place your certificate data
   into the ConfigMap in the data.sarama.config.Net.TLS.Config.RootPEMs field,
   for example:
   ```
   ...
   data:
     sarama: |
       config: |
         Net:
           TLS:
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

#### SASL authentication

To use SASL authentication, you will need the following information:

* A username and password.
* The type of SASL mechanism you wish to use. For example; `PLAIN`, `SCRAM-SHA-256` or `SCRAM-SHA-512`.

!!! note
    It is recommended to also enable TLS as described in the previous section.

1. Edit your config-kafka ConfigMap:
   ```shell
   kubectl -n knative-eventing edit configmap config-kafka
   ```
2. Set the SASL.Enable field to `true`, for example:
   ```
   ...
   data:
     sarama: |
       config: |
         Net:
           SASL:
             Enable: true
   ...
   ```
3. Create a secret with the username, password, and SASL mechanism, for example:
   ```shell
   kubectl create secret --namespace <namespace> generic <kafka-auth-secret> \
       --from-literal=password="SecretPassword" \
       --from-literal=saslType="PLAIN" \
       --from-literal=username="my-sasl-user"
   ```

### All channel types and authentication methods

1. If you have created a secret for your desired authentication method by
   using the previous steps, reference the secret and the namespace of the
   secret in the `config-kafka` ConfigMap:
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
