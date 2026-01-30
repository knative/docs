---
title: "v1.21 release"
linkTitle: "v1.21 release"
author: "[linkvt (Red Hat)](https://github.com/linkvt) and [gauron99 (Red Hat)](https://github.com/gauron99)"
author handle: https://github.com/linkvt
date: 2026-01-30
description: "Knative v1.21 release announcement"
type: "blog"
---

## Announcing Knative v1.21 Release

A new version of Knative is now available across multiple components.

Follow the instructions in [Installing Knative](https://knative.dev/docs/install/) to install the components you require.

## Table of Contents

- [Highlights](#highlights)
- [Serving](#serving)
- [Eventing](#eventing)
- [Functions](#functions)
- [Operator](#operator)
- [Thank you contributors](#thank-you-contributors)

## Highlights

Minimal supported version of k8s is now bumped to 1.33.

Serving prepares for the upcoming `secure-pod-defaults` change in v1.22 where `AllowRootBounded` will become the default. Request logging now supports OpenTelemetry W3C Trace Context while maintaining Zipkin B3 compatibility. A new `pod-is-always-schedulable` feature helps clusters with autoscaling skip the transient Unschedulable state.

Eventing had a light release focused on stability improvements and dependency updates.

Functions can now be deployed as standard Kubernetes Deployments without Knative Serving using `--deployer=raw`. The `func config ci` command gains GitHub Actions workflow generation, Tekton remote builds, and configurable registry authentication. Error handling is improved across the board with better validation and clearer messages.

---

## Serving

**Release notes**: [Knative Serving 1.21](https://github.com/knative/serving/releases/tag/knative-v1.21.0)

### Breaking or Notable Changes

#### Secure Pod Defaults ([#16042](https://github.com/knative/serving/pull/16042), [@nader-ziada](https://github.com/nader-ziada))

We've introduced `secure-pod-defaults` in an earlier release and included a new setting `AllowRootBounded` in v1.20 that offers a better security posture for your workloads but balances the compatibility with images that require/expect you to run as root.

For the 1.21 release the `secure-pod-defaults` default will remain `disabled` but in a future release (most likely v1.22) we will switch this default to `AllowRootBounded`.

_If you're unsure whether your workloads will support this new setting you should explicitly set this option to `disabled` prior to upgrading to v1.22._

For more information see the [documentation](https://knative.dev/development/serving/configuration/secure-pod-defaults/).

### New Features & Changes

- You can now set the new feature `pod-is-always-schedulable` to `true` in the config-deployment ConfigMap. As a result, Knative will not mark revisions as Unschedulable when a Pod is not scheduled. This makes sense if you want to omit this transient state in clusters that have cluster-autoscaling set up, and you can guarantee that all Pods will be eventually scheduled. ([#16146](https://github.com/knative/serving/pull/16146), [@SaschaSchwarze0](https://github.com/SaschaSchwarze0))
- Activator probe timeout and frequency are now configurable via `PROBE_TIMEOUT` and `PROBE_FREQUENCY` environment variables. ([#16250](https://github.com/knative/serving/pull/16250), [@bindrad](https://github.com/bindrad))
- Add `terminationGracePeriodSeconds` support for user and sidecar container probes ([#16255](https://github.com/knative/serving/pull/16255), [@flomedja](https://github.com/flomedja))
- Added support for OpenTelemetry W3C Trace Context (traceparent header) in request logging, while maintaining backward compatibility with Zipkin B3 format. ([#16168](https://github.com/knative/serving/pull/16168), [@SomilJain0112](https://github.com/SomilJain0112))
- Allow activator to be out of the request path when system-internal-tls is enabled ([#16183](https://github.com/knative/serving/pull/16183), [@linkvt](https://github.com/linkvt))
- Allow adjusting Revision min/max scale annotations ([#16186](https://github.com/knative/serving/pull/16186), [@dprotaso](https://github.com/dprotaso))
- Allow unreachable revisions with initialScale > 1 to scale to 0 ([#16327](https://github.com/knative/serving/pull/16327), [@aviralgarg05](https://github.com/aviralgarg05))
- Include two new activator metrics (`kn.activator.stats.conn.reachable`, `kn.activator.stats.conn.errors`) that reflect the stats reporter connection status ([#16318](https://github.com/knative/serving/pull/16318), [@prashanthjos](https://github.com/prashanthjos))

### Bug Fixes

- Preserve deployment and template annotations and labels during reconcile ([#16199](https://github.com/knative/serving/pull/16199), [@linkvt](https://github.com/linkvt))
- Fall back to HTTP1 on failed HTTP2 health probes (e.g. on connection error or non-readiness) ([#16205](https://github.com/knative/serving/pull/16205), [@linkvt](https://github.com/linkvt))
- Fix a rare data race in revision backend manager creating revision watchers during shutdown ([#16225](https://github.com/knative/serving/pull/16225), [@linkvt](https://github.com/linkvt))
- Fix metric names to match the original design document: `kn.queueproxy.app.duration` becomes `kn.serving.invocation.duration` and `kn.queueproxy.depth` becomes `kn.serving.queue.depth` ([#16290](https://github.com/knative/serving/pull/16290), [@dprotaso](https://github.com/dprotaso))
- Fix request log output corruption when using invalid log templates ([#16242](https://github.com/knative/serving/pull/16242), [@linkvt](https://github.com/linkvt))
- Fixed duplicate ACME challenge paths when Services with traffic tags use HTTP-01 challenges for TLS certificates. ([#16259](https://github.com/knative/serving/pull/16259), [@linkvt](https://github.com/linkvt))
- Services can no longer route traffic to revisions belonging to different services; attempting to do so will result in Ready=False with reason RevisionNotOwned. ([#16294](https://github.com/knative/serving/pull/16294), [@linkvt](https://github.com/linkvt))
- Services with invalid `networking.knative.dev/*` annotations on the revision template now fail immediately with a clear error instead of getting stuck. ([#16296](https://github.com/knative/serving/pull/16296), [@linkvt](https://github.com/linkvt))
- Switch to async metric instrumentation to avoid unbounded memory growth ([#16300](https://github.com/knative/serving/pull/16300), [@dprotaso](https://github.com/dprotaso))
- Fix sub-second precision metric reporting ([#16358](https://github.com/knative/serving/pull/16358), [@dprotaso](https://github.com/dprotaso))

---

## Eventing

**Release notes**: [Knative Eventing 1.21](https://github.com/knative/eventing/releases/tag/knative-v1.21.0)

This release includes minor improvements and bug fixes:

- Increase poll timings for IntegrationSource tests ([#8860](https://github.com/knative/eventing/pull/8860), [@creydr](https://github.com/creydr))
- Fix unused linter errors ([#8851](https://github.com/knative/eventing/pull/8851), [@simkam](https://github.com/simkam))

---

## Functions

**Release notes**: [Knative Functions 1.21](https://github.com/knative/func/releases/tag/knative-v1.21.0)

### Enhancements

- Add `--platform` flag to `func config ci` command allowing users to specify which CI/CD platform to generate manifests for. Currently supports "github" (default). ([#3379](https://github.com/knative/func/pull/3379), [@twoGiants](https://github.com/twoGiants))
- Add `--remote` flag to `func config ci` to build functions on a Tekton enabled cluster and `--workflow-dispatch` to trigger workflows manually via the GitHub CLI or UI. ([#3128](https://github.com/knative/func/pull/3128), [@twoGiants](https://github.com/twoGiants))
- Add the `--registry-authfile` build parameter to specify a custom registry auth file location ([#3208](https://github.com/knative/func/pull/3208), [@creydr](https://github.com/creydr))
- Add the possibility to deploy a function as raw Kubernetes deployment via the `--deployer=raw` argument ([#3075](https://github.com/knative/func/pull/3075), [@creydr](https://github.com/creydr))
- Added `env` as a short alias for the `environment` command. Users can now use `func env` as a convenient shorthand for `func environment`. ([#3219](https://github.com/knative/func/pull/3219), [@RayyanSeliya](https://github.com/RayyanSeliya))
- Allow to print the output from `func version` as `json` or `yaml` too ([#3280](https://github.com/knative/func/pull/3280), [@creydr](https://github.com/creydr))
- Event subscriptions now work with raw Kubernetes deployer (`--deployer raw`). ([#3335](https://github.com/knative/func/pull/3335), [@24aysh](https://github.com/24aysh))
- Pull secrets pre-check before deployment ([#3333](https://github.com/knative/func/pull/3333), [@matejvasek](https://github.com/matejvasek))
- Implement GitHub Actions workflow generation in `func config ci` command. The command now creates a complete deployment workflow with Kubernetes context setup, func CLI installation, and automated deployment. ([#3295](https://github.com/knative/func/pull/3295), [@twoGiants](https://github.com/twoGiants))
- Improve error message when `func describe` is run outside function directory to be more beginner-friendly. ([#3027](https://github.com/knative/func/pull/3027), [@RayyanSeliya](https://github.com/RayyanSeliya))
- Invalid domain names are now caught immediately with helpful error messages, preventing wasted build time ([#3152](https://github.com/knative/func/pull/3152), [@RayyanSeliya](https://github.com/RayyanSeliya))
- Invalid namespace names are now caught immediately with helpful error messages, preventing wasted build time ([#3133](https://github.com/knative/func/pull/3133), [@RayyanSeliya](https://github.com/RayyanSeliya))
- Provide used middleware version as a function label ([#3270](https://github.com/knative/func/pull/3270), [@creydr](https://github.com/creydr))
- The `func config ci` command now resolves `--path` and `--branch` flags intelligently, defaulting to the current directory and git branch. ([#3371](https://github.com/knative/func/pull/3371), [@twoGiants](https://github.com/twoGiants))
- The `func config ci` command now supports configurable registry authentication and runner options. ([#3297](https://github.com/knative/func/pull/3297), [@twoGiants](https://github.com/twoGiants))

### Bug Fixes

- Add latest middleware versions in `func version` output ([#3281](https://github.com/knative/func/pull/3281), [@creydr](https://github.com/creydr))
- Fix on-cluster-build freeze caused by co-scheduling/affinity issues ([#3350](https://github.com/knative/func/pull/3350), [@matejvasek](https://github.com/matejvasek))
- Fix populate image field in `func describe` ([#3220](https://github.com/knative/func/pull/3220), [@creydr](https://github.com/creydr))
- Fix push permission check with GitLab image registry ([#3263](https://github.com/knative/func/pull/3263), [@matejvasek](https://github.com/matejvasek))
- `func run --builder=host` now fails fast with helpful guidance when explicit ports are invalid, privileged, or already in use instead of silently choosing a random port ([#3176](https://github.com/knative/func/pull/3176), [@RayyanSeliya](https://github.com/RayyanSeliya))
- Function names starting with hyphens now show helpful DNS-1035 naming guidance instead of confusing flag parsing errors ([#3167](https://github.com/knative/func/pull/3167), [@RayyanSeliya](https://github.com/RayyanSeliya))
- `func deploy` now validates cluster connectivity before building, providing immediate feedback with clear error messages instead of wasting time on builds that will fail deployment. ([#3117](https://github.com/knative/func/pull/3117), [@RayyanSeliya](https://github.com/RayyanSeliya))
- Better error for s2i build -- show inner cause of the error ([#3185](https://github.com/knative/func/pull/3185), [@matejvasek](https://github.com/matejvasek))
- Hidden flags `--username`/`--password` (and affiliated envvars) now work also for s2i and pack builder ([#3298](https://github.com/knative/func/pull/3298), [@matejvasek](https://github.com/matejvasek))

---

## Knative Operator

**Release notes**: [Knative Operator 1.21](https://github.com/knative/operator/releases/tag/knative-v1.21.0)

This release contains dependency updates only.

---

## Thank you, contributors

Release Leads:

- [@linkvt](https://github.com/linkvt)
- [@gauron99](https://github.com/gauron99)

Contributors:

- [@24aysh](https://github.com/24aysh)
- [@aviralgarg05](https://github.com/aviralgarg05)
- [@bindrad](https://github.com/bindrad)
- [@creydr](https://github.com/creydr)
- [@dprotaso](https://github.com/dprotaso)
- [@flomedja](https://github.com/flomedja)
- [@linkvt](https://github.com/linkvt)
- [@matejvasek](https://github.com/matejvasek)
- [@nader-ziada](https://github.com/nader-ziada)
- [@prashanthjos](https://github.com/prashanthjos)
- [@RayyanSeliya](https://github.com/RayyanSeliya)
- [@SaschaSchwarze0](https://github.com/SaschaSchwarze0)
- [@simkam](https://github.com/simkam)
- [@SomilJain0112](https://github.com/SomilJain0112)
- [@twoGiants](https://github.com/twoGiants)

---

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
