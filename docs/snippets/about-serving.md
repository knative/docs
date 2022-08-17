<!-- Snippet used in the following topics:
- /docs/serving/README.md
- /docs/concepts/README.md
-->
Knative Serving defines a set of objects as Kubernetes Custom Resource
Definitions (CRDs). These resources are used to define and control how your
serverless workload behaves on the cluster.

![Diagram that displays how the Serving resources coordinate with each other.](https://github.com/knative/serving/raw/main/docs/spec/images/object_model.png)

The primary Knative Serving resources are Services, Routes, Configurations, and Revisions:

- [Services](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#service){target=_blank}:
  The `service.serving.knative.dev` resource automatically manages the whole
  lifecycle of your workload. It controls the creation of other objects to
  ensure that your app has a route, a configuration, and a new revision for each
  update of the service. Service can be defined to always route traffic to the
  latest revision or to a pinned revision.

- [Routes](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#route){target=_blank}:
  The `route.serving.knative.dev` resource maps a network endpoint to one or
  more revisions. You can manage the traffic in several ways, including
  fractional traffic and named routes.

- [Configurations](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#configuration){target=_blank}:
  The `configuration.serving.knative.dev` resource maintains the desired state
  for your deployment. It provides a clean separation between code and
  configuration and follows the Twelve-Factor App methodology. Modifying a
  configuration creates a new revision.

- [Revisions](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#revision){target=_blank}:
  The `revision.serving.knative.dev` resource is a point-in-time snapshot of the
  code and configuration for each modification made to the workload. Revisions
  are immutable objects and can be retained for as long as useful. Knative
  Serving Revisions can be automatically scaled up and down according to
  incoming traffic.

For more information on the resources and their interactions, see the [Resource Types Overview](https://github.com/knative/specs/blob/main/specs/serving/overview.md){target=_blank} in the `serving` Github repository.
