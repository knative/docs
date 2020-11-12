---
title: "Version v0.19 release"
linkTitle: "Version v0.19 release"
Author: "[Carlos Santana](https://twitter.com/csantanapr)"
Author handle: https://github.com/csantanapr
date: 2020-11-13
description: "Knative v0.19 release announcement"
type: "blog"
image: knative-eventing.png
---


## Announcing Knative v0.19 Release

A new version of Knative is now available across multiple components.
Follow the instructions in the documentation [Installing Knative](https://knative.dev/docs/install/) for the respective component.

Highlights:
- The monitoring bundle has been removed and the git repository archived.
- Improvements for cold start by adding a scale down delay.
- No longer mounting `/var/log` this allows certain images like `docker.io/nginx` that use this directory to be use as Knative Service.
- New Alpha feature that allows for domain name mapping at namespace scope.
- You specify delivery spec defaults for brokers in Eventing configmap `config-br-defaults`
- Eventing keeps improving stability by squashing bugs.

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

TODO

### Operator v0.19

TODO

### Thanks

Thanks to these contributors who contributed to v0.19!

- [@antoineco](https://github.com/antoineco)
- [@dprotaso](https://github.com/dprotaso)
- [@eclipselu](https://github.com/eclipselu)
- [@ian-mi](https://github.com/ian-mi)
- [@joshuawilson](https://github.com/joshuawilson)
- [@julz](https://github.com/julz)
- [@markusthoemmes](https://github.com/markusthoemmes)
- [@mattmoor](https://github.com/mattmoor)
- [@nak3](https://github.com/nak3)
- [@pierDipi](https://github.com/pierDipi)
- [@runzexia](https://github.com/runzexia)
- [@sheetalsingala](https://github.com/sheetalsingala)
- [@slinkydeveloper](https://github.com/slinkydeveloper)
- [@taragu](https://github.com/taragu)
- [@vaikas](https://github.com/vaikas)
- [@whaught](https://github.com/whaught)
- [@yanweiguo](https://github.com/yanweiguo)





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
