---
title: "v1.13 release"
linkTitle: "v1.13 release"
author: "[Stavros Kontopoulos (Red Hat)](https://github.com/skonto), [Reto Lehmann (Red Hat)](https://github.com/ReToCode), [Pierangelo Di Pilato (Red Hat)](https://github.com/pierDipi), [David Simansky (Red Hat)](https://github.com/dsimansk), [Calum Murray (Red Hat)](https://github.com/Cali0707), [Leo Li (Red Hat)](https://github.com/Leo6Leo), [Christoph Stäbler (Red Hat)](https://github.com/creydr)"

author handle: https://github.com/skonto https://github.com/ReToCode https://github.com/pierDipi https://github.com/dsimansk https://github.com/Cali0707 https://github.com/Leo6Leo https://github.com/creydr

date: 2024-1-25
description: "Knative v1.13 release announcement"
type: "blog"
---

# Announcing Knative 1.13 Release

A new version of Knative is now available across multiple components. Follow the instructions in [Installing Knative](https://knative.dev/docs/install/) to install the components you require.

This release brings a number of smaller improvements to the core Knative Serving and Eventing components, and several improvements to specific plugins.

## Table of Contents
- [Serving](#serving)
- [Eventing](#eventing)
- [kn CLI](#kn-cli)
- [Functions](#functions)
- [Knative Operator](#knative-operator)

### Serving
**Release Notes:** [Knative Serving 1.13](https://github.com/knative/serving/releases/tag/knative-v1.13.0)

#### 💫 New Features & Changes
- Http1 full duplex is now supported. Workloads need to be annotated with `features.knative.dev/http-full-duplex`. ([#14568](https://github.com/knative/serving/pull/14568), [@skonto](https://github.com/skonto))
- Improved default-domain log output for Services with no LoadBalancer IP ([#14788](https://github.com/knative/serving/pull/14788), [@lou-lan](https://github.com/lou-lan))
- Removed `/tmp` and `/var/log` from reserved paths ([#14719](https://github.com/knative/serving/pull/14719), [@jacksgt](https://github.com/jacksgt))
- `AppProtocol` is now set to "kubernetes.io/h2c" on Services when applicable ([#14757](https://github.com/knative/serving/pull/14757) and [#14809](https://github.com/knative/serving/pull/14809), [@KauzClay](https://github.com/KauzClay))
- Add Vegeta rates/targets to SLA in performance tests ([#14429](https://github.com/knative/serving/pull/14429), [@xiangpingjiang](https://github.com/xiangpingjiang))

#### 🐞 Bug Fixes
- If global defaults for `revision-idle-timeout-seconds` & `revision-response-start-timeout-seconds` are now applied when creating a Revision. ([#14600](https://github.com/knative/serving/pull/14600), [@skonto](https://github.com/skonto))
- Deployment and ReplicaSet errors surface to the Knative Services status correctly ([#14453](https://github.com/knative/serving/pull/14453), [@gabo1208](https://github.com/gabo1208))

### Eventing
**Release Notes:** [Knative Eventing 1.13](https://github.com/knative/eventing/releases/tag/knative-v1.13.0)

#### 🚨 Breaking or Notable
- Use RFC-3339 compliant string encodings in filters for attributes of type time. ([#7466](https://github.com/knative/eventing/pull/7466), [@Cali0707](https://github.com/Cali0707))

#### 💫 New Features & Changes
- `PingSource` schedule supports optional seconds field ([#7394](https://github.com/knative/eventing/pull/7394), [@SiBell](https://github.com/SiBell))
- Trust-manager integration ([#7532](https://github.com/knative/eventing/pull/7532), [@pierDipi](https://github.com/pierDipi))
- Allow configuring whether to allow cross namespaces Brokers configuration using the `config-br-defaults` ConfigMap. ([#7455](https://github.com/knative/eventing/pull/7455), [@pierDipi](https://github.com/pierDipi))
- Expose the Sequence OIDC service account name in the Sequence `.status.auth.serviceAccountName` ([#7361](https://github.com/knative/eventing/pull/7361), [@rahulii](https://github.com/rahulii))
- Introduce EventTypes v1beta3 version ([#7304](https://github.com/knative/eventing/pull/7304), [@matzew](https://github.com/matzew))
- EventType V1Beta2 deprecation ([#7454](https://github.com/knative/eventing/pull/7454), [@matzew](https://github.com/matzew))
- Provide OIDC token in SinkBinding under `/oidc/token` path. ([#7444](https://github.com/knative/eventing/pull/7444), [@creydr](https://github.com/creydr))
- Channel dispatcher authenticates requests with OIDC ([#7445](https://github.com/knative/eventing/pull/7445), [@Cali0707](https://github.com/Cali0707))
- Authenticate Requests from ApiServerSource ([#7452](https://github.com/knative/eventing/pull/7452), [@Leo6Leo](https://github.com/Leo6Leo))
- Use underlying input channels audience as sequence audience ([#7387](https://github.com/knative/eventing/pull/7387), [@md-saif-husain](https://github.com/md-saif-husain))

#### 🐞 Bug Fixes
- Enable storage of EventType v1beta2 instead of v1beta1 ([#7594](https://github.com/knative/eventing/pull/7594), [@dsimansk](https://github.com/dsimansk))
- EventType v1beta1 deprecation ([#7453](https://github.com/knative/eventing/pull/7453) and [#7303](https://github.com/knative/eventing/pull/7303), [@matzew](https://github.com/matzew))
- Fix mt-broker-ingress watch Broker ([#7499](https://github.com/knative/eventing/pull/7499), [@xiangpingjiang](https://github.com/xiangpingjiang))
- Refactor the AuthStatus Logic ([#7417](https://github.com/knative/eventing/pull/7417), [@xiangpingjiang](https://github.com/xiangpingjiang))
- InMemoryChannel send a 202 response only after successfully delivering the event to all subscribers ([#7415](https://github.com/knative/eventing/pull/7415), [@Cali0707](https://github.com/Cali0707))
- Under OIDC mode, all the outgoing event request will be appended with JWT Authorization header ([#7452](https://github.com/knative/eventing/pull/7452), [@Leo6Leo](https://github.com/Leo6Leo))
- Use `kmeta.ChildName()` to generate OIDC service account name ([#7521](https://github.com/knative/eventing/pull/7521), [@xiangpingjiang](https://github.com/xiangpingjiang))

### Client
**Release Notes:** [Knative Client 1.13](https://github.com/knative/client/releases/tag/knative-v1.13.0)

#### 💫 New Features & Changes
- Added support for the `--profile` flag, which will add the related annotations and labels to the service. ([#1903](https://github.com/knative/client/pull/1903), [@sharmaansh21](https://github.com/sharmaansh21))

#### Other (Cleanup or Flake)
- Fix version string of Kafka resources in examples ([#1886](https://github.com/knative/client/pull/1886), [@MeenuyD](https://github.com/MeenuyD))

### Functions
**Release Notes:** [Knative func 1.13](https://github.com/knative/func/releases/tag/knative-v1.13.0)

#### Enhancement
- Log if image is referenced by tag in s2i builder. ([#2090](https://github.com/knative/func/pull/2090), [@AdamKorcz](https://github.com/AdamKorcz))
- Adding local field to function for handling transient spec (Local.Remote) ([#2121](https://github.com/knative/func/pull/2121), [@vyasgun](https://github.com/vyasgun))

#### Bug or Regression
- Add limit to number of manifests ([#2055](https://github.com/knative/func/pull/2055), [@AdamKorcz](https://github.com/AdamKorcz))

#### Uncategorized
- `Kn func subscribe` will allow you to create Knative Eventing Triggers for improved event processing for `kn func` ([#2001](https://github.com/knative/func/pull/2001), [@matzew](https://github.com/matzew))
- Adding simple Podman insecure registry support ([#2060](https://github.com/knative/func/pull/2060), [@matzew](https://github.com/matzew))
- Using `$CONTAINER_ENGINE` variable instead of hard-coded docker ([#2066](https://github.com/knative/func/pull/2066), [@matzew](https://github.com/matzew))
- Smooth syntax and pass only in the filters not the entire config ([#2115](https://github.com/knative/func/pull/2115), [@matzew](https://github.com/matzew))
- Don't duplicate subscriptions ([#2116](https://github.com/knative/func/pull/2116), [@matzew](https://github.com/matzew))
- Testing two sources(brokers) and third invocation for an override on the first ([#2118](https://github.com/knative/func/pull/2118), [@matzew](https://github.com/matzew))
- Invoke instanced CE function's handle withNew() ([#2119](https://github.com/knative/func/pull/2119), [@matzew](https://github.com/matzew))
- Springboot bumps ([#2126](https://github.com/knative/func/pull/2126), [@matzew](https://github.com/matzew))
- Bump for GO-GIT 5.11 ([#2130](https://github.com/knative/func/pull/2130), [@matzew](https://github.com/matzew))


### Operator
**Release Notes:** [Knative Operator 1.13](https://github.com/knative/operator/releases/tag/knative-v1.13.0)

Only dependency update

## Thank you, contributors
**Release Leads:**

- [@skonto](https://github.com/skonto)

- [@ReToCode](https://github.com/ReToCode)

- [@pierDipi](https://github.com/pierDipi)

- [@dsimansk](https://github.com/dsimansk)

- [@Cali0707](https://github.com/Cali0707)

- [@Leo6Leo](https://github.com/Leo6Leo)

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
