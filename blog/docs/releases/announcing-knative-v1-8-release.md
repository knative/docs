**Authors: [Lionel Villard](https://github.com/lionelvillard) (IBM), [Kenjiro Nakayama](https://github.com/nak3) (Red Hat)**

**Date: 2022-10-22**

# Announcing Knative 1.8 Release

A new version of Knative is now available across multiple components.

Follow the instructions in [Installing Knative](https://knative.dev/docs/install/) to install the components you require.

This release brings a number of smaller improvements to the core Knative Serving and Eventing components, and several improvements to specific plugins.

## Table of Contents
- [General](#general)
- [Serving](#serving)
- [Eventing](#eventing)
- [`kn` CLI](#client)
- [Functions](#functions)
- [Knative Operator](#operator)

## General

### 🚨 Breaking or Notable

* Our macOS binaries have been notarized so you should be able to run them right away when downloading them from GitHub without having to change Gatekeeper settings.

### 💫 New Release

* [Security-Guard Alpha](https://github.com/knative-sandbox/security-guard/releases/tag/v0.2.0) is now released to allow cyber monitoring and control of knative services.

## Serving

[Release Notes](https://github.com/knative/serving/releases/tag/knative-v1.8.0)

### 🚨 Breaking or Notable

- Uses the cluster domain suffix `svc.cluster.local` as the default domain. As routes using the cluster domain suffix are not exposed through Ingress, users will need to [configure DNS](https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/#configure-dns) in order to expose their services (most users probably already are). ((#13259, @psschwei)
- Upgrade HorizontalPodAutoscaler to autoscaling/v2 API version (#13337, @nader-ziada)
- Services may now set `seccompProfile` in SecurityContext to allow users to comply with the `restricted` Pod Security Standards best-practice (#13401, @evankanderson)
- Bump min-version to k8s 1.23, so removing kind 1.22 testing (#13357, @nader-ziada)
- Increase the outbound context deadline in reconcilers to 30s (from 10s) to match the maximum K8s webhook timeout. (#13323, @mattmoor)

### 💫 New Features & Changes

- Add timeout handling in Activator  when processing a request for a revision (#13261, @nader-ziada)
- EmptyDir volumes feature flag is now enabled by default (#13405, @dprotaso)
- Queue proxy explicit set `SeccompProfile` to `RunTimeDefault` to be able to run under restricted PSP policy by default. (#13376, @skonto)
- Save data from perf tests to create a dashboard. (#13192, @nader-ziada)

### 🐞Bug Fixes

- Knative services can now specify securityContext.allowPrivilegeEscalation (#13395, @mattmoor)
- ConfigMap config-defaults property `revision-response-start-timeout-seconds` now defaults to `revision-timeout-seconds`. This should unblock upgrades who set `revision-timeout-seconds` lower than the default value of 300 (#13255, @dprotaso)
- Fix LatestReadyRevision semantics so it only advances forward. When a Revision fails the Configuration & Route will no longer fall back to older revision. The exception is when you rollback to a Revision that is explicitly named. (#13239, @dprotaso)

## Eventing

[Release Notes](https://github.com/knative/eventing/releases/tag/knative-v1.8.0)

### 🚨 Breaking or Notable

* The HorizontalPodAutoscaler manifests have been updated to v2, which is available with k8s 1.23+ (#6549, @matzew)
* Add readiness and liveness probes in Knative Eventing controller (#6566, @lionelvillard)
* Update k8s library to 1.25.2 (#6561, @lionelvillard)
* Update pelletier/go-toml/v2 to v2.0.5 (#6574, @dsimansk)

### 💫 New Features & Changes

* InMemoryChannel receiver validates received events (#6511, @pierDipi)

### 🐞Bug Fixes

* Fixing PodSecurity Policy warnings for restricted environments (#6533, @matzew)
* Remove check for v1 API of ConfigMap as there is only v1 CMs (#6502, @matzew)
* Fixes issue with sugar controller always setting the broker class to MTChannelBasedBroker instead of using the defaults ConfigMap (#6500, @gab-satchi)
* Port old e2e containersource test to reconciler test (#6507, @liuchangyan)
* Remove strict check in scorer plugins and respect max skew parameter. Requeue request when no pods available rather than fail scheduler. (#6524, @aavarghese)

## Client

[Release Notes](https://github.com/knative/client/releases/tag/knative-v1.8.0)

#### 💫 New Features & Changes

* Add `--scale-activation` flag to `service create` command options (#1729, @vyasgun)
* Provide cli options to enable Kubernetes user, uid, and group impersonation via `--as`, `--as-group` and `--as-uid` flags (#1745, @a7i)

### Bug or Regression

* Fix release script version calculation (#1737, @dsimansk)


## Functions

This is the first release for Functions as a part of Knative Core.

[Release Notes](https://github.com/knative/func/releases/tag/knative-v1.8.0)

#### 💫 New Features & Changes

* Cancel pipeline run on SIGINT/SIGTERM (#1329, @matejvasek)
* On cluster build using direct source upload (i.e. git is not needed) (#1298, @matejvasek)
* Changes package name from knative.dev/kn-plugin-func to knative.dev/func (#1311, @lance)

## Operator

[Release Notes](https://github.com/knative/operator/releases/tag/knative-v1.8.0)

#### 💫 New Features & Changes

* Allow to use custom bootstrap configmap for Kourier (#1227, thanks @nak3)
* Add workloads and deprecate deployments (#1246, thanks @pierDipi)
* Support deployments/workloads probe overrides (#1247, thanks @skonto)

#### 🐞 Bug Fixes

* Do not change spec.replicas directory for the Deployment which has HPA (#1201, thanks @nak3)
* Allow zero replicas for HA and Deployment config (#1225, thanks @matzew)
* Add the code to safeguard the nil pointer issue (#1228, thanks @houshengbo)
* Refactor the ingress service for istio (#1231, thanks @houshengbo)
* Update the fetcher and manfests for kafka sources (#1242, thanks @houshengbo)

## Thank you, contributors

#### Release Leads:

- [@lionelvillard](https://github.com/lionelvillard)
- [@nak3](https://github.com/nak3)

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
- Knative [Slack](https://slack.knative.dev)
- Knative on [YouTube](https://www.youtube.com/channel/UCq7cipu-A1UHOkZ9fls1N8A)
