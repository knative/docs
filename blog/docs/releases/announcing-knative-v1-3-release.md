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

Follow the instructions in
[Installing Knative](https://knative.dev/docs/install/) to install the components you require.

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

- The readiness probe port can now be different than the user container port.
- `net-certmanager` is now testing cert-manager v1.7.1.
- Various improvements and bug fixes for Eventing.
- The `kn` CLI has added Knative `eventtype` support.
- The Knative Operator has enabled v1beta1 API.

## Serving v1.3

<!-- Original notes are here: https://github.com/knative/serving/releases/tag/knative-v1.3.0 -->

### 🚨 Breaking or Notable Changes

- Dropped the alpha field `RevisionSpec.MaxDurationSeconds` in favour of fixing the behavior of the existing `Timeout` field. ([#12635](https://github.com/knative/serving/pull/12635))


### 💫 New Features & Changes

- Allows the readiness probe port to be different than the user container port. ([#12606](https://github.com/knative/serving/pull/12606))
- `net-certmanager` starts testing cert-manager v1.7.1. ([#12605](https://github.com/knative/serving/pull/12605))

### 🐞 Bug Fixes

- Bumped prometheus/client_golang to v1.11.1 in order to address [CVE-2022-21698](https://github.com/advisories/GHSA-cg3q-j54f-5p7p). ([#12653](https://github.com/knative/serving/pull/12653))
- Ensure the activator drains properly and the autoscaler rolls out conservatively.
This helps to avoid hitting 503 errors during upgrade. ([#12617](https://github.com/knative/serving/pull/12617))
- Fixed an activator crash that could disrupt traffic (503). ([#12679](https://github.com/knative/serving/pull/12679))
- Fixed the tag to digest resolution when the registry credential is in a Kubernetes secret. ([#12655](https://github.com/knative/serving/pull/12655))
- Provides more detailed error messages for invalid values of `autoscaling.knative.dev/initial-scale`. ([#12704](https://github.com/knative/serving/pull/12704))
- Removed an unnecessary start delay when resolving a tag to digest. ([#12668](https://github.com/knative/serving/pull/12668))
- Switches selectors for Knative resources to use the recommended `app.kubernetes.io` labels. ([#12587](https://github.com/knative/serving/pull/12587))
- The validating webhook returns a more accurate error for invalid `autoscaling.knative.dev/target` values. ([#12698](https://github.com/knative/serving/pull/12698))
- Updates serving configmap validating webhook to use an objectSelector to reduce unnecessary webhook invocations. ([#12612](https://github.com/knative/serving/pull/12612))


## Eventing v1.3

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/knative-v1.3.1 -->

### 🚨 Breaking or Notable Changes

- The sql field of the [new trigger filters](https://knative.dev/docs/eventing/experimental-features/new-trigger-filters/) experimental feature is now called cesql. ([#6148](https://github.com/knative/eventing/pull/6148))

### 💫 New Features & Changes

- Added missing Kubernetes labels to post install manifests. ([#6184](https://github.com/knative/eventing/pull/6184))
- Set dead letter sink URI in the Channel status. ([#6261](https://github.com/knative/eventing/pull/6261))
- `SubscriptionSpec.Delivery` is now mutable. ([#6139](https://github.com/knative/eventing/pull/6139))

### 🐞 Bug Fixes

- When the new-trigger-filters experimental feature is enabled, a bug was fixed where some invalid CE SQL expressions caused the Eventing webhook to crash. Now, those expressions will be considered invalid and the webhook will continue functioning normally. ([#6140](https://github.com/knative/eventing/pull/6140))


## Eventing Extensions

### Apache Kafka Broker v1.3

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka-broker/releases/tag/knative-v1.3.1 -->

#### 💫 New Features & Changes

- Shows an error in the Broker and Channel status when resolving sink failures. ([#1833](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1833))
- Added KafkaSource migration logic as a post-install job (`eventing-kafka-post-install.yaml`). ([#1889](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1889))
- Added Storage-Version-Migrator for KafkaSource and KafkaChannel. ([#1869](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1869))
- KafkaChannel is now conformant with the spec. Conformance tests are now run with every code change. ([#1825](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1825))

#### 🐞 Bug Fixes

- Added support for Brokers with long namespace and name values. ([#1971](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1971))
- KafkaChannel reconciler checks for empty subscriber URI. ([#1905](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1905))

#### Known issues

- The reference information for metrics is not built successfully for Kafka channels. ([#1824](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1824))

### RabbitMQ Broker and Source v1.3

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-rabbitmq/releases/tag/knative-v1.3.1 -->

#### 💫 New Features & Changes

- Broker URLs updated to be `http://<broker-URL>/<namespace>/<broker-name>`. ([#587](https://github.com/knative-sandbox/eventing-rabbitmq/pull/587))
- Short testing guide for contributors, converting from `.env` -> to `(direnv friendly).envrc` environment files. ([#599](https://github.com/knative-sandbox/eventing-rabbitmq/pull/599))

## Client v1.3

<!-- Original notes are here: https://github.com/knative/client/blob/main/CHANGELOG.adoc#v130-2022-03-08 -->

### 💫 New Features & Changes

- Added Knative eventtype support. ([#1598](https://github.com/knative/client/pull/1598))

### 🐞 Bug Fixes

- Fixed traffic split auto-redirection to only consider the active revisions. ([#1617](https://github.com/knative/client/pull/1617))
- Fixed missing Azure auth provider. ([#1616](https://github.com/knative/client/pull/1616))
- Removed the hardcoded `kn` for usage and error. ([#1603](https://github.com/knative/client/pull/1603))
- Fixed the display version of Serving and Eventing. ([#1601](https://github.com/knative/client/pull/1601))


## Operator v1.3

<!-- Original notes are here: https://github.com/knative/operator/releases/tag/knative-v1.3.1   -->

### 💫 New Features & Changes

- Refactored the common functions for the APIs for the API transition. ([#941](https://github.com/knative/operator/pull/941))
- Added v1beta1 API into the Knative Operator. ([#945](https://github.com/knative/operator/pull/945))
- Added the conversion function for v1alpha1 and v1beta1. ([#948](https://github.com/knative/operator/pull/948))
- Added conversion webhook module. ([#936](https://github.com/knative/operator/pull/936))
- Enabled v1beta1 APIs. ([#968](https://github.com/knative/operator/pull/968))
- Promoted v1beta1 as the storage version. ([#969](https://github.com/knative/operator/pull/969))

### 🐞 Bug Fixes

- Keep the default image name the same as the original. ([#958](https://github.com/knative/operator/pull/958))


## Thank you, contributors

Release leads:

- [@carlisia](https://github.com/carlisia)
- [@kvmware](https://github.com/kvmware)
- [@xtreme-sameer-vohra](https://github.com/xtreme-sameer-vohra)

Contributors:

- [@aliok](https://github.com/aliok)
- [@benmoss](https://github.com/benmoss)
- [@ChunyiLyu](https://github.com/ChunyiLyu)
- [@dprotaso](https://github.com/dprotaso)
- [@devguyio](https://github.com/devguyio)
- [@dsimansk](https://github.com/dsimansk)
- [@gabo1208](https://github.com/gabo1208)
- [@gab-satchi](https://github.com/gab-satchi)
- [@gvmw](https://github.com/gvmw)
- [@houshengbo](https://github.com/houshengbo)
- [@ikvmw](https://github.com/ikvmw)
- [@itsmurugappan](https://github.com/itsmurugappan)
- [@izabelacg](https://github.com/izabelacg)
- [@kobayashi](https://github.com/kobayashi)
- [@matzew](https://github.com/matzew)
- [@nak3](https://github.com/nak3)
- [@pierDipi](https://github.com/pierDipi)
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
