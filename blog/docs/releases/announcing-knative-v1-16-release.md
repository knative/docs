---
title: "v1.16 release"
linkTitle: "v1.16 release"
author: "[[David Simansky (Red Hat)](https://github.com/dsimansk), [Reto Lehmann (Red Hat)](https://github.com/ReToCode), [Stavros Kontopoulos (Red Hat)](https://github.com/skonto), "
author handle: https://github.com/dsimansk https://github.com/ReToCode https://github.com/skonto

date: 2024-10-24
description: "Knative v1.16 release announcement"
type: "blog"
---

# Announcing Knative 1.16 Release

A new version of Knative is now available across multiple components. Follow the instructions in [Installing Knative](https://knative.dev/docs/install/) to install the components you require.

This release brings a number of smaller improvements to the core Knative Serving and Eventing components, and several improvements to specific plugins.

## Table of Contents
- [Serving](#serving)
- [Eventing](#eventing)
- [kn CLI](#kn-cli)
- [Functions](#functions)
- [Knative Operator](#knative-operator)

### Serving
**Release Notes:** [Knative Serving 1.16](https://github.com/knative/serving/releases/tag/knative-v1.16.0)

#### 💫 New Features & Changes
- Allow hostPID, hostNetwork and HostIPC to be set for a Knative Service (feature flags: kubernetes.podspec-hostpid, kubernetes.podspec-hostnetwrok, kubernetes.podspec-hostipc). All features are disabled by default. ([#15414](https://github.com/knative/serving/pull/15414), @skonto)
- Support s390x/ppc when building our controllers ([#15407](https://github.com/knative/serving/pull/15407), @dprotaso)

#### 🐞 Bug Fixes
- Fixes Bug preventing the correct configuration of cert manager ([#15434](https://github.com/knative/serving/pull/15434), @mstein11)

### Eventing
**Release Notes:** [Knative Eventing 1.16](https://github.com/knative/eventing/releases/tag/knative-v1.16.0)

#### 💫 New Features & Changes
- Disable controller default health probes in the IMC dispatcher ([#8125](https://github.com/knative/eventing/pull/8125), @pierDipi)
- EventPolicy resources now support using SubscriptionsAPI filters at ingress. ([#8122](https://github.com/knative/eventing/pull/8122), @Cali0707)
- Set UID in Brokers backing channels EventPolicies OwnerReference([#8143](https://github.com/knative/eventing/pull/8143), @creydr)
- InMemoryChannel ingress: Reject unauthorized requests ([#8162](https://github.com/knative/eventing/pull/8162), @creydr)
- JobSink: Reject unauthorized requests ([#8169](https://github.com/knative/eventing/pull/8169), @creydr)
- Mt-broker-filter: Allow only requests from Triggers Subscriptions OIDC ID ([#8147](https://github.com/knative/eventing/pull/8147), @creydr)
- Reconcile EventPolicies for Parallel's channel. ([#8112](https://github.com/knative/eventing/pull/8112), @rahulii)
- The OIDC discovery url is now configurable with the oidc-discovery-base-url feature flag in the config-features configmap. ([#8145](https://github.com/knative/eventing/pull/8145), @Cali0707)
- Triggers referencing MTChannelBased Brokers now support the Delivery Format option ([#8151](https://github.com/knative/eventing/pull/8151), @Cali0707)
- Make auth package indepent from eventpolicy informer ([#8195](https://github.com/knative/eventing/pull/8195), @creydr)

### Client
**Release Notes:** [Knative Client 1.16](https://github.com/knative/client/releases/tag/knative-v1.16.0)

#### 💫 New Features & Changes
- Refactor codegen to use kube_codegen.sh script ([#1964](https://github.com/knative/client/pull/1964), @dsimansk)
- The knative.dev/client-pkg package is now deprecated in favor of the knative.dev/client/pkg package. ([#1953](https://github.com/knative/client/pull/1953), @cardil)

### Functions
**Release Notes:** [Knative func 1.16](https://github.com/knative/func/releases/tag/knative-v1.16.0)

#### 💫 New Features & Changes
- Feat: enabled on-cluster s2i build for Go ([#2471](https://github.com/knative/func/pull/2471), @matejvasek)

#### 🐞 Bug Fixes
- Fixes a bug where registries could sometimes not specify port ([#2510](https://github.com/knative/func/pull/2510), @lkingland)
- test: preventing dubios ownership repository error on git unit tests ([#2499](https://github.com/knative/func/pull/2499), @jrangelramos)
- Fix: Go functions fails to build using S2I on Windows ([#2535](https://github.com/knative/func/pull/2535), @matejvasek)

### Operator
**Release Notes:** [Knative Operator 1.16](https://github.com/knative/operator/releases/tag/knative-v1.16.0)

#### 💫 New Features & Changes
- Feature: Istio Gateway can be configured with automatic HTTP->HTTPS redirection ([#1912](https://github.com/knative/operator/pull/1912), @houshengbo)
- Statefulset kafka dispatcher have a managed scaling via kafka controller, hence we ignore replica on those ([#1889](https://github.com/knative/operator/pull/1889), @matzew)


## Thank you, contributors
**Release Leads:**

- [@dsimansk](https://github.com/dsimansk)

- [@ReToCode](https://github.com/ReToCode)

- [@skonto](https://github.com/skonto)


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
