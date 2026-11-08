---
audience:
  - developer
  - administrator
components:
  - functions
  - serving
  - eventing
---

# Understand Knative

Explore how Knative works, how its parts fit together, and the considerations
behind application and platform choices. These pages provide background, not a
required detour before every task.

## See the whole system

Start with the [Knative technical overview](../README.md#knative-technical-overview)
for the problems Knative addresses and the relationship between Functions,
Serving, Eventing, and Kubernetes. The
[component integration section](../README.md#how-components-work-together)
connects application development, HTTP services, and event routing.

## Understand Serving behavior

- [Serving architecture](../serving/architecture.md): the resources and controllers
  involved in running an application.
- [Request flow](../serving/request-flow.md): the path a request takes through
  networking, the Activator, and application pods.
- [Services](../serving/services/README.md) and
  [Revisions](../serving/revisions/README.md): how application configuration
  relates to immutable versions.
- [How concurrency affects autoscaling](../serving/autoscaling/concurrency-behavior.md):
  soft targets, hard limits, spare capacity, and scale-from-zero trade-offs.
  The [autoscaling overview](../serving/autoscaling/README.md) routes to related tasks
  and settings; [load balancing](../serving/load-balancing/README.md) explains
  request routing and capacity.

Use the linked settings pages when you need exact configuration details; use
[how-to guides](../how-to/README.md#deploy-and-manage-http-services) when you are
ready to change an application.

## Understand event-driven applications

- [Event Mesh](../eventing/concepts/event-mesh.md): how producers and consumers
  participate in event routing.
- [Brokers](../eventing/brokers/README.md) and
  [Channels](../eventing/channels/README.md): the routing abstractions you will
  encounter in Eventing.
- [Sources](../eventing/sources/README.md) and
  [sinks](../eventing/sinks/README.md): where events come from and where they go.
- [Duck typing](../eventing/concepts/duck-typing.md): how shared interfaces allow
  different resource types to work together.

The [Broker implementation catalog](../eventing/brokers/broker-types/README.md)
links to implementation-specific information. Check those pages and the
[delivery support tables](../eventing/reference/event-delivery.md#broker-support) before assuming the same
behavior across transports.

## Understand the Functions development model

[How Knative Functions fits together](../functions/about-functions.md) connects
function projects, container images, deployed Services, templates, and build
choices. Use the [Functions overview](../functions/README.md) to find related tasks
and command reference. The
[CLI tools overview](../client/README.md) explains the roles of `kubectl`, `kn`,
and `func` so you can choose the tool that fits your work.

## Understand platform responsibilities and security

- [Administrator overview](../admin/admin-overview.md): responsibilities,
  cluster-wide configuration, and the application/platform boundary.
- [Choosing an installation method](../install/installation-methods.md):
  YAML/Operator responsibilities, customization, and GitOps trade-offs.
- [Threat model](../reference/security/threat-model.md): security assumptions
  and boundaries.
- [Serving encryption overview](../serving/encryption/encryption-overview.md):
  the communication paths that encryption configuration addresses.

Continue with [a guided learning experience](../learn/README.md),
[a specific task](../how-to/README.md), or
[technical reference](../reference/README.md), according to what you need next.
