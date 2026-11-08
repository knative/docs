---
audience:
  - developer
  - administrator
components:
  - functions
  - serving
  - eventing
---

# Accomplish a task

Find directions for a concrete goal in your application or cluster. These guides
assume you know what you want to do; check each guide's prerequisites, permissions,
and required components. If you are trying Knative for the first time, choose a
[guided learning route](../learn/README.md) instead.

## Develop and deploy functions

- [Create a function project](../functions/creating-functions.md).
- [Build a function](../functions/building-functions.md) and
  [run it locally](../functions/running-functions.md).
- [Deploy a function](../functions/deploying-functions.md) and
  [invoke it](../functions/invoking-functions.md). For an existing published
  function image, use the [no-build/no-push deployment route](../functions/deploying-functions.md#use-an-image-that-is-already-published).
- If you need Broker events, [subscribe a function to events](../functions/subscribing-functions.md).
  Event subscription is optional, not a prerequisite for local execution or an
  HTTP-only deployment.

Start with local project creation and execution; build separately when that is
your goal. Deployment and event subscription are separate tasks with cluster,
registry, and component prerequisites described in their guides.

For tooling setup, see [installing `func`](../functions/install-func.md) and
[installing `kn`](../client/install-kn.md). For cluster-facing Functions commands,
use the [effective kubeconfig/current-context guard](../functions/deploying-functions.md#select-and-check-the-cluster).
A context selected only through a `kubectl` or `kn` flag does not select the
cluster for a later `func` command.

## Deploy and manage HTTP services

- Have a container image? [Deploy an HTTP container as a Knative Service](../serving/services/creating-services.md).
- [Manage traffic between revisions](../serving/traffic-management.md).
- [Set and verify a concurrency target](../serving/autoscaling/configure-concurrency.md).
- [Configure a custom domain for a Service](../serving/services/custom-domains.md).

Adapting an existing Kubernetes Deployment? Consult the
[Deployment-to-Service mapping reference](../serving/convert-deployment-to-knative-service.md)
for manifest correspondence and workload-fit constraints. It is not a migration
or cutover procedure; creating a separate Service does not redirect existing clients.

For related scaling guides and settings, use the
[autoscaling topic overview](../serving/autoscaling/README.md), including
[scale bounds](../serving/autoscaling/scale-bounds.md).

## Route and process events

- [Create a Broker](../eventing/brokers/create-broker.md).
- [Use a Trigger to subscribe to Broker events](../eventing/triggers/README.md).
- [Create a PingSource](../eventing/sources/ping-source/README.md).
- [Bind an event producer to a sink](../eventing/custom-event-source/sinkbinding/create-a-sinkbinding.md).
- [Configure Broker retries and a dead-letter sink](../eventing/event-delivery.md),
  with an isolated failure test and receipt verification.

Source and Broker implementations have their own requirements. Use the
[Eventing overview](../eventing/README.md) to locate related resource guides.

## Operate a Knative cluster

Cluster-level changes generally require administrator permissions. Application
configuration and cluster defaults are different scopes; follow the guide for
the scope you intend to change.

| Goal | Starting point |
| --- | --- |
| Install | [Choose an installation path](../install/README.md) for an existing cluster. |
| Configure | [Work with ConfigMaps](../admin/editing-configmaps.md) or use the [generic Operator-managed ConfigMap workflow](../install/operator/configuring-with-operator.md#managed-configmap-workflow), according to how your installation is managed. For other Operator changes, choose a [Serving configuration goal](../install/operator/configuring-serving-cr.md) or [Eventing configuration goal](../install/operator/configuring-eventing-cr.md). |
| Secure | [Choose a security configuration or artifact-verification task](#secure-a-knative-installation). For security boundaries, read the [threat model](../reference/security/threat-model.md). |
| Observe | Collect [Serving metrics](../serving/observability/metrics/collecting-metrics.md) or [Eventing metrics](../eventing/observability/metrics/collecting-metrics.md). |
| Upgrade | [Check the installed version](../install/upgrade/check-install-version.md), then consult the [upgrade guidance](../install/upgrade/README.md). |

The [administrator overview](../admin/admin-overview.md) connects these
responsibilities. Installation alone does not establish production readiness.

## Secure a Knative installation

- [Verify release images](../reference/security/verifying-images.md) or
  [verify client binaries](../reference/security/verifying-cli.md).
- [Configure Serving encryption](../serving/encryption/encryption-overview.md)
  for the communication path you intend to protect.
- For Eventing, consult [transport encryption](../eventing/features/transport-encryption.md)
  and [authorization](../eventing/features/authorization.md). These are
  feature-dependent paths: check the documented release, feature configuration,
  implementation compatibility, and prerequisites before changing a cluster.
  Transport encryption requires certificate setup; authorization requires
  [sender identity/authentication](../eventing/features/sender-identity.md).
  Do not assume either is enabled or applies uniformly to every component.

For trust boundaries and private vulnerability reporting, use
[security guidance and disclosure](../reference/security/README.md).
Artifact verification and installation alone do not establish a secure deployment.

## Investigate a problem

- Installation failing? Start with [installation troubleshooting](../install/troubleshooting.md).
- Service not behaving as expected? Use [Serving application debugging](../serving/troubleshooting/debugging-application-issues.md). Some checks are ingress-specific; use those matching your installation.
- Events not reaching a subscriber? Follow [existing Broker/Trigger route checks](../eventing/troubleshooting/events-not-delivered.md).
- Confirmed delivery errors, retries, or dead-letter receipts? Use
  [Events repeatedly fail delivery](../eventing/troubleshooting/delivery-failures.md).

To practice debugging rather than repair your own route, use the
[Channel/Subscription demonstration](../eventing/troubleshooting/README.md#example).

For the reasons behind a setting, switch to [explanation](../explanation/README.md).
For exact fields, defaults, and implementation constraints, use
[reference](../reference/README.md).
