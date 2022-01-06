---
title: "v0.22 release"
linkTitle: "v0.22 release"
Author: "[Carlos Santana](https://twitter.com/csantanapr)"
Author handle: https://github.com/csantanapr
date: 2021-04-06
description: "Knative v0.22 release announcement"
type: "blog"
image: knative-eventing.png
---


### Announcing Knative v0.22 Release

A new version of Knative is now available across multiple components.
Follow the instructions in the documentation [Installing Knative](https://knative.dev/docs/install/) for the respective component.

#### Table of Contents
- [Serving v0.22](#serving-v022)
- [Eventing v0.22](#eventing-v022)
- Eventing Extensions
    - [Apache Kafka Broker v0.22](#apache-kafka-broker-v022)
- `kn` [CLI v0.22](#client-v022)
    - `kn` [CLI Plugins](#cli-plugins)
- [Operator v0.22](#operator-v022)
- [Thank you contributors](#thank-you-contributors)



### Highlights

- Serving Domain Mapping improves multi-tenancy support to avoid domain name to be claim by users that don't legitimately owns them in the cluster.
- Eventing now allows subscribers and triggers from different namespaces to be used together.
- 1.18 is now the minimum Kubernetes version required to use the Apache Kafka broker with Knative Eventing v0.22.
- Apache Kafka broker now supports the ability to choose between ordered and unordered delivery
- The CLI `kn` v0.22.0 comes with some bug fixes and minor feature enhancements. It's mostly a polishing release. If you are using the Client API, there is a breaking change that was needed to align with Kubernetes Client API's
- There are two new CLI plugins to align with the v0.22 release, [kn-plugin-admin](https://github.com/knative-sandbox/kn-plugin-admin) and [kn-plugin-source-kafka](https://github.com/knative-sandbox/kn-plugin-source-kafka)
- The Knative Operator v0.22 release contains bug fixes and supports version v0.22 of Knative Serving and Eventing.


### Serving v0.22

<!-- Original notes are here: https://github.com/knative/serving/releases/tag/v0.22.0 -->

#### 💫 New Features & Changes

- Added an autoscaling annotation to choose a different aggregation algorithm for the autoscaling metrics. This is experimental currently. [#10840](https://github.com/knative/serving/pull/10840)
- Added the `autocreateClusterDomainClaims` flag to the network ConfigMap. [networking/#330](https://github.com/knative/networking/pull/330)

#### 🐞 Bug Fixes

- Added validation that a default `max-scale` is set if a `max-scale-limit` is specified in the autoscaler ConfigMap. Otherwise, the default `max-scale`, `0` = no max, would fail validation as it is above the `max-scale-limit`. [#10921](https://github.com/knative/serving/pull/10921)
- Raised the resource request and limits of the autoscaler to 100m/100Mi, 1000m/1000Mi respectively. [#10865](https://github.com/knative/serving/pull/10865)
- Fixed a regression where the latency of starting a pod could be 10s or more. [#10992](https://github.com/knative/serving/pull/10992)
- Reduced required memory allocations in the activator significantly, particularly when tracing is turned off. [#11016](https://github.com/knative/serving/pull/11016), [#11013](https://github.com/knative/serving/pull/11013), [#11009](https://github.com/knative/serving/pull/11009), [#11008](https://github.com/knative/serving/pull/11008)
- Fixed the incorrect gateway name format for the domain mapping auto TLS feature for `net-istio` implementation. [net-istio#532](https://github.com/knative-sandbox/net-istio/pull/532)


### Eventing v0.22

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/v0.22.1 -->

#### 🚨 API Changes

- `v1alpha1` channel duck types are no longer supported. [#5005](https://github.com/knative/eventing/pull/5005)

<!-- We don't know what this means in the release notes. Leaving here commented out to hide it.
- Allow Trigger users to set another namespace's Subscriber, And when Subscriber's namespace not been set, it will be set to Trigger's namespace [#4995](https://github.com/knative/eventing/pull/4995)
-->

#### 🐞 Bug Fixes

- Fixed a bug that caused the PingSource adapter to not always release the leader election lease when terminating. [#5162](https://github.com/knative/eventing/pull/5162)
- Fixed a bug that caused PingSource objects to send duplicate events when the leading adapter failed to renew its lease. [#4908](https://github.com/knative/eventing/pull/4908)
- Fixed a  bug that prevented namespace-scoped InMemoryChannel objects from becoming `READY`. [#4906](https://github.com/knative/eventing/pull/)
- Fixed excessive number of replicas that were being created for `eventing-webhook`. [#5112](https://github.com/knative/eventing/pull/5112)
- The webhook timeout for API server calls has been increased to 10 seconds. [#5175](https://github.com/knative/eventing/pull/5175)

#### 🧹 Clean up

- Do not set a finalizer for PingSource controllers. Use `reconcilekind` instead. [#5002](https://github.com/knative/eventing/pull/5002)

### Eventing Extensions


#### Apache Kafka Broker v0.22

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka-broker/releases/tag/v0.22.1 -->

#### 🚨 Breaking or Notable

#### 💫 New Features & Changes

- The Kafka broker now supports ordered delivery. You can choose between ordered and unordered delivery by using the `kafka.eventing.knative.dev/delivery.order` label in the trigger spec. See the [Kafka broker](https://knative.dev/docs/eventing/broker/kafka-broker) documentation. [#589](https://github.com/knative-sandbox/eventing-kafka-broker/pull/)

#### 🐞 Bug Fixes

- Added a producer interceptor, `io.cloudevents.kafka.PartitionKeyExtensionInterceptor`, to provide ordered delivery based on the partitioning extension of the CloudEvents spec. [#751](https://github.com/knative-sandbox/eventing-kafka-broker/pull/751)
- Fix unable to deploy KafkaSink without Kafka Broker installed. [#714](https://github.com/knative-sandbox/eventing-kafka-broker/pull/714)

### Client v0.22

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/v0.22.1 and https://github.com/knative/client/blob/main/CHANGELOG.adoc#v0220-2021-04-06 -->

#### Managing custom domain mappings

This release adds support for CRUD management of domain mappings. You can use the `kn domain` CLI command, along with its sub-commands `create`, `update`, `describe`, `list`, and `delete`, to fully manage DomainMapping resources to use custom domains for Knative services.

```
# Create a domain mappings 'hello.example.com' for Knative service 'hello'
kn domain create hello.example.com --ref hello

# Update a domain mappings 'hello.example.com' for Knative service 'hello'
kn domain create hello.example.com --refFlags hello

# List all domain mappings
kn domain list

# Delete domain mappings 'hello.example.com'
kn domain delete hello.example.com
```
See `kn domain help` for more information.


#### Client API signature change

A `context.Context` object was added as the first argument to every Client API method to align with the Kubernetes Client API signatures. This change does not affect client CLI usage unless the client-specific Golang API used to communicate with the Knative backend has changed.
To migrate to the updated API signature, you can pass an already existing context to the call, or use one of the available standard contexts, such as `context.TODO()`.

### CLI Plugins

#### 💫 New Features & Changes

The plugins that are released aligned with v0.22 are:

- [kn-plugin-admin](https://github.com/knative-sandbox/kn-plugin-admin) for managing Knative installations that are running on Kubernetes | [download](https://github.com/knative-sandbox/kn-plugin-admin/releases/tag/v0.22.0)
- [kn-plugin-source-kafka](https://github.com/knative-sandbox/kn-plugin-source-kafka) for managing a Kafka Source that has been installed via [eventing-kafka](https://github.com/knative-sandbox/eventing-kafka) on the backend | [download](https://github.com/knative-sandbox/kn-plugin-source-kafka/releases/tag/v0.22.0)

### Minor CLI updates

- `kn export` now uses the _Export_ format as the default.
- Added `S` column to specify built-in sources in `kn source list-types`.
- Added support for namespaces for all commands that takes a `--sink` option.

### Operator v0.22

<!-- Original notes are here: https://github.com/knative/operator/releases/tag/v0.22.1 -->

#### 🐞 Bug Fixes

- Delete installed ingress resources only. [#548](https://github.com/knative/operator/pull/548)
- Allow the update of ingress resources with `spec.additionalManifests`. [#531](https://github.com/knative/operator/pull/531)
- Refactored the cache mechanism. [#532](https://github.com/knative/operator/pull/532)
- Filter redundant resources in the target manifest. [#509](https://github.com/knative/operator/pull/509)

#### 🧹 Clean up

- Drop unnecessary occurrences of master [#513](https://github.com/knative/operator/pull/513)
- Add DEVELOPMENT.md [#503](https://github.com/knative/operator/pull/503)

### Thank you contributors

- [@dsimansk](https://github.com/dsimansk)
- [@eletonia](https://github.com/eletonia)
- [@ericmillin](https://github.com/ericmillin)
- [@evankanderson](https://github.com/evankanderson)
- [@faruryo](https://github.com/faruryo)
- [@houshengbo](https://github.com/houshengbo)
- [@itsmurugappan](https://github.com/itsmurugappan)
- [@julz](https://github.com/julz)
- [@Kaustubh-pande](https://github.com/Kaustubh-pande)
- [@lionelvillard](https://github.com/lionelvillard)
- [@markusthoemmes](https://github.com/markusthoemmes)
- [@matejvasek](https://github.com/matejvasek)
- [@n3wscott](https://github.com/n3wscott)
- [@pierDipi](https://github.com/pierDipi)
- [@slinkydeveloper](https://github.com/slinkydeveloper)
- [@vagababov](https://github.com/vagababov)
- [@vaikas](https://github.com/vaikas)
- [@zhaojizhuang](https://github.com/zhaojizhuang)
- [@ZhiminXiang](https://github.com/ZhiminXiang)


### Learn more

Knative is an open source project that anyone in the [community](https://knative.dev/docs/community/) can use, improve, and enjoy. We'd love you to join us!

- [Welcome to Knative](https://knative.dev/docs#welcome-to-knative)
- [Getting started documentation](https://knative.dev/docs/#getting-started)
- [Samples and demos](https://knative.dev/docs#samples-and-demos)
- [Knative meetings and work groups](https://knative.dev/contributing/#working-group)
- [Questions and issues](https://knative.dev/contributing/#questions-and-issues)
- [Knative User Mailing List](https://groups.google.com/forum/#!forum/knative-users)
- [Knative Development Mailing List](https://groups.google.com/forum/#!forum/knative-dev)
- Knative on Twitter [@KnativeProject](https://twitter.com/KnativeProject)
- Knative on [StackOverflow](https://stackoverflow.com/questions/tagged/knative)
- Knative [Slack](https://slack.knative.dev)
- Knative on [YouTube](https://www.youtube.com/channel/UCq7cipu-A1UHOkZ9fls1N8A)
