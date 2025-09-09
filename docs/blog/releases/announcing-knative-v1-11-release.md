---
title: "v1.11 release"
linkTitle: "v1.11 release"
author: "[Pierangelo Di Pilato (Red Hat)](https://github.com/pierDipi), [David Simansky (Red Hat)](https://github.com/dsimansk), [Christoph Stäbler (Red Hat)](https://github.com/creydr), [Stavros Kontopoulos (Red Hat)](https://github.com/skonto), [Vishal Choudhary (individual contributor)](https://github.com/Vishal-Chdhry)"
author handle: https://github.com/pierDipi https://github.com/dsimansk https://github.com/creydr https://github.com/skonto https://github.com/Vishal-Chdhry
date: 2023-07-25
description: "Knative v1.11 release announcement"
type: "blog"
---

# Announcing Knative 1.11 Release

A new version of Knative is now available across multiple components.

Follow the instructions in [Installing Knative](https://knative.dev/docs/install/) to install the components you require.

This release brings a number of smaller improvements to the core Knative Serving and Eventing components, and several improvements to specific plugins.

## Table of Contents

- [Serving](#serving)
- [Eventing](#eventing)
- [`kn` CLI](#client)
- [Functions](#functions)
- [Knative Operator](#operator)

## Serving

[Release Notes](https://github.com/knative/serving/releases/tag/knative-v1.11.0)

### 🚨 Breaking or Notable
- Activator uses TLS 1.3 as the minimum version when internal encryption is activated for communication with queue-proxy (#13887, @izabelacg)
- Domain mapping controller logic is now merged with the Serving controller. Domainmapping webhook is merged with the Serving webhook. (#14082, @skonto)
- DomainMapping/v1alpha1 is deprecated - use v1beta1 APIs (#14058, @dprotaso)

### 💫 New Features & Changes
- A new flag is introduced `queueproxy.resource-defaults` that sets resource requests, limits for Queue Proxy when enabled (applies only to cpu and memory). (#14039, @skonto)
- Activator now has a separate service account, reducing its privileges to the required minimum. (#14133, @davidhadas)
- Queue proxy resources can be configured via annotations at the service level.  The resource percentage annotation is now deprecated. (#14038, @skonto)
- Sets DefaultDomain to cluster's domain instead of hardcoded `svc.cluster.local` (#13964, @kauana)


### 🐞Bug Fixes
- Autoscaler metric are validated with global autoscaling class if no class annotation is set. (#13978, @xtreme-vikram-yadav)
- Drop `cluster-autoscaler.kubernetes.io/safe-to-evict` annotations on our control plane to allow nodes to drain (#14035, @dprotaso)
- Fix activator load balancing when using unbounded concurrency and when you have two instances of a revision (#14028, @dprotaso)
- Queue proxy metrics reporting period is now supported for both prometheus and opencensus.
  This allows fine-grained control of how often metrics are exported via a new config map attribute. (#14019, @skonto)
- Tag to digest min TLS version is 1.2 and can be configured higher using the controller environment variable `TAG_TO_DIGEST_TLS_MIN_VERSION` and supports values `"1.2"` and `"1.3"` (#13962, @dprotaso)

## Eventing

[Release Notes](https://github.com/knative/eventing/releases/tag/knative-v1.11.0)

##@ 💫 New Features & Changes

- Updated mtping TLS cert test to bind to free port (#7036, @Cali0707)
- Add TLS support for mt-broker-filter (#6940, @creydr)
- Adding v1beta2 version for EventType and type conversion (#6903, @matzew)
- ApiServerSource supports sending events to TLS endpoints, minimum TLS version is v1.2 (#6956, @pierDipi)
- ContainerSource supports sending events to TLS endpoints, minimum TLS version is v1.2 (#6957, @vishal-chdhry)
- Even Type auto-create feature:
  - Based on CloudEvents processed in an inmemorychannel corresponding `EventType` resources are created in the namespace (#7089, @Cali0707)
  - Feature flag to enable: `eventtype-auto-create` in `configmap/config-features`
  - Based on CloudEvents processed in a broker corresponding `EventType` resources are created in the namespace (#7034, @dsimansk)
- EventType v1b2 on sources `duck` controller/reconciler used (#6962, @matzew)
- EventType v1beta2 usage on the reconciler (#6949, @matzew)
- Do not parse flags in InitializeEventingFlags (#6966, @mgencur)
- PingSource supports sending events to TLS endpoints, minimum TLS version is v1.2 (#6965, @pierDipi)
- Source duck compliant source now create EventTypes for KResources, not just brokers (#7032, @matzew)
- The ApiServerSource controller now sets the K_CA_CERTS environment variable when creating the adapter and the sink has CACerts defined. (#6897, @vishal-chdhry)
- The ApiServerSource controller now sets the K_CA_CERTS environment variable when creating the adapter and the sink has CACerts defined. (#6920, @vishal-chdhry)
- The BROKER field of the EventType is deprecated, and is replaced by a KRef reference, pointing to the broker. In the future Knative will be able to support other addressables with EventType, instead of just a broker (#6870, @matzew)
- The EventType CRD can now point to other resources, like channels or sinks (#7023, @matzew)
- imc-dispatcher supports an https endpoint for receiving events. The channel is deduced from the path. (#6954, @gab-satchi)

## Client

[Release Notes](https://github.com/knative/client/releases/tag/knative-v1.11.0)

### 💫 New Features & Changes

- Add default SecurityContext to every new ksvc (#1821, @dsimansk)
- Add support for Eventing/v1beta2 EventTypes with `--reference` option flag (#1831, @dsimansk)
  - This a breaking change of backward compatibility with Eventing release that doesn't suppoert `EventTypes` API @ `v1beta2` 
- Change default SecurityContext value to `none` (#1832, @dsimansk)

### Bug or Regression

 - Fix plugin inlining that uses client-pkg dependency (#1816, @dsimansk)

## Functions

[Release Notes](https://github.com/knative/func/releases/tag/knative-v1.11.0)

### Chore

- Bumps faas-js-runtime to version 2.2.2
  - bumps cloudevents to version 7.0.1 (#1873, @lance)

### Enhancement

- Add Rust templates linting into CI workflow (#1814, @andrejusc)
- Add `func environment` to print the current function execution environment as JSON. (#1761, @lance)
- Add `func --domain`to choose routes (#1690, @lkingland)
- Feat: pipeline as code integration for gitlab (#1769, @matejvasek)
- Fixes a bug where local jobs were sometimes not canceling immediately
  - Startup timeout for local run tasks now configurable (#1750, @lkingland)

### API Change

- Allow specifying `persistentVolumeClaim` and `emptyDir` as volumes in functions. (#1666, @zalsader)

### Other (Cleanup or Flake)

- Updated Rust cloudevents example. (#1799, @saschagrunert)
- Updated Rust http example. (#1798, @saschagrunert) 

### Uncategorized
- Added support for serviceAccountName in func.yaml's deploy section to set the function service account. (#1811, @saschagrunert)
- Adds -R shorthand for --remote flag in func deploy (#1797, @nitishchauhan0022)
- Adds default builders for s2i and buildpacks to func environment (#1796, @nitishchauhan0022)
- Improve error msg when PAC is not installed (#1742, @zroubalik)
- On-cluster build: The pack build task result IMAGE_DIGEST is passed to the deploy task.
- On-cluster build: The deploy task explicitly sets the --image flag. (#1756, @matejvasek)
- Use jobs instead of plain pods for auxiliary tasks (#1857, @matejvasek)
- When building from an unreleased commit, such as the current Function main branch (which is 37 commits ahead of what was released as v0.37.0 in Knative 1.10: (#1817, @lkingland)

## Operator

[Release Notes](https://github.com/knative/operator/releases/tag/knative-v1.11.1)

## Thank you, contributors

#### Release Leads:

- [@pierDipi](https://github.com/pierDipi)
- [@creydr](https://github.com/creydr)
- [@dsimansk](https://github.com/dsimansk)
- [@skonto](https://github.com/skonto)
- [@vishal-chdhry](https://github.com/Vishal-Chdhry)

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
- [`#knative` on CNCF Slack](https://slack.cncf.io)
- Knative on [YouTube](https://www.youtube.com/channel/UCq7cipu-A1UHOkZ9fls1N8A)
