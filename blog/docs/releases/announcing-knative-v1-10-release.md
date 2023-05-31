---
title: "v1.10 release"
linkTitle: "v1.10 release"
author: "[Pierangelo Di Pilato (Red Hat)](https://github.com/pierDipi), [David Simansky (Red Hat)](https://github.com/dsimansk),  [Krsna Mahapatra (VMWare)](https://github.com/kvmware), [Pradnya Dixit VMWare](https://github.com/pradnyavmw)"
author handle: https://github.com/pierDipi https://github.com/dsimansk https://github.com/kvmware https://github.com/pradnyavmw
date: 2023-04-25
description: "Knative v1.10 release announcement"
type: "blog"
---

# Announcing Knative 1.10 Release

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

[Release Notes](https://github.com/knative/serving/releases/tag/knative-v1.10.0)

## 🚨 Breaking or Notable

- Container-freezer has been sunset in Knative v1.10. (#13830, @psschwei)
- Controller uses TLS 1.3 as the minimum version when communicating with image registries for tag to digest resolution (#13886, @izabelacg)

## 💫 New Features & Changes

- Adds support for downwardAPI sources in projected volumes on Knative Services (#13896, @KauzClay)
- Controllers now have liveness and readiness probes (#13563, @skonto)
- With enabling internal-encryption, activator pods needed to be restarted when certificates are updated. The restart is not necessary anymore. (#13854, @nak3)
- ImagePullSecrets with references to unknown service accounts won't error out anymore but fail silently like Kubernetes. (#13701, @Bisht13)

### Bug Fixes

- Fixes issue where certificates would not get renewed when using auto-tls. (#13666, @KauzClay)

## Eventing

[Release Notes](https://github.com/knative/eventing/releases/tag/knative-v1.10.0)

## 💫 New Features & Changes

- APIServerSource events includes apiVersion of the object (#6696, @gab-satchi)
- SecurityContext settings for ApiServerSource's Receive Adapter's container/deployment (#6788, @matzew)
- Set sidecar.istio.io/inject to true for API Server Source adapter pods for Istio integration. (#6789, @pierDipi)
- Allow event display to log requests, when REQUEST_LOGGING_ENABLED environment variable is set to true, the feature is explicitly discouraged for production usage due to the possibility of logging sensitive information (#6764, @pierDipi)
- Removes deprecated DeadLetterChannel in favor of DeliveryStatus (#6722, @Vishal-Chdhry)
- Remove eventing.knative.dev/release label from resources, use standard app.kubernetes.io/version label instead. (#6807, @Abhishek357)
- Add Broker class in kubectl get -o wide (#6723, @Vishal-Chdhry)

## Bug fixes

- 🐛 Fixes an issue where a Cloud Event in a response from a sink was truncated to 1024 bytes (#6758, @gab-satchi)
- 🐛 Use debug level logging for noisy scheduler logs (#6705, @matzew)

## Client

[Release Notes](https://github.com/knative/client/releases/tag/knative-v1.10.0)

### 💫 New Features & Changes

- Add 'kn service wait' for deployment status check (#1800, @manoelmarques)
- Add experimental filters to trigger describe cmd (#1794, @dsimansk)
- Add kn secret commands group for managing secrets (#1791, @dsimansk)

### Bug or Regression

- Fix issue with newer linter version (#1777, @rhuss)
- Fix run-as-nonRoot containers (#1787, @mgencur)
- Fix deprecated functions related to Go 1.20 (#1779, @scottmason88)
- Fix tagging of kn container image for latest releases (#1792, @dsimansk)

## Functions

[Release Notes](https://github.com/knative/func/releases/tag/knative-v1.10.0)

## 💫 New Features & Changes

- Adding func config git command and subcommands to handle intial support of Pipelines as Code (#1594, @zroubalik)
- Adds support for Git-based deploy options to be configured using CLI flags (#1604, @zroubalik)
- Adds support for branches and tags when adding a template repository using func repository add <uri> (#1558, @lance)
- Commands such as envs can be referred to by their singular form env and vice-versa. Commands with well-known command synonyms were added as aliases, such aslabels delete <name> now supports labels rm <name> (#1578, @lkingland)
- Current function values more accurately reflected in 'deploy' command help text. Builds cache more frequently when running func deploy (#1434, @lkingland)
- Enables Dapr runtime support from within Functions. Dapr control plane install required. (#1518, @lkingland)
- Enables custom health checks for Node.js and TypeScript functions (#1682, @lance)
- On cluster builds initiated from the CLI attempt to read git configuration settings from the local .git config (#1635, @zroubalik)
- Removes default endpoints from func.yaml to improve file legibility (#1555, @lance)
- Update Rust templates dependencies and UTs for Actix 4.x (#1661, @andrejusc)
- Update springboot templates to Spring Boot 3.0.5 (#1658, @andrejusc)
- Uses locally configured Git branch for on-cluster builds (#1636, @zroubalik)

### Chore

- Adds Tekton Tasks to release artifacts. (#1557, @lance)
- Fixes an issue where Node.js and TypeScript functions are not killed immediately on SIGHUP (#1570, @lance)

### Bug or Regression

- Fix: build stamp computation (#1608, @matejvasek)
- Fix: s2i build when node_modules present (#1612, @matejvasek)
- Fix: s2i python build on Windows (#1641, @matejvasek)

### API Change

- A new option "--builder" added to "run" command to be used when building. Default is "pack" (#1614, @manoelmarques)

### Other (Cleanup or Flake)

- Fixes issue where global settings for --verbose and --confirm were sometimes not considered
  Removes the --version flag; please use the 'version' subcommand. (#1564, @lkingland)

## Operator

[Release Notes](https://github.com/knative/operator/releases/tag/knative-v1.10.0)

## 💫 New Features & Changes

- Allow to set HostNetwork via spec.deployments.hostNetwork (#1363, @kahirokunn)

### Bug Fixes

- Added the ingress and source paths into the status.manifests (#1415, thanks @houshengbo)
- Add the image overriding support for StatefulSet (#1413, thanks @houshengbo)
- Allow to set HostNetwork via spec.deployments.hostNetwork (#1363, thanks @kahirokunn)

## Thank you, contributors

#### Release Leads:

- [@pierDipi](https://github.com/pierDipi)
- [@dsimansk](https://github.com/dsimansk)
- [@kvmware](https://github.com/kvmware)
- [@pradnyavmw](https://github.com/pradnyavmw)

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
