---
title: "Version v0.19 release"
linkTitle: "Version v0.19 release"
Author: "[Carlos Santana](https://twitter.com/csantanapr)"
Author handle: https://github.com/csantanapr
date: 2020-11-13
description: "Knative v0.19 release announcement"
type: "blog"
image: knative-eventing.png
---


## Announcing Knative v0.19 Release

A new version of Knative is now available across multiple components.
Follow the instructions in the documentation [Installing Knative](https://knative.dev/docs/install/) for the respective component.

Highlights:


### Serving v0.19

🚨 Breaking
- The deprecated monitoring bundle has been removed (#9807, @dprotaso)
- Drop serving v1alpha1 and v1beta1 APIs (#9617, #9620, @mattmoor, @dprotaso)
- We only mount a volume at /var/log if the operator has enabled log collection
- Runtime contract /var/log requirement has changed from MUST to MAY (#9683, @dprotaso)

💫 New Features & Changes
- Adds a Scale Down Delay feature, allowing maintaining replica count for a configurable period after request count drops to avoid cold start penalty. (#9626, @julz)
- (Alpha) Adds a DomainMapping CRD in v1alpha1, allowing mapping a custom domain name to a Knative Service (#9714, #9735, #9752, #9796, #9915, #10044, @julz)
- Adding cluster-wide flag max-scale-limit. This ensures that both cluster-wide flag max-scale and per-revision annotation "autoscaling.knative.dev/maxScale" for new revision will not exceed this number. (#9577, @taragu)
- All of our deployments run with a minimal set of kernel capabilities. (#9973, @markusthoemmes)
- Autoscaler now supports multiple pods. Autoscaler Deployment needs to be scaled to 0 first then scaled to other replica value. (#9682, @yanweiguo)
- Updated the Service schema to include a high level basic schema. (#9436, #9953, @joshuawilson)
- Queue-proxies are no longer allow to run as root, they have a read-only root filesystem and have all capabilities dropped. (#9974, @markusthoemmes)
- ResponsiveRevisionGC is enabled by default (#9710, @whaught)
- Revisions are now named more clearly and consistently. (#9740, @markusthoemmes)

🐞 Bug Fixes
- Domain is validated by k8s library IsFullyQualifiedDomainName(). (#10023, @nak3)
- Fixed a rare nil-pointer exception in the autoscaler (#9794, @markusthoemmes)
- Ingress is reconciled when label was different from desired. (#9719, @nak3)

### Eventing v0.19

### Eventing Contributions v0.19

### Client v0.19

### Operator v0.19

### Thanks

Thanks to these contributors who contributed to v0.19!

- @AverageMarcus


### Learn more

Knative is an open source project that anyone in the [community](https://knative.dev/community/) can use, improve, and enjoy. We'd love you to join us!

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
