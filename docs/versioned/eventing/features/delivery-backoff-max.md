---
audience: developer
components:
  - eventing
function: how-to
---

# DeliverySpec.BackoffMax field

**Flag name**: `delivery-backoff-max`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#9278](https://github.com/knative/eventing/issues/9278)

**Persona**: Developer

Use the `backoffMax` field to limit the time between delivery attempts when a
subscriber is unavailable. You can specify a `delivery` spec for Channels,
Subscriptions, Brokers, Triggers, and other resources that accept the
`delivery` field.

Without a maximum, an exponential backoff that starts at one second reaches an
interval of approximately 12 days after 20 retries and 34 years after 30
retries. A maximum lets you configure a large retry count without allowing the
interval between attempts to grow beyond an operationally useful value.

The following fields control different sources of retry delay:

| Field | Controls | Example |
| --- | --- | --- |
| `backoffMax` | The interval calculated from `backoffDelay` and `backoffPolicy` | `PT10M` limits normal retry intervals to ten minutes |
| [`retryAfterMax`](delivery-retryafter.md) | A delay requested by a subscriber through an HTTP `Retry-After` response header | `PT2M` limits a requested delay to two minutes |

## Before you begin

Before a developer can configure `backoffMax`, Knative Eventing must be
installed, and a cluster operator must [enable the Eventing
feature](README.md#features-configuration) by setting `delivery-backoff-max` to
`enabled` in the `config-features` ConfigMap in the `knative-eventing`
namespace.

## Configure a maximum retry interval

Set `backoffMax` to a positive
[ISO 8601 duration](https://en.wikipedia.org/wiki/ISO_8601#Durations). The
maximum applies to both linear and exponential backoff policies.

`backoffMax` affects retry timing only when the `delivery` spec also configures
`retry`, `backoffDelay`, and `backoffPolicy`.

The following Subscription retries delivery up to 100 times. Its exponential
backoff starts at one second and stops growing when it reaches ten minutes:

```yaml
apiVersion: messaging.knative.dev/v1
kind: Subscription
metadata:
  name: orders-to-processor
  namespace: default
spec:
  channel:
    apiVersion: messaging.knative.dev/v1
    kind: InMemoryChannel
    name: orders
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: order-processor
  delivery:
    retry: 100
    backoffPolicy: exponential
    backoffDelay: PT1S
    backoffMax: PT10M
```

In this example, the normal intervals begin at one second and increase
exponentially. After an interval reaches ten minutes, later normal intervals do
not exceed ten minutes.

If you omit `backoffMax`, Knative Eventing continues to calculate retry
intervals from `backoffDelay` and `backoffPolicy` without a configured maximum.

!!! note
    The feature flag controls whether the API accepts the `backoffMax` field. It
    does not guarantee that every Channel, Broker, or Source implementation
    supports the field. Check the documentation for the implementation that
    delivers your events.
