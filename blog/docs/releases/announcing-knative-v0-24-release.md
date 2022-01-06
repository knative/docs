---
title: "v0.24 release"
linkTitle: "v0.24 release"
Author: "[Omer Bensaadon](https://twitter.com/omer_bensaadon)"
Author handle: https://github.com/omerbensaadon
date: 2021-06-29
description: "Knative v0.24 release announcement"
type: "blog"
image: knative-eventing.png
---


### Announcing Knative v0.24 Release

A new version of Knative is now available across multiple components.

Follow the instructions in the documentation
[Installing Knative](https://knative.dev/docs/admin/install/) for the respective component.

#### Table of Contents
- [Highlights](#highlights)
- [Serving v0.24](#Serving-v024)
- [Eventing v0.24](#Eventing-v024)
- [Eventing Extensions](#Eventing-Extensions)
    - [Apache Kafka Broker v0.24](#Apache-Kafka-Broker-v024)
    - [RabbitMQ Eventing v0.24](#RabbitMQ-Eventing-v024)
- `kn` [CLI v0.24](#Client-v024)
- [Operator v0.24](#Operator-v024)
- [Thank you contributors](#Thank-you-contributors)


### Highlights
- The Knative site [has a brand new look!](https://knative.dev/docs/) We're built on [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).
- A brand new [Getting Started Tutorial](https://knative.dev/docs/getting-started/) has been added to the Knative site.
- We've done some reorganization of the Docs and we now have a [Developer guide](https://knative.dev/docs/developer/) and [Administrator's guide](https://knative.dev/docs/admin/).
- The DomainMapping feature is now BETA.
- In preparation for GA, some net-* components have been renamed. See [Breaking Changes](#Serving-v024) in the Serving section.
- Eventing has a new [Experimental features](https://knative.dev/docs/eventing/experimental-features/) process and two new experimental features for you to try.
- The Minimum Kubernetes version is now 1.19.


### Serving v0.24

<!-- Original notes are here: https://github.com/knative/serving/releases/tag/v0.24.0 -->

#### 🚨 Breaking or Notable Changes

* **Renaming of some `net-*` components**
    Related issue: [knative/networking#448](https://github.com/knative/networking/issues/448)

    As part of our efforts to GA/1.0 we've standardized on the naming of our networking plugins that
    are installed alongside Serving. If you're managing your Knative deployment manually with
    `kubectl` **this will require a two-phase upgrade process**. See the below sections:

    * Upgrade of [net-http01 to v0.24.0](https://github.com/knative-sandbox/net-http01/releases/tag/v0.24.0)

        ```
        # Apply the new release
        $ kubectl apply -f net-http01.yaml

        # Once the deployment is ready delete the old resources
        $ kubectl delete deployment http01-controller -n knative-serving
        $ kubectl delete service challenger -n knative-serving
        ```

    * Upgrade of [net-certmanager to v0.24.0](https://github.com/knative-sandbox/net-certmanager/releases/tag/v0.24.0)

        ```
        # Apply the new release
        $ kubectl apply -f net-certmanager.yaml

        # Once the deployment is ready apply the same file but
        # prune the old resources
        $ kubectl apply -f net-certmanager.yaml \
          --prune -l networking.knative.dev/certificate-provider=cert-manager
        ```

    * Upgrade [net-istio to v0.24.0](https://github.com/knative-sandbox/net-istio/releases/tag/v0.24.0)

        ```
        # Apply the new release
        $ kubectl apply -f net-istio.yaml

        # Once the deployment is ready apply the same file but
        # prune the old resources
        $ kubectl apply -f net-istio.yaml \
          --prune -l networking.knative.dev/ingress-provider=istio
        ```

    * Upgrade of [net-contour to v0.24.0](https://github.com/knative-sandbox/net-contour/releases/tag/v0.24.0)

        ```
        # Apply the new release
        $ kubectl apply -f net-contour.yaml

        # Once the deployment is ready apply the same file but
        # prune the old resources
        $ kubectl apply -f net-contour.yaml \
          --prune -l networking.knative.dev/ingress-provider=contour
        ```

    * Upgrade of [net-kourier to v0.24.0](https://github.com/knative-sandbox/net-kourier/releases/tag/v0.24.0).
    At this point we've deferred the renaming to net-kourier until the next release.
    We're looking to ensure there is no traffic disruption as part of the upgrade.
    Therefore upgrading to v0.24.0 requires no special instructions.

* **Kubernetes 1.19 is now required**

    As part of our
    [Kubernetes Minimum Version Principle](https://github.com/knative/community/blob/main/mechanics/RELEASE-VERSIONING-PRINCIPLES.md#k8s-minimum-version-principle)
    we now have a hard requirement on Kubernetes Version 1.19.

* **Webhook/Controller RBAC changes**

    The recommended way to delete a Knative installation is to run
    `kubectl delete -f serving-core.yaml` and other release YAMLs you might have applied.
    There's been a misconception that deleting the `knative-serving` namespace performs a
    similar cleanup but this does not remove cluster-scoped resources.
    In prior releases the cluster state would have _prevented_ the reinstall of Knative Serving.
    We've addressed this problem, but it requires some RBAC permissions on namespaces and
    finalizers.

    See the relevant issues and PRs below:

    * Original issue: [knative/pkg#2044](https://github.com/knative/pkg/issues/2044)
    * Workaround: [knative/pkg#2098](https://github.com/knative/pkg/pull/2098)
    * `knative-serving-core` cluster role has requires permission for namespaces/finalizers: [#11517](https://github.com/knative/serving/pull/11517)

* **DomainMapping feature is now BETA**

    This means it is built into the main `serving-core` YAML by default.
    It is still possible to opt out of the feature by setting replica count of the
    domainmapping-controller to zero.

    As part of this transition the default value for autocreateClusterDomainClaims in the
    `config-network` config map was changed to false, meaning cluster-wide permissions are
    required to delegate the ability to create particular DomainMappings to namespaces.
    Single tenant clusters may wish to allow arbitrary users to create Domain Mappings by changing
    this value back to `true`. ([#11573](https://github.com/knative/serving/pull/11573))

#### 💫 New Features & Changes

* Allow dropping capabilities from a container's security context ([#11344](https://github.com/knative/serving/pull/11344))
* DomainMapping can now specify a TLS secret to be used as the HTTPS certificate ([#11250](https://github.com/knative/serving/pull/11250))
* Provides a feature gate that, when enabled, allows adding capabilities from a container's security context ([#11410](https://github.com/knative/serving/pull/11410))
* `defaultExternalScheme` can now be used for default routes to surface a URL scheme of your choice rather than the default "http". ([#11480](https://github.com/knative/serving/pull/11480))
* Optimized generated routes to minimize Envoy configuration size ([net-istio#632](https://github.com/knative-sandbox/net-istio/pull/632))
* Rename Contour's ClusterRole and ClusterRoleBinding to differ from existing contour installation ([net-contour#500](https://github.com/knative-sandbox/net-contour/pull/500))
* Add a new ConfigMap `config-kourier`, with the initial `enable-service-access-logging` setting ([net-kourier#523](https://github.com/knative-sandbox/net-kourier/pull/523))

#### 🐞 Bug Fixes

* Fixed a bug where traffic was briefly routed 'wrong', leading to errors due to exceeded
queues in deployments with a large activator count and a low service Pod count. ([#11375](https://github.com/knative/serving/pull/11375))
* Traffic status in Route is updated whenever traffic configuration was wrong. ([#11477](https://github.com/knative/serving/pull/11477))
* Validates, consistently with other configmaps, that the `_example` section of the features
ConfigMap is not accidentally modified. ([#11391](https://github.com/knative/serving/pull/11391))


### Eventing v0.24

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/v0.24.1 -->

#### 🚨 Breaking or Notable Changes

* You must run the storage migration tool after the upgrade to migrate from v1beta2 to v1 `pingsources.sources.knative.dev` resources. ([#5381](https://github.com/knative/eventing/pull/5381))

#### 💫 New Features & Changes

We're glad to announce that we have introduced a new process to test and develop new features,
called the [experimental features process](https://github.com/knative/eventing/blob/a574b7ba95b9c8d4743ba3ee12184c39e0415d87/docs/experimental-features.md).

Thanks to this process, you are able to try out the new amazing features and provide feedback to the project!

We're introducing two experimental features to begin with:

* `kreference-group`: When using `ref`, refer to resources using only the API Group, and not the full API Version.
* `delivery-timeout`: When using the `delivery`, define per request timeout.

You can read more about how to enable these features and their usage in the
[experimental feature documentation](https://dev-knative.netlify.app/development/eventing/experimental-features/).

* `KReference.Group` now can be used in `Subscription.Spec.Channel` as well ([#5520](https://github.com/knative/eventing/pull/5520))
* Added `DeliverySpec.Timeout` ([#5149](https://github.com/knative/eventing/pull/5149))
* Added the experimental feature `kreference-group`.
By enabling it, you can use `Subscriber.Ref.Group` instead of `Subscriber.Ref.APIVersion` to refer to another Resource, without being explicit about the resource version (for example, v1beta1, v1, ...) ([#5440](https://github.com/knative/eventing/pull/5440))
* Remaining HA Control Plane Pods (through the operator) are now labeled with podAntiAffinity to ensure there isn't a single point of failure. ([#5409](https://github.com/knative/eventing/pull/5409))


#### 🐞 Bug Fixes

* Fixed a race condition with apiserversources reported ready before they have begun listening for events ([#5446](https://github.com/knative/eventing/pull/5446))
* Imc-controller cluster role now has update permission for namespaces/finalizers. ([#5539](https://github.com/knative/eventing/pull/5539))
* Knative-eventing-webhook cluster role has update permission for namespaces/finalizers. ([#5501](https://github.com/knative/eventing/pull/5501))


#### 🧹 Clean up

* `Subscription.Spec.Channel` now uses KReference and the `spec.channel` CRD schema is less permissive and matches the supported usage of KReference fields.
Subscription's users creating their resources with YAMLs are not affected. ([#5412](https://github.com/knative/eventing/pull/5412))
* The PingSource adapter now generates a normal event instead of a warning when the source is not ready. Rename the event to PingSourceSkipped.
    * The PingSource adapter now generates the normal event PingSourceSynchronized when it has been synchronized. ([#5549](https://github.com/knative/eventing/pull/5549))


### Eventing Extensions

#### Apache Kafka Broker v0.24

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka-broker/releases/tag/v0.24.0 -->

#### 💫 New Features & Changes

- Add some details in the existing Subscriber resolved condition about the delivery order. [#912](https://github.com/knative-sandbox/eventing-kafka-broker/pull/912)
- Receiver deployment uses all available CPUs. [#985](https://github.com/knative-sandbox/eventing-kafka-broker/pull/985)
- Now you can specify both in Broker and Trigger delivery specs the new timeout field, as part of the experimental feature delivery-timeout. For more information, see [Experimental features](https://knative.dev/docs/eventing/experimental-features/). [#1034](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1034)
- Updates Go to v1.16 [#886](https://github.com/knative-sandbox/eventing-kafka-broker/pull/886)
- Updates protobuf to v3.17.x [#946](https://github.com/knative-sandbox/eventing-kafka-broker/pull/946)
- Updates vert.x to v4.1 [#900](https://github.com/knative-sandbox/eventing-kafka-broker/pull/900)


#### RabbitMQ Eventing v0.24

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-rabbitmq/releases/tag/v0.24.0 -->

#### 💫 New Features & Changes
- Add validating webhook that checks RabbitMQBroker class brokers for valid [secret, rabbitmqcluster] configurations. ([#324](https://github.com/knative-sandbox/eventing-rabbitmq/pull/324))
- Provide an option for install that does not have dependency on rabbitmq cluster operator or messaging-topology-operator. That allows you to bring your own rabbitmq broker. ([#309](https://github.com/knative-sandbox/eventing-rabbitmq/pull/309))
- Add installation instructions for two kinds of brokers. ([#315](https://github.com/knative-sandbox/eventing-rabbitmq/pull/315))

#### 🐞 Bug Fixes
- Fix Standalone Broker to support Trigger DeadLetterSink properly. ([#341](https://github.com/knative-sandbox/eventing-rabbitmq/pull/341))
- Fix per trigger DeadLetterSink support. ([#337](https://github.com/knative-sandbox/eventing-rabbitmq/pull/337))
- Fix issue [#320](https://github.com/knative-sandbox/eventing-rabbitmq/issues/320): Fix incorrect links to both nightly and to-be-released standalone broker. ([#325](https://github.com/knative-sandbox/eventing-rabbitmq/pull/325))
- Remove unnecessary keda permissions since that functionality was moved to https://github.com/knative-sandbox/eventing-autoscaler-keda ([#319](https://github.com/knative-sandbox/eventing-rabbitmq/pull/319))
- Use better names for all RabbitMQ resources. Both k8s resources as well as RabbitMQ resources for standalone Broker. ([#344](https://github.com/knative-sandbox/eventing-rabbitmq/pull/344))


### Client v0.24

<!-- Original notes are here: https://github.com/knative/client/blob/main/CHANGELOG.adoc#v0240-2021-06-29 -->

#### 💫 New Features & Changes

- Prettify printing of webhook warnings [#1353](https://github.com/knative/client/pull/1353)
- Update Kubernetes dependencies to v0.20.7 [#1344](https://github.com/knative/client/pull/1344)
- Increase code coverage for Sources [#1343](https://github.com/knative/client/pull/1343)
- Make e2e test run over other networks [#1339](https://github.com/knative/client/pull/1339)
- Add `--env-value-from` flag and keep order of env vars as provided [#1328](https://github.com/knative/client/pull/1328)

#### 🐞 Bug Fixes

- Fix Subscription's Channel to use KRefence type [#1326](https://github.com/knative/client/pull/1326)


### Operator v0.24

<!-- Original notes are here: https://github.com/knative/operator/releases/tag/v0.24.0 -->

#### 💫 New Features & Changes

- Add the manifests of the Eventing sources [#641](https://github.com/knative/operator/pull/641)
- Change the APIs for Eventing sources [#613](https://github.com/knative/operator/pull/613)
- Add the logic to install sources [#645](https://github.com/knative/operator/pull/645)
- Drop use of pkg/test.KubeClient [#655](https://github.com/knative/operator/pull/655)
- Install the webhooks after installing the deployments and services [#674](https://github.com/knative/operator/pull/674)

#### 🐞 Bug Fixes

- Improve fetcher by supporting version parameter [#613](https://github.com/knative/operator/pull/613)
- Add a 20-second timeout before running the post-upgrade tests [#623](https://github.com/knative/operator/pull/623)
- Add $KO_FLAGS to e2e test [#649](https://github.com/knative/operator/pull/649)
- Make e2e test run over other networks [#650](https://github.com/knative/operator/pull/650)
- Allow to set NodeSelector through spec.deployments.nodeSelector [#658](https://github.com/knative/operator/pull/658)
- Gracefully handle net-* deployment rename [#669](https://github.com/knative/operator/pull/669)

### Thank you, contributors

- [@BbolroC](https://github.com/BbolroC)
- [@aliok](https://github.com/aliok)
- [@benmoss](https://github.com/benmoss)
- [@dprotaso](https://github.com/dprotaso)
- [@dsimansk](https://github.com/dsimansk)
- [@houshengbo](https://github.com/houshengbo)
- [@howardjohn](https://github.com/howardjohn)
- [@itsmurugappan](https://github.com/itsmurugappan)
- [@izabelacg](https://github.com/izabelacg)
- [@julz](https://github.com/julz)
- [@lberk](https://github.com/lberk)
- [@lionelvillard](https://github.com/lionelvillard)
- [@markusthoemmes](https://github.com/markusthoemmes)
- [@matzew](https://github.com/matzew)
- [@nak3](https://github.com/nak3)
- [@novahe](https://github.com/novahe)
- [@pierDipi](https://github.com/pierDipi)
- [@psschwei](https://github.com/psschwei)
- [@shinigambit](https://github.com/shinigambit)
- [@slinkydeveloper](https://github.com/slinkydeveloper)
- [@vaikas](https://github.com/vaikas)
- [@zroubalik](https://github.com/zroubalik)


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
