---
audience: developer
components:
  - functions
function: explanation
---

# Kafka functions

A function can consume messages from an Apache Kafka topic. When a function declares a `run.kafka` configuration, `func` deploys a language-agnostic runtime sidecar alongside it. The sidecar consumes the topic and delivers each record to the function as a CloudEvent over HTTP, so the function stays a plain CloudEvents handler in any language, with no Kafka client code of its own.

The full guide lives in the `func` repository, covering concepts, a getting-started walkthrough, delivery and retries, deployment and scaling, idempotency, local development, and troubleshooting:

- [Kafka functions guide](https://github.com/knative/func/blob/main/docs/kafka-functions/README.md){target=_blank}
- [`run.kafka` configuration reference](https://github.com/knative/func/blob/main/docs/reference/func_yaml.md#runkafka){target=_blank}