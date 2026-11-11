---
audience: developer
components:
  - serving
function: explanation
---

# Knative Serving

--8<-- "about-serving.md"

## Common use cases

Examples of supported Knative Serving use cases:

- Rapid deployment of serverless containers.
- Autoscaling, including scaling pods down to zero.
- Support for multiple networking layers, such as Contour, Kourier, and Istio, for integration into existing environments.

Knative Serving supports both HTTP and [HTTPS](encryption/encryption-overview.md) networking protocols.

## Installation

You can install Knative Serving via the methods listed on the [installation page](../install/README.md).

## Getting Started

For a guided first deployment, follow the [Knative Quickstart](../getting-started/README.md), then [deploy your first Service](../getting-started/first-service.md) and [observe autoscaling](../getting-started/first-autoscale.md). For language-specific examples after the basics, choose a [hello world sample](../samples/serving.md).

With the `Service` resource, a deployed service will automatically have a
matching route and configuration created. Each time the `Service` is updated, a
new revision is created.

## Choose your next goal

- **Accomplish a task:** [Set and verify a concurrency target](autoscaling/configure-concurrency.md) or [manage traffic between Revisions](traffic-management.md).
- **Understand behavior:** Read the [Serving architecture](architecture.md), [request flow](request-flow.md), or [concurrency and autoscaling explanation](autoscaling/concurrency-behavior.md).
- **Look up details:** Consult the [concurrency settings](autoscaling/concurrency.md), [scale bounds](autoscaling/scale-bounds.md), or [Serving API reference](reference/serving-api.md).
- **Explore autoscaling:** Use the [autoscaling landing page](autoscaling/README.md) to choose a tutorial, task, explanation, or settings reference.

## More samples and demos

- [Knative Serving code samples](../samples/serving.md)

## Debugging Knative Serving issues

- [Debugging application issues](troubleshooting/debugging-application-issues.md)

## Configuration and Networking

- [Configuring cluster local routes](services/private-services.md)
- [Using a custom domain](using-a-custom-domain.md)
- [Traffic management](traffic-management.md)

## Observability

- [Serving Metrics API](observability/metrics/serving-metrics.md)

## Known Issues

See the [Knative Serving Issues](https://github.com/knative/serving/issues) page
for a full list of known issues.
