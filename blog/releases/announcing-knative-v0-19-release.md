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
- The monitoring bundle has been removed and the git repository archived.
- Improvements for cold start by adding a scale down delay.
- No longer mounting `/var/log` this allows certain images like `docker.io/nginx` that use this directory to be use as Knative Service.
- New Alpha feature that allows for domain name mapping at namespace scope.


### Serving v0.19

🚨 Breaking
- The deprecated monitoring bundle has been removed ([#9807](https://github.com/knative/serving/pull/9807))
- Drop serving v1alpha1 and v1beta1 APIs ([#9617](https://github.com/knative/serving/pull/9617), [#9620](https://github.com/knative/serving/pull/9620))
- We only mount a volume at `/var/log` if the operator has enabled log collection. Runtime contract `/var/log` requirement has changed from MUST to MAY ([#9683](https://github.com/knative/serving/pull/9683)]

💫 New Features & Changes
- Adds a Scale Down Delay feature, allowing maintaining replica count for a configurable period after request count drops to avoid cold start penalty. ([#9626](https://github.com/knative/serving/pull/9626))
- (Alpha) Adds a DomainMapping CRD in v1alpha1, allowing mapping a custom domain name to a Knative Service ([#9714](https://github.com/knative/serving/pull/9714), [#9735](https://github.com/knative/serving/pull/9735), [#9752](https://github.com/knative/serving/pull/9752), [#9796](https://github.com/knative/serving/pull/9796), [#9915](https://github.com/knative/serving/pull/9915), [#10044](https://github.com/knative/serving/pull/10044))
- Adding cluster-wide flag max-scale-limit. This ensures that both cluster-wide flag max-scale and per-revision annotation "autoscaling.knative.dev/maxScale" for new revision will not exceed this number. ([#9577](https://github.com/knative/serving/pull/9577))
- All of our deployments run with a minimal set of kernel capabilities. ([#9973](https://github.com/knative/serving/pull/9973))
- Autoscaler now supports multiple pods. Autoscaler Deployment needs to be scaled to 0 first then scaled to other replica value. ([#9682](https://github.com/knative/serving/pull/9682))
- Updated the Service schema to include a high level basic schema. ([#9436](https://github.com/knative/serving/pull/9436), [#9953](https://github.com/knative/serving/pull/9953))
- Queue-proxies are no longer allow to run as root, they have a read-only root filesystem and have all capabilities dropped. ([#9974](https://github.com/knative/serving/pull/9974))
- ResponsiveRevisionGC is enabled by default ([#9710](https://github.com/knative/serving/pull/9710))
- Revisions are now named more clearly and consistently. ([#9740](https://github.com/knative/serving/pull/9740))

🐞 Bug Fixes
- Domain is validated by k8s library IsFullyQualifiedDomainName(). ([#10023](https://github.com/knative/serving/pull/10023))
- Fixed a rare nil-pointer exception in the autoscaler ([#9794](https://github.com/knative/serving/pull/9794))
- Ingress is reconciled when label was different from desired. ([#9719](https://github.com/knative/serving/pull/9719))

### Eventing v0.19

TODO

### Eventing Contributions v0.19

TODO

### Client v0.19

TODO

### Operator v0.19

TODO

### Thanks

Thanks to these contributors who contributed to v0.19!

- @dprotaso
- @joshuawilson
- @julz
- @markusthoemmes
- @mattmoor
- @nak3
- @taragu
- @whaught
- @yanweiguo



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
