---
title: "v0.19 release"
linkTitle: "v0.19 release"
Author: "[Carlos Santana](https://twitter.com/csantanapr)"
Author handle: https://github.com/csantanapr
date: 2020-11-13
description: "Knative v0.19 release announcement"
type: "blog"
image: knative-eventing.png
---


### Announcing Knative v0.19 Release

A new version of Knative is now available across multiple components.
Follow the instructions in the documentation [Installing Knative](https://knative.dev/docs/install/) for the respective component.

#### Table of Contents
- [Serving v0.19](#serving-v019)
- [Eventing v0.19](#eventing-v019)
- Eventing Extensions
    - [Eventing Kafka Broker v0.19](#eventing-kafka-broker-v019)
    - [Eventing Gitlab v0.19](#eventing-gitlab-v019)
    - [Eventing RabbitMQ v0.19](#eventing-rabbitmq-v019)
- [CLI v0.19](#client-v019)
- [Operator v0.19](#operator-v019)
- [Thank you contributors v0.19](#thank-you-contributors-v0.19)


### Highlights

- All components built by Knative are now multi architecture including `arm64` which is the architecture used in ARM based machines like the [Raspberry pi](https://www.raspberrypi.org/).
- The monitoring bundle has been removed and the git repository archived.
- Improvements for cold start by adding a scale down delay.
- No longer mounting `/var/log` this allows certain images like `docker.io/nginx` that use this directory to be use as Knative Service.
- New Alpha feature that allows for domain name mapping at namespace scope.
- You specify delivery spec defaults for brokers in Eventing configmap `config-br-defaults`
- Eventing keeps improving stability by squashing bugs.
- The CLI now offers `arm64` binary, and introduce two new commands `kn service apply` and `kn service import`

### Serving v0.19

🚨 Breaking
- The deprecated monitoring bundle has been removed ([#9807](https://github.com/knative/serving/pull/9807))
- Drop serving v1alpha1 and v1beta1 APIs ([#9617](https://github.com/knative/serving/pull/9617), [#9620](https://github.com/knative/serving/pull/9620))
- We only mount a volume at `/var/log` if the operator has enabled log collection. Runtime contract `/var/log` requirement has changed from MUST to MAY ([#9683](https://github.com/knative/serving/pull/9683)]

💫 New Features & Changes
- Adds a Scale Down Delay feature, allowing maintaining replica count for a configurable period after request count drops to avoid cold start penalty. ([#9626](https://github.com/knative/serving/pull/9626))
- (Alpha) Adds a DomainMapping CRD in v1alpha1, allowing mapping a custom domain name to a Knative Service ([#9714](https://github.com/knative/serving/pull/9714), [#9735](https://github.com/knative/serving/pull/9735), [#9752](https://github.com/knative/serving/pull/9752), [#9796](https://github.com/knative/serving/pull/9796), [#9915](https://github.com/knative/serving/pull/9915), [#10044](https://github.com/knative/serving/pull/10044))
- Adding cluster-wide flag max-scale-limit. This ensures that both cluster-wide flag max-scale and per-revision annotation "autoscaling.knative.dev/maxScale" for new revision will not exceed this number. ([#9577](https://github.com/knative/serving/pull/9577))
- All of our deployments run with a minimal set of kernel capabilities. ([#9973](https://github.com/knative/serving/pull/9973))
- Autoscaler now supports multiple pods. Autoscaler Deployment needs to be scaled to 0 first then scaled to other replica value. ([#9682](https://github.com/knative/serving/pull/9682))
- Updated the Service schema to include a high level basic schema. ([#9436](https://github.com/knative/serving/pull/9436), [#9953](https://github.com/knative/serving/pull/9953))
- Queue-proxies are no longer allow to run as root, they have a read-only root filesystem and have all capabilities dropped. ([#9974](https://github.com/knative/serving/pull/9974))
- ResponsiveRevisionGC is enabled by default ([#9710](https://github.com/knative/serving/pull/9710))
- Revisions are now named more clearly and consistently. ([#9740](https://github.com/knative/serving/pull/9740))

🐞 Bug Fixes
- Domain is validated by k8s library IsFullyQualifiedDomainName(). ([#10023](https://github.com/knative/serving/pull/10023))
- Fixed a rare nil-pointer exception in the autoscaler ([#9794](https://github.com/knative/serving/pull/9794))
- Ingress is reconciled when label was different from desired. ([#9719](https://github.com/knative/serving/pull/9719))

### Eventing v0.19

💫 New Features & Changes
- Config-br-defaults support setting delivery spec defaults ([#4328](https://github.com/knative/eventing/pull/4328))

🐞 Bug Fixes
- Fix a bug which could cause eventing-webhook to crashloop on initial creation. ([#4168](https://github.com/knative/eventing/pull/4168))
- Change the image pull policy so sinkbinding source tests work with kind. ([#4317](https://github.com/knative/eventing/pull/4317))
- Dependency readiness could sometimes be missed because mismatched informer/lister was being used in the trigger reconciler. ([#4296](https://github.com/knative/eventing/pull/4296))
- Dispatcher was incorrectly behaving like a normal reconciler instead of skipping status updates. I wonder if this was causing grief battling the normal reconciler. ([#4280](https://github.com/knative/eventing/pull/4280))
- Fix issue [#4375](https://github.com/knative/eventing/issues/4375) where we would not reconcile changes to reconcile policy or duration. ([#4405](https://github.com/knative/eventing/pull/4405))
- Only update the subscriber statuses in IMC after they have been added to handlers. Reduces failures where the
  subscribers have been marked before the dataplane has been actually configured. ([#4435](https://github.com/knative/eventing/pull/4435))
- Retry on network failures ([#4454](https://github.com/knative/eventing/pull/4454))
- ingress / filter now handle proper k8s lifecycle. ([#3917](https://github.com/knative/eventing/pull/3917))
- KnativeHistory extension is not added anymore to events going through channels ([#4366](https://github.com/knative/eventing/pull/4366))

🧹 Clean up
- Move fuzzer (test related code) to test files so they don't get baked into our binaries. Small reduction in binary size. ([#4399](https://github.com/knative/eventing/pull/4399))
- DeliverySpec validation rejects a negative retry config. ([#4216](https://github.com/knative/eventing/pull/4216))
- Just clean up some unused fields from the mtbroker reconciler struct. ([#4318](https://github.com/knative/eventing/pull/4318))
- Point to Broker ref instead of using a hard coded path. Also makes things little easier to reuse against other brokers. ([#4278](https://github.com/knative/eventing/pull/4278)))
- Reducing places where we pull in fuzzers. ([#4447](https://github.com/knative/eventing/pull/4447))
- Simplify the IMC implementation, reduce churn due to global resyncs. ([#4359](https://github.com/knative/eventing/pull/4359))
- Use github action to run codecov. ([#4237](https://github.com/knative/eventing/pull/4237))
- remove all knative fuzzers from our binaries. ([#4402](https://github.com/knative/eventing/pull/4402))
- Move ContainerSource to v1 API. ([#4257](https://github.com/knative/eventing/pull/4257))
- Eventing now tests the supported Kubernetes version range pre-submit. ([#4273](https://github.com/knative/eventing/pull/4273)))
- Run kind e2e tests every 4 hours on Github actions. ([#4412](https://github.com/knative/eventing/pull/4412))
- Updated go-retryablehttp to v0.6.7 ([#4423](https://github.com/knative/eventing/pull/4423))


### Eventing Contributions v0.19

#### Eventing Kafka Broker v0.19

Release Notes for [eventing-kafka-broker](https://github.com/knative-sandbox/eventing-kafka-broker)

**Actions Required (pre-upgrade)**
- Run `kubectl delete configmap -n knative-eventing kafka-broker-brokers-triggers`

🚨 Breaking
- Default replication factor is 3 (1 previously) ([#375](https://github.com/knative-sandbox/eventing-kafka-broker/pull/375))


💫 New Features & Changes
- `eventing-kafka.yaml` can be used to install Broker and KafkaSink. ([#367](https://github.com/knative-sandbox/eventing-kafka-broker/pull/367))
- Data plane pods expose server and client metrics in Prometheus format. ([#231](https://github.com/knative-sandbox/eventing-kafka-broker/pull/231) [#244](https://github.com/knative-sandbox/eventing-kafka-broker/pull/244))
    - The receiver component exposes:
      - `http_requests_produce_total` - Number of accepted produce requests (200-level responses)
      - `http_requests_malformed_total` - Number of malformed produce requests (400-level responses)
    - The dispatcher component exposes:
      - `http_events_sent_total` - Number of events delivered to Apache Kafka
- The Broker retries sending events. ([#268](https://github.com/knative-sandbox/eventing-kafka-broker/pull/268) [#263](https://github.com/knative-sandbox/eventing-kafka-broker/pull/263) [#258](https://github.com/knative-sandbox/eventing-kafka-broker/pull/258))

🐞 Bug Fixes
- Remove config-logging volume from the controller ([#288](https://github.com/knative-sandbox/eventing-kafka-broker/pull/288))
- Thread blocked when logging large configurations in debug mode ([#346](https://github.com/knative-sandbox/eventing-kafka-broker/pull/346) [#378](https://github.com/knative-sandbox/eventing-kafka-broker/pull/378))

🧹 Clean up
- The container image's sizes are ~90MB instead of ~287MB. ([#265](https://github.com/knative-sandbox/eventing-kafka-broker/pull/265) [#306](https://github.com/knative-sandbox/eventing-kafka-broker/pull/306))
- Gracefully clean up resources on shutdown ([#334](https://github.com/knative-sandbox/eventing-kafka-broker/pull/334))
- `KafkaSink` usage: https://gist.github.com/matzew/e2c2fcd2696a346f25b8bc9e64bfd0fa


#### Eventing Gitlab v0.19

Release Notes for [eventing-gitlab](https://github.com/knative-sandbox/eventing-gitlab)

💫 New Features & Changes
- Declare event types emitted by a GitLabSource instance so they are propagated as Knative EventTypes. ([#24](https://github.com/knative-sandbox/eventing-gitlab/pull/24))

🐞 Bug Fixes
- Sanitize the type attribute of emitted CloudEvents so it doesn't contain spaces and capital letters. ([#24](https://github.com/knative-sandbox/eventing-gitlab/pull/24))

🧹 Clean up
- Ensure the source attribute of emitted CloudEvents is stable and predictable. ([#24](https://github.com/knative-sandbox/eventing-gitlab/pull/24))


#### Eventing RabbitMQ v0.19

Release Notes for [eventing-rabbitmq](https://github.com/knative-sandbox/eventing-rabbitmq)

💫 New Features & Changes
- Implement Dead Letter Queue

🐞 Bug Fixes
- Fix a bug where Trigger Dependency would not be always tracked correctly
- Fix bug where in non-default cluster names the network names would be incorrect

🧹 Clean up
- Use Kind for e2e tests as well as use common github actions from Knative.


### Client v0.19

- The `kn` 0.19.0 introduces two new commands (`kn service apply` and `kn service import`) and removes some deprecated options, in addition to bug fixes and some other goodies described below.
- You can find the full list of changes in the [CHANGELOG](https://github.com/knative/client/blob/main/CHANGELOG.adoc).

🚨 Breaking

The following deprecated options have been removed:

-  `--async` for all CRUD commands. Use `--no-wait` instead
-  `--requests-cpu`, `--request-memory`, `--limits-cpu` and `--limits-memory` when managing services. The replacement is to use `--limit memory=..` and `--limit cpu=...` (same for `--request`). Both options can be combined as in `--limit memory=256Mi,cpu=500m`

💫 New Features & Changes

#### `kn service apply`

- A new `kn service apply` command has been added to allow a _declarative management_ for your Knative service.
    This new command is especially useful in can CI/CD context to allow for idempotent operations when creating or updating services.
    It works much like `kubectl apply` and used a client-side 3-way merge algorithm to update service. The kubectl merge algorithm is directly reused here.
    As `apply` operates on Knative's custom resource types, it suffers the same limitation as the client-side merge algorithm in `kubectl apply` when dealing with CRDs.
    I.e. arrays can't be merged but are just overwritten by an update.
    This limitation affects all containers specific parameters.

- For the future, we plan to add a better merge algorithm that supports a full strategic 3-way merge like the support of `kubectl apply` has for intrinsic K8s resources.

- It is important to note that `kn service apply` is fundamentally different to `kn service update` as with `kn service apply` the full configuration needs to be provided as command-line options or within a declaration file when used with `--filename`.
With `kn service update` you only specify the parts to be updated and don't touch any other service configuration.
This characteristic of `apply` also implies that you always have to provide the image as the only mandatory parameter with `kn service apply`.

- For example:
    ```
    # Initially apply a service with the given image and env var
    kn service apply random --image rhuss/random:1.0 --env foo=bar

    # Update the service to add a ying=yang env var to the already existing one
    kn service update random --env ying=yang

    # Apply a full new configuration. Note that foo=bar will be removed
    # because it is not specified here.
    kn service apply random --image rhuss/random:1.0 --env ying=yang
    ```

#### `kn service import`

- `kn service import` is the counterpart to `kn service export` and allows you to import a Service and all active revision that has been exported.
_Active revisions_ are revisions that are referenced in a traffic-split.

- This command is still marked experimental, and there are some known issues in the import how the `generation` of revision are created.
Please gives us feedback on how we can improve the support for this feature.

#### Other CLI Features

The following other features have been added, too:

-  An `arm64` flavour has been added to the released artefacts, as well as a `checksum.txt` which caries the sha256sum of all artefacts.
-  A `channel:` prefix has been added for `--sink` parameters, so that channels can be directly addressed by name.
-  Aliases are now appearing correctly in the help messages
- The [Client API](https://github.com/knative/client/blob/b93ca9b34d56621350e43a714a79ba32bd20d7b0/pkg/serving/v1/client.go#L49-L117) as a new list filter `WithLabel()` which can be used when listing services.

### Operator v0.19

The new operator can now deploy the new version `v0.19` of serving and eventing components.

🐞 Bug Fixes
- Add validation to the field spec.version ([#319](https://github.com/knative/operator/pull/319))
- Add support of the major.minor format for spec.version ([#326](https://github.com/knative/operator/pull/326))
- Removing incorrect pre-job for 0.17.0 ([#325](https://github.com/knative/operator/pull/325))

🧹 Clean up
- Update to pkg test/KubeClient changes ([#304](https://github.com/knative/operator/pull/304))
- Lint: previous condition includes return statement, pop else statement ([#305](https://github.com/knative/operator/pull/305))
- Drop istio dependency and replace with unstructured operations ([#311](https://github.com/knative/operator/pull/311))
- Drop dependency on pkg/errors ([#310](https://github.com/knative/operator/pull/310))
- Validate the major.minor as the version matching mechanism for customized manifests ([#320](https://github.com/knative/operator/pull/320))
- Use the hack repository for scripts ([#333](https://github.com/knative/operator/pull/333))
- Use the new update_deps script ([#332](https://github.com/knative/operator/pull/332))

### Thank you contributors v0.19

- [@antoineco](https://github.com/antoineco)
- [@daisy-ycguo](https://github.com/daisy-ycguo)
- [@danielhelfand](https://github.com/danielhelfand)
- [@dprotaso](https://github.com/dprotaso)
- [@dsimansk](https://github.com/dsimansk)
- [@eclipselu](https://github.com/eclipselu)
- [@houshengbo](https://github.com/houshengbo)
- [@ian-mi](https://github.com/ian-mi)
- [@itsmurugappan](https://github.com/itsmurugappan)
- [@joshuawilson](https://github.com/joshuawilson)
- [@julz](https://github.com/julz)
- [@lberk](https://github.com/lberk)
- [@markusthoemmes](https://github.com/markusthoemmes)
- [@mattmoor](https://github.com/mattmoor)
- [@matzew](https://github.com/matzew)
- [@n3wscott](https://github.com/n3wscott)
- [@nak3](https://github.com/nak3)
- [@navidshaikh](https://github.com/navidshaikh)
- [@pierDipi](https://github.com/pierDipi)
- [@rhuss](https://github.com/rhuss)
- [@runzexia](https://github.com/runzexia)
- [@sheetalsingala](https://github.com/sheetalsingala)
- [@slinkydeveloper](https://github.com/slinkydeveloper)
- [@taragu](https://github.com/taragu)
- [@vaikas](https://github.com/vaikas)
- [@whaught](https://github.com/whaught)
- [@yanweiguo](https://github.com/yanweiguo)
- [@zroubalik](https://github.com/zroubalik)





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
