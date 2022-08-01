# Knative Serving

--8<-- "about-serving.md"

## Common use cases

Examples of supported Knative Serving use cases:

- Rapid deployment of serverless containers.
- Autoscaling, including scaling pods down to zero.
- Support for multiple networking layers, such as Contour, Kourier, and Istio, for integration into existing environments.

Knative Serving supports both HTTP and [HTTPS](using-a-tls-cert.md) networking protocols.

## Installation

You can install Knative Serving via the methods listed on the [installation page](../install/README.md).

## Getting Started

To get started with Serving, check out one of the [hello world](../samples/serving.md)
sample projects. These projects use the `Service` resource, which manages all of
the details for you.

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
