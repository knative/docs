---
title: "v1.0 release"
linkTitle: "v1.0 release"
Author: "[Carlos Santana](https://twitter.com/csantanapr)"
Author handle: https://github.com/csantanapr
date: 2021-11-02
description: "Knative v1.0 release announcement"
type: "blog"
image: knative-eventing.png
---


### Announcing Knative v1.0 Release

A new version of Knative is now available across multiple components.

Follow the instructions in the documentation
[Installing Knative](https://knative.dev/docs/admin/install/) for the respective component.

#### Table of Contents
- [Highlights](#highlights)
- [Serving v1.0](#serving-v10)
- [Eventing v1.0](#eventing-v10)
- [Eventing Extensions](#eventing-extensions)
    - [Apache Kafka Broker v1.0](#apache-kafka-broker-v10)
    - [RabbitMQ Broker and Source v1.0](#rabbitmq-broker-and-source-v10)
- `kn` [CLI v1.0](#client-v10)
- [Knative Operator v1.0](#operator-v10)
- [Thank you contributors](#thank-you-contributors)


### Highlights

- All components versions are now tagged `knative-v1.0.0`, for users using go library use version `v0.27`
- The per-namespace wildcard certificate provisioner has been integrated into the base controllers
- By default, the Prefer: reply header is forwarded to Broker Triggers' subscribers





### Serving v1.0

<!-- Original notes are here: https://github.com/knative/serving/releases/tag/knative-v1.0.0 -->

#### 🚨 Breaking or Notable Changes

- The per-namespace wildcard certificate provisioner has been integrated into the base controllers
and is now controlled by the namespace-wildcard-cert-selector field. This field allows you
to use a Kubernetes LabelSelector to choose which namespaces should have certificates
provisioned.

- To migrate existing usage of the serving-nscert controller, do the following:
    - Set the namespace-wildcard-cert-selector to the value:
      ```yaml
      matchExpressions:
      - key: "networking.knative.dev/disableWildcardCert"
        operator: "NotIn"
        values: ["true"]
      ```
    - Remove the Deployment, Service and ClusterRole defined by the serving-nscert.yaml resources
in the previous release ([#12174](https://github.com/knative/serving/pull/12174))

#### 💫 New Features & Changes

- Per-namespace wildcard certificate provisioning has been integrated into the main
Knative controllers and is no longer a separate install. It is now controlled by a
label selector on Kubernetes namespaces.
- A new experimental feature, "concurrencyStateEndpoint", allows a webhook to be informed when a container's concurrency goes to/from zero ([#11802](https://github.com/knative/serving/pull/11802), [#12162](https://github.com/knative/serving/pull/12162), [#11917](https://github.com/knative/serving/pull/11917))
- When mesh compatibility mode is not set to "auto" in the networking config map,
the activator will respect Kubernetes's readiness state and avoid probing when
kubernetes readiness propagates more quickly than the activator's probe. ([#12086](https://github.com/knative/serving/pull/12086))

#### 🐞 Bug Fixes

- Fixes an issue where TLS certificates are requested before domain-ownership is established. ([#12080](https://github.com/knative/serving/pull/12080))

### Eventing v1.0

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/knative-v1.0.0 -->

#### 🚨 Breaking or Notable Changes

- If the "strict-subscriber" feature flag is set, Subscriptions will require spec.subscriber to be set. Previously, a bare spec.reply would be accepted by Subscriptions. This feature will be enabled in the 1.1 release; it breaks compatibility with previous versions in order to track the eventing spec and improve the user experience when using Subscriptions. ([#5762](https://github.com/knative/eventing/pull/5762))

#### 💫 New Features & Changes

- By default, the Prefer: reply header is forwarded to Broker Triggers' subscribers ([#5773](https://github.com/knative/eventing/pull/5773))
- The Header Prefer: reply is added to the request sent to a Subscription Subscriber if the spec.reply field is set. ([#5764](https://github.com/knative/eventing/pull/5764))
- The field spec.delivery.deadLetterSink.ref.namespace for Broker, Trigger, Channel and Subscription if not specified is defaulted to metadata.namespace. ([#5748](https://github.com/knative/eventing/pull/5748))
- Adds deadLetterSinkUri to the Channel status.
    - Deprecates deadLetterChannel with a 1-year timer. ([#5746](https://github.com/knative/eventing/pull/5746))
- Channel and Subscription will now enforce validation of the "delivery" field. ([#5777](https://github.com/knative/eventing/pull/5777))
- Next generation Multi-Tenant Scheduler and Descheduler: uses a plugin interface to specify a Scheduler profile with predicates and priorities that run filtering and scoring of pods, respectively to compute the best vreplica placements. When the autoscaler adds new pods, scheduler performs a rebalancing of the already placed vreplicas along with the new vreplicas. A Descheduler profile must be installed when vreplicas need to be scaled down and placements removed. ([#5818](https://github.com/knative/eventing/pull/5818))
- Add UID to the available Kreference mapping resolver template field ([#5810](https://github.com/knative/eventing/pull/5810))

#### 🐞 Bug Fixes

- Fix issue with Parallel updates leaked resources. In order for the fix to work the provided Channel must include the delete verb at the ClusterRole labeled duck.knative.dev/channelable. ([#5775](https://github.com/knative/eventing/pull/5775))
- Fix issue with Sequence updates leaked resources. In order for the fix to work the provided Channel must include the delete verb at the ClusterRole labeled duck.knative.dev/channelable. ([#5718](https://github.com/knative/eventing/pull/5718))


### Eventing Extensions

#### Apache Kafka Broker v1.0

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka-broker/releases/tag/knative-v1.0.0 -->


##### 💫 New Features & Changes

- ClusterRole `knative-kafka-data-plane` for KafkaBroker has been renamed to `knative-kafka-broker-data-plane` ([#1315](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1315))
- ServiceAccount `knative-kafka-data-plane` for KafkaBroker has been renamed to `knative-kafka-broker-data-plane` ([#1315](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1315))
- ClusterRoleBinding `knative-kafka-data-plane` for KafkaBroker has been renamed to `knative-kafka-broker-data-plane` ([#1315](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1315))
- ClusterRole `knative-kafka-data-plane` for KafkaSink has been renamed to `knative-kafka-sink-data-plane` ([#1315](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1315))
- ServiceAccount `knative-kafka-data-plane` for KafkaSink has been renamed to `knative-kafka-sink-data-plane` ([#1315](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1315))
- ClusterRoleBinding `knative-kafka-data-plane` for KafkaSink has been renamed to `knative-kafka-sink-data-plane` ([#1315](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1315))
- Set `status.deadLetterSinkUri` of Broker and Trigger to the resolved URI of `spec.delivery.deadLetterSink` ([#1349](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1349))

#### RabbitMQ Broker and Source v1.0

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-rabbitmq/releases/tag/knative-v1.0.0 -->


##### 💫 New Features & Changes

- A trigger will now send events to its subscriber in parallel, with the number of in-flight messages defaulting to 10 and configurable via the annotationrabbitmq.eventing.knative.dev/prefetchCount. ([#418](https://github.com/knative-sandbox/eventing-rabbitmq/pull/418))
- Trigger filters are now enforced to be immutable, since the underlying RMQ binding is immutable ([#468](https://github.com/knative-sandbox/eventing-rabbitmq/pull/468))

##### 🐞 Bug Fixes

- Brokers will no longer create a queue for dead-lettered events if no dead letter sink is defined ([#453](https://github.com/knative-sandbox/eventing-rabbitmq/pull/453))


### Client v1.0

<!-- Original notes are here: https://github.com/knative/client/blob/main/CHANGELOG.adoc#v100-2021-11-02 -->

#### 💫 New Features & Changes

- Remove deprecated flags `--lookup-path` ([#1506](https://github.com/knative/client/pull/1506))
- Rename `--extra-containers` to `--containers` ([#1499](https://github.com/knative/client/pull/1499))
- Remove deprecated flags `--min-scale` and `--max-scale` ([#1498](https://github.com/knative/client/pull/1498))
- Remove deprecated flags `--limits-cpu` and `--limits-memory` ([#1498](https://github.com/knative/client/pull/1498))
- Add more explanation to missing API error message ([#1497](https://github.com/knative/client/pull/1497))
- Deprecate `--concurrency-target` and `--concurrency-utilization` in favor of `--scale-target` and `--scale-utilization`, respectively ([#1490](https://github.com/knative/client/pull/1490))
- Deprecate `--autoscale-window` in favor of `--scale-window` ([#1489](https://github.com/knative/client/pull/1489))
- Calculate traffic split when N-1 revisions are specified ([#1483](https://github.com/knative/client/pull/1483))
- Create a default config file if it doesn’t exist ([#1472](https://github.com/knative/client/pull/1472))

#### 🐞 Bug Fixes

- Fix domain describe reference to show correct kind ([#1477](https://github.com/knative/client/pull/1477))


## Operator v1.0

<!-- Original notes are here: https://github.com/knative/operator/releases/tag/knative-v1.0.0   -->

#### 💫 New Features & Changes

- Adding COC, contributing doc ([#790](https://github.com/knative/operator/pull/790))
- Remove pingsource-mt-adapter from the list of unsupported HA ([#788](https://github.com/knative/operator/pull/788))
- Apply high-availability to all deployments managed by operator ([#749](https://github.com/knative/operator/pull/749))
fix misspelling of `with` ([#781](https://github.com/knative/operator/pull/781))
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

- [@Abirdcfly](https://github.com/)
- [@aavarghese](https://github.com/aavarghese)
- [@benmoss](https://github.com/benmoss)
- [@boaz0](https://github.com/boaz0boaz0)
- [@dsimansk](https://github.com/dsimansk)
- [@evankanderson](https://github.com/evankanderson)
- [@houshengbo](https://github.com/)
- [@julz](https://github.com/julz)
- [@lionelvillard](https://github.com/lionelvillard)
- [@mattmoor](https://github.com/mattmoor)
- [@matzew](https://github.com/)
- [@nak3](https://github.com/)
- [@odacremolbap](https://github.com/odacremolbap)
- [@pierDipi](https://github.com/pierDipi)
- [@pierDipi](https://github.com/pierDipi)
- [@psschwei](https://github.com/psschwei)
- [@travis-minke-sap](https://github.com/travis-minke-sap)
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
