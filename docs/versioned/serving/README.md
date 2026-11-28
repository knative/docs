---
audience: developer
components:
  - serving
function: explanation
hide_prev: true
hide_next: true
---

# Knative Serving

--8<-- "about-serving.md"

## Start here

New to Knative Serving? Follow [Try Serving](../getting-started/first-service.md)
to deploy a container, watch it scale to zero, and split traffic between
Revisions on a local cluster.

## Choose a task

- **Deploy and configure:** [create a Service](services/creating-services.md),
  [convert a Kubernetes Deployment](convert-deployment-to-knative-service.md),
  [deploy from a private registry](deploying-from-private-registry.md), or
  configure [resource limits](services/configure-requests-limits-services.md),
  [health probes](services/configure-probing.md), and [volumes](services/storage.md).
- **Networking:** configure [private Services](services/private-services.md),
  [custom domains](services/custom-domains.md),
  [custom TLS certificates](services/custom-tls-certificate-domain-mapping.md),
  or [HTTP protocols](services/http-protocol.md).
- **Revisions and traffic:** manage [Revisions](revisions/README.md),
  [split traffic and assign tags](traffic-management.md), or configure
  [gradual rollouts](rolling-out-latest-revision.md).
- **Autoscaling:** tune [autoscaling](autoscaling/README.md) defaults,
  [concurrency](autoscaling/concurrency.md), [scale bounds](autoscaling/scale-bounds.md),
  [scale to zero](autoscaling/scale-to-zero.md), and [request buffering](load-balancing/README.md).
- **Observe and troubleshoot:** [collect metrics](observability/metrics/collecting-metrics.md),
  browse the [metrics reference](observability/metrics/serving-metrics.md), or
  [troubleshoot application issues](troubleshooting/debugging-application-issues.md).

## Architecture and reference

- [Architecture](architecture.md) and [Request flow](request-flow.md)
- [Serving API reference](reference/serving-api.md)
- [Serving code samples](../samples/serving.md)
- [Install Knative Serving](../install/README.md)
