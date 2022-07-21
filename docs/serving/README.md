# Knative Serving

Knative Serving provides components that enable:

- Rapid deployment of serverless containers.
- Autoscaling, including scaling pods down to zero.
- Support for multiple networking layers, such as Contour, Kourier, and Istio, for integration into existing environments.

Knative Serving supports both HTTP and [HTTPS](using-a-tls-cert.md) networking protocols.

## Installation

You can install Knative Serving via the methods listed on the [installation page](../install/README.md).

## Serving resources

Knative Serving defines a set of objects as Kubernetes Custom Resource
Definitions (CRDs). These objects are used to define and control how your
serverless workload behaves on the cluster.

![Diagram that displays how the Serving resources coordinate with each other.](https://github.com/knative/serving/raw/main/docs/spec/images/object_model.png)

For more information on the resources and their interactions, see the [Resource Types Overview](https://github.com/knative/specs/blob/main/specs/serving/overview.md) in the Knative Serving repository.

### Services

[Service](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#service) resources automatically manage the whole lifecycle of a workload. Services control the creation of other objects to ensure that apps have a Route and a Configuration. A new Revision is created for each update to the Configuration for a Service.

### Configurations

[Configuration](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#configuration) resources maintain the desired state for your Knative Service. A Configuration provides a clean separation between code and configuration, and follows the Twelve-Factor App methodology. Modifying a Configuration for a Service creates a new Revision.

### Revisions

--8<-- "about-revisions.md"

### Routes

[Route](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#route) resources map a network endpoint to one or more Revisions of a Service. You can manage the traffic in several ways, including fractional traffic and named routes.
