---
title: "v0.23 release"
linkTitle: "v0.23 release"
Author: "[Carlos Santana](https://twitter.com/csantanapr)"
Author handle: https://github.com/csantanapr
date: 2021-05-18
description: "Knative v0.23 release announcement"
type: "blog"
image: knative-eventing.png
---


### Announcing Knative v0.23 Release

A new version of Knative is now available across multiple components.
Follow the instructions in the documentation [Installing Knative](https://knative.dev/docs/install/) for the respective component.

#### Table of Contents
- [Serving v0.23](#serving-v023)
- [Eventing v0.23](#eventing-v023)
- Eventing Extensions
    - [Apache Kafka Broker v0.23](#apache-kafka-broker-v023)
    - [RabbitMQ Eventing v0.23](#rabbitmq-eventing-v023)
- `kn` [CLI v0.23](#client-v023)
- [Operator v0.23](#operator-v023)
- [Thank you contributors](#thank-you-contributors)



### Highlights

- Serving improves support for Istio when using Mesh to access the user container directly
- Eventing removes old API version only leaving `v1` as the one available
- The `kn` CLI and Operator keeps crushing bugs in this release.



### Serving v0.23

<!-- Original notes are here: https://github.com/knative/serving/releases/tag/v0.23.0 -->

#### 🚨 Breaking or Notable Changes

- Change the default post-install job to use sslip.io rather than xip.io. [#11298](https://github.com/knative/serving/pull/11298)

#### 💫 New Features & Changes

- The stats scraping in the autoscaler is now sensitive to the `EnableMeshPodAddressability` setting. A restart of the autoscaler is required for the setting to take effect if changed. [#11161](https://github.com/knative/serving/pull/11161)
- The state keeping in the activator is now sensitive to the `EnableMeshPodAddressability` setting. A restart of the activator is required for the setting to take effect if changed. [#11172](https://github.com/knative/serving/pull/11172)
- Tightens the heuristic for mesh being enabled in the service scraper. We now expect all errors to be related to mesh (i.e. 503 status code). This prevents accidentally falling in to service scrape mode when errors are encountered for other reasons. [#11174](https://github.com/knative/serving/pull/11174)

#### 🐞 Bug Fixes

- Added schemas to all CRDs. [#11244](https://github.com/knative/serving/pull/11244)
- Changed the rollout behavior of application deployment changes (due to Knative upgrade for example) to never have less ready posd than required. [#11140](https://github.com/knative/serving/pull/11140)
- Rate limits digest resolution (10 QPS, retry back-off 1s to 1000s) to prevent exceeding quota at remote registries [#11279](https://github.com/knative/serving/pull/11279)
- Revision replicas now shut down 15 seconds faster. [#11249](https://github.com/knative/serving/pull/11249)
- The activator proxy now recognizes the `EnableMeshPodAddressability` setting. [#11162](https://github.com/knative/serving/pull/11162)
- Update the User-Agent used during tag resolution [#10590](https://github.com/knative/serving/pull/10590)


### Eventing v0.23

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/v0.23.1 -->

#### 🚨 Breaking or Notable Changes

- Remove {`eventing`,`flows`,`messaging`} `v1beta1` APIs [#5201](https://github.com/knative/eventing/pull/5201)
- Promote PingSource to v1 [#5324](https://github.com/knative/eventing/pull/5324)
- Remove `APIServerSource`, `ContainerSource`, `PingSource` and `SinkBinding` v1alpha2 APIs [#5318](https://github.com/knative/eventing/pull/5318)
- Remove `APIServerSource`, `ContainerSource`, `PingSource` and `SinkBinding` v1beta1 APIs [#5319](https://github.com/knative/eventing/pull/5319)
- Remove `APIServerSource` and `SinkBinding` v1alpha1 APIs [#5317](https://github.com/knative/eventing/pull/5317)

#### 💫 New Features & Changes

- InMemoryChannel can now be used independently of Knative Eventing, and can be installed by applying the `in-memory-channel.yaml`. [#5355](https://github.com/knative/eventing/pull/5355)
- Multi-tenant, channel-based brokers now have improved filter performance for Triggers with few or no filters. [#5288](https://github.com/knative/eventing/pull/5355)

#### 🐞 Bug Fixes

- `duckv1.SourceSpec`, `TimeZone`, `Schedule` will be populated when called by `v1beta1/v1alpha2` clients [#5153](https://github.com/knative/eventing/pull/5153)
- The Trigger `delivery` spec is now automatically propagated to Subscriptions that are connected to multi-tenant, channel-based Brokers. [#5267](https://github.com/knative/eventing/pull/5267)



#### 🧹 Clean up

- Tools from the [`eventing-contrib` repository](https://github.com/knative/eventing-contrib/tree/main/cmd) have now been moved to the `eventing` repository. [#5295](https://github.com/knative/eventing/pull/5295)
- Sequence now displays conditions as `Unknown` rather than `False` for non-terminal condition states. [#5369](https://github.com/knative/eventing/pull/5369)
- Running validation for event ingress on multi-tenant broker [#5275](https://github.com/knative/eventing/pull/5275)


### Eventing Extensions


#### Apache Kafka Broker v0.23

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka-broker/releases/tag/v0.23.0 -->


#### 💫 New Features & Changes

- In Kafka Broker, now the Kafka producer will wait for all ISR replicas ack. [#824](https://github.com/knative-sandbox/eventing-kafka-broker/pull/824)
- In Kafka Sink, now the Kafka producer will wait for all ISR replicas ack. [#827](https://github.com/knative-sandbox/eventing-kafka-broker/pull/827)

#### 🐞 Bug Fixes

- Fix out of bounds in unordered offset manager. [#814](https://github.com/knative-sandbox/eventing-kafka-broker/pull/814)
- Accept "PLAIN" as a valid sasl.mechanism secret value. [#855](https://github.com/knative-sandbox/eventing-kafka-broker/pull/855),[#840](https://github.com/knative-sandbox/eventing-kafka-broker/pull/840)


#### RabbitMQ Eventing v0.23

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-rabbitmq/releases/tag/v0.23.0 -->

#### 🚨 Breaking or Notable Changes

- requires [messaging-topology-operator](https://github.com/rabbitmq/messaging-topology-operator) version `v0.8.0` to be installed as well as [cluster-operator](https://github.com/rabbitmq/cluster-operator) version `v1.6.0`

#### 🐞 Bug Fixes

- Conformance tests for Broker now work
- If a Broker / Trigger is deleted but there's no secret to talk to the rabbit cluster, we now remove the resources and log that rabbitmq resources might have been leaked. This happens only when not using the Rabbit Cluster Operator. This left undeletable resources, so this change seems more user friendly. [#271](https://github.com/knative-sandbox/eventing-rabbitmq/pull/271)

### Client v0.23

<!-- Original notes are here: https://github.com/knative/client/blob/main/CHANGELOG.adoc#v0230-2021-05-18 -->

#### 💫 New Features & Changes

- Update Eventing Sources APIServerSource, ContainerSource, SinkBinding API to v1. [#1299](https://github.com/knative/client/pull/1299)
- Update Eventing Source PingSource API to v1beta2. [#1299](https://github.com/knative/client/pull/1299)
- Add number of instances to describe command. [#1289](https://github.com/knative/client/pull/1289)

#### 🐞 Bug Fixes

- Fix for serviceaccounts "default" not found flaky issue. [#1312](https://github.com/knative/client/pull/1312)
- Fix number of instances *int32 type in describe commands. [#1312](https://github.com/knative/client/pull/1312)
- Use fully qualified test images. [#1307](https://github.com/knative/client/pull/1307)
- Fix documentation of the configuration options. [#1297](https://github.com/knative/client/pull/1297)
- Respect -o in list commands in case if no data present. [#1276](https://github.com/knative/client/pull/1276)


### Operator v0.23

<!-- Original notes are here: https://github.com/knative/operator/releases/tag/v0.23.0 -->

#### 🐞 Bug Fixes

- Apply high availability settings to kourier as well. [#579](https://github.com/knative/operator/pull/579)
- Clear OwnerReferences on knative-local-gateway Service. [#567](https://github.com/knative/operator/pull/567)
- Set the namespace of the service knative-local-gateway to the istio namespace. [#590](https://github.com/knative/operator/pull/590)
- Add pingsource-mt-adapter into HA list. [#591](https://github.com/knative/operator/pull/591)
- Return an actual newest version of the directory latest is not available. [#576](https://github.com/knative/operator/pull/576)
- Allow for all Ingresses to be disabled. [#571](https://github.com/knative/operator/pull/571)

#### 🧹 Clean up

- Simplify Istio installation for end-to-end test. [#564](https://github.com/knative/operator/pull/564)
- Use he Kourier deployment namespace to determine Kourier's gateway namespace. [#577](https://github.com/knative/operator/pull/577)
- Updated the Knative Serving upgrade tests script. [#574](https://github.com/knative/operator/pull/574)


### Thank you contributors

- [@@matzew](https://github.com/matzew)
- [@benmoss](https://github.com/benmoss)
- [@dsimansk](https://github.com/dsimansk)
- [@eclipselu](https://github.com/eclipselu)
- [@evidolob](https://github.com/evidolob)
- [@houshengbo](https://github.com/houshengbo)
- [@jonjohnsonjr](https://github.com/jonjohnsonjr)
- [@julz](https://github.com/julz)
- [@lionelvillard](https://github.com/lionelvillard)
- [@markusthoemmes](https://github.com/markusthoemmes)
- [@mgencur](https://github.com/mgencur)
- [@n3wscott](https://github.com/n3wscott)
- [@nak3](https://github.com/nak3)
- [@pierDipi](https://github.com/pierDipi)
- [@polivbr](https://github.com/polivbr)
- [@pratham-m](https://github.com/pratham-m)
- [@rhuss](https://github.com/rhuss)
- [@slinkydeveloper](https://github.com/slinkydeveloper)
- [@vaikas](https://github.com/vaikas)



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
