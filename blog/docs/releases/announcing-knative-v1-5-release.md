---
title: "v1.5 release"
linkTitle: "v1.5 release"
Author: "[dprotaso](https://twitter.com/lintinmybelly)"
Author handle: https://github.com/dprotaso
date: 2022-06-06
description: "Knative 1.5 release announcement"
type: "blog"
---

## Announcing Knative 1.5 Release

A new version of Knative is now available across multiple components.

Follow the instructions in [Installing Knative](https://knative.dev/docs/install/) to install the components you require.

## Table of Contents
- [Serving](#serving)
- [Eventing](#eventing)
- [Eventing Extensions](#eventing-extensions)
    - [Apache Kafka Broker](#apache-kafka-broker)
    - [RabbitMQ Broker and Source](#rabbitmq-broker-and-source)
- [`kn` CLI](#client)
- [Knative Operator](#operator)
- [Thank you contributors](#thank-you-contributors)

## Serving

<!-- Original notes are here: https://github.com/knative/serving/releases/tag/knative-1.5 -->

### 💫 New Features & Changes

- Allows dnsConfig and dnsPolicy to be specified on pod specs when the feature is enabled in the config-features config map. ([#12897](https://github.com/knative/serving/issues/12897))
- Enabling the container freezer will disable the readiness probe defaulted in by Knative. ([#12967](https://github.com/knative/serving/issues/12967))
- [All hops encrypted epic](https://github.com/knative/serving/issues/11906) - (alpha) TLS between activator and queue proxy ([#12815](https://github.com/knative/serving/issues/12815))

### 🐞 Bug Fixes
- Support for parsing name and namespace in activator from a request when 'Host' header or host name contains a port ([#12974](https://github.com/knative/serving/issues/12974))
- The value of panicRPSM was set as observedStableValue, but it should have been observedPanicValue as part of the metric collection. ([#12910](https://github.com/knative/serving/issues/12910))
- Reduce the chance of 503s when rolling out a new revision ([#12842](https://github.com/knative/serving/issues/12842))

## Eventing

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/knative-1.5 -->

### 💫 New Features & Changes

- Propagate per-component logging levels to source receive adapters. ([#6391](https://github.com/knative/eventing/issues/6391))

### 🐞 Bug Fixes

- :broom: MTChannelBroker filter does not proxy headers from replies anymore other than the headers specified in its hardcoded allow-list. The list so far only contains `Retry-After`. ([#6357](https://github.com/knative/eventing/issues/6357))
- :bug: Fix pingsource-mt-adapter crash when the initial replicas is set to a value other than 0 ([#6359](https://github.com/knative/eventing/issues/6359), @lionelvillard)
- :bug: Fix Parallel not properly reporting underlying Channel creation failures ([#6354](https://github.com/knative/eventing/issues/6554))
-  :broom: Now the Eventing Performance tests are ready to use, including Sender Throughput  and latency graphs ([#6340](https://github.com/knative/eventing/issues/6340))


## Networking Extensions

### cert-manager plugin (net-certmanager)

#### 💫 New Features & Changes

- Cert-manager is now in version 1.8.0. ([#399](https://github.com/knative-sandbox/net-certmanager/issues/399))
- Secrets automatically generated due to certificate creation are labeled with a special label key to support proper filtering from K8s informers in components that consume them. ([#402](https://github.com/knative-sandbox/net-certmanager/402))

### Istio plugin (net-istio)

#### 💫 New Features & Changes

- Memory leak fix for large clusters where all cluster secrets were listed in net-istio.
Secret informer in ingress controller can be enabled to filter secrets based on the existence of a label key `certificate.networking.knative.dev`
  - Users are required to add the label key for custom secrets defined in ingresses.
For special cases users are recommended to reach out to Knative community.
  - In case of AutoTLS provided by Knative net-certmanager this is done transparently.
  - To enable this behavior at net-istio set env var `ENABLE_SECRET_INFORMER_FILTERING_BY_CERT_UID` to `true`.
  - This will be available by default in future releases. ([#920](https://github.com/knative-sandbox/net-istio/issues/920))
 - local-gateway.mesh: "mesh" option was dropped. ([#915](https://github.com/knative-sandbox/net-istio/issues/915))

## Eventing Extensions

### Apache Kafka Broker

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka-broker/releases/tag/knative-1.5 -->

#### 💫 New Features & Changes

- Deploy just the KafkaSource v2 controller and new statefulset dispatcher (no receiver) for users of KakfaSource ([#2089](https://github.com/knative-sandbox/eventing-kafka-broker/issues/2089))
- With the `kafka.eventing.knative.dev/external.topic` annotation it is possible to use an externally managed Apache Kafka topic for the broker usage ([#1023](https://github.com/knative-sandbox/eventing-kafka-broker/issues/1023))
- `vertx_*` metrics have been removed since they were causing unnecessary allocations. ([#2147](https://github.com/knative-sandbox/eventing-kafka-broker/issues/2147))
- 🧽 Update or clean up current behavior
  The control plane sends retry configurations to the data plane. ([#263](https://github.com/knative-sandbox/eventing-kafka-broker/issues/263/))


#### 🐞 Bug Fixes

- Receiver's prober targets services instead of pods directly to allow components to be part of an Istio mesh ([#2112](https://github.com/knative-sandbox/eventing-kafka-broker/issues/2112))

### RabbitMQ Broker and Source

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-rabbitmq/releases/tag/knative-1.5 -->


### 🚨 Breaking or Notable
- With the removal of standalone-broker, Secret type is no longer a supported Broker.Config ([#773](https://github.com/knative-sandbox/eventing-rabbitmq/issues/773))

#### 💫 New Features & Changes

- A new type RabbitmqBrokerConfig can be used to configure a Broker ([#780](https://github.com/knative-sandbox/eventing-rabbitmq/issues/780))
- Dispatcher will timeout after 30s when sending to the subscriber ([#687](https://github.com/knative-sandbox/eventing-rabbitmq/issues/687))
- Now the docs are better organized and performance tests graphs are correct ([#721](https://github.com/knative-sandbox/eventing-rabbitmq/issues/721))
- Resource requests for source controller increased ([#738](https://github.com/knative-sandbox/eventing-rabbitmq/issues/738))
- The Broker's Ingress and Dispatcher have deployment resource requests and limits
  -  The Source's Receive Adapter have deployment resources requests and limits ([#771](https://github.com/knative-sandbox/eventing-rabbitmq/issues/771))
-  The Broker's ingress uses the Binary representation of the CloudEvents
  -  The Broker's Dispatcher uses the protocol binding to get a CloudEvent from a RabbitMQ Message
  -  Added performance tests for the source using the new Ingress CE Binary representation, that makes the Ingress plugable to the Source ([#751](https://github.com/knative-sandbox/eventing-rabbitmq/issues/751))
-  Script to automate the generation of the performance results per release
  - Complete performance results graph tests for the RabbitMQ's Broker and Source ([#767](https://github.com/knative-sandbox/eventing-rabbitmq/issues/767))

#### 🐞 Bug Fixes

- The backoffDelay env variable is parsed correctly on the Broker's and Trigger's Dispatcher
  - The backoffDelay env variable is parsed correctly on the Source's receive adapter ([#750](https://github.com/knative-sandbox/eventing-rabbitmq/issues/750))
- BackoffDelay is used when defined in Broker or Trigger delivery spec
  - dead letter messaging uses the same delivery spec ([#723](https://github.com/knative-sandbox/eventing-rabbitmq/issues/723))
- Fixed bug in Trigger dispatcher deployment from getting updated too frequently ([#744](https://github.com/knative-sandbox/eventing-rabbitmq/issues/744))
- Fixed bug where the broker ingress was not reconnecting after the connection or channel with RabbitMQ was closed ([#778](https://github.com/knative-sandbox/eventing-rabbitmq/issues/778))

## Client

<!-- Original notes are here: https://github.com/knative/client/blob/main/CHANGELOG.adoc#TODO-CLI-CHANGELOG-ENTRY -->

### 💫 New Features & Changes

- New flag options has been added to broker create and broker update commands:
    ```
    Options:
          --backoff-delay string     The delay before retrying.
          --backoff-policy string    The retry backoff policy (linear, exponential).
          --class string             Broker class like 'MTChannelBasedBroker' or 'Kafka' (if available).
          --dl-sink string           The sink receiving event that could not be sent to a destination.
      -n, --namespace string         Specify the namespace to operate in.
          --retry int32              The minimum number of retries the sender should attempt when sending an event before moving it to the dead letter sink.
          --retry-after-max string   An optional upper bound on the duration specified in a "Retry-After" header when calculating backoff times for retrying 429 and 503 response codes. Setting the value to zero ("PT0S") can be used to opt-out of respecting "Retry-After" header values altogether. This value only takes effect if "Retry" is configured, and also depends on specific implementations (Channels, Sources, etc.)
                                     choosing to provide this capability.
          --timeout string           The timeout of each single request. The value must be greater than 0.

    ```

## Operator

<!-- Original notes are here: https://github.com/knative/operator/releases/tag/knative-1.5   -->

### 💫 New Features & Changes
- Update the template and samples for csv bundle ([#1061](https://github.com/knative/operator/pull/1061))

### 🐞 Bug Fixes
- Add the support of port and host configuration for gateways ([#1047](https://github.com/knative/operator/pull/1047))
- Add the configuration of selector for services ([#1050](https://github.com/knative/operator/pull/1050))
- Add the annotation sidecar.istio.io/inject: "false" to operator-webhook ([#1066](https://github.com/knative/operator/pull/1066))
- Support overriding env vars per container ([#1085](https://github.com/knative/operator/pull/1085))

## Thank you, contributors

#### Release Leads:

- [@dprotaso](https://github.com/dprotaso)
- [@gab-satchi](https://github.com/gab-satchi)

#### Contributors:

- [@aavarghese](https://github.com/aavarghese)
- [@aliok](https://github.com/aliok)
- [@antoineco](https://github.com/antoineco)
- [@dprotaso](https://github.com/dprotaso)
- [@gab-satchi](https://github.com/gab-satchi)
- [@gabo1208](https://github.com/gabo1208)
- [@lionelvillard](https://github.com/lionelvillard)
- [@matzew](https://github.com/matzew)
- [@Mgla96](https://github.com/Mgla96)
- [@nak3](https://github.com/nak3)
- [@Nalin28](https://github.com/Nalin28)
- [@pierDipi](https://github.com/pierDipi)
- [@psschwei](https://github.com/psschwei)
- [@skonto](https://github.com/skonto)
- [@stevenchen-db](https://github.com/stevenchen-db)

## Learn more

Knative is an open source project that anyone in the [community](https://knative.dev/docs/community/) can use, improve, and enjoy. We'd love you to join us!

- [Knative docs](https://knative.dev/docs)
- [Quickstart tutorial](https://knative.dev/docs/getting-started)
- [Samples](https://knative.dev/docs/samples)
- [Knative Working Groups](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md)
- [Knative User Mailing List](https://groups.google.com/forum/#!forum/knative-users)
- [Knative Development Mailing List](https://groups.google.com/forum/#!forum/knative-dev)
- Knative on Twitter [@KnativeProject](https://twitter.com/KnativeProject)
- Knative on [StackOverflow](https://stackoverflow.com/questions/tagged/knative)
- Knative [Slack](https://slack.knative.dev)
- Knative on [YouTube](https://www.youtube.com/channel/UCq7cipu-A1UHOkZ9fls1N8A)
