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

- TODO: Add any breaking or notable changes, using format `TEXT ([#PR-NUMBER](PR-URL))`

### 💫 New Features & Changes

- TODO: Add new features and changes here

### 🐞 Bug Fixes

- TODO: Add bugs here

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

### 💫 New Features & Changes

- TODO: Add new features and changes here

### 🐞 Bug Fixes

- TODO: Add bugs here

### RabbitMQ Broker and Source v1.3

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-rabbitmq/releases/tag/knative-v1.3.0 -->


### 💫 New Features & Changes

- TODO: Add new features and changes here

### 🐞 Bug Fixes

- TODO: Add bugs here

## Client v1.3

<!-- Original notes are here: https://github.com/knative/client/blob/main/CHANGELOG.adoc#v130-2022-03-08 -->

### 💫 New Features & Changes

- Add Knative Eventtype support. ([#1598](https://github.com/knative/client/pull/1598))

### 🐞 Bug Fixes

- Fix traffic split auto-redirection to only consider the active revisions. ([#1617](https://github.com/knative/client/pull/1617))
- Fix missing Azure auth provider. ([#1616](https://github.com/knative/client/pull/1616))
- Remove hardcoded `kn` for usage and error. ([#1603](https://github.com/knative/client/pull/1603)) <!-- Tell CLI team to update link in changelog. -->
- Fix display version of Serving and Eventing. ([#1601](https://github.com/knative/client/pull/1601))


## Operator TODO-KNATIVE-VERSION

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

- [@dsimansk](https://github.com/dsimansk)
- [@itsmurugappan](https://github.com/itsmurugappan)
- [@kobayashi](https://github.com/kobayashi)
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
