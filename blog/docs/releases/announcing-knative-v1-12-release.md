---
title: "v1.12 release"
linkTitle: "v1.12 release"
author: "[David Simansky (Red Hat)](https://github.com/dsimansk), [Christoph Stäbler (Red Hat)](https://github.com/creydr), [Stavros Kontopoulos (Red Hat)](https://github.com/skonto), [Calum Murray (Red Hat)](https://github.com/Cali0707), [Reto Lehmann (Red Hat)](https://github.com/retocode)"
author handle: https://github.com/dsimansk https://github.com/creydr https://github.com/skonto https://github.com/Cali0707 https://github.com/retocode
date: 2023-10-27
description: "Knative v1.12 release announcement"
type: "blog"
---

# Announcing Knative 1.12 Release

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

[Release Notes](https://github.com/knative/serving/releases/tag/knative-v1.12.0)

### 🚨 Breaking or Notable
- net-http01 component has been deprecated (see: https://github.com/knative/serving/issues/14640)
- Label the webhook service with "app: webhook" label (#14258, @JordanDeBeer)
- `auto-tls` is now named `external-domain-tls`  (#14472, @ReToCode)
- `internal-encryption` is now named `system-internal-tls`  (#14472, @ReToCode)
- `cluster-local-domain-tls` is introduced as a new alpha state flag to control TLS certificates for cluster-local domains (#14472, @ReToCode)
- Traffic from Ingress to Activator/QP uses TLS 1.3 when `system-internal-tls` is enabled. (#14074, @nak3)
- Validating webhook will now allow adding the NET_BIND_SERVICE or nil capabilities when secure pods defaults feature is enabled (#14445, @kauana)

### 💫 New Features & Changes
- Allow `shareProcessNamespace` to be set for a Knative Service (feature flag: `kubernetes.podspec-shareprocessnamespace`). Disabled by default. (#14454, @rhuss)
- Internal encryption verifies a new SAN `kn-user-<ns>`. (#14452, @nak3)
- ReadinessProbe with path contains a query string is supported now. (#14273, @nak3)
- Support gRPC probe. (#14134, @seongpyoHong)
- When `system-internal-tls` is enabled, queue-proxy mounts the certificate secret as projected-volume and automatically reloads the certificates on change. (#14189, @ReToCode)

### 🐞Bug Fixes
- Activator correctly propagates pod health when triggered by changes other than pod probes. (#14347, @arsenetar)
- Activator no longer cancels all probes when one fails (#14303, @arsenetar)
- Applied an upper bound to the statistics data read from the queue-proxy by the autoscaler. (#14523, @evankanderson)
- Certificate generation errors are bubbled up to its parent Route. (#14496, @gabo1208)
- Fix secure 'secure-pod-defaults' to work with restricted namespaces (#14363, @KauzClay)

## Eventing

[Release Notes](https://github.com/knative/eventing/releases/tag/knative-v1.12.0)

### New Features

- The `filters` field in Triggers is now **beta and enabled by default**
    - New Event Filters are now only created once, rather than on each event (#7213, @Cali0707)
    - The Any filter now dynamically optimizes the order of nested filters for optimal performance. (#7205, @Cali0707)
    - The all filter now dynamically optimizes its ordering to improve performance (#7300, @Cali0707)
    - The exact filter now uses less memory and is faster! (#7311, @Cali0707)
    - The prefix filter just got a whole lot faster! (#7309, @Cali0707)
    - The suffix filter is now faster! (#7312, @Cali0707)
- OIDC authentication feature
    - Add Audience field in CRDs (#7244, @xiangpingjiang)
    - Expose OIDC audience of a Broker in its status (#7237, @creydr)
    - Expose OIDC audience of an InMemoryChannel in its status (#7371, @creydr)
    - Expose the APIServerSource OIDC service account name in the APIServerSource .status.auth.serviceAccountName (#7330, @Leo6Leo)
    - Expose the PingSource OIDC service account name in the PingSource .status.auth.serviceAccountName (#7344, @Leo6Leo)
    - Expose the SinkBinding OIDC service account name in the SinkBinding .status.auth.serviceAccountName (#7327, @rahulii)
    - Expose the SubscriptionsOIDC service account name in the Subscriptions.status.auth.serviceAccountName (#7338, @xiangpingjiang)
    - Expose the Triggers OIDC service account name in the Triggers .status.auth.serviceAccountName (#7299, @creydr)
    - Mt-broker-ingress: verify the audience of the received JWT if OIDC authentication is enabled (#7336, @creydr)
    - OIDC tokens are now cached to improve performance. (#7335, @Cali0707)
- It is now possible to specify a subset of features in `config-features` without overriding default values (#7379, @pierDipi)

### Bug Fixes

- Fix unique name generator for auto-created `EventType` (#7160, @dsimansk)
- Correctly handle networking errors when ApiServerSource adapter can't retrieve resources when starts. (#7279, @pierDipi)
- Event Types are now only created once when using a MTChannelBasedBroker. (#7161, @Cali0707)
- Set cluster domain suffix in TLS records correctly. (#7145, @creydr)
- :bug: Memory leak in the not filter was fixed. (#7310, @Cali0707)
- :bug: The filters field now only overrides the filter field on a trigger if there are filters in the filters field. (#7286, @Cali0707)
- Fixed bug where eventtypes for builtin sources were created and deleted in a loop (#7245, @Cali0707)
- Fix of the rule aggregation of the `knative-eventing-namespaced-edit` role to only give view permissions on knative eventing resources. (#7124, @creydr)
- Update go `x/net` dependency to help mitigate CVE-2023-44487 (#7348, @Cali0707)

## Client

[Release Notes](https://github.com/knative/client/releases/tag/knative-v1.12.0)

### Breaking or Notable

- 🐣 Upgrade deprecated `v1alpha1` DomainMapping API to `v1beta1` (#1856, @xiangpingjiang)

### New Features

- Context Sharing POC  (#1855, @dsimansk)

### Bug or Regression

- Remove unusable `--broker` flag from `trigger update` cmd (#1847, @dsimansk)

### Other (Cleanup or Flake)

- Fix shellcheck warnings in `hack/build.sh` script (#1860, @xiangpingjiang)
- Remove deprecated `--inject-broker` flag from `kn trigger` cmd group (#1853, @xiangpingjiang)
- Update core cli dependencies (#1851, @dsimansk)

## Functions

[Release Notes](https://github.com/knative/func/releases/tag/knative-v1.12.0)

### Bug or Regression

- Fix: parsing of registries with more complex hierarchy (sub-paths) (#1929, @matejvasek)
- Fix: version semantic (#1933, @lkingland)

### Other (Cleanup or Flake)

- Chore: Update client-go dependency to aligned version (#1957, @dsimansk)
- Fix: OnCluster builds of Golang functions (#1445, @Shashankft9)

### Uncategorized

- Chore: using nodejs-16-minimal instead of nodejs-16 as default builder for JS/TS (#2015, @matejvasek)
- Chore: Use custom jammy paketo builder  (#1911, @matejvasek)
- Chore: update maven profile buildEnv in springboot templates (#2014, @trisberg)

## Operator

[Release Notes](https://github.com/knative/operator/releases/tag/knative-v1.12.0)

### Uncategorized

- Add more env vars for pingsource adapter env var preservation to prevent the eventing-controller and the operator fighting to set env var values. (#1534, @aliok)
- Added http-port and https-port for the ServiceType NodePort  (kourier config) (#1541, @eBeyond)
- Autoscaling/v2beta1 and policy/v1beta1 are no longer supported. Please use autoscaling/v2 and policy/v1 if you are using custom manifests. (#1579, @nak3)
- Disable probe when explicitly settting the empty overrideProbe. (#1519, @nak3)
- Support Eventing transport-encryption (TLS), for more information, see https://knative.dev/docs/eventing/experimental-features/transport-encryption/ (#1582, @pierDipi)
- The operator now sets HorizontalPodAutoscaler replicas (on resources with HPAs) when workload overrides are defined. (#1548, @ReToCode)

## Thank you, contributors

#### Release Leads:

- [@ReToCode](https://github.com/retocode)
- [@creydr](https://github.com/creydr)
- [@dsimansk](https://github.com/dsimansk)
- [@skonto](https://github.com/skonto)
- [@Cali0707](https://github.com/Cali0707)

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
