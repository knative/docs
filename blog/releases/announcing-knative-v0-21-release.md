---
title: "Version v0.21 release"
linkTitle: "Version v0.21 release"
Author: "[Carlos Santana](https://twitter.com/csantanapr)"
Author handle: https://github.com/csantanapr
date: 2021-02-26
description: "Knative v0.21 release announcement"
type: "blog"
image: knative-eventing.png
---


### Announcing Knative v0.21 Release

A new version of Knative is now available across multiple components.
Follow the instructions in the documentation [Installing Knative](https://knative.dev/docs/install/) for the respective component.

#### Table of Contents
- [Serving v0.21](#serving-v020)
- [Eventing v0.21](#eventing-v020)
- Eventing Extensions
    - [Eventing Kafka Broker v0.21](#eventing-kafka-broker-v020)
- [CLI v0.21](#client-v020)
- [Operator v0.21](#operator-v020)
- [Thank you contributors v0.21](#thank-you-contributors-v0.21)


### Highlights

- Kubernetes minimum version has changed to v1.18
    - See our [K8s minimum version principle](https://github.com/knative/community/blob/master/mechanics/RELEASE-VERSIONING-PRINCIPLES.md#k8s-minimum-version-principle)
- Now Serving supports Istio 1.9 and Contour 1.12
- Fix for DomainMapping when using Kourier with AutoTLS
- Eventing Source **PingSource** binary mode has breaking changes.
- Eventing sync has the ability to know when to reply, see the [event reply header contract](https://github.com/knative/eventing/blob/release-0.21/docs/spec/data-plane.md#event-reply-contract) specification for more details.



### Serving v0.21

#### 🚨 Breaking or Notable

- Kubernetes minimum version has changed to v1.18
    - See our [K8s minimum version principle](https://github.com/knative/community/blob/master/mechanics/RELEASE-VERSIONING-PRINCIPLES.md#k8s-minimum-version-principle)
- GC v1 and Labeler v1 deprecated and removed from the code base
- Webhooks certificates now use Ed25519 instead of RSA/2048 and have an expiry of one week ([knative/pkg#1998](https://github.com/knative/pkg/pull/1998))

#### 💫 New Features & Changes

- Introduces autocreateClusterDomainClaim in config-network config map. This allows DomainMappings to be safely used in shared clusters by disabling automatic ClusterDomainClaim creation. With this option set to "false", cluster administrators must explicitly delegate domain names to namespaces by creating a ClusterDomainClaim with an appropriate spec.Namespace set. ([#10537](https://github.com/knative/serving/pull/10537))
- Domain mappings disallow mapping from cluster local domain names (generally domains under "cluster.local") ([#10798]())
- Allow setting ReadOnlyRootFilesystem on the container's SecurityContext ([#10560](https://github.com/knative/serving/pull/10560))
- A container's readiness probe FailureThreshold & TimeoutSeconds are now defaulted to 3 and 1 respectively when a user opts into non-aggressive probing (ie. PeriodTimeout > 1) ([#10700](https://github.com/knative/serving/pull/10700))
- Avoids implicitly adding an "Accept-Encoding: gzip" header to proxied requests if one was not already present. ([#10691](https://github.com/knative/serving/pull/10691))
- Gradual Rollout is possible to set on individual Revisions usingserving.knative.dev/rolloutDuration annotation, ([#10561](https://github.com/knative/serving/pull/10561))
- Support Istio 1.9 (knative-sandbox/net-istio#515](https://github.com/knative-sandbox/net-istio/pull/515))
- Support Contour 1.12 (knative-sandbox/net-contour#414](https://github.com/knative-sandbox/net-contour/pull/414))

#### 🐞 Bug Fixes

- Fixes problem with domainmapping when working with auto-tls and kourier challenge ([#10811](https://github.com/knative/serving/pull/10811)
- Fixed a bug where the activator's metrics could get stuck and thus scale to and from zero didn't work as expected. ([#10729](https://github.com/knative/serving/pull/10729))
- Fixes a race in Queue Proxy drain logic that could, in a very unlikely edge case, lead to the pre-stop hook not exiting even though draining has finished ([#10781](https://github.com/knative/serving/pull/10781))
- Avoid slow out-of-memory issue related to metrics ([knative/pkg#2005](https://github.com/knative/pkg/pull/2020))
- Stop reporting reflector metrics since they were removed upstream ([knative/pkg#2020](https://github.com/knative/pkg/pull/2020))

### Eventing v0.21

#### 🚨 Breaking or Notable

- **BREAKING CHANGE**: PingSource binary mode now sends the actual binary data in event body instead of base64-encoded form. (#4851](https://github.com/knative/eventing/pull/4851), @eclipselu)
- You need to run the storage migration tool after the upgrade to migrate from `v1beta1` to `v1beta2` `pingsources.sources.knative.dev` resources. (#4750](https://github.com/knative/eventing/pull/4750), @eclipselu)


#### 💫 New Features & Changes

- Adding HorizontalPodAutoscaler and PodDisruptionBudget for the eventing webhook ([#4792](https://github.com/knative/eventing/pull/4792))
- Add [event reply header contract](https://github.com/knative/eventing/blob/release-0.21/docs/spec/data-plane.md#event-reply-contract) to the spec ([#4560](https://github.com/knative/eventing/pull/4560))
- Cloudevent traces available for PingSource ([#4877](https://github.com/knative/eventing/pull/4877))
- CloudEvents send to dead-letter endpoints include extension attribute called ce-knativedispatcherr which contains encoded HTTP Response error information from final dispatch attempt. ([#4760](https://github.com/knative/eventing/pull/4760), @travis-minke-sap)
- Message receiver supports customized liveness and readiness check ([#4730](https://github.com/knative/eventing/pull/4730))
- The imc-dispatcher service adds new trace span attributes to be consistent with broker-ingress.knative-eventing & broker-filter.knative-eventing services. The new attributes are messaging.destination, messaging.message_id, messaging.protocol and messaging.system ([#4659](https://github.com/knative/eventing/pull/4659))
- Add Trigger.Delivery field which allows configuration of Delivery per Trigger. ([#4654](https://github.com/knative/eventing/pull/4654))

#### 🐞 Bug Fixes

- Fix availability of zipkin traces for APIServerSource ([#4842](https://github.com/knative/eventing/pull/4842))
- Fix bug where sometimes the pods were not deemed up during setup. ([#4725](https://github.com/knative/eventing/pull/4725), [#4741](https://github.com/knative/eventing/pull/4741))
- Fix bug where v1beta1 would allow mutations to immutable fields. v1beta1 trigger.spec.broker is immutable. ([#4843](https://github.com/knative/eventing/pull/4843))

#### 🧹 Clean up

- Now the config-imc-event-dispatcher values are not configurable on-fly anymore, that is, if you need to configure such values, you need to redeploy the dispatcher deployment ([#4543](https://github.com/knative/eventing/pull/4543))
- PingSource: remove special handling of JSON data since events are always sent in binary mode. ([#4858](https://github.com/knative/eventing/pull/4858))
- Cleanup channel duck types internals ([#4749](https://github.com/knative/eventing/pull/4749))

### Eventing Extensions

#### 💫 New Features & Changes

#### 🐞 Bug Fixes

#### 🧹 Clean up

### Client v0.21

### CLI Plugins

#### 💫 New Features & Changes

#### 🧹 Clean up

#### Other CLI Features

### Operator v0.21

#### 🐞 Bug Fixes

#### 🧹 Clean up

### Thank you contributors v0.21

https://github.com/whaught
https://github.com/Harwayne
https://github.com/julz
https://github.com/senthilnathan
https://github.com/shinigambit
https://github.com/vagababov
https://github.com/arturenault
https://github.com/mattmoor
https://github.com/markusthoemmes
https://github.com/skonto
https://github.com/eclipselu
https://github.com/matzew
https://github.com/zhongduo
https://github.com/Shashankft9
https://github.com/travis-minke-sap
https://github.com/grac3gao
https://github.com/xtreme-sameer-vohra
https://github.com/slinkydeveloper
https://github.com/vaikas
https://github.com/lionelvillard



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
