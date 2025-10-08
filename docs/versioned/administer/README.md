---
audience: administrator
components:
  - eventing
  - serving
function: concept
---

# Administration Overview

The Knative [Serving](../serving/) and [Eventing](../ eventing/) components extend Kubernetes clusters to provide consistent serverless compute and event-delivery interfaces for developers.  (Knative [Functions](../functions/) provides primarily client-side tools for more easily building containers.)  This means that Serving and Eventing need to be installed on a Kubernetes cluster, and they extend the Kubernetes API using [Custom Resources Definitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/).

Knative aims to integrate with Kubernetes, so existing tools for managing Kubernetes such as RBAC, quota, admission control, and monitoring should "just work".  By using a plug-in model for underlying HTTP and event routing functionality, Knative aims to integrate with existing battle-tested software you may already have installed on your cluster, such as Istio, Contour, Kafka, NATS or RabbitMQ.  Knative also provides lightweight implementations for these functions if you are looking to avoid pulling in large, complex systems.