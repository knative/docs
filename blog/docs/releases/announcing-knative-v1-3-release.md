---
title: "v1.3 release"
linkTitle: "v1.3 release"
Author: "Samia Nneji"
Author handle: https://github.com/snneji
date: 2022-03-08
description: "Knative v1.3 release announcement"
type: "blog"
---

## Announcing Knative v1.3 Release

A new version of Knative is now available across multiple components.

Follow the instructions in the documentation
[Installing Knative](https://knative.dev/docs/install/) for the respective component.

## Table of Contents

- [Highlights](#highlights)
- [Serving v1.3](#serving-v13)
- [Eventing v1.3](#eventing-v13)
- [Eventing Extensions](#eventing-extensions)
    - [Apache Kafka Broker v1.3](#apache-kafka-broker-v13)
    - [RabbitMQ Broker and Source v1.3](#rabbitmq-broker-and-source-v13)
- `kn` [CLI v1.3](#client-v13)
- [Knative Operator v1.3](#operator-v13)
- [Thank you contributors](#thank-you-contributors)


## Highlights

- TODO: Add list of highlights for the release


## Serving v1.3

<!-- Original notes are here: https://github.com/knative/serving/releases/tag/knative-v1.3.0 -->

## 🚨 Breaking or Notable Changes

- Dropped the alpha field `RevisionSpec.MaxDurationSeconds` in favour of fixing the behavior of the existing `Timeout` field. ([#12635](https://github.com/knative/serving/pull/12635))


### 💫 New Features & Changes

- Allow the readiness probe port to be different than the user container port. ([#12606](https://github.com/knative/serving/pull/12606))
- `net-certmanager` starts testing cert-manager v1.7.1. ([#12605](https://github.com/knative/serving/pull/12605))

### 🐞 Bug Fixes

- Bump prometheus/client_golang to v1.11.1 in order to address [CVE-2022-21698](https://github.com/advisories/GHSA-cg3q-j54f-5p7p). ([#12653](https://github.com/knative/serving/pull/12653))
- Ensure the activator drains properly and the autoscaler rolls out conservatively.
This helps to avoid hitting 503 errors during upgrade. ([#12617](https://github.com/knative/serving/pull/12617))
- Fix an activator crash that could disrupt traffic (503). ([#12679](https://github.com/knative/serving/pull/12679))
- Fix the tag to digest resolution when the registry credential is in a Kubernetes secret. ([#12655](https://github.com/knative/serving/pull/12655))
- Provides more detailed error messages for invalid values of `autoscaling.knative.dev/initial-scale`. ([#12704](https://github.com/knative/serving/pull/12704))
- Remove an unnecessary start delay when resolving a tag to digest. ([#12668](https://github.com/knative/serving/pull/12668))
- Switches selectors for Knative resources to use the recommended `app.kubernetes.io` labels. ([#12587](https://github.com/knative/serving/pull/12587))
- The validating webhook returns a more accurate error for invalid `autoscaling.knative.dev/target` values. ([#12698](https://github.com/knative/serving/pull/12698))
- Updates serving configmap validating webhook to use an objectSelector to reduce unnecessary webhook invocations. ([#12612](https://github.com/knative/serving/pull/12612))

## Eventing v1.3

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/knative-v1.3.0 -->

### 🚨 Breaking or Notable Changes

- TODO: Add any breaking or notable changes

### 💫 New Features & Changes

- TODO: Add new features and changes here

### 🐞 Bug Fixes

- TODO: Add bugs here

## Eventing Extensions

### Apache Kafka Broker v1.3

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka-broker/releases/tag/knative-v1.3.0 -->

#### 💫 New Features & Changes

- TODO: Add new features and changes here

#### 🐞 Bug Fixes

- TODO: Add bugs here

### RabbitMQ Broker and Source v1.3

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-rabbitmq/releases/tag/knative-v1.3.0 -->

#### 💫 New Features & Changes

- Add publisher confirms to ingress. Return HTTP Status 200 only when RabbitMQ confirms receiving and storing the message. See issue [#334](https://github.com/knative-sandbox/eventing-rabbitmq/issues/334). ([#568](https://github.com/knative-sandbox/eventing-rabbitmq/pull/568))
- The Source Adapter and Broker Dispatcher's Prefetch Count behavior is the same. Updated the Trigger's webhook to validate:
    - Has a default value of 1. FIFO behavior
    - Have limits: 1 ≤ prefetchCount ≤ 1000 ([#536](https://github.com/knative-sandbox/eventing-rabbitmq/pull/536))
- All core Knative Eventing RabbitMQ pods should now be able to run in the restricted pod security standard profile. ([#541](https://github.com/knative-sandbox/eventing-rabbitmq/pull/541))
- Various refactorings and code health improvements. ([#552](https://github.com/knative-sandbox/eventing-rabbitmq/pull/552), [#572](https://github.com/knative-sandbox/eventing-rabbitmq/pull/572))
- Makefile-based worklow, includes migrating GitHub Actions. ([#525](https://github.com/knative-sandbox/eventing-rabbitmq/pull/525), [#569](https://github.com/knative-sandbox/eventing-rabbitmq/pull/569), [#579](https://github.com/knative-sandbox/eventing-rabbitmq/pull/579))
- Improved Broker and Source README docs and Samples description and files. ([#555](https://github.com/knative-sandbox/eventing-rabbitmq/pull/555))


#### 🐞 Bug Fixes

- Removing the dead letter sink on a trigger will now properly fall back to the Broker's dead letter sink, if one is defined. ([#533](https://github.com/knative-sandbox/eventing-rabbitmq/pull/533))
- Configuring messages sent into the RabbitMQ Broker to be persistent as the Queues used by the Broker are always durable.
Now if the user set the configuration of the RabbitMQ Source Exchange and Queue to be durable, the messages are also durable. ([#560](https://github.com/knative-sandbox/eventing-rabbitmq/pull/560))


## Client v1.3

<!-- Original notes are here: https://github.com/knative/client/blob/main/CHANGELOG.adoc#v130-2022-03-08 -->

### 💫 New Features & Changes

- Add Knative Eventtype support. ([#1598](https://github.com/knative/client/pull/1598))

### 🐞 Bug Fixes

- Fix traffic split auto-redirection to only consider the active revisions. ([#1617](https://github.com/knative/client/pull/1617))
- Fix missing Azure auth provider. ([#1616](https://github.com/knative/client/pull/1616))
- Remove hardcoded `kn` for usage and error. ([#1603](https://github.com/knative/client/pull/1603)) 
- Fix display version of Serving and Eventing. ([#1601](https://github.com/knative/client/pull/1601))


## Operator v1.3

<!-- Original notes are here: https://github.com/knative/operator/releases/tag/knative-v1.3.0   -->

### 💫 New Features & Changes

- TODO: Add new features and changes here

### 🐞 Bug Fixes

- TODO: Add bugs here

## Thank you, contributors

Release leads:

- [@carlisia](https://github.com/carlisia)
- [@kvmware](https://github.com/kvmware)
- [@xtreme-sameer-vohra](https://github.com/xtreme-sameer-vohra)

Contributors:

- [@benmoss](https://github.com/benmoss)
- [@ChunyiLyu](https://github.com/ChunyiLyu)
- [@dprotaso](https://github.com/dprotaso)
- [@dsimansk](https://github.com/dsimansk)
- [@gabo1208](https://github.com/gabo1208)
- [@gvmw](https://github.com/gvmw)
- [@ikvmw](https://github.com/ikvmw)
- [@itsmurugappan](https://github.com/itsmurugappan)
- [@izabelacg](https://github.com/izabelacg)
- [@kobayashi](https://github.com/kobayashi)
- [@nak3](https://github.com/nak3)
- [@psschwei](https://github.com/psschwei)
- [@qu1queee](https://github.com/qu1queee)
- [@vyasgun](https://github.com/vyasgun)

## Learn more

Knative is an open source project that anyone in the [community](https://knative.dev/docs/community/) can use, improve, and enjoy. We'd love you to join us!

- [Knative docs](https://knative.dev/docs)
- [Quickstart documentation](https://knative.dev/docs/getting-started)
- [Samples](https://knative.dev/docs/samples)
- [Knative working groups](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md)
- [Knative User Mailing List](https://groups.google.com/forum/#!forum/knative-users)
- [Knative Development Mailing List](https://groups.google.com/forum/#!forum/knative-dev)
- Knative on Twitter [@KnativeProject](https://twitter.com/KnativeProject)
- Knative on [StackOverflow](https://stackoverflow.com/questions/tagged/knative)
- Knative [Slack](https://slack.knative.dev)
- Knative on [YouTube](https://www.youtube.com/channel/UCq7cipu-A1UHOkZ9fls1N8A)
