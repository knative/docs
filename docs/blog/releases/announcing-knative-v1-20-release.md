---
title: "v1.20 release"
linkTitle: "v1.20 release"
author: "[gauron99 (Red Hat)](https://github.com/gauron99) and [linkvt (Red Hat)](https://github.com/linkvt)"
author handle: https://github.com/gauron99
date: 2025-11-07
description: "Knative v1.20 release announcement"
type: "blog"
---

## Announcing Knative v1.20 Release

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

There have been various changes in core components for this release.

- For serving we introduced new value `AllowRootBounded` for `secure-pod-defaults` option that balances security with compatibility and is planned to become the default in v1.21 (More info below!).
- Eventing introduces a complete Request Reply data plane and adds support for Pod default credentials in AWS Integration resources.
- Functions' CLI now provides more clearer errors and hints to users when things go wrong with build, deploy and delete commands. We also include some bug fixes.
- Operator recieved a fix for deadlock occurring during KnativeServing creation with `system-internal-tls` enabled.

## Serving

**Original notes**: [Knative Serving 1.20](https://github.com/knative/serving/releases/tag/knative-v1.20.0)

### 🚨 Breaking or Notable Changes

- In v1.19 we've dropped support for OpenCensus (which has been deprecated for a while) in favour of OpenTelemetry. This is a breaking change and details are documented here in the [design document](https://docs.google.com/document/d/1QQ_ubc0RjeZbRHdN4rQR85Z7RZfTSjz4GoKsE0dZ2Z0/edit?pli=1&tab=t.0#heading=h.n8a530nnrb=). and the website (https://knative.dev/docs/serving/observability/metrics/collecting-metrics/)
- Secure Pod Defaults  ([#16042](https://github.com/knative/serving/16042), [@nader-ziada](https://github.com/nader-ziada))
- We've introduced `secure-pod-defaults` in an earlier release but this release includes a new setting `AllowRootBounded` that offers a better security posture for your workloads
but balances the compatibility with images that require/expect you to run as root.
For `v1.20` release the `secure-pod-defaults` default will remain `disabled` but in a future release (most likely `v1.21`) we will switch this default to `AllowRootBounded`.

### 💫 New Features & Changes

- Create a new value for `secure-pod-defaults`: `AllowRootBounded` when AllowRootBounded,
defaults SeccompProfile and Capabilities if nil and when enabled sets RunAsNonRoot
to true if not already specified ([#16042](https://github.com/knative/serving/pull/16042), [@nader-ziada](https://github.com/nader-ziada))
- Made it possible to configure the `httputil.ReverseProxy` or add `http.Handler`s to queue-proxy in out-of-tree builds. ([#16097](https://github.com/knative/serving/pull/16097), [@mbaynton](https://github.com/mbaynton))
- Podspec-dryrun feature flag has been removed. Dry run validation will now occur when a user opts into it using `kubectl apply --dry-run=server` ([#16008](https://github.com/knative/serving/pull/16008), [@Alexander-Kita](https://github.com/Alexander-Kita))
- Add distinct logging for timeout types ([#16109](https://github.com/knative/serving/pull/16109), [@thiagomedina](https://github.com/thiagomedina))
- drop unnecessary 'kn.activator.proxy' metric/span attribute ([#16045](https://github.com/knative/serving/pull/16045), [@dprotaso](https://github.com/dprotaso))
- bump Istio to v1.27 and Contour to v1.33 ([#16099](https://github.com/knative/serving/pull/16099),[@dprotaso](https://github.com/dprotaso))
- Keep queue-proxy admin server on HTTP for PreStop hooks ([#16163](https://github.com/knative/serving/pull/16163), [@Fedosin](https://github.com/Fedosin))

### 🐞Bug Fixes

- Fix min-scale transition ([#16094](https://github.com/knative/serving/pull/16094), [@dprotaso](https://github.com/dprotaso))
- Add initialize conditions to MakePA to avoid potential race conditions ([#16037](https://github.com/knative/serving/pull/16037), [@nader-ziada](https://github.com/nader-ziada))
- For orphaned certificates if we have an issue listing just log the error ([#16096](https://github.com/knative/serving/pull/16096), [@dprotaso](https://github.com/dprotaso))
- Fix queue proxy user metrics port ([#16018](https://github.com/knative/serving/pull/16018), [@dprotaso](https://github.com/dprotaso))
- drop unused metrics domain env var ([#16019](https://github.com/knative/serving/pull/16019), [@dprotaso](https://github.com/dprotaso))
- fix otelhttp setup in activator ([#16044](https://github.com/knative/serving/pull/16044), [@dprotaso](https://github.com/dprotaso))
- Drop probe tracing in queue-proxy ([#16048](https://github.com/knative/serving/pull/16048), [@dprotaso](https://github.com/dprotaso))
- Adjust queue proxy metric attributes ([#16049](https://github.com/knative/serving/pull/16049), [@dprotaso](https://github.com/dprotaso))
- Serving Metric Tweaks ([#16062](https://github.com/knative/serving/pull/16062), [@dprotaso](https://github.com/dprotaso))
- Fix: PodAutoscaler not reconciled due to missing class annotation ([#16141](https://github.com/knative/serving/pull/16141), [@nader-ziada](https://github.com/nader-ziada))

## Eventing

**Original notes**: [Knative Eventing 1.20](https://github.com/knative/eventing/releases/tag/knative-v1.20.0)

### 💫 New Features & Changes

- Add support for using Pod default credentials in AWS IntegrationSource and IntegrationSink resources by specifying a ServiceAccount. ([#8731](https://github.com/knative/eventing/pull/8731), [@qswinson](https://github.com/qswinson))
- Event files received by Jobsinks will now include the Distributed Tracing extension ([#8626](https://github.com/knative/eventing/pull/8626), [@cobyge](https://github.com/cobyge))
- Eventing Core triggers now support the KN_VERIFY_CORRELATION_ID CESQL function ([#8700](https://github.com/knative/eventing/pull/8700), [@Cali0707](https://github.com/Cali0707))
- Feat: Added complete request reply data plane ([#8699](https://github.com/knative/eventing/pull/8699), [@Cali0707](https://github.com/Cali0707))
- Feat: the RequestReply resource can now be deployed from eventing core ([#8701](https://github.com/knative/eventing/pull/8701), [@Cali0707](https://github.com/Cali0707))

### 🐞Bug Fixes

- Fix a bug where the SkipPermissions mode of the ApiServerSource was not restarting the adapter pod properly. ([#8736](https://github.com/knative/eventing/pull/8736), [@rh-hemartin](https://github.com/rh-hemartin))
- Fix: metrics with prometheus use the same default port as before, 9092 ([#8669](https://github.com/knative/eventing/pull/8669), [@Cali0707](https://github.com/Cali0707))
- Fixes broken MT channel based broker when TLS is disabled and OIDC enabled ([#8727](https://github.com/knative/eventing/pull/8727), [@twoGiants](https://github.com/twoGiants))

### Documentation

- Correct guide on how to install Cert-manager manually in DEVELOPMENT.md ([#8741](https://github.com/knative/eventing/pull/8741), [@twoGiants](https://github.com/twoGiants))

## Functions

**Original notes**: [Knative Functions 1.20](https://github.com/knative/functions/releases/tag/knative-v1.20.0)

### 💫 New Features & Changes

- Func build and deploy commands now provide better error messages and validation ([#3058](https://github.com/knative/func/pull/3058),[#3062](https://github.com/knative/func/pull/3062),[#3066](https://github.com/knative/func/pull/3066), [@RayyanSeliya](https://github.com/RayyanSeliya))
- Improve error messages and include user hints on failures for various commands ([#3016](https://github.com/knative/func/pull/3016),[#3018](https://github.com/knative/func/pull/3018),[#3022](https://github.com/knative/func/pull/3022),[#3025](https://github.com/knative/func/pull/3025),[#3038](https://github.com/knative/func/pull/3038) [@RayyanSeliya](https://github.com/RayyanSeliya))
- Improve func delete user experience by creating better error messages ([#3054](https://github.com/knative/func/pull/3054), [@RayyanSeliya](https://github.com/RayyanSeliya))
- Improve func deploy user experience by showing clear error guidance ([#3042](https://github.com/knative/func/pull/3042), [@RayyanSeliya](https://github.com/RayyanSeliya))

### 🐞Bug Fixes

- Fix: Python pack build/run doesn't pick up code changes ([#3079](https://github.com/knative/func/pull/3079)) ([#3080](https://github.com/knative/func/pull/3080), [@matejvasek](https://github.com/matejvasek))
- Fix: fallback to python3 if python not present ([#3082](https://github.com/knative/func/pull/3082), [@matejvasek](https://github.com/matejvasek))
- Fix: host builder can push images to cluster internal registries ([#3130](https://github.com/knative/func/pull/3130), [@matejvasek](https://github.com/matejvasek))
- Fix: host builder uses base-image with correct version of Python ([#2965](https://github.com/knative/func/pull/2965), [@matejvasek](https://github.com/matejvasek))

### Other (Cleanup or Flake)

- Remove the --container flag - builds are determined via builder itself for func run command ([#2987](https://github.com/knative/func/pull/2987), [@gauron99](https://github.com/gauron99))
- Improved function run output to show both host and port when running locally ([#2953](https://github.com/knative/func/pull/2953), [@RayyanSeliya](https://github.com/RayyanSeliya))
- Fix pod security context fs permissions ([#2946](https://github.com/knative/func/pull/2946), [@lkingland](https://github.com/lkingland))
- Fix: backward compatibility for building old Python Functions with newer func ([#2962](https://github.com/knative/func/pull/2962), [@matejvasek](https://github.com/matejvasek))

## Operator

**Original notes**: [Knative Operator 1.20](https://github.com/knative/operator/releases/tag/knative-v1.20.0)

### 🐞Bug Fixes

- Fix deadlock during creation of KnativeServing with system-internal-tls enabled ([#2179](https://github.com/knative/operator/pull/2179), [@linkvt](https://github.com/linkvt))

# Thank you, contributors

Release Leads:

- [@gauron99](https://github.com/gauron99)
- [@linkvt](https://github.com/linkvt)

Contributors:

- [@Cali0707](https://github.com/Cali0707)
- [@cobyge](https://github.com/cobyge)
- [@dprotaso](https://github.com/dprotaso)
- [@gauron99](https://github.com/gauron99)
- [@linkvt](https://github.com/linkvt)
- [@lkingland](https://github.com/lkingland)
- [@matejvasek](https://github.com/matejvasek)
- [@nader-ziada](https://github.com/nader-ziada)
- [@qswinson](https://github.com/qswinson)
- [@RayyanSeliya](https://github.com/RayyanSeliya)
- [@rh-hemartin](https://github.com/rh-hemartin)
- [@twoGiants](https://github.com/twoGiants)

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

