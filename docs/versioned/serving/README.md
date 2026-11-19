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

Follow [Get started with Serving](../getting-started/first-service.md) to deploy
and call a service, observe scale-to-zero, and split traffic between revisions.
This is the same Serving track linked from Get Started, not a separate tutorial.
It links to the shared learning-cluster setup if you need an environment.

With the `Service` resource, a deployed service will automatically have a
matching route and configuration created. Each time the `Service` is updated, a
new revision is created.

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
