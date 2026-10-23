---
title: "v1.23 release"
linkTitle: "v1.23 release"
author: "[dsimansk](https://github.com/dsimansk)"
author handle: https://github.com/dsimansk
date: 2026-07-31
description: "Knative v1.23 Release Announcement"
type: "blog"
---

## Announcing Knative v1.23 Release

A new version of Knative is now available across multiple components.

Follow the instructions in [Installing Knative](https://knative.dev/docs/install/) to install the components you require.

## Highlights

- **Generic ephemeral volumes** in Serving, enabling dynamically provisioned pod-scoped storage
- **EndpointSlice migration** in Eventing, moving off deprecated v1 Endpoints
- **IPv6 support** for Serving autoscaler EndpointSlice creation
- **New `func logs` and `func clusters` commands** for streaming function logs and one-command local dev cluster creation
- **Security updates** across Kafka Broker dependencies and a RabbitMQ ingress shutdown race fix

Minimal supported version of Kubernetes is 1.34. See our [release schedule](https://github.com/knative/community/blob/main/mechanics/RELEASE-SCHEDULE.md) for details.

## Serving

**Release notes**: [Knative Serving 1.23](https://github.com/knative/serving/releases/tag/knative-v1.23.0)

This release adds ephemeral volume support, IPv6 networking improvements, and startup probe validation.

**Generic Ephemeral Volumes**

Serving now supports generic ephemeral volumes via `volumeClaimTemplate`, behind the `kubernetes.podspec-volumes-ephemeral` feature flag ([#16590](https://github.com/knative/serving/pull/16590) by [@jbunting](https://github.com/jbunting)). This allows workloads to request dynamically provisioned storage that is tied to the pod lifecycle without needing pre-created PVCs.

**Startup Probe Validation**

Validation has been added for startup probes in user and sidecar containers ([#16594](https://github.com/knative/serving/pull/16594) by [@thiagomedina](https://github.com/thiagomedina)), catching misconfigured probes at admission time rather than at runtime.

**IPv6 Support for Autoscaler**

The autoscaler EndpointSlice creation and activator port replacement now support IPv6 ([#16591](https://github.com/knative/serving/pull/16591) by [@linkvt](https://github.com/linkvt)), extending dual-stack networking support in Serving.

**Bug Fixes**

A fix was made to the ResponseRecorder hijack state tracking for WebSocket connections ([#16611](https://github.com/knative/serving/pull/16611) by [@immanuwell](https://github.com/immanuwell)).

---

### Serving Networking Extensions

#### net-contour

**Release notes**: [net-contour 1.23](https://github.com/knative-extensions/net-contour/releases/tag/knative-v1.23.0)

**Contour Updated to v1.33.5**

Contour has been bumped to v1.33.5 ([#1292](https://github.com/knative-extensions/net-contour/pull/1292) by [@dprotaso](https://github.com/dprotaso)), picking up the latest bug fixes and patches.


#### net-gateway-api

**Release notes**: [net-gateway-api 1.23](https://github.com/knative-extensions/net-gateway-api/releases/tag/knative-v1.23.0)

**Proxy Protocol Support**

Support for proxy protocol has been added ([#947](https://github.com/knative-extensions/net-gateway-api/pull/947) by [@BobyMCbobs](https://github.com/BobyMCbobs)), enabling backends to receive the original client connection information when traffic passes through load balancers.


#### net-istio

**Release notes**: [net-istio 1.23](https://github.com/knative-extensions/net-istio/releases/tag/knative-v1.23.0)

A maintenance release with CI fixes and dependency updates.


#### net-kourier

**Release notes**: [net-kourier 1.23](https://github.com/knative-extensions/net-kourier/releases/tag/knative-v1.23.0)

**IPv6 Support**

IPv6 support has been added to Kourier ([#1455](https://github.com/knative-extensions/net-kourier/pull/1455) by [@linkvt](https://github.com/linkvt)), extending dual-stack networking support across the Knative networking stack.

---

## Eventing

**Release notes**: [Knative Eventing 1.23](https://github.com/knative/eventing/releases/tag/knative-v1.23.0)

This release focuses on reliability fixes and modernizing the networking layer.

**EndpointSlice Migration**

Eventing has migrated from deprecated v1 Endpoints to `discovery.k8s.io/v1` EndpointSlice ([#9032](https://github.com/knative/eventing/pull/9032) by [@creydr](https://github.com/creydr)), aligning with the Kubernetes deprecation timeline and improving scalability.

**Configurable klog Verbosity**

A `klog-verbosity` flag has been added to the `config-logging` ConfigMap ([#9035](https://github.com/knative/eventing/pull/9035) by [@Ankitsinghsisodya](https://github.com/Ankitsinghsisodya)), giving operators more control over log verbosity without redeploying.

**Bug Fixes**

- JobSink status Location paths for event metadata containing slashes have been fixed ([#9100](https://github.com/knative/eventing/pull/9100) by [@immanuwell](https://github.com/immanuwell))
- A goroutine and memory leak in `SubjectAndFiltersPass` has been fixed ([#9151](https://github.com/knative/eventing/pull/9151) by [@creydr](https://github.com/creydr))
- The vreplica spreading across `minReplicas` pods in the scheduler has been fixed ([#9157](https://github.com/knative/eventing/pull/9157) by [@creydr](https://github.com/creydr))

---

### Eventing Extensions

#### Apache Kafka Broker

**Release notes**: [Kafka Broker 1.23](https://github.com/knative-extensions/eventing-kafka-broker/releases/tag/knative-v1.23.0)

This release brings improved error handling, security patches, and several data-plane fixes.

**Improved Error Handling**

Error handling has been improved across broker, channel, consumer group, and trigger reconcilers ([#4724](https://github.com/knative-extensions/eventing-kafka-broker/pull/4724) by [@chriscannon](https://github.com/chriscannon)), making it easier to diagnose reconciliation failures.

**Security Updates**

Netty, logback-core, vertx-core, and jackson-core have been updated to resolve known vulnerabilities ([#4744](https://github.com/knative-extensions/eventing-kafka-broker/pull/4744)).

**Bug Fixes**

- The KafkaSink reconciler cluster admin error has been fixed ([#4720](https://github.com/knative-extensions/eventing-kafka-broker/pull/4720) by [@chriscannon](https://github.com/chriscannon))
- A null check has been added to `ExactFilter` to handle missing `FilterAttributes` ([#4717](https://github.com/knative-extensions/eventing-kafka-broker/pull/4717) by [@Dominic-Stout-GA-i3](https://github.com/Dominic-Stout-GA-i3))
- The OpenTelemetry BOM ordering has been fixed to ensure the declared version takes precedence ([#4752](https://github.com/knative-extensions/eventing-kafka-broker/pull/4752) by [@creydr](https://github.com/creydr))
- A timer drift in the cache implementation has been fixed ([#4762](https://github.com/knative-extensions/eventing-kafka-broker/pull/4762) by [@dsimansk](https://github.com/dsimansk))


#### RabbitMQ Broker and Source

**Release notes**: [RabbitMQ 1.23](https://github.com/knative-extensions/eventing-rabbitmq/releases/tag/knative-v1.23.0)

This release adds adapter customization and fixes an ingress shutdown race condition.

**Customizable Adapter Container Name**

The RabbitmqSource adapter container name can now be customized ([#1762](https://github.com/knative-extensions/eventing-rabbitmq/pull/1762) by [@vgaidarji](https://github.com/vgaidarji)).

**Ingress Shutdown Race Fix**

A race condition between RabbitMQ connection close and HTTP drain during ingress shutdown has been fixed ([#1760](https://github.com/knative-extensions/eventing-rabbitmq/pull/1760) by [@deadtrickster](https://github.com/deadtrickster)).

---

## Functions

**Release notes**: [Functions 1.23](https://github.com/knative/func/releases/tag/knative-v1.23.0)

A substantial release with new commands, improved builder support, and a growing MCP server.

**New `func logs` Command**

A new `func logs` command streams function logs directly from the CLI ([#3669](https://github.com/knative/func/pull/3669) by [@Itx-Psycho0](https://github.com/Itx-Psycho0)), removing the need to switch to `kubectl` or a dashboard to see what your function is doing.

**Dev Cluster Creation with `func clusters`**

The new `func clusters` command can create local development clusters with Knative pre-installed ([#3754](https://github.com/knative/func/pull/3754) by [@lkingland](https://github.com/lkingland)), making it easier to get a working Knative environment for local development.

**Kafka Event Sourcing for Go Functions**

Go functions can now be scaffolded with Kafka event sourcing support ([#3950](https://github.com/knative/func/pull/3950) by [@aliok](https://github.com/aliok)), providing a ready-made template for consuming Kafka events.

**ImagePullSecret Support**

Functions now support specifying an `ImagePullSecret` ([#3656](https://github.com/knative/func/pull/3656) by [@creydr](https://github.com/creydr)), enabling deployments from private registries that require authentication.

**func-operator Integration**

The deploy command now integrates with the func-operator ([#3657](https://github.com/knative/func/pull/3657) by [@creydr](https://github.com/creydr)), and the deployer choice is now persisted in `func.yaml` with guards against incompatible deployer switches ([#3953](https://github.com/knative/func/pull/3953) by [@gauron99](https://github.com/gauron99)).

**Improved `.funcignore` Support**

`.funcignore` rules are now applied consistently across the host builder ([#3624](https://github.com/knative/func/pull/3624) by [@lkingland](https://github.com/lkingland)) and the OCI builder ([#3789](https://github.com/knative/func/pull/3789) by [@gauron99](https://github.com/gauron99)).

**AWS ECR Credentials Loader**

An AWS ECR credentials loader has been added to Kubernetes keychains ([#3864](https://github.com/knative/func/pull/3864) by [@Nachiket-Roy](https://github.com/Nachiket-Roy)), enabling seamless authentication with ECR registries in cluster builds.

**MCP Server Improvements**

The MCP server received numerous fixes and enhancements, including secret and ConfigMap support for `config_envs_add` ([#3685](https://github.com/knative/func/pull/3685) by [@Ankitsinghsisodya](https://github.com/Ankitsinghsisodya)), split config tools for accurate tool annotations ([#3661](https://github.com/knative/func/pull/3661) by [@Ankitsinghsisodya](https://github.com/Ankitsinghsisodya)), and version info in healthcheck output ([#3745](https://github.com/knative/func/pull/3745) by [@cubaseuser123](https://github.com/cubaseuser123)).

**Security Hardening**

Config files now use secure file permissions ([#3726](https://github.com/knative/func/pull/3726) by [@Itx-Psycho0](https://github.com/Itx-Psycho0)), GitHub webhooks default to TLS verification ([#3714](https://github.com/knative/func/pull/3714) by [@Vi-shub](https://github.com/Vi-shub)), and shell metacharacters are now rejected in prefix validation ([#3760](https://github.com/knative/func/pull/3760) by [@Elvand-Lie](https://github.com/Elvand-Lie)).

**IPv6 and Dual-Stack Support**

Multiple fixes improve IPv6 support: dual-stack `net.Dial` via Happy Eyeballs ([#3692](https://github.com/knative/func/pull/3692)), IPv6 in local Kind cluster setup ([#3693](https://github.com/knative/func/pull/3693)), and listening on IPv6 loopback ([#3817](https://github.com/knative/func/pull/3817)) — all by [@matejvasek](https://github.com/matejvasek).

---

## Client

**Release notes**: [Client 1.23](https://github.com/knative/client/releases/tag/knative-v1.23.0)

A maintenance release with dependency updates and CI improvements.


### kn-plugin-quickstart

**Release notes**: [Quickstart 1.23](https://github.com/knative-extensions/kn-plugin-quickstart/releases/tag/knative-v1.23.0)

**Custom Kind Host Port**

You can now set a custom host port when creating Kind clusters ([#660](https://github.com/knative-extensions/kn-plugin-quickstart/pull/660) by [@psschwei](https://github.com/psschwei)), making it easier to avoid port conflicts in multi-cluster or shared development environments.

**Improved Startup Reliability**

The plugin now waits for pods to appear before checking readiness ([#669](https://github.com/knative-extensions/kn-plugin-quickstart/pull/669) by [@psschwei](https://github.com/psschwei)), fixing race conditions during cluster setup.


### Other Client Plugins

These releases contain dependency updates:

- [kn-plugin-admin](https://github.com/knative-extensions/kn-plugin-admin/releases/tag/knative-v1.23.0)
- [kn-plugin-event](https://github.com/knative-extensions/kn-plugin-event/releases/tag/knative-v1.23.0)
- [kn-plugin-source-kafka](https://github.com/knative-extensions/kn-plugin-source-kafka/releases/tag/knative-v1.23.0)

---

## Operator

**Release notes**: [Operator 1.23](https://github.com/knative/operator/releases/tag/knative-v1.23.0)

This release switches to the official secretreader plugin and includes fixes for CRD webhooks and eventing RBAC.

**Official SecretReader Plugin**

The operator now uses the official secretreader plugin ([#2306](https://github.com/knative/operator/pull/2306) by [@kahirokunn](https://github.com/kahirokunn)), replacing the previous custom implementation.

**Bug Fixes**

- Operator CRD conversion webhooks have been restored ([#2293](https://github.com/knative/operator/pull/2293) by [@kahirokunn](https://github.com/kahirokunn))
- `AggregationRuleTransform` has been moved to a shared common package to fix an eventing RBAC race condition ([#2316](https://github.com/knative/operator/pull/2316) by [@creydr](https://github.com/creydr))

---

## Thank you, contributors

Release Leads:

- [@dsimansk](https://github.com/dsimansk)

New Contributors 🎉:

- [@brucearctor](https://github.com/brucearctor)
- [@chriscannon](https://github.com/chriscannon)
- [@cubaseuser123](https://github.com/cubaseuser123)
- [@deadtrickster](https://github.com/deadtrickster)
- [@Dominic-Stout-GA-i3](https://github.com/Dominic-Stout-GA-i3)
- [@Elvand-Lie](https://github.com/Elvand-Lie)
- [@gouthamhusky](https://github.com/gouthamhusky)
- [@immanuwell](https://github.com/immanuwell)
- [@Itx-Psycho0](https://github.com/Itx-Psycho0)
- [@jahnavigajjala-3](https://github.com/jahnavigajjala-3)
- [@jbunting](https://github.com/jbunting)
- [@mdering](https://github.com/mdering)
- [@Nachiket-Roy](https://github.com/Nachiket-Roy)
- [@Shrey327](https://github.com/Shrey327)
- [@vgaidarji](https://github.com/vgaidarji)
- [@Vi-shub](https://github.com/Vi-shub)
- [@vishwas-droid](https://github.com/vishwas-droid)
- [@xenonnn4w](https://github.com/xenonnn4w)

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
