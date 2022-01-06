---
title: "v0.21 release"
linkTitle: "v0.21 release"
author: "[Carlos Santana](https://twitter.com/csantanapr)"
author handle: https://github.com/csantanapr
date: 2021-02-26
description: "Knative v0.21 release announcement"
type: "blog"
image: knative-eventing.png
---


### Announcing Knative v0.21 Release

A new version of Knative is now available across multiple components.
Follow the instructions in the documentation [Installing Knative](https://knative.dev/docs/install/) for the respective component.

#### Table of Contents
- [Serving v0.21](#serving-v021)
- [Eventing v0.21](#eventing-v021)
- Eventing Extensions
    - [Eventing RabbitMQ v0.21](#eventing-rabbitmq-v021)
    - [Eventing Kafka Source, Channel v0.21](#eventing-kafka-source-channel-v021)
    - [Eventing Kafka Broker v0.21](#eventing-kafka-broker-v021)
- `kn` [CLI v0.21](#client-v021)
    - `kn` [CLI Plugins](#cli-plugins)
- [Operator v0.21](#operator-v021)
- [Thank you contributors v0.21](#thank-you-contributors-v0.21)



### Highlights

- Kubernetes minimum version has changed to v1.18
    - See our [K8s minimum version principle](https://github.com/knative/community/blob/main/mechanics/RELEASE-VERSIONING-PRINCIPLES.md#k8s-minimum-version-principle)
- Now Serving supports Istio 1.9 and Contour 1.12
- Fix for DomainMapping when using Kourier with AutoTLS
- Eventing Source **PingSource** binary mode has breaking changes.
- Eventing sync has the ability to know when to reply, see the [event reply header contract](https://github.com/knative/eventing/blob/release-0.21/docs/spec/data-plane.md#event-reply-contract) specification for more details.
- The CLI `kn` 0.21.0 comes with some bug fixes and minor feature enhancements. It's mostly a polishing release. It is also the first release that brings two kn plugins to the Knative release train.
- The Knative Operator now supports net-kourier
- The Knative Opertor now supports a version of `latest` as a special version supported by the operator


### Serving v0.21

#### 🚨 Breaking or Notable

- Kubernetes minimum version has changed to v1.18
    - See our [K8s minimum version principle](https://github.com/knative/community/blob/main/mechanics/RELEASE-VERSIONING-PRINCIPLES.md#k8s-minimum-version-principle)
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

#### Eventing RabbitMQ v0.21

#### 🚨 Breaking or Notable

- Kubernetes minimum version has changed to v1.18
    - Upgrade to v0.19.7 of k8s libraries. Minimum k8s version is now 1.18. ([#213](https://github.com/knative-sandbox/eventing-rabbitmq/pull/213))

#### 💫 New Features & Changes

- Support new releases of rabbitmq cluster operator v1.0, v1.1, v1.2, v1.3 . ([#204](https://github.com/knative-sandbox/eventing-rabbitmq/pull/204))


#### 📖 Documentation
- Added user-facing documentation for the RabbitMQ source ([#201](https://github.com/knative-sandbox/eventing-rabbitmq/pull/201))

#### 🧹 Clean up
- Update or clean up current behavior - Use go 1.15 in kind e2e tests. ([#196](https://github.com/knative-sandbox/eventing-rabbitmq/pull/196))
- Update or clean up current behavior Use go 1.15 in go.mod ([#215](https://github.com/knative-sandbox/eventing-rabbitmq/pull/215))
- Update the comments in cmd/failer/main.go to match reality. ([#210](https://github.com/knative-sandbox/eventing-rabbitmq/pull/210))
- Use scripts from hack to determine pod readiness.([#209](https://github.com/knative-sandbox/eventing-rabbitmq/pull/209))


#### Eventing Kafka Source, Channel v0.21

#### 💫 New Features & Changes

- Adding new optional field named sasltype to default kafka-secret to enable other Kafka SASL Methods than PLAIN. Supports SCRAM-SHA-256 or SCRAM-SHA-512. ([#332](https://github.com/knative-sandbox/eventing-kafka/pull/332))
- Adding tls.enabled flag for public cert usage and allowing skipping CA/User certs and key ([#359](https://github.com/knative-sandbox/eventing-kafka/pull/359))
- KafkaSource and KafkaChannel will be default use the config-leader-election CM for configs ([#231](https://github.com/knative-sandbox/eventing-kafka/pull/231))
- Removed support for pooling Azure EventHub Namespaces and now only support a single Namespace/Authentication which limits Azure EventHub usage to their constrained number of EventHubs (Kafka Topics). ([#297](https://github.com/knative-sandbox/eventing-kafka/pull/297))
- The "distributed" KafkaChannel configuration YAML now includes the KafkaChannel WebHook which provides conversion. ([#187](https://github.com/knative-sandbox/eventing-kafka/pull/187))
- The KafkaSource will be installed in the knative-eventing namespace, and the old controller in knative-sources is scalled to 0 ([#224](https://github.com/knative-sandbox/eventing-kafka/pull/224))
- Add a new alternative KafkaSource implementation in which a single global StatefulSet handles all KafkaSource instances. ([#186](https://github.com/knative-sandbox/eventing-kafka/pull/186))
- It is now possible to define Sarama config defaults for KafkaSource in config-kafka configmap with a sarama field. ([#337](https://github.com/knative-sandbox/eventing-kafka/pull/337))
- It is now possible to define Sarama config defaults for consolidated channel in config-kafka configmap with a sarama field. ([#305](https://github.com/knative-sandbox/eventing-kafka/pull/305))
- KafkaChannel CustomResourceDefinition now uses apiextensions.k8s.io/v1 APIs ([#132](https://github.com/knative-sandbox/eventing-kafka/pull/132))
- The KafkaSource scale subresource can now be used to scale up and down the underlying deployment ([#138](https://github.com/knative-sandbox/eventing-kafka/pull/138))
- Defaulting the connection args to a sane value ([#353](https://github.com/knative-sandbox/eventing-kafka/pull/353))

#### 🐞 Bug Fixes

- A bug was fixed in the consolidated KafkaChannel where subscriptions would show up in the channel's status.subscribers before the dispatcher becomes ready to dispatch messages for those subscribers.
    - Consolidated KafkaChannel dispatcher's horizontal scalability works now seamlessly with reconciler leader election. ([#182](https://github.com/knative-sandbox/eventing-kafka/pull/182))
- Fix concurrent modification of consumer groups map, which causes undefined behaviours while running reconciliation in the dispatcher ([#352](https://github.com/knative-sandbox/eventing-kafka/pull/352), @slinkydeveloper)
- Fix crash in Kafka consumer when a rebalance occurs ([#263](https://github.com/knative-sandbox/eventing-kafka/pull/263), @lionelvillard)
- Fix race on error channel in consumer factory ([#364](https://github.com/knative-sandbox/eventing-kafka/pull/364))
- The KafkaSource dispatchers now expose metrics and profiling information ([#221](https://github.com/knative-sandbox/eventing-kafka/pull/221))
- The consolidated KafkaChannel now relies by default on SyncProducer for safer event production. ([#181](https://github.com/knative-sandbox/eventing-kafka/pull/181))

#### Eventing Kafka Broker v0.21

#### 💫 New Features & Changes

- Add support for SASL and SSL. ([#534](https://github.com/knative-sandbox/eventing-kafka-broker/pull/534), @pierDipi)
    - [Eventing Kafka Broker documentation](https://knative.dev/docs/eventing/broker/kafka-broker/#security)
    - [Eventing Kafka Sink documentation](https://knative.dev/docs/eventing/sink/kafka-sink/#security)
- Add support for Trigger.Spec.DeliverySpec ([#612](https://github.com/knative-sandbox/eventing-kafka-broker/pull/612))
- Improve status fields description in KafkaSink CRD. ([#552](https://github.com/knative-sandbox/eventing-kafka-broker/pull/552))
- Reduce error logging noise on clean shutdown. ([#625](https://github.com/knative-sandbox/eventing-kafka-broker/pull/625))
- Support Kubernetes 1.20. ([#542](https://github.com/knative-sandbox/eventing-kafka-broker/pull/542))

#### 🐞 Bug Fixes

- Consume topic from the earliest offset ([#557](https://github.com/knative-sandbox/eventing-kafka-broker/pull/557))
- Fix offset management ([#557](https://github.com/knative-sandbox/eventing-kafka-broker/pull/557))
- Data plane reconciler handles failed reconciliation. ([#568](https://github.com/knative-sandbox/eventing-kafka-broker/pull/568))
- Fix TimeoutException and DnsNameResolverTimeoutException. ([#539](https://github.com/knative-sandbox/eventing-kafka-broker/pull/539))

### Client v0.21

#### 🚨 Breaking or Notable

**Revision naming**

In this version, kn changes the default of how revisions are named. Up to now, the name was selected by the client itself, leveraging the "bring-your-own" (BYO) revision name support of Knative serving.

However, it turned out that this mode has several severe drawbacks:

- If you create a service with client-side revision naming, you have to provide a new revision name on every update. This is especially tedious if using other clients than kn, like editing the resource directly in the cluster or you tools like the OpenShift Developer console. Assuming that kn is the only client to be used is a bit of a too bold attitude.
- `SinkBinding` [do not work with BYO revision names](https://github.com/knative/serving/issues/9544)
- `kn service apply` can't use client-generated revision names, so kn service apply ignore `--revision-name` option and always uses server-side generated revision names. The same is true if you want to use `kubectl apply` after you have created a service with BYO revision name mode with `kn`.
- Revision name's are random and do not reflect a certain generational order as for server-side generated revision names
- There are issues with new revision created when updated with the same image name again (see [#398](https://github.com/knative/client/issues/398#issuecomment-779654440))

Please refer to issue [#1144](https://github.com/knative/client/issues/1144) (and issues referencing this issue) for more details about the reasoning for this breaking change.

**ACTION REQUIRED**

If you rely on client-side revision naming, you have to add `--revision-name {{.Service}}-{{.Random 5}}-{{.Generation}}` to `kn service create` to get back the previous default behaviour. However, in most of all cases, you shound not worry about whether the revision names are created by `kn` or by the Knative serving controller

In case of issues with this change, please let us know and we will fix it asap. We are committed to supporting you with any issues caused by this change.

#### 💫 New Features & Changes

- Options `--context` and `--cluster` allow you to select the parameters for connecting to your Kubernetes cluster. Those options work the same as for kubectl.
- Some cleanup of cluster-specific runtime information when doing a kn export.


### CLI Plugins

#### 💫 New Features & Changes

CLI `kn` [Plugins](https://github.com/knative/client/blob/main/docs/plugins/README.md) jump on the release train

With release v0.21, Knative ships also it first set of kn plugins, that are aligned with respect to their dependencies, so that they can be easily [inlined](https://github.com/knative/client/blob/main/docs/plugins/README.md#plugin-inlining).

The plugins included in version `v0.21` are:

- [kn-plugin-admin](https://github.com/knative-sandbox/kn-plugin-admin) for managing Knative installations that are running on Kubernetes | [download](https://github.com/knative-sandbox/kn-plugin-admin/releases/tag/v0.21.0)
- [kn-plugin-source-kafka](https://github.com/knative-sandbox/kn-plugin-source-kafka) for managing a Kafka Source that has been installed via [eventing-kafka](https://github.com/knative-sandbox/eventing-kafka) on the backend | [download](https://github.com/knative-sandbox/kn-plugin-source-kafka/releases/tag/v0.21.0)

To give those plugins a try, just download them and put the binary into your execution path. You then get help with kn admin --help and kn source kafka --help, respectively.

### Operator v0.21

#### 💫 New Features & Changes

The latest network ingress v0.21.0 artifacts, bundled within the image of this operator, include net-istio.yaml, net-contour.yaml and kourier.yaml.

- Allow to configure Kourier gateway service-type ([#470](https://github.com/knative/operator/pull/470))
- Adds support for extension custom manifests ([#468](https://github.com/knative/operator/pull/468))
- Add HA support for autoscaler ([#480](https://github.com/knative/operator/pull/480))
- Support spec.deployments to override configuration of system deployments ([#472](https://github.com/knative/operator/pull/472))
- Add ha eventing master ([#444](https://github.com/knative/operator/pull/444))

#### 🐞 Bug Fixes

- Transition to the new upgrade framework for upgrade tests ([#437](https://github.com/knative/operator/pull/437))
- Add ingress configuration support ([#312](https://github.com/knative/operator/pull/312))

#### 🧹 Clean up

- Add `latest` as a special version supported by the operator ([#443](https://github.com/knative/operator/pull/443))
- Rewrite the tests for serving and eventing upgrade ([#441](https://github.com/knative/operator/pull/441))
- Allow to specify build platform for test images ([#451](https://github.com/knative/operator/pull/451))
- Bump a few assorted dependencies to their latest versions ([#463](https://github.com/knative/operator/pull/463))
- Align all used YAML modules ([#462](https://github.com/knative/operator/pull/462))
- Move istio gateway's override setting into spec.ingress.istio ([#469](https://github.com/knative/operator/pull/469))

### Thank you contributors v0.21

- [@BbolroC](https://github.com/BbolroC)
- [@Harwayne](https://github.com/Harwayne)
- [@Shashankft9](https://github.com/Shashankft9)
- [@aliok](https://github.com/aliok)
- [@arturenault](https://github.com/arturenault)
- [@cardil](https://github.com/cardil)
- [@csantanapr](https://github.com/csantanapr)
- [@devguyio](https://github.com/devguyio)
- [@dsimansk](https://github.com/dsimansk)
- [@eclipselu](https://github.com/eclipselu)
- [@evankanderson](https://github.com/evankanderson)
- [@grac3gao](https://github.com/grac3gao)
- [@houshengbo](https://github.com/houshengbo)
- [@julz](https://github.com/julz)
- [@larhauga](https://github.com/larhauga)
- [@lionelvillard](https://github.com/lionelvillard)
- [@markusthoemmes](https://github.com/markusthoemmes)
- [@mattmoor](https://github.com/mattmoor)
- [@matzew](https://github.com/matzew)
- [@matzew](https://github.com/matzew)
- [@nak3](https://github.com/nak3)
- [@navidshaikh](https://github.com/navidshaikh)
- [@pierDipi](https://github.com/pierDipi)
- [@rhuss](https://github.com/rhuss)
- [@senthilnathan](https://github.com/senthilnathan)
- [@shinigambit](https://github.com/shinigambit)
- [@skonto](https://github.com/skonto)
- [@slinkydeveloper](https://github.com/slinkydeveloper)
- [@travis-minke-sap](https://github.com/travis-minke-sap)
- [@vagababov](https://github.com/vagababov)
- [@vaikas](https://github.com/vaikas)
- [@whaught](https://github.com/whaught)
- [@xtreme-sameer-vohra](https://github.com/xtreme-sameer-vohra)
- [@zhongduo](https://github.com/zhongduo)

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
