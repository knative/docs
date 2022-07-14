**Authors: [Evan Anderson](https://twitter.com/e_k_anderson) (VMware), Paul Schweigert (IBM)**

**Date: 2022-07-12**

# Announcing Knative 1.6 Release

A new version of Knative is now available across multiple components.

Follow the instructions in [Installing Knative](https://knative.dev/docs/install/) to install the components you require.

This release brings a number of smaller improvements to the core Knative Serving and Eventing components, and several improvements to specific plugins, in particular `net-kourier`, `net-gateway-api`, and `eventing-rabbitmq`.

## Table of Contents
- [Serving](#serving)
- [Eventing](#eventing)
- [`kn` CLI](#client)
- [Knative Operator](#operator)
- [Networking Extensions](#networking-extensions)
    - [Kourier plugin](#kourier-plugin)
    - [Gateway-API plugin](#gateway-api-plugin)
- [Eventing Extensions](#eventing-extensions)
    - [Apache Kafka Source](#apache-kafka-source)
    - [RabbitMQ Broker and Source](#rabbitmq-broker-and-source)
- [Thank you contributors](#thank-you-contributors)

## Serving

[Release Notes](https://github.com/knative/serving/releases/tag/knative-v1.6.0)

### 💫 New Features & Changes

* The `HTTPRedirect` feature is stable and the feature flag has been removed. This feature enabled use of the `networking.knative.dev/httpOption` annotation to configure HTTP -> HTTPS redirect on a per-service basis. [#13084](https://github.com/knative/serving/pull/13084)
* The Serving API no longer rejects unknown fields, and instead relies on the kubernetes apiserver to prune (remove) those fields. [#13095](https://github.com/knative/serving/pull/13095), [#13111](https://github.com/knative/serving/pull/13111)

## Eventing

[Release Notes](https://github.com/knative/eventing/releases/tag/knative-v1.6.0)

### 🐞 Bug Fixes

* Parallel was creating invalid subscriptions in some cases. [#6405](https://github.com/knative/eventing/pull/6405)

## Client

[Release Notes](https://github.com/knative/client/releases/tag/knative-v1.6.0)

### 💫 New Features & Changes

* Eventing support for the `--broker-config` flag has been added to `broker create` [#1700](https://github.com/knative/client/pull/1700)
* Serving support for `--probe-*` flags have been added to manage service liveness and readiness [#1697](https://github.com/knative/client/pull/1697)
* Serving support for mounting EmptyDir and PersistentVolumeClaims has been added [#1679](https://github.com/knative/client/pull/1679), [#1693](https://github.com/knative/client/pull/1693)

## Operator

[Release Notes](https://github.com/knative/operator/releases/tag/knative-v1.6.0)

### 💫 New Features & Changes

* The operator supports overriding the default broker class. [#1123](https://github.com/knative/operator/pull/1123)
* Implement minAvailable in PodDisruptionBudget. [#1125](https://github.com/knative/operator/pull/1125)

### 🐞 Bug Fixes

* The `v1alpha1` versions have been removed. [#1104](https://github.com/knative/operator/pull/1104)

## Networking Extensions

### kourier plugin

#### 💫 New Features & Changes

* Add a new experimental configuration parameter to separate internal traffic for different namespaces by TCP port. This should enable use of NetworkPolicy with Knative. [#852](https://github.com/knative-sandbox/net-kourier/pull/852)
* Experimentally enable filtered secret watches when using AutoTLS. This should provide performance improvements in large clusters. [#862](https://github.com/knative-sandbox/net-kourier/pull/862)

### 🐞 Bug Fixes

* Fix SNI when using `proxy_protocol`. [#869](https://github.com/knative-sandbox/net-kourier/pull/869)

### Gateway-API plugin

#### 💫 New Features & Changes

* Adds support for AutoTLS [#316](https://github.com/knative-sandbox/net-gateway-api/pull/316)

### 🐞 Bug Fixes

* Network programming probes now respect the Service port of the gateway. [#310](https://github.com/knative-sandbox/net-gateway-api/pull/310)

## Eventing Extensions

### Apache Kafka Source

#### 🐞 Bug Fixes

* Deletion of KafkaSource resources now properly cleans up internal scheduling resources. [#1206](https://github.com/knative-sandbox/eventing-kafka/pull/1206)


### RabbitMQ Broker and Source

#### Breaking Changes

* Some deprecated fine-grained configuration options have been removed from RabbitMQSource. [#800](https://github.com/knative-sandbox/eventing-rabbitmq/pull/800)
* RabbitMQSource now uses a RabbitCluster reference like the Broker. [#801](https://github.com/knative-sandbox/eventing-rabbitmq/pull/801)
* RabbitMQSource parameters have been re-arranged into logical groups. [#810](https://github.com/knative-sandbox/eventing-rabbitmq/pull/810)

#### 💫 New Features & Changes

* Message pre-fetch is now automatically set to 100, increasing steady-state throughput. [#856](https://github.com/knative-sandbox/eventing-rabbitmq/pull/856)
* Added the ability to configure queue types in RabbitmqBrokerConfig. [#808](https://github.com/knative-sandbox/eventing-rabbitmq/pull/803)
* Support for RabbitMQ ClusterReference connection secrets. [#822](https://github.com/knative-sandbox/eventing-rabbitmq/pull/822)

#### 🐞 Bug Fixes

* Fixed a bug where RabbitMQSource objects with `retries` configured could crash when receiving an error from the event destination. [#831](https://github.com/knative-sandbox/eventing-rabbitmq/pull/831)


## Thank you, contributors

#### Release Leads:

- [@evankanderson](https://github.com/evankanderson)
- [@psschwei](https://github.com/psschwei)

#### Contributors:

- [@aavarghese](https://github.com/aavarghese)
- [@aliok](https://github.com/aliok)
- [@carlisia](https://github.com/carlisia)
- [@davidsalerno](https://github.com/davidsalerno)
- [@dprotaso](https://github.com/dprotaso)
- [@dsimansk](https://github.com/dsimansk)
- [@evankanderson](https://github.com/evankanderson)
- [@gab-satchi](https://github.com/gab-satchi)
- [@gabo1208](https://github.com/gabo1208)
- [@houshengbo](https://github.com/houshengbo)
- [@ikvmw](https://github.com/ikvmw)
- [@lionelvillard](https://github.com/lionelvillard)
- [@mattmoor](https://github.com/mattmoor)
- [@naderziada](https://github.com/naderziada)
- [@nak3](https://github.com/nak3)
- [@RamyChaabane](https://github.com/RamyChaabane)
- [@skonto](https://github.com/skonto)
- [@vyasgun](https://github.com/vyasgun)

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
