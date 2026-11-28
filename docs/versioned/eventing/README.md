---
audience: developer
components:
  - eventing
function: explanation
hide_prev: true
hide_next: true
---

# Knative Eventing

--8<-- "about-eventing.md"

New to Eventing? Start with [Try Eventing](../getting-started/getting-started-eventing.md) to send a CloudEvent through a Broker and deliver it with a Trigger, or follow the [Bookstore tutorial](../bookstore/page-0/welcome-knative-bookstore-tutorial.md) for a multi-service app.

## What do you want to do?

- **Route events with Brokers and Triggers** — [Create a Broker](brokers/create-broker.md), compare [Broker types](brokers/broker-types/README.md), filter events with [Triggers](triggers/README.md), and configure retries and dead-letter sinks in [Delivery failures](event-delivery.md).
- **Connect event producers** — Choose a built-in producer in [Event sources](sources/README.md) (Kubernetes API, schedules, Kafka, RabbitMQ, Redis Streams, or Camel integrations), or bind an existing workload with [SinkBinding](custom-event-source/sinkbinding/README.md).
- **Deliver to destinations** — Send events to Knative Services, Kubernetes Services, [JobSink](sinks/job-sink.md), [Kafka](sinks/kafka-sink.md), or [IntegrationSink](sinks/integration-sink/README.md) in [Event sinks](sinks/README.md).
- **Compose pipelines and transformations** — Chain steps with [Sequences](flows/sequence/README.md), fan out with [Parallel](flows/parallel.md), reshape payloads with [Event transformations](transforms/README.md), or use [Channels and Subscriptions](channels/README.md) directly.
- **Observe and debug** — Collect metrics in [Observability](observability/metrics/collecting-metrics.md) or trace lost events in [Troubleshooting](troubleshooting/README.md).
- **Install or administer Eventing** — See [Install and Manage](../install/README.md) for installation, Broker class defaults, and cluster-wide settings.
