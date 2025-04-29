---
title: "v1.18 release"
linkTitle: "v1.18 release"
author: "[David Simansky (Red Hat)](https://github.com/dsimansk) and [David Fridrich (Red Hat)](https://github.com/gauron99)"
author handle: https://github.com/dsimansk
date: 2025-04-29
description: "Knative v1.18 release announcement"
type: "blog"
---

## Announcing Knative v1.18 Release

A new version of Knative is now available across multiple components.

Follow the instructions in
[Installing Knative](https://knative.dev/docs/install/) to install the components you require.
## Table of Contents
- [Highlights](#highlights)
- [Serving](#serving)
- [Eventing](#eventing)
- [Functions](#functions)
- [Knative Operator](#operator)
- [Thank you contributors](#thank-you-contributors)

## Highlights

This release's core components bring a few new changes.

- Serving brings a notable change of new minimum version of k8s to
`v1.31` with some additional smaller improvements and/or fixes.
- Eventing comes with a new `EventTransform` API CRD and a few other changes.
- Functions component introduces a new Python middleware using ASGI
specification and allowing the use of the Host builder with some other minor
fixes and improvements.

## Serving

**Original notes**: https://github.com/knative/serving/releases/tag/knative-v1.18.0

### 🚨 Breaking or Notable Changes

- Kubernetes min version is now v1.31 ([#15774](https://github.com/knative/serving/pull/15774), [@dprotaso](https://github.com/dprotaso))

### 💫 New Features & Changes

- Add the ability to use `mountPropagation` for `volumeMounts`, gated under kubernetes.podspec-volumes-mount-propagation ([#15758](https://github.com/knative/serving/pull/15758), [@elijah-rou](https://github.com/elijah-rou))
- Adding support for CSI (Container Storage Interface) volumes. This feature allows users to mount CSI-compatible storage volumes into their Knative service containers. It enables integration with enterprise storage solutions and cloud provider storage services that implement the CSI specification. The feature is behind the flag `kubernetes.podspec-volumes-csi`. ([#15815](https://github.com/knative/serving/pull/15815), [@mwritescode](https://github.com/mwritescode))
- Autoscaling: ignore ScaleDownDelay if the revision is not reachable ([#15831](https://github.com/knative/serving/pull/15831), [@scottjmaddox](https://github.com/scottjmaddox))
- Support exec readiness probes for sidecar containers ([#15773](https://github.com/knative/serving/pull/15773), [@flomedja](https://github.com/flomedja))

### 🐞 Bug Fixes

- Fixes revision timeout defaulting when identical values are present in timeout settings. ([#15617](https://github.com/knative/serving/pull/15617), [@skonto](https://github.com/skonto))

## Eventing

**Original notes**: https://github.com/knative/eventing/releases/tag/knative-v1.18.0

### 💫 New Features & Changes

- Add EventTransform API CRD. ([#8456](https://github.com/knative/eventing/pull/8456), [@pierDipi](https://github.com/pierDipi))
- Add EventTransform API types. ([#8447](https://github.com/knative/eventing/pull/8447), [@pierDipi](https://github.com/pierDipi))
- Add `sinks.knative.dev` to namespaced ClusterRoles ([#8432](https://github.com/knative/eventing/pull/8432), [@pierDipi](https://github.com/pierDipi))
- Allow storage-version-migration job to successfully run when optional CRDs are not installed (inmemorychannels, etc). ([#8510](https://github.com/knative/eventing/pull/8510), [@PinotNoir04](https://github.com/PinotNoir04))
- ContainerSource now compares the entire `PodTemplateSpec`, instead of just its `PodSpec`. This avoids loosing edits on metadata, like annotations ([#8558](https://github.com/knative/eventing/pull/8558), [@matzew](https://github.com/matzew))
- EventTransform: Support transforming response from Sink ([#8469](https://github.com/knative/eventing/pull/8469), [@pierDipi](https://github.com/pierDipi))
- Reduce `mt-broker-controller` memory usage with namespaced endpoint informer. ([#8418](https://github.com/knative/eventing/pull/8418), [@pierDipi](https://github.com/pierDipi))
- SinkBinding: Set specific conditions for reconciler steps: `SinkBindingAvailable` and `TrustBundlePropagated` ([#8508](https://github.com/knative/eventing/pull/8508), [@pierDipi](https://github.com/pierDipi))
- TLS / Cert Manager integration for IntegrationSink ([#8509](https://github.com/knative/eventing/pull/8509), [@matzew](https://github.com/matzew))
Update k8s version in e2e tests ([#8503](https://github.com/knative/eventing/pull/8503), [@dsimansk](https://github.com/dsimansk))

## Functions
**Original notes**: https://github.com/knative/functions/releases/tag/knative-v1.18.0

### 🐞 Bug Fixes

- Fix: Go s2i build issue with user added dependencies ([#2765](https://github.com/knative/func/pull/2765), [@matejvasek](https://github.com/matejvasek))

### 💫 New Features & Changes


- Removes redundant default labels and annotations ([#2746](https://github.com/knative/func/pull/2746), [@KapilSareenp](https://github.com/KapilSareen))
- Adds the ability to specify a storage class for remote build volumes with --remote-storage-class ([#2693](https://github.com/knative/func/pull/2693), [@lkingland](https://github.com/lkingland))
- Python Functions now use the ASGI specification for method signature;
Python Functions now support instances and lifecycle events. See the new templates for details.
The Host builder now can build and run Python functions locally without a container. ([#2685](https://github.com/knative/func/pull/2685), [@lkingland](https://github.com/lkingland))

## Operator

**Original notes**: https://github.com/knative/operator/releases/tag/knative-v1.18.0

### 💫 New Features & Changes

- Added support to specify tolerations for Operator deployments. ([#2031](https://github.com/knative/operator/pull/2031), [@bacek](https://github.com/bacek))
- Proper order is enforced now during manifest installation. ([#2010](https://github.com/knative/operator/pull/2010), [@skonto](https://github.com/skonto))
- Watch and reconcile operator-controller ConfigMaps and reduce memory usage by only watching Knative specific deployments and configmaps. ([#2062](https://github.com/knative/operator/pull/2062), [@pierDipi](https://github.com/pierDipi))

## Thank you, contributors

Release Leads:

- [@dsimansk](https://github.com/dsimansk)
- [@dfridric](https://github.com/gauron99)

Contributors:

- [bacek](https://github.com/bacek)
- [dprotaso](https://github.com/dprotaso)
- [dsimansk](https://github.com/dsimansk)
- [elijah-ro](https://github.com/elijah-rou)
- [flomedj](https://github.com/flomedja)
- [lkingland](https://github.com/lkingland)
- [matejvasek](https://github.com/matejvasek)
- [matzew](https://github.com/matzew)
- [mwritescode](https://github.com/mwritescode)
- [pierDip](https://github.com/pierDipi)
- [PinotNoir0](https://github.com/PinotNoir04)
- [scottjmaddo](https://github.com/scottjmaddox)
- [skonto](https://github.com/skonto)
## Learn more

Knative is an open source project that anyone in the [community](https://knative.dev/docs/community/) can use, improve, and enjoy. We'd love you to join us!

- [Knative docs](https://knative.dev/docs)
- [Quickstart tutorial](https://knative.dev/docs/getting-started)
- [Samples](https://knative.dev/docs/samples)
- [Knative working groups](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md)
- [Knative User Mailing List](https://groups.google.com/forum/#!forum/knative-users)
- [Knative Development Mailing List](https://groups.google.com/forum/#!forum/knative-dev)
- Knative on Twitter [@KnativeProject](https://twitter.com/KnativeProject)
- Knative on [StackOverflow](https://stackoverflow.com/questions/tagged/knative)
- Knative [Slack](https://slack.cncf.io)
- Knative on [YouTube](https://www.youtube.com/channel/UCq7cipu-A1UHOkZ9fls1N8A)
