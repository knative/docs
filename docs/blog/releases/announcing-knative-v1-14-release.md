---
title: "v1.14 release"
linkTitle: "v1.14 release"
author: "[Izabela Gomes (Broadcom)](https://github.com/izabelacg), [David Simansky (Red Hat)](https://github.com/dsimansk), [Calum Murray (Red Hat)](https://github.com/Cali0707), [Christoph Stäbler (Red Hat)](https://github.com/creydr)"
author handle: https://github.com/izabelacg https://github.com/dsimansk https://github.com/Cali0707 https://github.com/creydr

date: 2024-5-3
description: "Knative v1.14 release announcement"
type: "blog"
---

# Announcing Knative 1.14 Release

A new version of Knative is now available across multiple components. Follow the instructions in [Installing Knative](https://knative.dev/docs/install/) to install the components you require.

This release brings a number of smaller improvements to the core Knative Serving and Eventing components, and several improvements to specific plugins.

## Table of Contents
- [Serving](#serving)
- [Eventing](#eventing)
- [kn CLI](#kn-cli)
- [Functions](#functions)
- [Knative Operator](#knative-operator)

### Serving
**Release Notes:** [Knative Serving 1.14](https://github.com/knative/serving/releases/tag/knative-v1.14.0)

#### 💫 New Features & Changes
- A new feature (`multi-container-probing`) is introduced to enable liveness and readiness probes for Knative Services with multiple containers ([#14853](https://github.com/knative/serving/pull/14853), @ReToCode)
- Add support for multiple wildcard certificate domains in domain config ([#14543](https://github.com/knative/serving/pull/14543), @arsenetar)
- Certificate generation errors are bubbled up to its parent Route. ([#14962](https://github.com/knative/serving/pull/14543), @ckcd)
- Check all container's status when calculating revision ContainerHealthy condition ([#14744](https://github.com/knative/serving/pull/14744), @seongpyoHong)
- Serving now supports the experimental feature `cluster-local-domain-tls` and creates the necessary `KnativeCertificates` ([#14610](https://github.com/knative/serving/pull/14610), @ReToCode)
- The autoscaler now keeps the desiredScale of a PodAutoscaler at its current value while it initializes and therefore has not yet metrics ([#14866](https://github.com/knative/serving/pull/14866), @SaschaSchwarze0)
- Don't drop traffic when upgrading a deployment fails ([#14795](https://github.com/knative/serving/pull/14795), @dprotaso)
- Add upstream TLS trust from CM bundles ([#14717](https://github.com/knative/serving/pull/14717), @ReToCode)
- Make route domain error specific ([#15082](https://github.com/knative/serving/pull/15082), @skonto)

### Eventing
**Release Notes:** [Knative Eventing 1.14](https://github.com/knative/eventing/releases/tag/knative-v1.14.0)

#### 💫 New Features & Changes
- EventType Autocreate is now a non blocking operation ([#7709](https://github.com/knative/eventing/pull/7709), @Cali0707)
- EventTypes are now autocreated on Triggers and Subscriptions when there is a reply event sent to them ([#7733](https://github.com/knative/eventing/pull/7733), @Cali0707)
- Added the ability to configure a `nodeSelector` when deploying an ApiServerSource ([#7584](https://github.com/knative/eventing/pull/7584), @sadath-12)
- Replace YAML merge tags, to comply with YAML 1.2 ([#7662](https://github.com/knative/eventing/pull/7662), @converge)
- StatefulSet scheduling now makes fewer API server requests, reducing APIServer load. ([#7651](https://github.com/knative/eventing/pull/7651), @Cali0707)

#### 🐞 Bug Fixes
- Reduce the scope for the Config validation webhook to only the `knative-eventing` namespace. ([#7792](https://github.com/knative/eventing/pull/7792), @pierDipi)

### Client
**Release Notes:** [Knative Client 1.14](https://github.com/knative/client/releases/tag/knative-v1.14.0)

#### 💫 New Features & Changes
- Add completion support for fish and PowerShell shells ([#1929](https://github.com/knative/client/pull/1929), @tuhtah)

#### 🐞 Bug Fixes

- Fix client-pkg import paths ([#1931](https://github.com/knative/client/pull/1931), @dsimansk)
- Fix wait-loop in domain E2E test ([#1919](https://github.com/knative/client/pull/1919), @dsimansk)

### Functions
**Release Notes:** [Knative func 1.14](https://github.com/knative/func/releases/tag/knative-v1.14.0)

#### 💫 New Features & Changes

- Functions built with the experimental "Host" builder include FUNC_CREATED and FUNC_VERSION metadata environment variables. ([#2195](https://github.com/knative/func/pull/2195), @lkingland)

#### 🐞 Bug Fixes

- Func invoke now correctly handles data with contenttype application/json ([#2256](https://github.com/knative/func/pull/2256), @Cali0707)
- Fix: "no main packages to build" on darwin/aarch64 ([#2148](https://github.com/knative/func/pull/2148), @matejvasek)
- Func deploy --username=func --*** get password registry.example.com) ([#2242](https://github.com/knative/func/pull/2242), @lkingland)
- The prototype host builder now supports nonregular files such as symlinks ([#2156](https://github.com/knative/func/pull/2195), @lkingland)
- Fix typo in run cmd ([#2168](https://github.com/knative/func/pull/2168), @Sanket-0510)
- Update docs ([#2169](https://github.com/knative/func/pull/2169), @matzew)
- Bump go-func to v0.20.0 ([#2170](https://github.com/knative/func/pull/2170), @matzew)
- Remove discontinued tanzu builder image ([#2178](https://github.com/knative/func/pull/2178), @matzew)
- Using upstream lifecycle image that has multi-arch support ([#2196](https://github.com/knative/func/pull/2196), @matzew)
- Fix make was not called ([#2245](https://github.com/knative/func/pull/2245), @matzew)
- Usage of only proper handler API, no longer need for redundant Context ([#2249](https://github.com/knative/func/pull/2249), @matzew)


### Operator
**Release Notes:** [Knative Operator 1.14](https://github.com/knative/operator/releases/tag/knative-v1.14.0)

Only dependency update

## Thank you, contributors
**Release Leads:**

- [@izabelacg](https://github.com/izabelacg)

- [@dsimansk](https://github.com/dsimansk)

- [@Cali0707](https://github.com/Cali0707)

- [@creydr](https://github.com/creydr)

## Learn more
- [Knative docs](https://knative.dev/docs/)
- [Quickstart tutorial](https://knative.dev/docs/getting-started/)
- [Samples](https://knative.dev/docs/samples/)
- [Knative Working Groups](https://knative.dev/community/contributing/working-groups/)
- [Knative User Mailing List](https://groups.google.com/g/knative-users)
- [Knative Development Mailing List](https://groups.google.com/g/knative-dev)
- [Knative on Twitter @KnativeProject](https://twitter.com/KnativeProject)
- [Knative on StackOverflow](https://stackoverflow.com/questions/tagged/knative)
- [#knative on CNCF Slack](https://slack.knative.dev/)
- [Knative on YouTube](https://www.youtube.com/c/KnativeProject)
