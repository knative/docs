---
title: "v1.1 release"
linkTitle: "v1.1 release"
Author: "[Carlos Santana](https://twitter.com/csantanapr)"
Author handle: https://github.com/csantanapr
date: 2021-12-14
description: "Knative v1.1 release announcement"
type: "blog"
---


### Announcing Knative v1.1 Release

A new version of Knative is now available across multiple components.

Follow the instructions in the documentation
[Installing Knative](https://knative.dev/docs/install/) for the respective component.

#### Table of Contents
- [Highlights](#highlights)
- [Serving v1.1](#serving-v11)
- [Eventing v1.1](#eventing-v11)
- [Eventing Extensions](#eventing-extensions)
    - [Apache Kafka Broker v1.1](#apache-kafka-broker-v11)
    - [RabbitMQ Broker and Source v1.1](#rabbitmq-broker-and-source-v11)
- `kn` [CLI v1.1](#client-v11)
- [Knative Operator v1.1](#operator-v11)
- [Thank you contributors](#thank-you-contributors)


### Highlights

- Serving now has a global `min-scale` configuration
- Eventing has more experimental features


### Serving v1.1

<!-- Original notes are here: https://github.com/knative/serving/releases/tag/knative-v1.1.0 -->

#### 💫 New Features & Changes

- Add cluster wide default min-scale ([#12290](https://github.com/knative/serving/pull/12290))
- HPA autoscaler stabilization window can be set from autoscaling window annotation ([#12286](https://github.com/knative/serving/pull/12286))
- Metrics with names other than "cpu" or "memory" are allowed as pod custom metrics ([#12277](https://github.com/knative/serving/pull/12277))

#### 🐞 Bug Fixes

- Allow setting TCP and HTTP port to be equal to containerPort on readiness and liveness probes ([#12225](https://github.com/knative/serving/pull/12225))
- Drops the unix socket listener from Queue Proxy, since it is no longer used ([#12298](https://github.com/knative/serving/pull/12298))
- Generated HPAs are now v2beta2. Window annotation will be set to HPA stabilization window ([#12278](https://github.com/knative/serving/pull/12278))
- Remove performance tests using Mako ([#12266](https://github.com/knative/serving/pull/12266))
- The activator optimization which directly probes the queue proxy for readiness rather than waiting for Kubernetes to report readiness is now disabled when exec probes are used (since queue proxy cannot execute these probes on the user container's behalf) ([#12250](https://github.com/knative/serving/pull/12250))
- Use pkg/drain in queue proxy ([#12033](https://github.com/knative/serving/pull/12033))

### Eventing v1.1

<!-- Original notes are here: https://github.com/knative/eventing/releases/tag/knative-v1.1.0 -->

#### 💫 New Features & Changes

- New experimental-feature "delivery-retryafter" flag allows use of "DeliverySpec.retryAfter" to configure handling of Retry-After headers in 429 / 503 responses. See [experimental-features](https://knative.dev/development/eventing/experimental-features/delivery-retryafter.md). ([#5813](https://github.com/knative/eventing/pull/5813))
- All core Knative Eventing Pods should now be able to run in the restricted pod security standard profile ([#5863](https://github.com/knative/eventing/pull/5863))
- Triggers now include a CloudEvents Subscriptions API compatible filters field as an experimental feature ([#5715](https://github.com/knative/eventing/pull/5715))

#### 🐞 Bug Fixes

- The Sequence type accepts any Channel spec field in the `spec.channelTemplate.spec` field ([#5955](https://github.com/knative/eventing/pull/5955))
- Upgrade dependencies that contains vulnerabilities in Snyk DB ([#5889](https://github.com/knative/eventing/pull/5889))

### Eventing Extensions

#### Apache Kafka Broker v1.1

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-kafka-broker/releases/tag/knative-v1.1.0 -->

#### 🚨 Breaking or Notable Changes

- Add a new implementation of the KafkaSource API ([#1415](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1415))
- Kafka Broker event delivery is hundreds of times faster ([#1405](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1405))
- `broker.spec.config` is now required ([#1555](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1555))

#### 💫 New Features & Changes

- The kafka-controller deployment emits probe requests against the data plane (kafka-sink-receiver and kafka-broker-receiver) to determine Kafka Broker and KafkaSink readiness ([#1495](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1495))
- You can now configure which header format (b3 multi header, b3 single header, and w3c trace-context) to be used while using Zipkin backend ([#1546](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1546))
- Handle non-retryable HTTP status codes as reported in the spec.
For more information, see the [Eventing spec](https://github.com/knative/specs/blob/c348f501de9eb998b4fd010c54d9127033ee41be/specs/eventing/data-plane.md#event-acknowledgement-and-delivery-retry) in GitHub ([#1574](https://github.com/knative-sandbox/eventing-kafka-broker/pull/1574))


#### RabbitMQ Broker and Source v1.1

<!-- Original notes are here: https://github.com/knative-sandbox/eventing-rabbitmq/releases/tag/knative-v1.1.0 -->


#### 💫 New Features & Changes

- Adds tracing with opencensus to the dispatcher and ingress ([#370](https://github.com/knative-sandbox/eventing-rabbitmq/pull/370))
- RabbitMQ source now can use predefined queues instead of creating new ones ([#493](https://github.com/knative-sandbox/eventing-rabbitmq/pull/493))
- Now the source Adapter processes messages concurrently depending on the `channel_config.prefetch_count` argument (default to 1) ([#522](https://github.com/knative-sandbox/eventing-rabbitmq/pull/522))
- Do not expose the broker class that the controller operates on as an environment variable ([#512](https://github.com/knative-sandbox/eventing-rabbitmq/pull/512))
- The RabbitMQ Source now translates RabbitMQ messages according to the RabbitMQ Protocol Binding Spec for CloudEvents ([#475](https://github.com/knative-sandbox/eventing-rabbitmq/pull/475))
    - Falls back to RabbitMQ message content type if it is not set on the CloudEvent data or headers
    - Avoids re-wrapping RabbitMQ messages that are already in the CloudEvent format

#### 🐞 Bug Fixes

- The trigger dispatcher will now only retry deliveries when response status codes status are 5XX, 404, 409, 429, or -1 ([#486](https://github.com/knative-sandbox/eventing-rabbitmq/pull/486))

### Client v1.1

<!-- Original notes are here: https://github.com/knative/client/blob/main/CHANGELOG.adoc#v110-2021-12-14 -->

#### 💫 New Features & Changes

- Add `--tag` to `service create` and allow traffic split <100 when `@latest` is specified ([#1514](https://github.com/knative/client/pull/1514))

#### 🐞 Bug Fixes

- Fixed panic in `kn service update` ([#1533](https://github.com/knative/client/pull/1533))
- Fixed panic in `kn service describe` ([#1529](https://github.com/knative/client/pull/1529))
- Fix env, annotation and labels flags in service create/update/apply ([#1516](https://github.com/knative/client/pull/1516))

### Operator v1.1

<!-- Original notes are here: https://github.com/knative/operator/releases/tag/knative-v1.1.0   -->

#### 💫 New Features & Changes

- Refactor image transformer to de-duplicate and simplify it ([#863](https://github.com/knative/operator/pull/863))

### Thank you, contributors

Release leads: [@matzew](https://github.com/matzew) and [@nak3](https://github.com/nak3)

- [@benmoss](https://github.com/benmoss)
- [@boaz0](https://github.com/boaz0)
- [@devguyio](https://github.com/devguyio)
- [@enoodle](https://github.com/enoodle)
- [@evankanderson](https://github.com/evankanderson)
- [@gabo1208](https://github.com/gabo1208)
- [@ikvmw](https://github.com/ikvmw)
- [@nader-ziada](https://github.com/nader-ziada)
- [@nak3](https://github.com/nak3)
- [@pierDipi](https://github.com/pierDipi)
- [@rikatz](https://github.com/rikatz)
- [@snowwolf007cn](https://github.com/snowwolf007cn)
- [@steven0711dong](https://github.com/steven0711dong)
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
