# About Knative Services

Knative Services are used to deploy an application. To create an application using Knative, you must create a YAML file that defines a Service. This YAML file specifies metadata about the application, points to the hosted image of the app, and allows the Service to be configured.

Each Service is defined by a Route and a Configuration that have the same name as the service. The Configuration and Route are created by the service controller, and derive their configuration from the configuration of the Service.

Each time the configuration is updated, a new Revision is created. Revisions are immutable snapshots of a particular configuration, and use underlying Kubernetes resources to scale the number of pods based on traffic.

## Modifying Knative services

Any changes to specifications, metadata labels, or metadata annotations for a Service must be copied to the Route and Configuration owned by that Service. The `serving.knative.dev/service` label on the Route and Configuration must also be set to the name of the Service. Any additional labels or annotations on the Route and Configuration not specified earlier must be removed.

The Service updates its `status` fields based on the corresponding `status` value for the owned Route and Configuration.
The Service must include conditions of `RoutesReady` and `ConfigurationsReady` in addition to the generic `Ready` condition. Other conditions can also be present.

## Additional resources

* For more information about the Knative Service object, see the [Resource Types](https://github.com/knative/specs/blob/main/specs/serving/overview.md) documentation.
