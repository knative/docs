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
and required components. If you are trying Knative for the first time, begin with
the [Quickstart tutorial](../getting-started/README.md) instead.

## Develop and deploy functions

- [Create a function project](../functions/creating-functions.md).
- [Build a function](../functions/building-functions.md) and
  [run it locally](../functions/running-functions.md).
- [Deploy a function](../functions/deploying-functions.md) and
  [invoke it](../functions/invoking-functions.md).
- [Subscribe a function to events](../functions/subscribing-functions.md).

For tooling setup, see [installing `func`](../functions/install-func.md) and
[installing `kn`](../client/install-kn.md). Before changing cluster resources,
[select a context and verify CLI access](../client/connect-to-cluster.md).

## Deploy and manage HTTP services

- [Create a Knative Service](../serving/services/creating-services.md) or
  [convert a Kubernetes Deployment](../serving/convert-deployment-to-knative-service.md).
- [Manage traffic between revisions](../serving/traffic-management.md).
- [Set and verify a concurrency target](../serving/autoscaling/configure-concurrency.md).
- [Configure a custom domain for a Service](../serving/services/custom-domains.md).

For related scaling guides and settings, use the
[autoscaling topic overview](../serving/autoscaling/README.md), including
[scale-bound settings](../serving/autoscaling/scale-bounds.md).

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
| Configure | [Work with ConfigMaps](../admin/editing-configmaps.md) or [change and verify an Operator-managed ConfigMap value](../install/operator/configuring-with-operator.md), according to how your installation is managed. For other Operator changes, choose a [Serving configuration goal](../install/operator/configuring-serving-cr.md) or [Eventing configuration goal](../install/operator/configuring-eventing-cr.md). |
| Secure | [Verify Knative images](../reference/security/verifying-images.md) and [configure Serving encryption](../serving/encryption/encryption-overview.md). For security boundaries, read the [threat model](../reference/security/threat-model.md). |
| Observe | Collect [Serving metrics](../serving/observability/metrics/collecting-metrics.md) or [Eventing metrics](../eventing/observability/metrics/collecting-metrics.md). |
| Upgrade | [Check the installed version](../install/upgrade/check-install-version.md), then consult the [upgrade guidance](../install/upgrade/README.md). |

The [administrator overview](../admin/admin-overview.md) connects these
responsibilities. Installation alone does not establish production readiness.

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
