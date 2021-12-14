---
title: "v0.17 release"
linkTitle: "v0.17 release"
Author: Carlos Santana
Author handle: https://twitter.com/csantanapr
date: 2020-08-24
description: "Knative v0.17 release announcement"
type: "blog"
image: knative-eventing.png
---


## Announcing Knative v0.17 Release

A new version of Knative is now available across multiple components.
Follow the instructions in the documentation [Installing Knative](https://knative.dev/docs/install/) for the respective component.
- Serving continues their journey with test and benchmark optimizations on the already v1 API version.
- Eventing now provides ContainerSource and PingSource as v1beta1.
- `kn` CLI continues the journey to full Eventing support adding Channel resources.
- Operator adds support of customized manifests for Knative installation.

Remember to check the [upgrade docs](https://knative.dev/docs/install/upgrade-installation/) for any concerns applicable to your current version before you upgrade to the latest version.


### Serving v0.17

**InitialScale annotation to control the initial deployment size**

There is a new annotation that can be used to control the number of pods that are initially deployed when new Revisions are rolled out.

**net-contour and net-kourier have moved to Beta**

In addition to net-istio, Knative now supports three other networking layers that are in Beta status.

**Kubernetes minimum version has NOT changed**

Kubernetes **1.16** remains as the minimum version.

<details><summary>Autoscaling</summary>

- [ [#8613](https://github.com/knative/serving/pull/8613), [#8846](https://github.com/knative/serving/pull/8846) ] Launched the initial scale with possibility of starting with 0 (thanks [@taragu](https://github.com/taragu))
- Launched new KPA statuses, which permit significant simplification of the state machine in revision and KPA itself:
    - Initial scale reached (thanks [@markusthoemmes](https://github.com/markusthoemmes) & [@taragu](https://github.com/taragu))
    - SKS ready (thanks [@vagababov](https://github.com/vagababov))
- [ [#8787](https://github.com/knative/serving/pull/8787), [#8796](https://github.com/knative/serving/pull/8796) ] Concurrency & stat reporting rewrite in Activator (thanks [@markusthoemmes](https://github.com/markusthoemmes))
- [ [#8810](https://github.com/knative/serving/pull/8810), [#9027](https://github.com/knative/serving/pull/9027) ] Configurable idle conns/conns per host (thanks [@vagababov](https://github.com/vagababov) & [@julz](https://github.com/julz))
- [ [#8759](https://github.com/knative/serving/pull/8759),[#8762](https://github.com/knative/serving/pull/8762) ] Optimize pod counting in KPA (3 passes over pods to 1) (thanks [@vagababov](https://github.com/vagababov))
- [#8851](https://github.com/knative/serving/pull/8851) Tricky optimization of returned lambda in activator saving 16b allocations per every request in activator (thanks [@julz](https://github.com/julz))
- Lots of new benchmarks (thanks [@julz](https://github.com/julz) & [@markusthoemmes](https://github.com/markusthoemmes))
- Various cleanups, test stability, code optimizations, etc (thanks [@julz](https://github.com/julz), [@markusthoemmes](https://github.com/markusthoemmes), [@vagababov](https://github.com/vagababov), [@skonto](https://github.com/skonto))

</details>


<details><summary>Core API</summary>

- Leader Election enabled by default (thanks [@mattmoor](https://github.com/mattmoor))
    - By default control plane components now enable leader election, which can be disabled (for now) with --disable-ha.
- New feature flags are now available - see config-features for details
    - [#8645](https://github.com/knative/serving/pull/8645) Enable affinity, nodeSelector and tolerations (thanks [@emaildanwilson](https://github.com/emaildanwilson))
    - [#9060](https://github.com/knative/serving/pull/9060) Enable additional container & pod security context attributes (thanks [@dprotaso](https://github.com/dprotaso))
- [pkg#1512](https://github.com/knative/pkg/pull/1512) Adopt a two-lane work queue for our controllers to prevent starvation during global re-syncs (thanks [@vagababov](https://github.com/vagababov))
- [#8951](https://github.com/knative/serving/pull/8951) Add config knob "max-value," which allows for setting a cluster-wide value for the max scale of any revision that doesn't have the "autoscaling.knative.dev/maxScale" annotation (thanks [@arturenault](https://github.com/arturenault))
- [#8724](https://github.com/knative/serving/pull/8724) Adds a 60 second timeout for image digest resolution to guard against slow registries (thanks [@julz](https://github.com/julz))
- [#8621](https://github.com/knative/serving/pull/8621) Implemented new garbage collector that allows for either time-based or min/max count bounds for automatic deletion of old revisions (thanks [@whaught](https://github.com/whaught))
    - To enable this a new v2 Labeler populates RoutingState and RoutingStateModified annotations on Revisions
- [#8828](https://github.com/knative/serving/pull/8828) PodSpec DryRun also validates unparented (service-less) Configurations thanks [@whaught](https://github.com/whaught))
- [#8846](https://github.com/knative/serving/pull/8846) Users can specify the size of the initial deployment with both cluster-wide flag initial-scale, and annotation "autoscaling.internal.knative.dev/initialScale". Cluster-wide flag allow-zero-initial-scale controls whether the cluster-wide and revision initial scale can be zero (thanks [@taragu](https://github.com/taragu))
- [#8757](https://github.com/knative/serving/pull/8757) When enabled, the ResponsiveGC feature flag disables lastPinned annotation timestamp refreshes (thanks [@whaught](https://github.com/whaught))
- [pkg#1592](https://github.com/knative/pkg/pull/1592) Added a workaround so Knative will work on AKS 1.17+ (thanks [@n3wscott](https://github.com/n3wscott))
- [pkg#1517](https://github.com/knative/pkg/pull/1517) Webhooks now drain for longer when shutting down (thanks [@mattmoor](https://github.com/mattmoor))

</details>

<details><summary>Networking</summary>

- [#2737](https://github.com/knative/serving/pull/2737) Net-contour is moved to Beta stage (thanks [@mattmoor](https://github.com/mattmoor))
- [#2738](https://github.com/knative/serving/pull/2738) Net-kourier is moved to Beta stage (thanks [@mattmoor](https://github.com/mattmoor))
- [#8965](https://github.com/knative/serving/pull/8965) The default Kingress timeout is increased to 48 hours to prevent gRPC stream timeout (thanks [@tcnghia](https://github.com/tcnghia))
- Code in knative/serving/pkg/network is completely moved to knative/networking repo (thanks [@tcnghia](https://github.com/tcnghia))
- [#8798](https://github.com/knative/serving/pull/8798) Placeholder service's labels and annotations are propagated from Route (thanks [@nak3](https://github.com/nak3))
- [knative-sandbox/net-istio#170](https://github.com/knative-sandbox/net-istio/pull/170) When auto TLS is enabled, now net-istio controller generates Istio TLS Gateway per Kingress instead of reconciling the knative-ingress-gateway Gateway (thanks [@ZhiminXiang](https://github.com/ZhiminXiang))
- [knative-sandbox/net-istio#174](https://github.com/knative-sandbox/net-istio/pull/174) Kingress (net-istio) introduces RewriteHost feature (thanks [@julz](https://github.com/julz))
- [knative-sandbox/net-istio##190](https://github.com/knative-sandbox/net-istio/pull/190) Kingress prober improvement for net-istio: probing a single host instead of every host to improve the throughput of the prober queue (thanks [@JRBANCEL](https://github.com/JRBANCEL))
</details>

### Eventing v0.17

**Action Required**
- [#3564](https://github.com/knative/eventing/pull/3564) High availability is now enabled by default on control-plane components; it can be disabled with --disable-ha for now. (thanks [@mattmoor](https://github.com/mattmoor))
    - You must manually delete the (previously scaled to 0) Deployment:
    ```yaml
    metadata:
    name: broker-controller
    namespace: knative-eventing
    ```
- [#3547](https://github.com/knative/eventing/pull/3547) kubectl delete deployment -n knative-eventing broker-controller (thanks [@vaikas](https://github.com/vaikas))


<details><summary>New Features</summary>

- [#3661](https://github.com/knative/eventing/pull/3661) ContainerSource is now in v1beta1 (thanks [@bharattkukreja](https://github.com/bharattkukreja))
- [#3577](https://github.com/knative/eventing/pull/3577) SinkBinding is now in v1beta1 (thanks [@nachocano](https://github.com/nachocano))
- [#3605](https://github.com/knative/eventing/pull/3605) Eventing conformance tests now can validate Sources status conformance (thanks [@devguyio](https://github.com/devguyio))
- [#3607](https://github.com/knative/eventing/pull/3607) PingSource now supports setting the time zone. (thanks [@lionelvillard](https://github.com/lionelvillard))
- [#3741](https://github.com/knative/eventing/pull/3741) The APIServerSource now sets name, kind and namespace as extension attributes in the CloudEvent. (thanks [@danyinggu](https://github.com/danyinggu))
- [#3632](https://github.com/knative/eventing/pull/3632) Add two flags to broker to control rest client QPS / Burst. Defaults to same as before. (thanks [@vaikas](https://github.com/vaikas))
- [#2932](https://github.com/knative/eventing/pull/2932) In Memory Channel and Multi-Tenant Channel Based Broker retry sending events (thanks [@pierDipi](https://github.com/pierDipi))

</details>



<details><summary>Removed Features</summary>

- [#3676](https://github.com/knative/eventing/pull/3676) Do not emit k8s events for every successful reconcile of IMC (thanks [@vaikas](https://github.com/vaikas))
- [#3494](https://github.com/knative/eventing/pull/3494) Remove the v1alpha1 CRD api versions. (thanks [@vaikas](https://github.com/vaikas))
- [#3837](https://github.com/knative/eventing/pull/3837) Remove PingSource v1alpha1 API (thanks [@lionelvillard](https://github.com/lionelvillard))

</details>


<details><summary>Bug Fixes</summary>

- [#3534](https://github.com/knative/eventing/pull/3534) Fixes issue where migration jobs would fail on Istio cluster with auto-inject enabled (thanks [@vayyappaneni](https://github.com/vayyappaneni))
- [#3693](https://github.com/knative/eventing/pull/3693) For ApiServerSource, the Kubernetes event "ApiServerSourceReconciled" is no longer produced for clean runs of the ReconcileKind method. (thanks [@n3wscott](https://github.com/n3wscott))
- [#3694](https://github.com/knative/eventing/pull/3694) For Channel, the Kubernetes event "ChannelReconciled" is no longer produced for clean runs of the ReconcileKind method. (thanks [@n3wscott](https://github.com/n3wscott))
- [#3696](https://github.com/knative/eventing/pull/3696) For EventType, the Kubernetes event "EventTypeReconciled" is no longer produced for clean runs of the ReconcileKind method. ([@n3wscott](https://github.com/n3wscott))
- [#3697](https://github.com/knative/eventing/pull/3697) For MTBroker, the Kubernetes event "BrokerReconciled" is no longer produced for clean runs of the FinalizeKind method. ([@n3wscott](https://github.com/n3wscott))
- [#3698](https://github.com/knative/eventing/pull/3698) For Parallel, the Kubernetes event "ParallelReconciled" is no longer produced for clean runs of the ReconcileKind method. (thanks [@n3wscott](https://github.com/n3wscott))
- [#3699](https://github.com/knative/eventing/pull/3699) For PingSource, the Kubernetes event "PingSourceReconciled" is no longer produced for clean runs of the ReconcileKind method. For Sequence, the Kubernetes event "SequenceReconciled" is no longer produced for clean runs of the ReconcileKind method. (thanks [@n3wscott](https://github.com/n3wscott))
- [#3695](https://github.com/knative/eventing/pull/3695) For Subscription, the Kubernetes event "SubscriptionReconciled" is no longer produced for clean runs of the ReconcileKind method. (thanks [@n3wscott](https://github.com/n3wscott))
- [#3574](https://github.com/knative/eventing/pull/3574) DeadLetterChannel was being dropped when converting between v1beta1<->v1 (thanks [@vaikas](https://github.com/vaikas))
    - Not all the conditions were being properly converted between v1beta1<->v1. Basically only the Ready was.
- [#3596](https://github.com/knative/eventing/pull/3596) Extend the terminationGracePeriod to fix issues shutting down the webhook. (thanks [@mattmoor](https://github.com/mattmoor))
- [#3619](https://github.com/knative/eventing/pull/3619) v1 and v1beta1 DeliverySpec.BackoffDelay accept ISO8601 duration (thanks [@pierDipi](https://github.com/pierDipi))
- [#3831](https://github.com/knative/eventing/pull/3831) PingSource does not lose events anymore when being shutdown close to the minute (thanks [@lionelvillard](https://github.com/lionelvillard))

</details>


<details><summary>Other Changes</summary>

- [#3562](https://github.com/knative/eventing/pull/3562) Add missing "leases" RBAC to controller and webhook to support leader election. (thanks [@mattmoor](https://github.com/mattmoor))
- [#3795](https://github.com/knative/eventing/pull/3795) Control plane components now specify anti-affinity so that replicas will not be colocated. (thanks [@mattmoor](https://github.com/mattmoor))
- [#3451](https://github.com/knative/eventing/pull/3451) The multi-tenant PingSource adapter consumes less resources. (thanks [@lionelvillard](https://github.com/lionelvillard))
- [#3587](https://github.com/knative/eventing/pull/3587) Reconcile eventing.{Broker,Trigger} using v1 api shape. Operate on dependent resources (Subscriptions, etc.) using their v1 shapes. (thanks [@vaikas](https://github.com/vaikas))
- [#3643](https://github.com/knative/eventing/pull/3643) When Trigger is reconciled, do not emit an event for it (thanks [@vaikas](https://github.com/vaikas))

</details>

### Eventing Contributions v0.17

Eventing Contributions include source and channels references implementations.
Sources with v1beta1 APIs get improvements and bug fixes.

<details><summary>New Features</summary>

- [#1409](https://github.com/knative/eventing-contrib/pull/1409) Kafka Channel retries sending events (thanks [@pierDipi](https://github.com/pierDipi))

</details>

<details><summary>Bug Fixes</summary>

- [#1155](https://github.com/knative/eventing-contrib/pull/1155) KafkaChannel now correctly implements tracing using eventing-wise tracing configuration from config-tracing ( thanks [@slinkydeveloper](https://github.com/slinkydeveloper))
- [#1398](https://github.com/knative/eventing-contrib/pull/1398) KafkaChannel conversion v1beta1<>v1alpha1 is fixed (thanks [@aliok](https://github.com/aliok))

</details>

<details><summary>Other Changes</summary>

- [#1407](https://github.com/knative/eventing-contrib/pull/1407) Reconcile KafkaChannel using v1beta1 api shape. Operate on dependent resources (Subscriptions, etc.) using their v1 shapes. (thanks [@aliok](https://github.com/aliok))
- [#1405](https://github.com/knative/eventing-contrib/pull/1405) Reconcile KafkaSource and KafkaBinding using v1beta1 API shape. Operate on dependent resources (Subscriptions, etc.) using their v1 shapes. Note that `resource` and `serviceAccountName` fields are removed from the types in v1beta1. (thanks [@aliok](https://github.com/aliok))

</details>

### Client v0.17

CLI (Command Line Interface) continues the journey to full Eventing support and adds some additional goodies for this release.

**Meta**

The compile dependencies have been updated to Knative Serving 0.17.0 and Knative Eventing 0.17.0.

**Eventing support**

- [#967](https://github.com/knative/client/pull/967) This release adds full support for managing Channel resources . It allows you to specify the channel type during creation and also to add some mappings of GVK coordinates to symbolic names in your configuration.

**Plugin Inline Support**

- [#902](https://github.com/knative/client/pull/902) It is possible now to create custom variations of kn that can inline golang based plugins into a single binary. See the [plugin README](https://github.com/knative/client/tree/main/docs/plugins#plugin-inlining) for a brief explanation about the mechanics. More documentation and examples pending. (thanks [@rhuss](https://github.com/rhuss))
    - It is important to note, that kn as released from the [client repository](https://github.com/knative/client) will not inline any plugins. It just provides the hooks for enabling plugin inlining.

<details><summary>New Features</summary>

- [#980](https://github.com/knative/client/pull/980) kn source list use now an own list type for heterogeneous lists (thanks [@navidshaikh](https://github.com/navidshaikh))
- [#951](https://github.com/knative/client/pull/951) NAMESPACE header column has been added to kn source list -A (thanks [@Kaustubh-pande](https://github.com/Kaustubh-pande))
- [#937](https://github.com/knative/client/pull/937) Add support to combine kn service create --filename with other options (thanks [@dsimansk](https://github.com/dsimansk))

</details>

<details><summary>Bug Fixes</summary>

- [#975](https://github.com/knative/client/pull/975) Client side volume name generation has been fixed (thanks [@navidshaikh](https://github.com/navidshaikh))
- [#948](https://github.com/knative/client/pull/948) List only built-in sources if access to CRDs is restricted (thanks [@navidshaikh](https://github.com/navidshaikh))

</details>

<details><summary>Other Changes</summary>

- [#974](https://github.com/knative/client/pull/974) Build test images for e2e tests, add `.ko.yaml` specifying base image (thanks [@itsmurugappan](https://github.com/itsmurugappan))
- [#972](https://github.com/knative/client/pull/972) Add mock test client for dynamic client (thanks [@priyshar01](https://github.com/priyshar01))
- [#971](https://github.com/knative/client/pull/971) Fix exit code for `kn service delete` and `kn revision delete` failures (thanks [@hemanrnjn](https://github.com/hemanrnjn))
- [#957](https://github.com/knative/client/pull/957) Allow the kn test image to be customized via environment variable (thanks [@mvinkler](https://github.com/mvinkler))
- [#943](https://github.com/knative/client/pull/943) Separate PodSpecFlags from Service ConfigurationEditFlags (thanks [@daisy-ycguo](https://github.com/daisy-ycguo))

</details>


### Operator v0.17


This new version of the Operator enables the support of customized manifests for Knative installation. The field `spec.manifests` is introduced in the operator CRD's to specify the links of Knative component to install. This field is usually used together with the field `spec.version`.

<details><summary>Bug Fixes</summary>

- [#236](https://github.com/knative/operator/pull/236) Adding istio ignore annotation transformer for jobs (thanks [@AceHack](https://github.com/AceHack))
- [#224](https://github.com/knative/operator/pull/224) Update to latest manifestival to fix an issue on CRD/v1 transformer (thanks [@jimoosciuc](https://github.com/jimoosciuc)])
- [#147](https://github.com/knative/operator/pull/147) Add the support to specify customized yamls (thanks [@houshengbo](https://github.com/houshengbo))
- [#246](https://github.com/knative/operator/pull/246) Validate whether spec.version matches the version of manifests (thanks [@houshengbo](https://github.com/houshengbo))
- [#255](https://github.com/knative/operator/pull/255) `sinkBindingSelectionMode` in CR spec (thanks [@aliok](https://github.com/aliok))

</details>

<details><summary>Other Changes</summary>

- [#220](https://github.com/knative/operator/pull/220) Make clear that deployments are not the only override-able container (thanks [@jcrossley3](https://github.com/jcrossley3))
- [#211](https://github.com/knative/operator/pull/211) Assorted linting fixes (thanks [@markusthoemmes](https://github.com/markusthoemmes))
- [#235](https://github.com/knative/operator/pull/235) Add the postdowngrade tests (thanks [@houshengbo](https://github.com/houshengbo))
- [#257](https://github.com/knative/operator/pull/257) Add the label operator.knative.dev/release into the operator resource for release (thanks [@houshengbo](https://github.com/houshengbo))

</details>


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
