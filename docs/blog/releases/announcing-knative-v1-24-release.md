---
title: "v1.24 release"
linkTitle: "v1.24 release"
author: "[dsimansk](https://github.com/dsimansk)"
author handle: https://github.com/dsimansk
date: 2026-11-02
description: "Knative v1.24 Release Announcement"
type: "blog"
---

## Announcing Knative v1.24 Release

A new version of Knative is now available across multiple components.

Follow the instructions in [Installing Knative](https://knative.dev/docs/install/) to install the components you require.

!!! warning "Deprecations and retiring components"
    As part of a [community repository review](https://github.com/knative/community/issues/1802), the following integrations are deprecated and their repositories will be archived:

    - [autoscaler-keda](https://github.com/knative-extensions/autoscaler-keda)
    - [backstage-plugins](https://github.com/knative-extensions/backstage-plugins) (including the Event Mesh plugin)
    - [discovery](https://github.com/knative-extensions/discovery)
    - [eventing-autoscaler-keda](https://github.com/knative-extensions/eventing-autoscaler-keda)
    - [func-tastic](https://github.com/knative-extensions/func-tastic) (template repository for `func create`)
    - [kn-plugin-sample](https://github.com/knative-extensions/kn-plugin-sample)
    - [kn-plugin-service-log](https://github.com/knative-extensions/kn-plugin-service-log)
    - [kn-plugin-source-kamelet](https://github.com/knative-extensions/kn-plugin-source-kamelet)
    - [security-guard](https://github.com/knative-extensions/security-guard) (including QPOptions)

    Existing release binaries, images, and installation assets are preserved. The Knative Operator will emit a non-blocking status warning when Security Guard is enabled, and the setting will become a no-op in Operator v1.25. If you rely on any of these components, see [knative/community#1802](https://github.com/knative/community/issues/1802) for details and alternatives.

## Highlights

- **Kafka runtime sidecar** in Functions, enabling language-agnostic Kafka event sourcing with TLS/SASL support and KEDA consumer-lag scaling
- **Maximum backoff duration** for Eventing delivery retries, giving finer control over retry behavior
- **OAUTHBEARER support** in the Kafka Broker, propagating SASL JAAS configuration from auth secrets
- **Generic resource patches** in the Operator, plus new Helm chart options and multicluster improvements
- **Deprecation of inactive integrations** following the community repository review

Minimal supported version of Kubernetes is 1.35. See our [release schedule](https://github.com/knative/community/blob/main/mechanics/RELEASE-SCHEDULE.md) for details.

## Serving

**Release notes**: [Knative Serving 1.24](https://github.com/knative/serving/releases/tag/knative-v1.24.0)

This release is primarily a maintenance release with a DomainMapping traffic improvement.

**Route Traffic for DomainMappings**

DomainMappings can now copy the first matching cluster-local HTTP paths from the referenced Knative Service or Route into the DomainMapping Ingress, preserving the last-known-good configuration when the source is unavailable ([#16685](https://github.com/knative/serving/pull/16685) by [@kahirokunn](https://github.com/kahirokunn)). The behavior is opt-in through the `domainmapping-direct-route-traffic` flag in `config-features` and defaults to `Disabled`.

**Kubernetes 1.36 and 1.37 in E2E**

The kind E2E test matrix now includes Kubernetes 1.36 and 1.37 ([#16713](https://github.com/knative/serving/pull/16713) by [@dsimansk](https://github.com/dsimansk)), validating Serving against upcoming Kubernetes releases.

---

### Serving Networking Extensions

#### net-contour

**Release notes**: [net-contour 1.24](https://github.com/knative-extensions/net-contour/releases/tag/knative-v1.24.0)

**Endpoint Probe Improvements**

Backend ports and host rewrites are now preserved in endpoint probes ([#1301](https://github.com/knative-extensions/net-contour/pull/1301) by [@kahirokunn](https://github.com/kahirokunn)), fixing readiness checks for services that rewrite the Host header.


#### net-gateway-api

**Release notes**: [net-gateway-api 1.24](https://github.com/knative-extensions/net-gateway-api/releases/tag/knative-v1.24.0)

**Endpoint Probe Improvements**

Host rewrites are now preserved in endpoint probes ([#988](https://github.com/knative-extensions/net-gateway-api/pull/988) by [@kahirokunn](https://github.com/kahirokunn)), aligning behavior with the other networking extensions.

**Testing and Cleanup**

Unit tests have been added for `isHTTPRouteReady` and `isGatewayAdmitted` ([#983](https://github.com/knative-extensions/net-gateway-api/pull/983) by [@brucearctor](https://github.com/brucearctor)), and stale knative-sandbox organization references have been fixed ([#982](https://github.com/knative-extensions/net-gateway-api/pull/982) by [@brucearctor](https://github.com/brucearctor)).


#### net-istio

**Release notes**: [net-istio 1.24](https://github.com/knative-extensions/net-istio/releases/tag/knative-v1.24.0)

A maintenance release with dependency updates and kind E2E tests on Kubernetes 1.35 and 1.36.


#### net-kourier

**Release notes**: [net-kourier 1.24](https://github.com/knative-extensions/net-kourier/releases/tag/knative-v1.24.0)

A maintenance release with dependency updates and kind E2E tests on Kubernetes 1.35 and 1.36.

---

## Eventing

**Release notes**: [Knative Eventing 1.24](https://github.com/knative/eventing/releases/tag/knative-v1.24.0)

This release focuses on delivery retry improvements and reliability fixes.

**Maximum Backoff Duration for Delivery Retries**

A maximum backoff duration can now be configured for event delivery retries ([#9279](https://github.com/knative/eventing/pull/9279) by [@kahirokunn](https://github.com/kahirokunn)), capping exponential backoff for retriable delivery spec fields, covered by E2E tests through Triggers ([#9330](https://github.com/knative/eventing/pull/9330) by [@kahirokunn](https://github.com/kahirokunn)).

**Bug Fixes**

- A duplicate reply deadlock in RequestReply has been fixed ([#9191](https://github.com/knative/eventing/pull/9191) by [@rootp1](https://github.com/rootp1))
- Double injection of trust-bundle CA volumes in the reconcile loop has been fixed ([#9260](https://github.com/knative/eventing/pull/9260) by [@dsimansk](https://github.com/dsimansk))
- Deleted Subscriptions are now dropped from the tracker ([#9421](https://github.com/knative/eventing/pull/9421) by [@pujitha24](https://github.com/pujitha24))
- The first linear retry now waits one backoff delay before firing ([#9425](https://github.com/knative/eventing/pull/9425) by [@kahirokunn](https://github.com/kahirokunn))

**Dependencies**

The cert-manager libraries and resources have been updated to 1.20.3 ([#9259](https://github.com/knative/eventing/pull/9259) by [@dsimansk](https://github.com/dsimansk)).

---

### Eventing Extensions

#### Apache Kafka Broker

**Release notes**: [Kafka Broker 1.24](https://github.com/knative-extensions/eventing-kafka-broker/releases/tag/knative-v1.24.0)

This release brings OAUTHBEARER support and multiple consumer group reliability fixes.

**OAUTHBEARER Support**

`sasl.jaas.config` and `sasl.login.callback.handler.class` are now propagated from the auth secret for OAUTHBEARER authentication ([#4789](https://github.com/knative-extensions/eventing-kafka-broker/pull/4789) by [@dmetzler](https://github.com/dmetzler)), enabling OAuth-based authentication against Kafka clusters.

**Consumer Group Reliability**

- Orphaned Kafka groups on ConsumerGroup deletion are now prevented ([#4785](https://github.com/knative-extensions/eventing-kafka-broker/pull/4785) by [@qaiser42](https://github.com/qaiser42))
- Orphaned Kafka consumers that block ConsumerGroup finalization under load have been fixed ([#4799](https://github.com/knative-extensions/eventing-kafka-broker/pull/4799) by [@simkam](https://github.com/simkam))
- The reconciler now requeues at a fixed interval while the consumer group is not empty ([#4828](https://github.com/knative-extensions/eventing-kafka-broker/pull/4828) by [@gauron99](https://github.com/gauron99))

**Bug Fixes**

- The tracing context is now isolated per record in the unordered consumer ([#4800](https://github.com/knative-extensions/eventing-kafka-broker/pull/4800) by [@jrangelramos](https://github.com/jrangelramos))
- The KafkaChannel subscriber ServiceAccount check now uses the configured system namespace ([#4778](https://github.com/knative-extensions/eventing-kafka-broker/pull/4778) by [@pujitha24](https://github.com/pujitha24))


#### RabbitMQ Broker and Source

**Release notes**: [RabbitMQ 1.24](https://github.com/knative-extensions/eventing-rabbitmq/releases/tag/knative-v1.24.0)

A maintenance release with dependency updates.

---

## Functions

**Release notes**: [Functions 1.24](https://github.com/knative/func/releases/tag/knative-v1.24.0)

A substantial release with a language-agnostic Kafka runtime, git-based deployments, and continued MCP server growth.

**Language-Agnostic Kafka Runtime Sidecar**

Kafka event sourcing is no longer limited to Go: functions of any runtime can consume Kafka events via a runtime sidecar ([#4060](https://github.com/knative/func/pull/4060) by [@aliok](https://github.com/aliok)), pinned to the released v0.1.0 image ([#4095](https://github.com/knative/func/pull/4095) by [@aliok](https://github.com/aliok)). The sidecar includes a startup probe ([#4103](https://github.com/knative/func/pull/4103) by [@aliok](https://github.com/aliok)) and a fix for volume mounts at a certificate path's parent directory ([#4101](https://github.com/knative/func/pull/4101) by [@aliok](https://github.com/aliok)).

**Kafka TLS/SASL and KEDA Scaling**

Kafka functions now support TLS and SASL authentication ([#3975](https://github.com/knative/func/pull/3975) by [@aliok](https://github.com/aliok)), and KEDA-based consumer-lag scaling is available via `scale.keda` ([#4069](https://github.com/knative/func/pull/4069) by [@aliok](https://github.com/aliok)), including RBAC grants for Kafka scalers ([#4077](https://github.com/knative/func/pull/4077) by [@aliok](https://github.com/aliok)).

**Deploy from a Git Repository**

Functions can now be deployed directly from a git repository without a local checkout ([#4064](https://github.com/knative/func/pull/4064) by [@gauron99](https://github.com/gauron99)), with the remote source nameable via `--source`, `--source-dir`, and `--revision` ([#4048](https://github.com/knative/func/pull/4048) by [@gauron99](https://github.com/gauron99)). Pipelines now ship the effective config inside the source upload ([#3919](https://github.com/knative/func/pull/3919) by [@gauron99](https://github.com/gauron99)).

**Top-Level `scale` Field in func.yaml**

A top-level `scale` field has been added to `func.yaml` ([#4063](https://github.com/knative/func/pull/4063) by [@aliok](https://github.com/aliok)), collecting scaling settings such as `scale.keda` in one place.

**`func list` Improvements**

The `RUNTIME` column is now populated in `func list` ([#4010](https://github.com/knative/func/pull/4010) by [@pmeida](https://github.com/pmeida)), and the replica count of deployed functions is shown ([#4011](https://github.com/knative/func/pull/4011) by [@pmeida](https://github.com/pmeida)).

**MCP Server Improvements**

The MCP server gained many new tools: `config_ci` for CI/CD workflow generation ([#3997](https://github.com/knative/func/pull/3997)), repository management ([#3823](https://github.com/knative/func/pull/3823)), `describe` ([#3995](https://github.com/knative/func/pull/3995)), `invoke` ([#3986](https://github.com/knative/func/pull/3986)), `run` and `run_stop` ([#3998](https://github.com/knative/func/pull/3998)), a version tool ([#3996](https://github.com/knative/func/pull/3996)), a logs tool for deployed functions ([#3819](https://github.com/knative/func/pull/3819)), structured JSON output from `list` ([#4001](https://github.com/knative/func/pull/4001)), git config tools ([#3818](https://github.com/knative/func/pull/3818)), and a parameterized `onboard` prompt ([#4021](https://github.com/knative/func/pull/4021)) — mostly by [@Ankitsinghsisodya](https://github.com/Ankitsinghsisodya). Read-only mode is now enforced in more handlers, blocking `build --push` ([#3828](https://github.com/knative/func/pull/3828) by [@Ankitsinghsisodya](https://github.com/Ankitsinghsisodya), [#3708](https://github.com/knative/func/pull/3708) by [@Elvand-Lie](https://github.com/Elvand-Lie)).

**Cluster and Registry Improvements**

`func clusters` migrated its registry from the host container to an in-cluster deployment ([#3856](https://github.com/knative/func/pull/3856) by [@lkingland](https://github.com/lkingland)), installs `act` for local GitHub Actions runs ([#3968](https://github.com/knative/func/pull/3968) by [@lkingland](https://github.com/lkingland)), and waits for the CoreDNS rollout during cluster creation ([#4038](https://github.com/knative/func/pull/4038) by [@gauron99](https://github.com/gauron99)). Azure Container Registry login now uses the Azure SDK to obtain credentials and tokens ([#3398](https://github.com/knative/func/pull/3398) by [@dbalseiro](https://github.com/dbalseiro)), and a single `dockerconfigjson` registry Secret is now shared by remote builds and the func-operator ([#4082](https://github.com/knative/func/pull/4082) by [@gauron99](https://github.com/gauron99)).

**Bug Fixes**

- Malformed subscribe filters are now rejected ([#4036](https://github.com/knative/func/pull/4036) by [@axhatggg](https://github.com/axhatggg))
- File modes are normalized in the Python image layer ([#4037](https://github.com/knative/func/pull/4037) by [@matejvasek](https://github.com/matejvasek))
- Orphaned local-run directories are cleaned up ([#3989](https://github.com/knative/func/pull/3989) by [@Elvand-Lie](https://github.com/Elvand-Lie))

---

## Client

**Release notes**: [Client 1.24](https://github.com/knative/client/releases/tag/knative-v1.24.0)

**API Improvements**

`WatchServiceWithVersion` is now exposed on the `KnServingClient` interface ([#2274](https://github.com/knative/client/pull/2274) by [@cvas22](https://github.com/cvas22)), allowing library consumers to watch services for a specific Serving version.

**Bug Fixes**

- An error is now returned instead of panicking on a valueless mount option ([#2271](https://github.com/knative/client/pull/2271) by [@arpitjain099](https://github.com/arpitjain099))
- The sink type is formatted with `%v` instead of `%q` ([#2276](https://github.com/knative/client/pull/2276) by [@gauron99](https://github.com/gauron99))

---

## Operator

**Release notes**: [Operator 1.24](https://github.com/knative/operator/releases/tag/knative-v1.24.0)

This release adds generic resource patches, Helm chart options, and multicluster improvements.

**Generic Resource Patches**

Knative resources can now be patched generically via the Operator spec ([#2337](https://github.com/knative/operator/pull/2337) by [@kahirokunn](https://github.com/kahirokunn)), reducing the need for specialized patching fields.

**Helm Chart Improvements**

The knative-operator chart now supports `extraObjects` ([#2342](https://github.com/knative/operator/pull/2342) by [@aqeelat](https://github.com/aqeelat)), a configurable webhook replica count ([#2353](https://github.com/knative/operator/pull/2353) by [@kahirokunn](https://github.com/kahirokunn)), and an exposed `nodeSelector` ([#2358](https://github.com/knative/operator/pull/2358) by [@magic-peach](https://github.com/magic-peach)).

**Multicluster Improvements**

The Operator migrated to Cluster Inventory API v0.2.0 ([#2361](https://github.com/knative/operator/pull/2361) by [@kahirokunn](https://github.com/kahirokunn)), installs remote Knative components in canonical namespaces ([#2349](https://github.com/knative/operator/pull/2349) by [@kahirokunn](https://github.com/kahirokunn)), makes multicluster CRD waits resilient ([#2338](https://github.com/knative/operator/pull/2338) by [@kahirokunn](https://github.com/kahirokunn)), and guards Knative readiness predicates against failed reads ([#2348](https://github.com/knative/operator/pull/2348) by [@kahirokunn](https://github.com/kahirokunn)).

**Bug Fixes**

- The Kourier bootstrap namespace has been fixed ([#2336](https://github.com/knative/operator/pull/2336) by [@kahirokunn](https://github.com/kahirokunn))
- The Kafka 1.23 generated manifests have been updated ([#2346](https://github.com/knative/operator/pull/2346) by [@kahirokunn](https://github.com/kahirokunn))

---

## Thank you, contributors

Release Leads:

- [@dsimansk](https://github.com/dsimansk)
- [@gauron99](https://github.com/gauron99)

New Contributors 🎉:

- [@aqeelat](https://github.com/aqeelat)
- [@arpitjain099](https://github.com/arpitjain099)
- [@axhatggg](https://github.com/axhatggg)
- [@cvas22](https://github.com/cvas22)
- [@dbalseiro](https://github.com/dbalseiro)
- [@dmetzler](https://github.com/dmetzler)
- [@magic-peach](https://github.com/magic-peach)
- [@pmeida](https://github.com/pmeida)
- [@pujitha24](https://github.com/pujitha24)
- [@qaiser42](https://github.com/qaiser42)
- [@rootp1](https://github.com/rootp1)

---

## Learn more

Knative is an open source project that anyone in the [community](https://knative.dev/community/) can use, improve, and enjoy. We'd love you to join us!

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
