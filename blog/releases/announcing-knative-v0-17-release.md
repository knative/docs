---
title: "Version v0.17 release"
linkTitle: "Version 0.17 release"
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

- Launched the initial scale with possibility of starting with 0
(thanks [@taragu](https://github.com/taragu)) [[#8613](https://github.com/knative/serving/pull/8613), [#8846](https://github.com/knative/serving/pull/8846)]
- Launched new KPA statuses, which permit significant simplification of the state machine in revision and KPA itself:
    - Initial scale reached (thanks [@markusthoemmes](https://github.com/markusthoemmes) & [@taragu](https://github.com/taragu))
    - SKS ready (thanks [@vagababov](https://github.com/vagababov))
- Concurrency & stat reporting rewrite in Activator (thanks [@markusthoemmes](https://github.com/markusthoemmes)) [[#8787](https://github.com/knative/serving/pull/8787), [#8796](https://github.com/knative/serving/pull/8796) ]
- Configurable idle conns/conns per host (thanks [@vagababov](https://github.com/vagababov) & [@julz](https://github.com/julz)) [[#8810](https://github.com/knative/serving/pull/8810), [#9027](https://github.com/knative/serving/pull/9027)]
- Optimize pod counting in KPA (3 passes over pods to 1) (thanks [@vagababov](https://github.com/vagababov)) [[#8759](https://github.com/knative/serving/pull/8759), [#8762](https://github.com/knative/serving/pull/8762)]
- Tricky optimization of returned lambda in activator saving 16b allocations per every request in activator (thanks [@julz](https://github.com/julz)) ([#8851](https://github.com/knative/serving/pull/8851)
- Lots of new benchmarks (thanks [@julz](https://github.com/julz) & [@markusthoemmes](https://github.com/markusthoemmes))
- Various cleanups, test stability, code optimizations, etc (thanks [@julz](https://github.com/julz), [@markusthoemmes](https://github.com/markusthoemmes), [@vagababov](https://github.com/vagababov), [@skonto](https://github.com/skonto))
</details>


<details><summary>Core API</summary>

- Leader Election enabled by default (thanks [@mattmoor](https://github.com/mattmoor))
    - By default control plane components now enable leader election, which can be disabled (for now) with --disable-ha.
- New feature flags are now available - see config-features for details
    - Enable affinity, nodeSelector and tolerations. [#8645](https://github.com/knative/serving/pull/8645) (thanks [@emaildanwilson](https://github.com/emaildanwilson))
    - Enable additional container & pod security context attributes. [#9060](https://github.com/knative/serving/pull/9060) (thanks [@dprotaso](https://github.com/dprotaso))
- Adopt a two-lane work queue for our controllers to prevent starvation during global re-syncs [pkg#1512](https://github.com/knative/pkg/pull/1512) (thanks [@vagababov](https://github.com/vagababov))
- Add config knob "max-value," which allows for setting a cluster-wide value for the max scale of any revision that doesn't have the "autoscaling.knative.dev/maxScale" annotation. [#8951](https://github.com/knative/serving/pull/8951) (thanks [@arturenault](https://github.com/arturenault))
- Adds a 60 second timeout for image digest resolution to guard against slow registries [#8724](https://github.com/knative/serving/pull/8724) (thanks [@julz](https://github.com/julz))
- Implemented new garbage collector that allows for either time-based or min/max count bounds for automatic deletion of old revisions. [#8621](https://github.com/knative/serving/pull/8621) (thanks [@whaught](https://github.com/whaught))
    - To enable this a new v2 Labeler populates RoutingState and RoutingStateModified annotations on Revisions
- PodSpec DryRun also validates unparented (service-less) Configurations. [#8828](https://github.com/knative/serving/pull/8828) (thanks [@whaught](https://github.com/whaught))
- Users can specify the size of the initial deployment with both cluster-wide flag initial-scale, and annotation "autoscaling.internal.knative.dev/initialScale". Cluster-wide flag allow-zero-initial-scale controls whether the cluster-wide and revision initial scale can be zero. [#8846](https://github.com/knative/serving/pull/8846), (thanks [@taragu](https://github.com/taragu))
- When enabled, the ResponsiveGC feature flag disables lastPinned annotation timestamp refreshes [#8757](https://github.com/knative/serving/pull/8757) (thanks [@whaught](https://github.com/whaught))
- Added a workaround so Knative will work on AKS 1.17+ [pkg#1592](https://github.com/knative/pkg/pull/1592) (thanks [@n3wscott](https://github.com/n3wscott))
- Webhooks now drain for longer when shutting down [pkg#1517](https://github.com/knative/pkg/pull/1517) (thanks [@mattmoor](https://github.com/mattmoor))
</details>

<details><summary>Networking</summary>

- Net-contour is moved to Beta stage [#2737](https://github.com/knative/serving/pull/2737) (thanks [@mattmoor](https://github.com/mattmoor))
- Net-kourier is moved to Beta stage [#2738](https://github.com/knative/serving/pull/2738) (thanks [@mattmoor](https://github.com/mattmoor))
- The default Kingress timeout is increased to 48 hours to prevent gRPC stream timeout [#8965](https://github.com/knative/serving/pull/8965) (thanks [@tcnghia](https://github.com/tcnghia))
- Code in knative/serving/pkg/network is completely moved to knative/networking repo (thanks [@tcnghia](https://github.com/tcnghia))
- Placeholder service's labels and annotations are propagated from Route. [#8798](https://github.com/knative/serving/pull/8798) (thanks [@nak3](https://github.com/nak3))
- When auto TLS is enabled, now net-istio controller generates Istio TLS Gateway per Kingress instead of reconciling the knative-ingress-gateway Gateway [knative-sandbox/net-istio#170](https://github.com/knative-sandbox/net-istio/pull/170) (thanks [@ZhiminXiang](https://github.com/ZhiminXiang)
- Kingress (net-istio) introduces RewriteHost feature [knative-sandbox/net-istio#174](https://github.com/knative-sandbox/net-istio/pull/174) (thanks [@julz](https://github.com/julz))
- Kingress prober improvement for net-istio: probing a single host instead of every host to improve the throughput of the prober queue [knative-sandbox/net-istio##190](https://github.com/knative-sandbox/net-istio/pull/190) (thanks [@JRBANCEL](https://github.com/JRBANCEL))
</details>

### Eventing v0.17

**Action Required**
- High availability is now enabled by default on control-plane components; it can be disabled with --disable-ha for now. ([#3564](https://github.com/knative/eventing/pull/3564), [@mattmoor](https://github.com/mattmoor)
- You must manually delete the (previously scaled to 0) Deployment:
```
metadata:
  name: broker-controller
  namespace: knative-eventing
```
- kubectl delete deployment -n knative-eventing broker-controller
([#3547](https://github.com/knative/eventing/pull/3547), [@vaikas](https://github.com/vaikas)


<details><summary>New Features</summary>

- ContainerSource is now in v1beta1 ([#3661](https://github.com/knative/eventing/pull/3661), [@bharattkukreja](https://github.com/bharattkukreja)
- SinkBinding is now in v1beta1 ([#3577](https://github.com/knative/eventing/pull/3577), [@nachocano](https://github.com/nachocano)
- Eventing conformance tests now can validate Sources status conformance ([#3605](https://github.com/knative/eventing/pull/3605), [@devguyio](https://github.com/devguyio)
- PingSource now supports setting the time zone. ([#3607](https://github.com/knative/eventing/pull/3607), [@lionelvillard](https://github.com/lionelvillard)
- The APIServerSource now sets name, kind and namespace as extension attributes in the CloudEvent. ([#3741](https://github.com/knative/eventing/pull/3741), [@danyinggu](https://github.com/danyinggu)
- Add two flags to broker to control rest client QPS / Burst. Defaults to same as before. ([#3632](https://github.com/knative/eventing/pull/3632), [@vaikas](https://github.com/vaikas)
- In Memory Channel and Multi-Tenant Channel Based Broker retry sending events ([#2932](https://github.com/knative/eventing/pull/2932), [@pierDipi](https://github.com/pierDipi)

</details>



<details><summary>Removed Features</summary>

- Do not emit k8s events for every successful reconcile of IMC ([#3676](https://github.com/knative/eventing/pull/3676), [@vaikas](https://github.com/vaikas)
- Remove the v1alpha1 CRD api versions. ([#3494](https://github.com/knative/eventing/pull/3494), [@vaikas](https://github.com/vaikas)
- Remove PingSource v1alpha1 API ([#3837](https://github.com/knative/eventing/pull/3837), [@lionelvillard](https://github.com/lionelvillard)

</details>


<details><summary>Bug Fixes</summary>

- Fixes issue where migration jobs would fail on Istio cluster with auto-inject enabled ([#3534](https://github.com/knative/eventing/pull/3534), [@vayyappaneni](https://github.com/vayyappaneni)
- For ApiServerSource, the Kubernetes event "ApiServerSourceReconciled" is no longer produced for clean runs of the ReconcileKind method. ([#3693](https://github.com/knative/eventing/pull/3693), [@n3wscott](https://github.com/n3wscott)
- For Channel, the Kubernetes event "ChannelReconciled" is no longer produced for clean runs of the ReconcileKind method. ([#3694](https://github.com/knative/eventing/pull/3694), [@n3wscott](https://github.com/n3wscott)
- For EventType, the Kubernetes event "EventTypeReconciled" is no longer produced for clean runs of the ReconcileKind method. ([#3696](https://github.com/knative/eventing/pull/3696), [@n3wscott](https://github.com/n3wscott)
- For MTBroker, the Kubernetes event "BrokerReconciled" is no longer produced for clean runs of the FinalizeKind method. ([#3697](https://github.com/knative/eventing/pull/3697), [@n3wscott](https://github.com/n3wscott)
- For Parallel, the Kubernetes event "ParallelReconciled" is no longer produced for clean runs of the ReconcileKind method. ([#3698](https://github.com/knative/eventing/pull/3698), [@n3wscott](https://github.com/n3wscott)
- For PingSource, the Kubernetes event "PingSourceReconciled" is no longer produced for clean runs of the ReconcileKind method.
- For Sequence, the Kubernetes event "SequenceReconciled" is no longer produced for clean runs of the ReconcileKind method. ([#3699](https://github.com/knative/eventing/pull/3699), [@n3wscott](https://github.com/n3wscott)
- For Subscription, the Kubernetes event "SubscriptionReconciled" is no longer produced for clean runs of the ReconcileKind method. ([#3695](https://github.com/knative/eventing/pull/3695), [@n3wscott](https://github.com/n3wscott)
- DeadLetterChannel was being dropped when converting between v1beta1<->v1 ([#3574](https://github.com/knative/eventing/pull/3574), [@vaikas](https://github.com/vaikas)
- Not all the conditions were being properly converted between v1beta1<->v1. Basically only the Ready was.
- Extend the terminationGracePeriod to fix issues shutting down the webhook. ([#3596](https://github.com/knative/eventing/pull/3596), [@mattmoor](https://github.com/mattmoor)
- v1 and v1beta1 DeliverySpec.BackoffDelay accept ISO8601 duration ([#3619](https://github.com/knative/eventing/pull/3619), [@pierDipi](https://github.com/pierDipi)
- PingSource does not lose events anymore when being shutdown close to the minute ([#3831](https://github.com/knative/eventing/pull/3831), [@lionelvillard](https://github.com/lionelvillard)

</details>


<details><summary>Other Changes</summary>

- Add missing "leases" RBAC to controller and webhook to support leader election. ([#3562](https://github.com/knative/eventing/pull/3562), [@mattmoor](https://github.com/mattmoor)
- Control plane components now specify anti-affinity so that replicas will not be colocated. ([#3795](https://github.com/knative/eventing/pull/3795), [@mattmoor](https://github.com/mattmoor)
- The multi-tenant PingSource adapter consumes less resources. ([#3451](https://github.com/knative/eventing/pull/3451), [@lionelvillard](https://github.com/lionelvillard)
- Reconcile eventing.{Broker,Trigger} using v1 api shape. Operate on dependent resources (Subscriptions, etc.) using their v1 shapes. ([#3587](https://github.com/knative/eventing/pull/3587), [@vaikas](https://github.com/vaikas)
- When Trigger is reconciled, do not emit an event for it ([#3643](https://github.com/knative/eventing/pull/3643), [@vaikas](https://github.com/vaikas)

</details>

### Client v0.17

CLI (Command Line Interface) continues the journey to full Eventing support and adds some additional goodies for this release.

**Meta**

The compile dependencies have been updated to Knative Serving 0.17.0 and Knative Eventing 0.17.0.

**Eventing support**

This release adds full support for managing Channel resources [#967](https://github.com/knative/client/pull/967). It allows you to specify the channel type during creation and also to add some mappings of GVK coordinates to symbolic names in your configuration.

**Plugin Inline Support**

- [#902](https://github.com/knative/client/pull/902) It is possible now to create custom variations of kn that can inline golang based plugins into a single binary. See the [plugin README](https://github.com/knative/client/tree/master/docs/plugins#plugin-inlining) for a brief explanation about the mechanics. More documentation and examples pending.
    - It is important to note, that kn as released from the [client repository](https://github.com/knative/client) will not inline any plugins. It just provides the hooks for enabling plugin inlining.

<details><summary>New Features</summary>

- [#980](https://github.com/knative/client/pull/980) kn source list use now an own list type for heterogeneous lists 
- [#951](https://github.com/knative/client/pull/951) NAMESPACE header column has been added to kn source list -A
- [#937](https://github.com/knative/client/pull/937) Add support to combine kn service create --filename with other options 

</details>

<details><summary>Bug Fixes</summary>

- [#975](https://github.com/knative/client/pull/975) Client side volume name generation has been fixed 
- [#948](https://github.com/knative/client/pull/948) List only built-in sources if access to CRDs is restricted

</details>

<details><summary>Other Changes</summary>

- [#974](https://github.com/knative/client/pull/974) Build test images for e2e tests, add `.ko.yaml` specifying base image
- [#972](https://github.com/knative/client/pull/972) Add mock test client for dynamic client
- [#971](https://github.com/knative/client/pull/971) Fix exit code for `kn service delete` and `kn revision delete` failures
- [#957](https://github.com/knative/client/pull/957) Allow the kn test image to be customized via environment variable
- [#943](https://github.com/knative/client/pull/943) Separate PodSpecFlags from Service ConfigurationEditFlags

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
