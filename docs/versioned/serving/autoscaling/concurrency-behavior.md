---
audience: developer
components:
  - serving
function: explanation
---

# How concurrency affects autoscaling

Concurrency is the number of requests being processed at the same time. For a service using the Knative Pod Autoscaler (KPA) with the concurrency metric, the Autoscaler uses observed concurrency to decide how many replicas are needed. A concurrency target describes desired load per replica; it is not the same as a limit on what the application can accept.

## Soft targets and hard limits

A **soft target** tells the Autoscaler the desired concurrency per replica. It is not strictly enforced: an individual replica can receive more concurrent requests than the target, particularly during a sudden burst while additional replicas are starting.

A **hard limit**, set through `containerConcurrency`, is an enforced upper bound on simultaneous requests admitted to each replica. When a replica reaches this limit, surplus requests are buffered and wait for capacity. A hard limit does not make additional capacity available immediately.

When both are configured, the Autoscaler uses the smaller of the soft target and the nonzero hard limit as its concurrency target, before applying target utilization. An unlimited hard-limit setting does not cap the soft target.

Without an explicit soft target, a nonzero hard limit supplies the concurrency target rather than merely capping the cluster default. Only when neither an explicit target nor a nonzero hard limit is present does the cluster concurrency default supply the target. See the [target-resolution reference](concurrency.md#soft-limit) for the exact cases and utilization calculation.

!!! warning
    Use a hard limit only when your application has a clear need to bound simultaneous requests. A low hard limit can reduce throughput, increase latency through queuing, and cause additional cold starts.

A soft target is appropriate when the goal is to influence scaling while allowing a replica to absorb bursts. A hard limit is appropriate when admitting more concurrent requests to a replica would harm the application. Neither replaces load testing: request duration and the application's resource use affect how much concurrency a replica can handle.

## Target utilization and spare capacity

Target utilization leaves headroom by making the Autoscaler aim for a fraction of the concurrency target. For example, with a hard limit of 10, no smaller soft target, and utilization of 70%, the effective autoscaling target is an average of 7 concurrent requests per replica. Each replica can still admit up to 10 concurrent requests.

This headroom allows scaling to respond before replicas reach the hard limit. It does not guarantee that a new replica will be ready as soon as the average reaches 7. The Autoscaler observes load over time, and starting replicas takes time. See [KPA scaling windows and panic mode](kpa-specific.md) for the settings that govern that response.

A lower utilization aims for more spare capacity at the same load. A higher utilization aims to keep replicas busier, leaving less headroom for bursts. Capacity and latency trade-offs depend on the workload rather than on the target alone.

## Concurrency and scale from zero

Concurrency settings govern load on active replicas; they do not keep a replica running when there is no traffic. With scale to zero enabled and no positive minimum scale, a later request can require starting a replica before the application can serve it. The [request flow explanation](../request-flow.md) describes how the Activator participates in this path.

To retain replicas during idle periods, look up the [lower scale bound](scale-bounds.md#lower-bound). To delay scale-down rather than prevent it, see [scale-down delay](scale-bounds.md#scale-down-delay). These settings address different goals from limiting concurrency.

## Related pages

- [Set a concurrency target for a service](configure-concurrency.md) — change and verify the configuration of an existing service.
- [Concurrency settings](concurrency.md) — keys, scopes, defaults, and examples.
- [Try autoscaling in Quickstart](../../getting-started/first-autoscale.md) — observe scale to zero and subsequent activation.
