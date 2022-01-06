---
title: "v0.26 release"
linkTitle: "v0.26 release"
Author: "[Carlos Santana](https://twitter.com/csantanapr)"
Author handle: https://github.com/csantanapr
date: 2021-10-04
description: "Knative v0.26 release announcement"
type: "blog"
image: knative-eventing.png
---


### Announcing Knative v0.26 Release

A new version of Knative is now available across multiple components.

Follow the instructions in the documentation
[Installing Knative](https://knative.dev/docs/admin/install/) for the respective component.

#### Table of Contents
- [Highlights](#highlights)
- [Serving v0.26](#Serving-v026)
- [Eventing v0.26](#Eventing-v026)
- [Eventing Extensions](#Eventing-Extensions)
    - [Apache Kafka Broker v0.26](#Apache-Kafka-Broker-v026)
    - [Apache Kafka Source and Channels v0.26](#apache-kafka-source-and-channels-v026)
    - [Eventing Kogito v0.26](#eventing-kogito-v026)
- `kn` [CLI v0.26](#Client-v026)
- [Operator v0.26](#Operator-v026)
- [Thank you contributors](#Thank-you-contributors)


### Highlights

- **Kubernetes 1.20+ is now required**
- Improvements for Istio mesh compatibility mode.
- New features in eventing kafka
- New CLI plugins available
- Many improvements in install operator





### Serving v0.26

<!-- Original notes are here: https://github.com/knative/serving/releases/tag/v0.26.0 -->

#### 🚨 Breaking or Notable Changes

- **Kubernetes 1.20+ is now required**

#### 💫 New Features & Changes

- Allow users to set container[*].securityContext.runAsGroup ([#12003](https://github.com/knative/serving/pull/12003))
- A new setting, `mesh-compatibility-mode`, in the networking config map allows an administrator
to explicitly tell Activator and Autoscaler to use Direct Pod IP (most efficient, but not compatible
with mesh being enabled), Cluster IP (less efficient, but needed if mesh is enabled), or to
Autodetect (the current behaviour, and the default, causes Activator and Autoscaler to first attempt
Direct Pod IP communication, and then fall back to Cluster IP if it sees a mesh-related error status
code). ([#11999](https://github.com/knative/serving/pull/11999))
- Adds more debug logs to background digest resolver ([#11959](https://github.com/knative/serving/pull/11959))
- Dropped the startup probe on the queue-proxy which makes the pods start ~500ms quicker on average. ([#11965](https://github.com/knative/serving/pull/11965))
- Removes the ServiceName field from RevisionStatus which has been deprecated for several releases. This field was effectively equal to the revision name. ([#11817](https://github.com/knative/serving/pull/11817))
- When enabled, queue proxy tracks the request count for each pod (disabled by default) ([#11783](https://github.com/knative/serving/pull/11783))

#### 🐞 Bug Fixes

- User-supplied readinessProbes with a probePeriod set greater than zero are no longer silently ignored after pod startup. ([#11190](https://github.com/knative/serving/pull/11190))
### Eventing v0.26

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/v0.26.1 -->

#### 🚨 Breaking or Notable Changes

- **Kubernetes 1.20+ is now required**

#### 💫 New Features & Changes

- Add new `kreference-naming` experimental feature. When enabled, it allows overriding the default Knative reference resolver behavior. See the document for more details. ([#5599](https://github.com/knative/eventing/pull/5599))
- The heartbeats sample app now supports Golang-style time durations as the period interval ([#5683](https://github.com/knative/eventing/pull/5683))
- Dead Letter Sink CloudEvents from certain Channels will include the `knativeerrordest` extension attribute indicating the original destination URL of the failed event. ([#5727](https://github.com/knative/eventing/pull/5727))
- Event Display and Heartbeats sample programs will emit traces to a trace endpoint if it's configured ([#5631](https://github.com/knative/eventing/pull/5631))
- Traces are exported by the mtbroker controller ([#5634](https://github.com/knative/eventing/pull/5634))
- Trigger accepts a timeout field in its delivery parameters `spec.delivery.timeout` ([#5687](https://github.com/knative/eventing/pull/5687))

#### 🐞 Bug Fixes

- Validate CloudEvent overrides as defined by the CloudEvent spec. ([#5730](https://github.com/knative/eventing/pull/5730))
- Fix DeadLetterSinkURI not persisting to Trigger status ([#5642](https://github.com/knative/eventing/pull/5642))

#### 🧹 Clean up

- NewListableTracker is deprecated, use NewListableTrackerFromTracker instead. ([#5651](https://github.com/knative/eventing/pull/5651))
- Adopted app.kubernetes.io labels ([#5628](https://github.com/knative/eventing/pull/5628))
- Clarify the semantic of `ceOverrides` ([#5641](https://github.com/knative/eventing/pull/5641))
- The post job is now having a generated name, instead of an unmaintained versioned name. ([#5664](https://github.com/knative/eventing/pull/5664))

### Eventing Extensions

#### Apache Kafka Broker v0.26

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka-broker/releases/tag/v0.26.0 -->

##### 🚨 Breaking or Notable Changes

- **Kubernetes 1.20+ is now required**

##### 🐞 Bug Fixes

- The fields Broker.spec.delivery.deadLetterSink.ref.namespace and Trigger.spec.delivery.deadLetterSink.ref.namespace are optional. By default the controller uses the object namespace. ([#1254](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1254))

#### Apache Kafka Source and Channels v0.26

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka/releases/tag/v0.26.1 -->

##### 💫 New Features & Changes

- KafkaChannel CRD Spec now includes a RetentionDuration field, allowing per-channel control over retention. A Post-Install Job (config/post-install/retentionupdate) is available to migrate existing KafkaChannels forward by populating this field. The "topic" configuration defaults which were not working have been removed from the config-kafka ConfigMap. ([#828](https://github.com/knative-sandbox/eventing-kafka/pull/828))
- KafkaChannel ConfigMap now supports custom Labels and Annotations for dynamically generated resources. ([#806](https://github.com/knative-sandbox/eventing-kafka/pull/806))
- Provide an option for the user to specify the initial offset for a consumer group in Kafka source, this field is honored only if there are no prior offsets committed for the consumer group. ([#779](https://github.com/knative-sandbox/eventing-kafka/pull/779))
- KafkaSource now supports ceOverrides. ([#811](https://github.com/knative-sandbox/eventing-kafka/pull/811))
- The Multi-tenant `KafkaSource` calculates an optimal maximum allowed replica number based on Kafka source partitions count so that scheduler does not schedule more vreplicas than the calculated number ([#822](https://github.com/knative-sandbox/eventing-kafka/pull/822))
- Autoscaling annotations can now be automatically added to KafkaSource objects. See the documentation for more details. ([#855](https://github.com/knative-sandbox/eventing-kafka/pull/855))

##### 🐞 Bug Fixes

- Fix bug: status.address of KafkaChannel is not required anymore, thus conditions are reflected successfully in case of an early stage error ([#857](https://github.com/knative-sandbox/eventing-kafka/pull/857))
- Remove confusing error message `Kafka source is not ready`. This error is returned as an event regardless the Kafka source has any real issue or not and users should not see this error message unless it is a legitimate error or it is an error they can fix. ([#809](https://github.com/knative-sandbox/eventing-kafka/pull/809))
- multi-tenant source webhook cluster role has update permission for namespaces/finalizers. ([#854](https://github.com/knative-sandbox/eventing-kafka/pull/854))

##### 🧹 Clean up

- Inherent immutability of KafkaChannel and ResetOffset spec fields is now enforced by the kafka-webhook. ([#863](https://github.com/knative-sandbox/eventing-kafka/pull/863))
- Next generation Multi-Tenant Scheduler and Descheduler: uses a plugin interface to specify a Scheduler profile with predicates and priorities that run filtering and scoring of pods, respectively to compute the best vreplica placements. When the autoscaler adds new pods, scheduler performs a rebalancing of the already placed vreplicas along with the new vreplicas. A Descheduler profile must be installed when vreplicas need to be scaled down and placements removed. ([#768](https://github.com/knative-sandbox/eventing-kafka/pull/768))
- The consolidated KafkaChannel dispatcher is now owned by the controller. ([#798](https://github.com/knative-sandbox/eventing-kafka/pull/798))

#### Eventing Kogito v0.26

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kogito/releases/tag/v0.26.0 -->

##### 💫 New Features & Changes

- Introduce the new Kogito Source CRD and add support to K_SINK environment variable to Kogito services ([#1](https://github.com/knative-sandbox/eventing-kogito/pull/1))

### Client v0.26

<!-- Original notes are here: https://github.com/knative/client/blob/main/CHANGELOG.adoc#v0260-2021-08-10 -->

#### 💫 New Features & Changes

- Add `--env-file` option to function create/update command ([#1433](https://github.com/knative/client/pull/1433))
- New CLI plugin `kn-plugin-kamelet`, a Knative CLI plugin for managing Kamelets and KameletBindings as Knative event sources. Download latest release [here](https://github.com/knative-sandbox/kn-plugin-source-kamelet/releases)
    - List available Kamelets
    - Describe Kamelet and print detailed information (e.g. provider, support level, properties)
    - Bind Kamelet as source to a Knative sink (broker, channel, service)
    - List Kamelet bindings
    - Create Kamelet binding to bind source to Knative sink (broker, channel, service)
- New CLI experimental functions plugin `kn-plugin-func` Download latest release [here](https://github.com/knative-sandbox/kn-plugin-func/releases)
- New CLI experimental cloud event plugin `kn-plugin-event` Download latest release [here](https://github.com/knative-sandbox/kn-plugin-event/releases)
#### 🧹 Clean up

- Remove `DeprecatedImageDigest` field ([#1454](https://github.com/knative/client/pull/1454))
- Reuse conflict retry loop from client-go/util/retry ([#1441](https://github.com/knative/client/pull/1441))


## Operator v0.26

<!-- Original notes are here: https://github.com/knative/operator/releases/tag/v0.26.1 -->

#### 💫 New Features & Changes

- Detect missing Istio requirement and suggests user to instal the Istio Gateway CRD ([#697](https://github.com/knative/operator/pull/613))
- Adding COC, contributing doc ([#790](https://github.com/knative/operator/pull/790))
- Remove pingsource-mt-adapter from the list of unsupported HA ([#788](https://github.com/knative/operator/pull/788))
- Apply high-availability to all deployments managed by operator ([#749](https://github.com/knative/operator/pull/749))
- fix misspelling of with ([#781](https://github.com/knative/operator/pull/781))
- Add the support of spec.deployments.affinity ([#777](https://github.com/knative/operator/pull/777))
- Adjust maxReplicas in HPA when high-availability has larger number ([#748](https://github.com/knative/operator/pull/748))
- Prepare the Knative Operator for the label app.kubernetes.io/version ([#738](https://github.com/knative/operator/pull/738))
- Allow to set Tolerations via spec.deployments.tolerations ([#747](https://github.com/knative/operator/pull/747))
- Remove pingsource from HA scaling ([#740](https://github.com/knative/operator/pull/740))
- Drop deprecated enabledComponents field setting ([#735](https://github.com/knative/operator/pull/735))
- Use knative.dev/hack/codegen-library.sh in hack/update-codegen.sh ([#734](https://github.com/knative/operator/pull/734))
- Remove heartbeats for eventing ([#792](https://github.com/knative/operator/pull/792))

#### 🐞 Bug Fixes

- Fix the error issue with installing spec.manifests ([#750](https://github.com/knative/operator/pull/750))

### Thank you, contributors

- [@Abirdcfly](https://github.com/Abirdcfly)
- [@aavarghese](https://github.com/aavarghese)
- [@aliok](https://github.com/aliok)
- [@benmoss](https://github.com/benmoss)
- [@devguyio](https://github.com/devguyio)
- [@dprotaso](https://github.com/dprotaso)
- [@dsimansk](https://github.com/dsimansk)
- [@gabo1208](https://github.com/gabo1208)
- [@houshengbo](https://github.com/houshengbo)
- [@itsmurugappan](https://github.com/itsmurugappan)
- [@julz](https://github.com/julz)
- [@lionelvillard](https://github.com/lionelvillard)
- [@markusthoemmes](https://github.com/markusthoemmes)
- [@mattmoor](https://github.com/mattmoor)
- [@matzew](https://github.com/matzew)
- [@nak3](https://github.com/nak3)
- [@pierDipi](https://github.com/pierDipi)
- [@psschwei](https://github.com/psschwei)
- [@ricardozanini](https://github.com/ricardozanini)
- [@steven0711dong](https://github.com/steven0711dong)
- [@travis-minke-sap](https://github.com/travis-minke-sap)
- [@upodroid](https://github.com/upodroid)
- [@vyasgun](https://github.com/vyasgun)

### Learn more

Knative is an open source project that anyone in the [community](https://knative.dev/docs/community/) can use, improve, and enjoy. We'd love you to join us!

- [Welcome to Knative](https://knative.dev/docs)
- [Getting started documentation](https://knative.dev/docs/getting-started)
- [Samples](https://knative.dev/docs/samples)
- [Knative working groups](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md)
- [Knative User Mailing List](https://groups.google.com/forum/#!forum/knative-users)
- [Knative Development Mailing List](https://groups.google.com/forum/#!forum/knative-dev)
- Knative on Twitter [@KnativeProject](https://twitter.com/KnativeProject)
- Knative on [StackOverflow](https://stackoverflow.com/questions/tagged/knative)
- Knative [Slack](https://slack.knative.dev)
- Knative on [YouTube](https://www.youtube.com/channel/UCq7cipu-A1UHOkZ9fls1N8A)
