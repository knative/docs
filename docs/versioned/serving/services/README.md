---
audience: developer
components:
  - serving
function: explanation
---

# Knative Services

Knative Services deploy an application from a container image. You can create or
update one using YAML with `kubectl` or the `kn` CLI. Both approaches configure
the same Service resource, including its metadata, image, and application settings.
See [Creating a Service](creating-services.md) for the task guide.

Each Service is defined by a Route and a Configuration that have the same name as the service. The Configuration and Route are created by the service controller, and derive their configuration from the configuration of the Service.

Each time the configuration is updated, a new Revision is created. Revisions are immutable snapshots of a particular configuration, and use underlying Kubernetes resources to scale the number of pods based on traffic.

## Modifying Knative services

The **Service controller** reconciles changes to the Service into the Route and
Configuration it owns, including propagated labels and annotations. It also sets
`serving.knative.dev/service` to identify their owning Service. These are controller
responsibilities, not extra manual steps: configure the Service rather than copying
its changes into the generated Route and Configuration yourself.

The Service updates its `status` fields based on the corresponding `status` value for the owned Route and Configuration.
The Service must include conditions of `RoutesReady` and `ConfigurationsReady` in addition to the generic `Ready` condition. Other conditions can also be present.

## Additional resources

* For more information about the Knative Service object, see the [Resource Types](https://github.com/knative/specs/blob/main/specs/serving/overview.md) documentation.
