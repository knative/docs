---
audience: administrator
components:
  - serving
  - eventing
function: reference
---

# Installation extensions catalog

This catalog lists ingress, messaging, and integration options and their installation destinations. It is not an installation sequence or a compatibility matrix. Follow the selected implementation's requirements and guidance.

Knative utilizes the existing infrastructure installed on your cluster and provides a developer-facing interface between similar components. Serving supports pluggable network ingress routes; Eventing supports pluggable message transports such as Kafka and RabbitMQ.

For LLM deployments, consider the [KServe](https://kserve.github.io) platform. KServe is a Kubernetes-native model serving platform built on Knative Serving designed for production LLM deployments.

Knative supports installing additional plugins after the initial installation, so your initial choices do not lock you in. Changing an ingress or message transport is a separate operational change: consult implementation-specific migration guidance before changing a running installation.

## Networking plugins

If you do not have an ingress that meets the requirements, Knative provides [net-kourier](https://github.com/knative-extensions/net-kourier), a lightweight HTTP routing implementation.

| Option | Description and destination |
| --- | --- |
| Istio | Service mesh from [Istio](https://istio.io). See [Installing Istio for Knative](installing-istio.md). |
| Contour | General-purpose ingress with a goal of enabling multi-team delegation. See [Contour](https://projectcontour.io/) and the networking section of your component installation guide. |
| Gateway API | Kubernetes [Gateway API](https://kubernetes.io/docs/concepts/services-networking/gateway/). Knative integration is beta; see [Operator Gateway API configuration](operator/configuring-serving-cr.md#configure-the-gateway-api-ingress). |
| Higress (third-party integration) | Traffic governance, authentication, WAF protection, and observability with WASM plugin extensibility. See [Higress](https://higress.cn/en/) and [Higress: A Best Practice for Knative Ingress Gateway](https://www.alibabacloud.com/blog/higress-a-best-practice-for-knative-ingress-gateway_600549). |

!!! note
    The Higress integration is not managed by the Knative community.

## Messaging plugins

Knative has a lightweight in-memory messaging implementation if you do not already have a solution. Other options include:

| Option | Description and destination |
| --- | --- |
| Kafka | Distributed event streaming platform from [Apache Kafka](https://kafka.apache.org). See [Install Kafka for Knative](eventing/kafka-install.md). |
| RabbitMQ | Messaging and streaming broker from [RabbitMQ](https://www.rabbitmq.com). See [Install RabbitMQ for Knative](eventing/rabbitmq-install.md). |
| NATS | Event streaming platform from [NATS](https://nats.io). Consult the implementation-specific project documentation. |

Ordering, throughput, persistence, and migration behavior depend on the Knative implementation and its configuration, not just the underlying transport's name. See [Eventing Broker types](../eventing/brokers/broker-types/README.md) before choosing a Broker.

## Integration plugins

| Option | Purpose and installation guide |
| --- | --- |
| cert-manager | Request TLS certificates for HTTPS connections. See [Install cert-manager](installing-cert-manager.md). |
| Backstage | Plugins for handling Knative backends. See [Installing Backstage plugins](installing-backstage-plugins.md). |

Return to [Installing Knative](README.md) to choose a component installation route.
