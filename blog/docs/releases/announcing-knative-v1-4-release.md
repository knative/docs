---
title: "v1.4 release"
linkTitle: "v1.4 release"
Author: "[Nader Ziada](https://twitter.com/nziada)"
Author handle: https://github.com/nader-ziada
date: 2022-04-20
description: "Knative v1.4 release announcement"
type: "blog"
---


## Announcing Knative 1.4 Release

A new version of Knative is now available across multiple components.

Follow the instructions in
[Installing Knative](https://knative.dev/docs/install/) to install the components you require.

## Table of Contents
- [Highlights](#highlights)
- [Serving v1.4](#serving-v1.4-NOSPACES)
- [Eventing v1.4](#eventing-v1.4-NOSPACES)
- [Eventing Extensions](#eventing-extensions)
    - [Apache Kafka Broker v1.4](#apache-kafka-broker-v1.4-NOSPACES)
    - [RabbitMQ Broker and Source v1.4](#rabbitmq-broker-and-source-v1.4-NOSPACES)
- `kn` [CLI v1.4](#client-v1.4-NOSPACES)
- [Knative Operator v1.4](#operator-v1.4-NOSPACES)
- [Thank you contributors](#thank-you-contributors)


## Highlights

- Our minimum supported Kubernetes version is now 1.22


## Serving v1.4

<!-- Original notes are here: https://github.com/knative/serving/releases/tag/knative-v1.4.0 -->

🚨 Breaking or Notable
 - Our minimum supported Kubernetes version is now 1.22 (#12753, @dprotaso)
 - When using the Horizontal Pod Autoscaler (HPA), revisions will only be marked as ready after the initial-scale / min-scale value is reached. For example, if min-scale: "4", the revision will not be marked ready until all four pods are ready. Note that revisions may take slightly longer to become ready after this change. See https://knative.dev/docs/serving/autoscaling/scale-bounds/ for more details. (#12811, @psschwei)

💫 New Features & Changes
 - Support annotations 'networking.knative.dev/http-protocol' for Overriding the default HTTP behavior per service in DomainMapping CRD. (#12786, @wei840222)
 - serving.knative.dev/release labels, deprecated in v1.3, have been removed. Please switch over to using app.kubernetes.io/name: knative-serving and app.kubernetes.io/version: $VERSION. (#12754, @psschwei)
 - Users can configure a per-revision progress deadline by setting the serving.knative.dev/progress-deadline annotation in .spec.template.metadata.annotations (#12751, @psschwei)

🐞 Bug Fixes
 - Changes the default target-burst-capacity to 210 in order to fix a configuration issue that caused rapid swapping of activator in/out of path. (#12774, @psschwei)
 - Fix gc: delete revision in correct order (#12752, @Taction)
 - Fix tag to digest resolution when using imagePullSecrets (#12836, @dprotaso)

## Eventing v1.4

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/knative-v1.4.0 -->

### 🚨 Breaking or Notable Changes

- The minimum Kubernetes version is 1.22. (#6280, @pierDipi)
- The sugar reconciler has been integrated into the base eventing controller and is now controlled by two LabelSelector fields.
  `namespace-sugar-selector` and `trigger-sugar-selector` fields in the `config-sugar` ConfigMap in `knative-eventing` Namespace allow you to use a Kubernetes LabelSelector to choose which namespaces or triggers respectively should have a Broker provisioned.

  To migrate existing usage of the sugar controller, do the following:

  1. Set the namespace-sugar-selector to the value:
      matchExpressions:
      - key: "eventing.knative.dev/injection"
        operator: "In"
        values: ["enabled"]

  2. Set the trigger-sugar-selector to the value:
      matchExpressions:
      - key: "eventing.knative.dev/injection"
        operator: "In"
        values: ["enabled"]

  3. Remove the Deployment defined by the eventing-sugar-controller.yaml resources
     in the previous release. (#6027, @xtreme-sameer-vohra)

### 💫 New Features & Changes

- Reduced duplication of observability.yaml config map which existed in multiple locations by symlinking "config/channels/in-memory-channel/configmaps/observability.yaml" to "config/core/configmaps/observability.yaml". (#6301, @matzew)
- Reduced duplication of tracing.yaml config map which existed in multiple locations by symlinking "config/channels/in-memory-channel/configmaps/tracing.yaml" to "config/core/configmaps/tracing.yaml". (#6295, @xtreme-sameer-vohra)
- The `sendevent` tool is not part of Eventing core anymore, an alternative is available as `kn` plugin https://github.com/knative-sandbox/kn-plugin-event (#6284, @pierDipi)

### 🐞 Bug Fixes

 - Set dead letter sink URI in the Channel status (#6256, @pierDipi)
 - MTChannelBroker can now co-exist with other broker implementations. (#6265, @n3wscott)
 - The service created for the inmemorychannel's dispatcher will have ports defined, similar to the rest of the services. (#6283, @jhill072)

## Eventing Extensions

### Apache Kafka Broker v1.4

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka-broker/releases/tag/knative-v1.4.0 -->

#### 💫 New Features & Changes

 - Handle host headers in dataplane for identification of channel instances (#1990, @aliok)
 - There is now auto-migration from old consolidated KafkaChannel to the new KafkaChannel. Low level configuration options such as Sarama settings are not migrated to the new channel. However, channel url and auth settings are migrated. (#2004, @aliok)
 - Discard Consumer records that are not CloudEvents (#2066, @aavarghese)
 - Dynamically set max.poll.interval.ms based on the delivery spec (#2058, @pierDipi)
 - The default request timeout is 10 minutes now, it was previously set to 10 seconds.
 - It can be overridden using spec.delivery.timeout on Broker, Trigger, KafkaChannel and Subscription. (#2057, @pierDipi)
 - Add new new-trigger-filters experimental feature. When enabled, Triggers support a new filters field that conforms to the filters API field defined in the CloudEvents Subscriptions API. It allows you to specify a set of powerful filter expressions, where each expression evaluates to either true or false for each event. (#1922, @devguyio)


### RabbitMQ Broker and Source v1.4

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-rabbitmq/releases/tag/knative-v1.4.0 -->

### 🚨 Breaking or Notable Changes

- Remove support for managed RabbitMQ brokers (#708, @gab-satchi)

#### 💫 New Features & Changes

- Now performance graphs for the RabbitMQ Broker are going to be generated for every mayor version release inside our performance test directories (#668, @gabo1208)
- Now the RabbitMQ Source, when failing to send an event, does not get stuck in a cycle requeueing messages as they come. It follows a retries based backoff strategy (and does not reqeue them if the prefetchCount is 1) (#614, @gabo1208)
- Now the RabbitMQ's Broker Ingress pod can recover from a closed Channel or Connection (#648, @gabo1208)
- 🧹 Changed prefetchCount env variable name to Parallelism in both Trigger and Source, to better reflect its functionality (#676, @gabo1208)

## Client v1.4

<!-- Original notes are here: https://github.com/knative/client/releases/tag/knative-v1.4.0 -->

### 💫 New Features & Changes

- The compile dependencies have been updated to Knative Serving v1.4.0, Knative Eventing v1.4.0 (Go module versions are v0.31.0).
- Some new flags have been added to `kn service create`, `kn service update` and `kn service apply`:
  - `--timeout` for specifying the amount of time (in seconds) to wait for the application to respond to a request before returning with a timeout error. The value of this option sets the `.spec.template.spec.timeoutSecond` field on the service. The server-side default is used if not provided, which is 300s by default.
  - `--pull-policy` for setting the imagePullPolicy for the application's image. Like for a pod's container, this can one of `Always`, `Never`, `IfNotPresent`. The pull policy will be applied against the digest of the resolved image (Knative always resolves an image tag to a digest) and not the image tag.
  - `--wait-window` for setting the error window which allows intermediate errors while waiting for the ready status of a service. If not given, a default of 2 seconds is used (i.e. if an error state occurs but gets back to a success state within two seconds, then `kn` won't return an error but considers to be an expected fluctuation during the reconciliation process).
  - `--scale-metric` for setting the `autoscaling.knative.dev/metric` annotation on a service that specifies the metric the autoscaler should scale on. Possible value are `concurrency`, `cpu`, `memory` and `rps`.
- Added subpath functionality to the `--mount` flag so that subdirectories of a volume can be mounted. For example, `--mount /mydir=cm:myconfigmap/cmkey` will mount the value of key `cmkey` in ConfigMap `myconfigmap` to a directory `/mydir` within the services' application container.

### Released Plugins

- The kn-plugin-event plugin is now included since this release.
- The plugins that are released in parallel and aligned with Knative v1.4.0 are:
  - `kn-plugin-admin` for managing Knative installations that are running on Kubernetes | [download](https://github.com/knative-sandbox/kn-plugin-admin/releases/tag/knative-v1.4.0)
  - `kn-plugin-quickstart` to quickly set up a local Knative environment from the command line. | [download](https://github.com/knative-sandbox/kn-plugin-quickstart/releases/tag/knative-v1.4.0)
  - `kn-plugin-source-kafka` for managing a Kafka Source that has been installed via eventing-kafka on the backend | [download](https://github.com/knative-sandbox/kn-plugin-source-kafka/releases/tag/knative-v1.4.0)
  - `kn-plugin-source-kamelet` for managing Kamelet Sources that has been installed via Camel-K on the backend | [download](https://github.com/knative-sandbox/kn-plugin-source-kamelet/releases/tag/knative-v1.4.0)
  - `kn-plugin-event` for creating and sending CloudEvents from insider or outside the cluster | [download](https://github.com/knative-sandbox/kn-plugin-event/releases/tag/knative-v1.4.0)

  Note: All those plugins are released separately and are technically not part of this knative/client release, however they are aligned to share the same Knative dependencies and can be targeted for inlining.


## Operator v1.4

<!-- Original notes are here: https://github.com/knative/operator/releases/tag/knative-v1.4.0  -->

### 💫 New Features & Changes

- Refactor the post-install yaml files for API migration (#996, thanks @houshengbo)
- Fix the RBAC issue for Knative due to the label change (#1010, thanks @houshengbo)
- Set capability to Seamless Upgrades (#1014, thanks @pierDipi)
- Implement the label and annotation overwriting for service (#1033, thanks @houshengbo)
- Adding code of conduct to reference knative/community's CoC (#1003, thanks @rhuss)


### 🐞 Bug Fixes

- Change int32 into *int32 for Replicas (#1029, thanks @houshengbo)

## Thank you, contributors

Release Leads:

- [@nader-ziada](https://github.com/nader-ziada)
- [@ikvmw](https://github.com/ikvmw)

Contributors:

- [@aavarghese](https://github.com/aavarghese)
- [@aliok](https://github.com/aliok)
- [@devguyio](https://github.com/devguyio)
- [@dprotaso](https://github.com/dprotaso)
- [@gab-satchi](https://github.com/gab-satchi)
- [@gabo1208](https://github.com/gabo1208)
- [@houshengbo](https://github.com/houshengbo)
- [@jhill072](https://github.com/jhill072)
- [@Juneezee](https://github.com/Juneezee)
- [@matzew](https://github.com/matzew)
- [@n3wscott](https://github.com/n3wscott)
- [@pierDipi](https://github.com/pierDipi)
- [@psschwei](https://github.com/psschwei)
- [@Taction](https://github.com/Taction)
- [@vyasgun](https://github.com/vyasgun)
- [@wei840222](https://github.com/wei840222)
- [@xtreme-sameer-vohra](https://github.com/wei840222)

## Learn more

Knative is an open source project that anyone in the [community](https://knative.dev/docs/community/) can use, improve, and enjoy. We'd love you to join us!

- [Knative docs](https://knative.dev/docs)
- [Quickstart tutorial](https://knative.dev/docs/getting-started)
- [Samples](https://knative.dev/docs/samples)
- [Knative working groups](https://github.com/knative/community/blob/main/working-groups/WORKING-GROUPS.md)
- [Knative User Mailing List](https://groups.google.com/forum/#!forum/knative-users)
- [Knative Development Mailing List](https://groups.google.com/forum/#!forum/knative-dev)
- Knative on Twitter [@KnativeProject](https://twitter.com/KnativeProject)
- Knative on [StackOverflow](https://stackoverflow.com/questions/tagged/knative)
- Knative [Slack](https://slack.knative.dev)
- Knative on [YouTube](https://www.youtube.com/channel/UCq7cipu-A1UHOkZ9fls1N8A)
