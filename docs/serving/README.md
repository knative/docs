# Knative Serving

Knative Serving provides components that enable:

- Rapid deployment of serverless containers.
- Autoscaling, including scaling pods down to zero.
- Support for multiple networking layers, such as Ambassador, Contour, Kourier, Gloo, and Istio, for integration into existing environments.
- Point-in-time snapshots of deployed code and configurations.

Knative Serving supports both HTTP and [HTTPS](using-a-tls-cert.md) networking protocols.

## Serving resources

Knative Serving defines a set of objects as Kubernetes Custom Resource
Definitions (CRDs). These objects are used to define and control how your
serverless workload behaves on the cluster:

- [Service](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#service):
  The `service.serving.knative.dev` resource automatically manages the whole
  lifecycle of your workload. It controls the creation of other objects to
  ensure that your app has a route, a configuration, and a new revision for each
  update of the service. Service can be defined to always route traffic to the
  latest revision or to a pinned revision.
- [Route](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#route):
  The `route.serving.knative.dev` resource maps a network endpoint to one or
  more revisions. You can manage the traffic in several ways, including
  fractional traffic and named routes.
- [Configuration](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#configuration):
  The `configuration.serving.knative.dev` resource maintains the desired state
  for your deployment. It provides a clean separation between code and
  configuration and follows the Twelve-Factor App methodology. Modifying a
  configuration creates a new revision.
- [Revision](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#revision):
  The `revision.serving.knative.dev` resource is a point-in-time snapshot of the
  code and configuration for each modification made to the workload. Revisions
  are immutable objects and can be retained for as long as useful. Knative
  Serving Revisions can be automatically scaled up and down according to
  incoming traffic. See
  [Configuring the Autoscaler](autoscaling/README.md) for more
  information.

![Diagram that displays how the Serving resources coordinate with each other.](https://github.com/knative/serving/raw/main/docs/spec/images/object_model.png)

## Getting Started

To get started with Serving, check out one of the [hello world](samples/README.md)
sample projects. These projects use the `Service` resource, which manages all of
the details for you.

With the `Service` resource, a deployed service will automatically have a
matching route and configuration created. Each time the `Service` is updated, a
new revision is created.

For more information on the resources and their interactions, see the [Resource Types Overview](https://github.com/knative/specs/blob/main/specs/serving/overview.md) in the Knative Serving repository.

## More samples and demos

- [Knative Serving code samples](samples/README.md)

## Debugging Knative Serving issues

- [Debugging application issues](../serving/troubleshooting/debugging-application-issues.md)

## Configuration and Networking

- [Configuring cluster local routes](../serving/services/private-services.md)
- [Using a custom domain](using-a-custom-domain.md)
- [Traffic management](../serving/traffic-management.md)

## Observability

- [Serving Metrics API](observability/metrics/serving-metrics.md)

## Known Issues

See the [Knative Serving Issues](https://github.com/knative/serving/issues) page
for a full list of known issues.
