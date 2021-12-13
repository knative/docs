---
title: "v0.18 release"
linkTitle: "v0.18 release"
Author: Carlos Santana
Author handle: https://twitter.com/csantanapr
date: 2020-09-30
description: "Knative v0.18 release announcement"
type: "blog"
image: knative-eventing.png
---


## Announcing Knative v0.18 Release

A new version of Knative is now available across multiple components.
Follow the instructions in the documentation [Installing Knative](https://knative.dev/docs/install/) for the respective component.

- Kubernetes minimum version has changed to v1.17
  - See our [K8s minimum version principle](https://github.com/knative/community/blob/main/mechanics/RELEASE-VERSIONING-PRINCIPLES.md#k8s-minimum-version-principle)
- Eventing APIs gradauted from v1beta1 to v1
- Eventing Contribution sources are moved to a new github organization [knative-sandbox](https://github.com/knative-sandbox)
- The `kn` CLI now has alias for commands and other new features.

Remember to check the [upgrade docs](https://knative.dev/docs/install/upgrade-installation/) for any concerns applicable to your current version before you upgrade to the latest version.


### Serving v0.18

**Serving v1alpha1 & v1beta1 will EOL in our next release (v0.19)**
- This applies to the resources: Service, Route, Revision, Configuration
- You will want to migrate your storage version for these resources to v1 using our [post-install job](https://github.com/knative/serving/blob/main/config/post-install/storage-version-migration.yaml)

**Breaking EnableVarLogCollection behaviour**
- We always mount a emptyDir volume at /var/log in our user-containers. This impacts some popular containers images (ie. nginx) preventing them from starting.
- In the next release (v0.19) we plan on changing this default behaviour and only mount a volume when EnableVarLogCollection is set to true.
- Please reach out in [#7881](https://github.com/knative/serving/issues/7881) if you have issues/comments about the approach & timeline.

**net-contour has moved to stable status**

**Kubernetes minimum version changed to 1.17**


#### Core API

- [#9264](https://github.com/knative/serving/pull/9264) Add support for serviceAccountToken in projected volumes.
- [#9072](https://github.com/knative/serving/pull/9072) Added RuntimeClassName feature flag.
- [#9325 ](https://github.com/knative/serving/pull/9325) Fixes a race where the Route controller would report readiness prematurely.
- [#9489](https://github.com/knative/serving/pull/9489) For security reasons, registries that are shipping image metadata on TLS version 1.0 or 1.1 are no longer supported.
- [#9455](https://github.com/knative/serving/pull/9455),[#9354](https://github.com/knative/serving/pull/9354),[#9442](https://github.com/knative/serving/pull/9442) Digest resolution improvements & timeout.
- [#9335](https://github.com/knative/serving/pull/9335) Responsive revision garbage collection is on (allowed) by default.
- [knative/pkg#1464](https://github.com/knative/pkg/pull/1464) Reduce the cardinality of our webhook metrics to reduce memory usage.

#### Autoscaling

- [#9506](https://github.com/knative/serving/pull/9506),[#9502](https://github.com/knative/serving/pull/9502),[#9503](https://github.com/knative/serving/pull/9503),[#9566](https://github.com/knative/serving/pull/9566),[#9501](https://github.com/knative/serving/pull/9501),[#9488](https://github.com/knative/serving/pull/9488),[#9344](https://github.com/knative/serving/pull/9344),[#9338](https://github.com/knative/serving/pull/9338),[#9287](https://github.com/knative/serving/pull/9287),[#9184](https://github.com/knative/serving/pull/9184) Improving performance, memory allocation, testability and readability of the codebase
- [#9419](https://github.com/knative/serving/pull/9419),[#9426](https://github.com/knative/serving/pull/9426),[#9434](https://github.com/knative/serving/pull/9434) Max Scale Limit configuration
- [#9211](https://github.com/knative/serving/pull/9211),[#9176](https://github.com/knative/serving/pull/9176) Use Unix socket for probing in QueueProxy
- [#9133](https://github.com/knative/serving/pull/9133),[#9113](https://github.com/knative/serving/pull/9113) Random Shuffle for pod scraping improving the variety of the pods that we scrape in autoscaler
- Permit and use configuration to the number of cached connections in the Activator
- [#9358](https://github.com/knative/serving/pull/9358) The absence of autoscaling annotations in both Service and Configuration's top-level metadata is now validated. This gives users an actionable error message but might potentially cause old (faulty) YAML to start to fail to be accepted now.


#### Networking

- [knative/docs#2808](https://github.com/knative/docs/pull/2808) Net-contour is moved to stable stage
- [#9194](https://github.com/knative/serving/pull/9194) Allow disabling AutoTLS with an annotation
- [#9013](https://github.com/knative/serving/pull/9013) Use networking.knative.dev/visibility instead of serving.knative.dev/visibility
- [knative/networking#164](https://github.com/knative/networking/pull/164) Remove short-names for gateways with all-numeric Top Level Domains
- [knative/networking#154](https://github.com/knative/networking/pull/154) Move Kcert and KIngress CRDs yaml from serving to networking repo.
- [#9375](https://github.com/knative/serving/pull/9375) Serving repo has the CRDs yaml as symlinks from networking repo.
- [knative/networking#139](https://github.com/knative/networking/pull/139) Make kingress conformance amenable to KinD
- [knative/networking#129](https://github.com/knative/networking/pull/129),[knative/networking#132](https://github.com/knative/networking/pull/132),[knative/networking#137](https://github.com/knative/networking/pull/137) Deprecate retry, ingress.spec.visibility and ingress.status.LoadBalancer in Ingress
- [knative/networking#107](https://github.com/knative/networking/pull/107) Rework RewriteHost to require splits.
- [#8856](https://github.com/knative/serving/pull/8856) The `tagHeaderBasedRouting` flag in `config-network` is moved to `config-features` as `tag-header-based-routing`.
- [knative-sandbox/net-istio#237](https://github.com/knative-sandbox/net-istio/pull/237) Add a new local gateway sharing same deployment as ingress Gateway for the future cluster local gateway deprecation

### Eventing v0.18

Eventing APIs graduated from v1beta1 to v1

#### Action Required for Upgrades

- [#4031](https://github.com/knative/eventing/pull/4031) You must run pre-install job prior to upgrading to get apiserversource to v1beta1 API.
- [#3936](https://github.com/knative/eventing/pull/3936) Change storage version of remaining messaging.- resources from v1beta1 to v1:
    - “Subscriptions.messaging.knative.dev”
    - You must run pre-install job prior to upgrading to get messaging.- resources to v1 API.
- [#3951](https://github.com/knative/eventing/pull/3951) Change storage versions of pingsource resource from v1alpha2 to v1beta1 API
    - You must run pre-install job prior to upgrading to get pingsource resources to v1beta2 API.
- [#3923](https://github.com/knative/eventing/pull/3923) Change storage versions of eventing.- resources from v1beta1 to v1:
    - “brokers.eventing.knative.dev”
    - “Triggers.eventing.knative.dev”
    - You must run pre-install job prior to upgrading to get eventing.- resources to v1 API.
- [#3925](https://github.com/knative/eventing/pull/3925) Change storage versions of flows.- resources from v1beta1 to v1:
    - “Channels.messaging.knative.dev”
    - “Inmemorychannels.messaging.knative.dev”
    - You must run pre-install job prior to upgrading to get messaging.- resources to v1 API.
- [#3924](https://github.com/knative/eventing/pull/3924) Change storage versions of flows.- resources from v1beta1 to v1:
    - “Parallels.flows.knative.dev”
    - “Sequences.flows.knative.dev”
    - You must run pre-install job prior to upgrading to get flows.- resources to v1 API.


#### New Features

- [#3962](https://github.com/knative/eventing/pull/3962) Allow MTChannelBroker TTL to be configured via ENV variable.
- [#4009](https://github.com/knative/eventing/pull/4009) PingSource adapter now uses bucket-based leader election
- [#3987](https://github.com/knative/eventing/pull/3987) PingSource adapter deployment can now be customized at installation time


#### Bug Fixes

- [#4115](https://github.com/knative/eventing/pull/4115) The default exponential backoff duration now matches the advertised algorithm in the DeliverySpec.BackoffDelay comments. User action required to evaluate if DeliverySpec.BackoffDelay settings in `Subscription.spec.delivery` remain appropriate
- [#4112](https://github.com/knative/eventing/pull/4112) Channels and Brokers correctly retry on non 2xx HTTP status codes
- [#4099](https://github.com/knative/eventing/pull/4099) Make pingsource adapter controller read-only
- [#3946](https://github.com/knative/eventing/pull/3946) If you create a Parallel, then later add branches to it, caused a panic.
- [#3897](https://github.com/knative/eventing/pull/3897) In cases where Filter sends a message and it fails or response is nil, it will panic because it uses it.
- [#3906](https://github.com/knative/eventing/pull/3906) Tests sometimes flake when the webhook fails.
- [#4042](https://github.com/knative/eventing/pull/4042) The subscription reconciler correctly propagates delivery configurations to the channel (`retry`, `backoffDelay`, `backoffPolicy`).
- [#3966](https://github.com/knative/eventing/pull/3966) Trigger reconciler correctly reconciles Triggers during parallel updates of the Trigger and the referenced Broker.
- [#4030](https://github.com/knative/eventing/pull/4030) When not reconciling triggers not owned by my brokerclass, would print incorrect msg, logic was correct however, just wrong log message.
- [#3870](https://github.com/knative/eventing/pull/3870) Update the spec to include v1 of the channelable.


### Eventing Contributions v0.18

Code moved to the the [knative-sandbox](https://github.com/knative-sandbox/) Github organization

#### Action Required

- [knative/eventing#3924](https://github.com/knative/eventing/pull/3924),[knative/eventing#3925](https://github.com/knative/eventing/pull/3925) Change storage versions of flows.- resources from v1beta1 to v1
    - `channels.messaging.knative.dev`
    - `inmemorychannels.messaging.knative.dev`
    - `parallels.flows.knative.dev`
    - `sequences.flows.knative.dev`
    - You must run pre-install job prior to upgrading to get eventing.- resources to v1 API.


#### New Features

- [#1510](https://github.com/knative/eventing-contrib/pull/1510) Kafka Channel and Kafka Source support Kafka 2.6 (#1510, @pierDipi)


#### Bug Fixes

- [#1536](https://github.com/knative/eventing-contrib/pull/1536) Cluster scoped KafkaChannel dispatcher is now created with 0 replicas in advance and will be scaled up with the creation of the first KafkaChannel. No manual operation is needed when upgrading.
- [#1533](https://github.com/knative/eventing-contrib/pull/1533) When kafkasource goes into “sink not found” status, receiver adapter will be deleted. The receiver adapter will be created again when the sink is available and ready to receive events.


#### Code Moved to a different github organization

- [#1576](https://github.com/knative/eventing-contrib/pull/1576) The AWSSQS source artifacts have moved to https://github.com/knative-sandbox/eventing-awssqs
- [#1574](https://github.com/knative/eventing-contrib/pull/1574) The Camel artifacts have moved to https://github.com/knative-sandbox/eventing-camel
- [#1585](https://github.com/knative/eventing-contrib/pull/1585) The Ceph source artifacts have moved to https://github.com/knative-sandbox/eventing-ceph
- [#1583](https://github.com/knative/eventing-contrib/pull/1583) The CouchDB source artifacts have moved to https://github.com/knative-sandbox/eventing-couchdb
- [#1573](https://github.com/knative/eventing-contrib/pull/1573) The GitHub artifacts have moved to https://github.com/knative-sandbox/eventing-github
- [#1584](https://github.com/knative/eventing-contrib/pull/1584) The GitLab source artifacts have moved to https://github.com/knative-sandbox/eventing-gitlab
- [#1587](https://github.com/knative/eventing-contrib/pull/1587) The Natss artifacts have moved to https://github.com/knative-sandbox/eventing-natss
- [#1586](https://github.com/knative/eventing-contrib/pull/1586) The Prometheus source artifacts have moved to https://github.com/knative-sandbox/eventing-prometheus
- [#1555](https://github.com/knative/eventing-contrib/pull/1555) Remove camel source from this repo. move it to https://github.com/knative-sandbox/eventing-camel
- [#3923](https://github.com/knative/eventing-contrib/pull/3923) versions of eventing.- resources from v1beta1 to v1
    - `brokers.eventing.knative.dev`
    - `triggers.eventing.knative.dev`
    - You must run pre-install job prior to upgrading to get eventing.- resources to v1 API.


### Client v0.18

Release 0.18.0 of the Knative client `kn` comes with some bug fixes plus some additional support for Knative eventing features

#### Eventing Support

The `kn channel` support has been extended by a `kn channel list-types` which shows you all the channel types that are available in the cluster.
This information can be used to select the type when creating a channel with `kn channel create`.

Subscriptions which connect a sink with a channel can now be fully managed with `kn subscription` commands.


#### Aliases

For a better user experience we added some aliases for commonly used commands:

| Command | ALias |
| --- | --- |
| service | ksvc, services |
| revision | revisions |
| route | routes |
| source | sources |
| broker | brokers |
| trigger | triggers |
| channel | channels |
| subscription | subscriptions, sub |
| plugin | plugins |
| list | ls |


#### Other Changes

- You can use now `--annotation-service` and `--annotation-revision` to select the part of Knative service where you want to put an annotation on. With `--annotation` you add an annotation to both parts, the Knative service's annotation and to the annotation of the Pod template used to create revisions.
- A new option `--scale-init` allows to specify the initial number of pods that should be created when a Knative service is created. By default this number is one, but you can set it to 0 if you don't want to create a pod during service creation.

### Operator v0.18


The new operator can now deploy the new version `v0.18` of serving and eventing components.

#### Bug Fixes

- [#202](https://github.com/knative/operator/pull/202) Docs for publishing the operator in OperatorHub
- [#299](https://github.com/knative/operator/pull/299) Don't wait for Ksvc to scale to zero


#### Other Changes

- [#266](https://github.com/knative/operator/pull/266) Skip the version checking for network ingress deployment
- [#275](https://github.com/knative/operator/pull/275) Bumping k8s to 1.18
- [#273](https://github.com/knative/operator/pull/273) Add linting config and fix issues
- [#278](https://github.com/knative/operator/pull/278) Transform jobs first so images are overridable
- [#280](https://github.com/knative/operator/pull/280) Pin deps to release-0.18


### Learn more
Knative is an open source project that anyone in the [community](https://knative.dev/docs/community/) can use, improve, and enjoy. We'd love you to join us!

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
