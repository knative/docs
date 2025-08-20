---
title: "v1.19 release"
linkTitle: "v1.19 release"
author: "[dsimansk (Red Hat)](https://github.com/dsimansk) and [gauron99 (Red Hat)](https://github.com/gauron99)"
author handle: https://github.com/dsimansk
date: 2025-07-28
description: "Knative v1.19 release announcement"
type: "blog"
---

## Announcing Knative v1.19 Release

!!! note
    We've discovered severse issues with the OpenTelemetry Prometheus Exporter (see: https://github.com/knative/pkg/issues/3224). We advise users to hold off upgrading until we have new patch releases out.

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

This release's core components brings some notable changes.

- Serving supports new K8s "image" volume type.
- Eventing now uses OTel to report it's metrics across multiple components
instead of Zipkin/OpenCensus and other features or improvements.
- Functions `run` command now supports `--address` specification, adds multiple
automation possibilities with new ENV variables or flags and your function can now
be invoked via `GET` requests and some additional bug fixes and smaller improvements.

## Serving

**Original notes**: [Knative Serving 1.19](https://github.com/knative/serving/releases/tag/knative-v1.19.0)

### 🐞 Bug Fixes

- Fix labels and annotations propagation to k8s service on update ([#15892](https://github.com/knative/serving/pull/15892), [@dsimansk](https://github.com/dsimansk))

### 💫 New Features & Changes

- Knative Serving now supports Kubernetes’ new "image" volume type. ([#15878](https://github.com/knative/serving/pull/15878), [@Fedosin](https://github.com/Fedosin))
- System_internal_tls_test.go:110: TLS not used on requests to queue-proxy: pods "system-internal-tls-mjhqutwi-00001-deployment-6b84b959d7-mjkcs" not found ([#15895](https://github.com/knative/serving/pull/15895), [@maschmid](https://github.com/maschmid))

## Eventing

**Original notes**: [Knative Eventing 1.19](https://github.com/knative/eventing/releases/tag/knative-v1.19.0)

### 💫 New Features & Changes

- Adding `features.knative.dev/apiserversource-skip-permissions-check` makes the ApiServerSource to skip permissions check before creating the receiver. This helps with large clusters where otherwise a large amount of SubjectAccessReviews would be created. Defaults to "false". Check the documentation for more information. ([#8615](https://github.com/knative/eventing/pull/8615), [@rh-hemartin](https://github.com/rh-hemartin))
- ContainerSources now correctly set labels in the Deployment when they are set in the .spec.template ([#8634](https://github.com/knative/eventing/pull/8634), [@Cali0707](https://github.com/Cali0707))
- Knative now supports the KN_VERIFY_CORRELATION_ID CESQL function, allowing you to verify knative correlation ids in your trigger filters. ([#8608](https://github.com/knative/eventing/pull/8608), [@Cali0707](https://github.com/Cali0707))
- The JobSink now reports metrics with OTel ([#8639](https://github.com/knative/eventing/pull/8639), [@Cali0707](https://github.com/Cali0707))
- The adapter is instrumented to provide traces and metrics with OTel ([#8640](https://github.com/knative/eventing/pull/8640), [@Cali0707](https://github.com/Cali0707))
- The broker filter, ingress, and InMemoryChannel deployments now expose metrics and traces with OpenTelemetry instead of Zipkin/OpenCensus ([#8635](https://github.com/knative/eventing/pull/8635), [@Cali0707](https://github.com/Cali0707))

## Functions

**Original notes**: [Knative Functions 1.19](https://github.com/knative/functions/releases/tag/knative-v1.19.0)

### 💫 New Features & Changes

- Add --base-image flag to override the base image for host builds ([#2935](https://github.com/knative/func/pull/2935), [@gauron99](https://github.com/gauron99))
- Feat: Python and Go function listen dualstack ([#2898](https://github.com/knative/func/pull/2898), [@matejvasek](https://github.com/matejvasek))
- Feat: run 'func invoke --request-type=GET' for invoking GET request ([#2942](https://github.com/knative/func/pull/2942), [@gauron99](https://github.com/gauron99))
- Func config remove now supports noninteractive usecases via a --name flag ([#2879](https://github.com/knative/func/pull/2879), [@lkingland](https://github.com/lkingland))
- Func run now supports json output ([#2893](https://github.com/knative/func/pull/2893), [@lkingland](https://github.com/lkingland))
- Func run now supports the --address flag ([#2887](https://github.com/knative/func/pull/2887), [@lkingland](https://github.com/lkingland))
- Function describe subcommand now includes labels. ([#2882](https://github.com/knative/func/pull/2882), [@lkingland](https://github.com/lkingland))
- Labels configuration now supports flags for a noninteractive flow. ([#2886](https://github.com/knative/func/pull/2886), [@lkingland](https://github.com/lkingland))
- Local clusters can now be set up on MacOS via the repository's allocate.sh and registry.sh scripts. ([#2897](https://github.com/knative/func/pull/2897), [@lkingland](https://github.com/lkingland))
- The path to "go" can be altered from that in PATH by using the FUNC_GO environment variable when using the host builder. ([#2877](https://github.com/knative/func/pull/2877), [@lkingland](https://github.com/lkingland))
- The path to git can be altered from that in PATH by using the FUNC_GIT environment variable when using the host builder. ([#2876](https://github.com/knative/func/pull/2876), [@lkingland](https://github.com/lkingland))
- User will be warned when their local branch differs from that configured for remote builds. ([#2884](https://github.com/knative/func/pull/2884), [@lkingland](https://github.com/lkingland))

- fix pod security context fs  ([#2941](https://github.com/knative/func/pull/2941), [@lkingland](https://github.com/lkingland))
- Configuring volumes now supports noninteractive CLI flow ([#2883](https://github.com/knative/func/pull/2883), [@lkingland](https://github.com/lkingland))
- Feat: make heroku's builders trusted ([#2818](https://github.com/knative/func/pull/2818), [@matejvasek](https://github.com/matejvasek))
- Fix: error "failed to write group file" when using untrusted builder ([#2516](https://github.com/knative/func/pull/2516)) ([#2819](https://github.com/knative/func/pull/2819), [@matejvasek](https://github.com/matejvasek))

### 🐞 Bug Fixes

- Fix: Python local buildpack build ([#2907](https://github.com/knative/func/pull/2907), [@matejvasek](https://github.com/matejvasek))
- Fix: fixes issue with func in-cluster build/deploy pipelines to work on ARM64 ([#2842](https://github.com/knative/func/pull/2842), [@luciantin](https://github.com/luciantin))
- Fix: in-cluster-dialer not used when it should be when pushing image to in cluster registry ([#2841](https://github.com/knative/func/pull/2841), [@matejvasek](https://github.com/matejvasek))
- Fix: non-containerized build/run with external dependencies ([#2847](https://github.com/knative/func/pull/2847), [@matejvasek](https://github.com/matejvasek))
- Fix: refer correct version of schema in func.yaml ([#2924](https://github.com/knative/func/pull/2924), [@matejvasek](https://github.com/matejvasek))
- Fixes a bug where remote tekton builds would use a stale image to upload the source directory. ([#2852](https://github.com/knative/func/pull/2852), [@luciantin](https://github.com/luciantin))

## Operator

**Original notes**: [Knative Operator 1.19](https://github.com/knative/operator/releases/tag/knative-v1.19.0)

### 💫 New Features & Changes

- Propagate manifests paths earlier to operator status ([#2106](https://github.com/knative/operator/pull/2106), [@dsimansk](https://github.com/dsimansk))

# Thank you, contributors

Release Leads:

- [@dsimansk](https://github.com/dsimansk)
- [@gauron99](https://github.com/gauron99)

Contributors:

- [@Cali0707](https://github.com/Cali0707)
- [@dsimansk](https://github.com/dsimansk)
- [@Fedosin](https://github.com/Fedosin)
- [@gauron99](https://github.com/gauron99)
- [@lkingland](https://github.com/lkingland)
- [@luciantin](https://github.com/luciantin)
- [@maschmid](https://github.com/maschmid)
- [@matejvasek](https://github.com/matejvasek)
- [@rh-hemartin](https://github.com/rh-hemartin)

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

