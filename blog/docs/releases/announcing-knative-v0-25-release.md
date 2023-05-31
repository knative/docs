---
title: "v0.25 release"
linkTitle: "v0.25 release"
author: "[Carlos Santana](https://twitter.com/csantanapr)"
author handle: https://github.com/csantanapr
date: "2021-08-22"
description: "Knative v0.25 release announcement"
type: "blog"
image: knative-eventing.png
---


### Announcing Knative v0.25 Release

A new version of Knative is now available across multiple components.

Follow the instructions in the documentation
[Installing Knative](https://knative.dev/docs/admin/install/) for the respective component.

#### Table of Contents
- [Highlights](#highlights)
- [Serving v0.25](#Serving-v025)
- [Eventing v0.25](#Eventing-v025)
- [Eventing Extensions](#Eventing-Extensions)
    - [Apache Kafka Broker v0.25](#Apache-Kafka-Broker-v025)
    - [Apache Kafka Source and Channels v0.25](#apache-kafka-source-and-channels-v025)
- `kn` [CLI v0.25](#Client-v025)
- [Operator v0.25](#Operator-v025)
- [Thank you contributors](#Thank-you-contributors)


### Highlights
- In preparation for GA, the **net-kourier** components have been renamed. See [Breaking Changes](#-breaking-or-notable-changes) in the Serving section.
- The depecreated namespace label `networking.internal.knative.dev/disableWildcardCert` is now removed. See [Breaking Changes](#-breaking-or-notable-changes) in the Serving section.
- Trigger ready status now takes into account the `DeadLetterURI`
- The `kn` CLI now looks for plugin in the `$PATH` allowing for easy installation of plugins like `kn-quickstart`




### Serving v0.25

<!-- Original notes are here: https://github.com/knative/serving/releases/tag/v0.25.0 -->

#### 🚨 Breaking or Notable Changes

- **Renaming of some `net-kourier` component**

    Related issue: [knative/networking#448](https://github.com/knative/networking/issues/448)

    As part of our efforts to GA/1.0 we've standardized on the naming of our networking plugins that
    are installed alongside Serving. If you're managing your Knative deployment manually with
    `kubectl` **this will require a two-phase upgrade process**. In order to upgrade [net-kourier to v0.25.0](https://github.com/knative-sandbox/net-kourier/releases/tag/v0.25.0) using `kubectl` please follow the steps:

        ```bash
        # Apply the new release
        $ kubectl apply -f net-kourier.yaml

        # Once the deployment is ready apply the same file but
        # prune the old resources
        $ kubectl apply -f net-kourier.yaml \
        --prune -l networking.knative.dev/ingress-provider=kourier
        ```
- **Disabling namespace certificate provisioning legacy label**

    The namespace label `networking.internal.knative.dev/disableWildcardCert` has been deprecated since `v0.15.0` release in favour of `networking.knative.dev/disableWildcardCert`. We have dropped support for this legacy label ([#11626](https://github.com/knative/serving/pull/11626))

#### 💫 New Features & Changes

- A feature flag is available to enable priorityClassName for Knative Services. See config-features for details. ([#11746](https://github.com/knative/serving/pull/11746))
- Add memory metrics for HPA: `hpa.autoscaling.knative.dev` ([#11668](https://github.com/knative/serving/pull/11668))
- Added `app.kubernetes.io/name` labels to resources. It will be replacing app labels in the future. ([#11655](https://github.com/knative/serving/pull/11655))
- Users can set in the field `spec.template.spec.containers[*].securityContext.runAsNonRoot` to true in a PodSpec without a feature flag ([#11606](https://github.com/knative/serving/pull/11606))
- Users can set in the field `spec.template.spec.automountServiceAccountToken` to false in a PodSpec in order to opt-out of Kubenetes' default behaviour of mounting a ServiceAccount token in that Pod's containers. ([#11723](https://github.com/knative/serving/pull/11723))
- Add `v1beta1` version of DomainMapping CRD ([#11682](https://github.com/knative/serving/pull/11682))

#### 🐞 Bug Fixes

- Set `ENABLE_HTTP2_AUTO_DETECTION` to false by default if the feature is not enabled. ([#11760](https://github.com/knative/serving/pull/11760))

### Eventing v0.25

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/v0.25.1 -->


#### 💫 New Features & Changes

- Add `DeadLetterURI` to Trigger status, block ready until it is resolvable ([#5551](https://github.com/knative/eventing/pull/5551))
- Add a health endpoint to `event_display` for enabling readiness probes. ([#5608](https://github.com/knative/eventing/pull/5608))
- Adds support for HTTP OPTIONS and CloudEvents Webhook preflight ([#5542](https://github.com/knative/eventing/pull/5542))

#### 🐞 Bug Fixes

- PingSource schedules starting with `@every` are now properly rejected. ([#5585](https://github.com/knative/eventing/pull/5585))


### Eventing Extensions

#### Apache Kafka Broker v0.25

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka-broker/releases/tag/v0.25.0 -->

#### 💫 New Features & Changes

- The Trigger status contains the resolved URL of the configured dead letter sink. ([#1092](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1092))

#### 🐞 Bug Fixes

- Fix to support subscribers that are a Kubernetes service. The service's endpoint doesn't contain a trailing slash. ([#1123](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1123))

#### Apache Kafka Source and Channels v0.25

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka/releases/tag/v0.25.0 -->

#### 💫 New Features & Changes

- Distributed KafkaChannel Dispatcher will now re-queue KafkaChannels after failed reconciliation which will improve various failure recovery scenarios, but could consume CPU resources if reconciliation is blocked by underlying system issues (bad Kafka Secret config, etc.) ([#795](https://github.com/knative-sandbox/eventing-kafka/pull/795))
- Separated CRDs to extra, additional YAML manifest (similar to eventing) ([#799](https://github.com/knative-sandbox/eventing-kafka/pull/799))
- Enabled support for ResetOffset CRD in distributed KafkaChannel, see config/command/resetoffset for details. ([#761](https://github.com/knative-sandbox/eventing-kafka/pull/761))
- The consolidated KafkaChannel dispatcher is now owned by the controller. ([#798](https://github.com/knative-sandbox/eventing-kafka/pull/798))


### Client v0.25

<!-- Original notes are here: https://github.com/knative/client/blob/main/CHANGELOG.adoc#v0250-2021-08-10 -->

#### 💫 New Features & Changes

- The new plugin `kn-quickstart` is now part of the home-brew plugins suite. Install the plugin using `brew install knative-sandbox/kn-plugins/quickstart` then use it with `kn quickstart kind` this will create a kind cluster with knative installed. Make sure to update `kn` to `v0.25` for example using `brew upgrade kn`

- Deprecate `lookup-path` as path lookup will always be enabled in the future ([#1422](https://github.com/knative/client/pull/1422))
- Add `--tls` option to domain create command ([#1419](https://github.com/knative/client/pull/1419))
- Lookup plugins in `$PATH` by default ([#1412](https://github.com/knative/client/pull/1412))
- Add `--class` flag to broker create command ([#1402](https://github.com/knative/client/pull/1402))
- Add `darwin/arm64` support to kn ([#1401](https://github.com/knative/client/pull/1401))
- Add `base64` data handling to Ping commands ([#1392](https://github.com/knative/client/pull/1392)) ([#1388](https://github.com/knative/client/pull/1388))
- Add support for multiple containers in Service spec ([#1382](https://github.com/knative/client/pull/1382))
- Make `--cmd` flag an array instead of string ([#1380](https://github.com/knative/client/pull/1380))
- Add a `client.knative.dev/updateTimestamp` annotation to trigger a new revision when required ([#1364](https://github.com/knative/client/pull/1364))


#### 🐞 Bug Fixes

- Fix plugin lookup for arguments with slashes ([#1415](https://github.com/knative/client/pull/1415))
- Show server error messages without any taints ([#1406](https://github.com/knative/client/pull/1406))
- Fix path not being escaped when applying a regex on Windows ([#1395](https://github.com/knative/client/pull/1395))
- Fix wait for ready to skip non modified event first ([#1390](https://github.com/knative/client/pull/1390))

## Operator v0.25

<!-- Original notes are here: https://github.com/knative/operator/releases/tag/v0.25.0 -->

#### 💫 New Features & Changes

- Detect missing Istio requirement and suggests user to instal the Istio Gateway CRD [#697](https://github.com/knative/operator/pull/613)


### Thank you, contributors

- [@antoineco](https://github.com/antoineco)
- [@benmoss](https://github.com/benmoss)
- [@cardil](https://github.com/cardil)
- [@devguyio](https://github.com/devguyio)
- [@dsimansk](https://github.com/dsimansk)
- [@evankanderson](https://github.com/evankanderson)
- [@houshengbo](https://github.com/houshengbo)
- [@itsmurugappan](https://github.com/itsmurugappan)
- [@julz](https://github.com/julz)
- [@lionelvillard](https://github.com/lionelvillard)
- [@matzew](https://github.com/matzew)
- [@nak3](https://github.com/nak3)
- [@nealhu](@https://github.com/nealhu)
- [@pierDipi](https://github.com/pierDipi)
- [@psschwei](@https://github.com/psschwei)
- [@psschwei](https://github.com/psschwei)
- [@rhuss](https://github.com/rhuss)
- [@senthilnathan](@https://github.com/senthilnathan)
- [@travis-minke-sap](https://github.com/travis-minke-sap)
- [@upodroid](@https://github.com/upodroid)
- [@vyasgun](https://github.com/vyasgun)
- [@zhaojizhuang](@https://github.com/zhaojizhuang)



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
