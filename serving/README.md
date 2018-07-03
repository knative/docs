
# Knative Serving

Knative Serving builds on Kubernetes and Istio to support deploying and serving
of serverless applications and functions. Serving is easy to get started with
and scales to support advanced scenarios.

The Knative Serving project provides middleware primitives that enable:

* Rapid deployment of serverless containers
* Automatic scale up and down to zero
* Routing and network programming for Istio components
* Point in time snapshots of deployed code and configurations

## Serving resources

Knative Serving defines a set of principals objects as Kubernetes 
Custom Resource Definitions (CRDs). These objects are used to define and control
how your serverless workload behaves on the cluster:

* [Service](https://github.com/knative/serving/blob/master/docs/spec/spec.md#service): 
  The `service.serving.knative.dev` resource manages the whole
  lifecycle of your workload automatically. It manages creating the other
  objects to ensure your app has a route, configuration, and a new revision
  for each update of the service. Service can be defined to always route traffic to the
  latest revision or to a pinned revision.
* [Route](https://github.com/knative/serving/blob/master/docs/spec/spec.md#route):
  The `route.serving.knative.dev` resource maps a network endpoint to a one or
  more revisions. You can manage the traffic in several ways, including fractional
  traffic or named routes.
* [Configuration](https://github.com/knative/serving/blob/master/docs/spec/spec.md#configuration): 
  The `configuration.serving.knative.dev` resource maintains
  the desired state for your deployment. It provides a clean separation between
  code and configuration, following the 12 factor app methodology. Modifying a configuration
  will create a new revision.
* [Revision](https://github.com/knative/serving/blob/master/docs/spec/spec.md#revision):
  The `revision.serving.knative.dev` resource is a point in time snapshot
  of the code and configuration for each modification made to the workload. Revisions
  are immutable objects and can be retained for as long as useful.

![Diagram displaying the way the Serving resources coordinate with each other.](https://github.com/knative/serving/raw/master/docs/spec/images/object_model.png)

## Getting Started

To get started with Serving, check out one of the [hello world](samples/) sample projects.
These projects use the `Service` resource, which manage all the details for you.

With the `Service` resource, a deployed service will automatically have a matching route
and configuration created. Each time the `Service` is updated, a new revision will be
created.

For more information on the resources and their interactions, see the
[Resource Types Overview](https://github.com/knative/serving/blob/master/docs/spec/overview.md)
in the Knative Serving repo.

## Known Issues

See the [Knative Serving Issues](https://github.com/knative/serving/issues) for a full list of
known issues.

* **No support for TLS** - Currently the Knative Serving components do not support TLS connections for
  inbound HTTPS traffic. See [#537](https://github.com/knative/serving/issues/537) for more details.

## Observability

* [Installing Logging, Metrics and Traces](./installing-logging-metrics-traces.md)
* [Accessing Logs](./accessing-logs.md)
* [Accessing Metrics](./accessing-metrics.md)
* [Accessing Traces](./accessing-traces.md)
* [Debugging Application Issues](./debugging-application-issues.md)
* [Debugging Performance Issues](./debugging-performance-issues.md)

## Networking

* [Setting up DNS](./DNS.md)