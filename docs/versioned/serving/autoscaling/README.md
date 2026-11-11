---
audience: developer
components:
  - serving
function: explanation
---

# Autoscaling

Knative Serving automatically adjusts the number of application replicas to match incoming demand. The Knative Pod Autoscaler (KPA) is enabled by default. You do not need to set concurrency or scale bounds to enable its default behavior for a Service.

When a Revision receives no traffic, KPA can scale it to zero if scale to zero is enabled and the lower scale bound allows it. New traffic causes replicas to start again. A positive minimum scale keeps replicas available instead. Cluster administrators control whether scale to zero is enabled.

Choose a page for what you want to do next:

| Your goal | Start here |
| --- | --- |
| Try scaling down to zero and back up | [Autoscaling in Quickstart](../../getting-started/first-autoscale.md), after [deploying your first Service](../../getting-started/first-service.md) |
| Change a service's scaling target | [Set a concurrency target for a service](configure-concurrency.md), with readiness and configuration checks |
| Understand targets, hard limits, and spare capacity | [How concurrency affects autoscaling](concurrency-behavior.md) |
| Look up keys, defaults, and scopes | [Concurrency settings](concurrency.md) and [scale bounds](scale-bounds.md) |

## Other configuration goals

- Keep a minimum number of replicas, cap the replica count, or delay scale-down: see the [scale bounds reference](scale-bounds.md#lower-bound) for settings and fragments.
- Enable or disable scale to zero for the cluster: see [Configuring scale to zero](scale-to-zero.md) (requires cluster administrator permissions).
- Choose KPA or HPA: see [Supported Autoscaler types](autoscaler-types.md). HPA requires an [optional Serving extension](../../install/yaml-install/serving/install-serving-with-yaml.md#install-optional-serving-extensions).
- Choose a metric other than concurrency: see the [metrics reference](autoscaling-metrics.md) and [requests-per-second targets](rps-target.md).

## Additional resources

- [Go autoscaling sample](autoscale-go/README.md) — run a load experiment after you have a working Serving environment.
- [KPA-specific settings](kpa-specific.md) — look up scaling windows and panic-mode settings.
- [Request flow](../request-flow.md) — understand the Activator's role when requests arrive without available replica capacity.
