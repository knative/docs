
# Knative Serving

Knative Serving builds on Kubernetes and Istio to support deploying and serving
of serverless applications and functions. Serving is easy to get started with
and scales to support advanced scenarios.

The Knative Serving project provides middleware primitives that enable:

* Rapid deployment of serverless containers
* Automatic scaling up and down to zero
* Routing and network programming for Istio components
* Point-in-time snapshots of deployed code and configurations

## Serving resources

Knative Serving defines a set of objects as Kubernetes
Custom Resource Definitions (CRDs). These objects are used to define and control
how your serverless workload behaves on the cluster:

* [Service](https://github.com/knative/serving/blob/master/docs/spec/spec.md#service):
  The `service.serving.knative.dev` resource automatically manages the whole
  lifecycle of your workload. It controls the creation of other
  objects to ensure that your app has a route, a configuration, and a new revision
  for each update of the service. Service can be defined to always route traffic to the
  latest revision or to a pinned revision.
* [Route](https://github.com/knative/serving/blob/master/docs/spec/spec.md#route):
  The `route.serving.knative.dev` resource maps a network endpoint to a one or
  more revisions. You can manage the traffic in several ways, including fractional
  traffic and named routes.
* [Configuration](https://github.com/knative/serving/blob/master/docs/spec/spec.md#configuration):
  The `configuration.serving.knative.dev` resource maintains
  the desired state for your deployment. It provides a clean separation between
  code and configuration and follows the Twelve-Factor App methodology. Modifying a configuration
  creates a new revision.
* [Revision](https://github.com/knative/serving/blob/master/docs/spec/spec.md#revision):
  The `revision.serving.knative.dev` resource is a point-in-time snapshot
  of the code and configuration for each modification made to the workload. Revisions
  are immutable objects and can be retained for as long as useful.

![Diagram that displays how the Serving resources coordinate with each other.](https://github.com/knative/serving/raw/master/docs/spec/images/object_model.png)

## Getting Started

To get started with Serving, check out one of the [hello world](samples/) sample projects.
These projects use the `Service` resource, which manages all of the details for you.

With the `Service` resource, a deployed service will automatically have a matching route
and configuration created. Each time the `Service` is updated, a new revision is
created.

For more information on the resources and their interactions, see the
[Resource Types Overview](https://github.com/knative/serving/blob/master/docs/spec/overview.md)
in the Knative Serving repository.

## More samples and demos

* [Autoscaling with Knative Serving](./samples/autoscale-go/README.md)
* [Source-to-URL with Knative Serving](./samples/source-to-url-go/README.md)
* [Telemetry with Knative Serving](./samples/telemetry-go/README.md)
* [REST API sample](./samples/rest-api-go/README.md)

## Setting up Logging and Metrics 

* [Installing Logging, Metrics and Traces](./installing-logging-metrics-traces.md)
* [Accessing Logs](./accessing-logs.md)
* [Accessing Metrics](./accessing-metrics.md)
* [Accessing Traces](./accessing-traces.md)
* [Setting up a logging plugin](./setting-up-a-logging-plugin.md)

## Debugging Knative Serving issues 

* [Debugging Application Issues](./debugging-application-issues.md)
* [Debugging Performance Issues](./debugging-performance-issues.md)

## Configuration and Networking

* [Configuring outbound network access](./outbound-network-access.md)
* [Using a custom domain](./using-a-custom-domain.md)
* [Assigning a static IP address for Knative on Google Kubernetes Engine](./gke-assigning-static-ip-address.md)

## Known Issues

See the [Knative Serving Issues](https://github.com/knative/serving/issues) page for a full list of
known issues.

* **No support for TLS** - Currently the Knative Serving components do not support TLS connections for
  inbound HTTPS traffic. See [#537](https://github.com/knative/serving/issues/537) for more details.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
