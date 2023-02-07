**Authors: [Paul Schweigert](https://github.com/psschwei) (IBM), [Evan Anderson](https://github.com/evankanderson) (VMware)**

**Date: 2022-1-27**

# Announcing Knative 1.9 Release

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

[Release Notes](https://github.com/knative/serving/releases/tag/knative-v1.9.0)

## 🚨 Breaking or Notable

- Knative will now _warn_ (but not error) when creating or updating a PodSpec
  where containers have additional privilege due to unset SecurityContext values.
  Explicitly setting these values to any setting, including high-privilege ones,
  will disable this warning.
  
  These fields are:
  - `runAsNonRoot` (empty means `false`)
  - `allowPrivilegeEscalation` (empty means `true`)
  - `seccompProfile.type` (empty string means `Unconfined`)
  - `capabilities.drop` (default maintains privileges, use `ALL` to drop unneeded linux capabilities) (#13399, @evankanderson)
- All Serving container images are signed with cosign (@upodroid).

## 💫 New Features & Changes

- Net-contour respects the `internal-encryption` Knative configuration, and encrypts traffic from Contour controlled Envoy to Activator. Requires Contour 1.24.0 or greater (#819, @KauzClay)
- Adds the `secure-pod-defaults` feature, which is defaulted to Disabled in
  this release.
  When enabled, containers described by users will have best-practice
  SecurityContext features enabled unless insecure settings are specifically
  requested. (#13398, @evankanderson)
- Work around for cert-manager not allowing us to create certs for 64+ bytes name ksvc (#13569, @KauzClay and @dprotaso)
- Autoscaler now runs a single leader election go routine (#13585, @dprotaso)

### Small Improvements

- Add `app` label to Service selector for `webhook` and `domainmapping-webhook`. (#13265, @a7i)
- Upgrade tests now stream logs from user and system namespace. The logs are printed on failure. (#13587, @mgencur)
- net-kourier deployments now have Prometheus scraping annotations (#978, @evankanderson)
- net-kourier deployments now have resource requests and limits

### Bug Fixes

- Changes to Pod or Revision-level defaults during Knative upgrades will no longer be attempted (and failed) when supplying your own Revision name. (#13565, @evankanderson)
- net-contour would erroneously redirect cluster-local endpoints to HTTPS URLs when AutoTLS was enabled _and_ `default-tls-secret` was set.  (#856, @jsanin-vmw)
- Improved truncation of long generated names, which would sometimes produce invalid kubernetes resource names. (#847, @KauzClay)


## Eventing

[Release Notes](https://github.com/knative/eventing/releases/tag/knative-v1.9.0)

## 💫 New Features & Changes

- 📄 ApiServerSource can specify a selector to target one or more namespaces. If the selector is missing, it will default to targeting the namespace in which the source resides (#6665, @gab-satchi)
- All Eventing container images are signed with cosign (@upodroid).

## Bug fixes

- 🐛 Fixes an issue where creating a Trigger before a RabbitMQ Broker could create an invalid Trigger. (#1018, @gab-satchi)


## Client

[Release Notes](https://github.com/knative/client/releases/tag/knative-v1.9.0)

### 💫 New Features & Changes

* `quickstart` plugin will now create a local registry. (#376, @ehudyonasi)
* All Client container images are signed with cosign (@upodroid).


### Small improvements

* Updates the quickstart version of Kubernetes to v1.25.3. Also updates the recommended versions of kind and minikube to 0.16 and 1.28, respectively. (#368, @psschwei)
* `quickstart` will exit quickly if Knative namespace already exist in cluster. (#379, @ehudyonasi)


## Functions

[Release Notes](https://github.com/knative/func/releases/tag/knative-v1.9.0)

## 💫 New Features & Changes

- The springboot function templates have been updated to use Spring Boot 3.0 and the new Spring 6.0 AOT support. Note: this requires Java 17 when building locally. (#1509, @trisberg)
- Node.js and TypeScript functions now support ESM modules (#1468, @lance)

## Small Improvements

- Updated `springboot` function templates to use Spring Boot version 2.7.7 (#1502, @trisberg)

### Bug or Regression

- Fix: envvar parsing for pack tekton task when envvar contains the `=` char (#1512, @matejvasek)
- Fixes a bug preventing autoscaling options from being applied (#1482, @zroubalik)
- Fixes a bug where --path was sometimes not evaluated. (#1519, @lkingland)

### Other (Cleanup or Flake)

- Fixes an issue for developers where code in the test package would not be fully supported by some IDEs (#1503, @lkingland)
- Update the error message when neither the --registry flag nor the FUNC_REGISTRY environment variable are set (#1510, @lance)


## Operator

[Release Notes](https://github.com/knative/operator/releases/tag/knative-v1.9.0)

- Security-Guard version 0.4 can now be installed using the Knative Operator. This new release of Security-Guard also includes TLS+Token support to secure internal communications between Security-Guard components (#1301, @houshengbo)
- All Operator container images are signed with cosign (@upodroid).


## Thank you, contributors

#### Release Leads:

- [@psschwei](https://github.com/psschwei)
- [@evankanderson](https://github.com/evankanderson)

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
