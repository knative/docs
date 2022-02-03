# DeliverySpec.RetryAfterMax field

**Flag name**: `delivery-retryafter`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#5811](https://github.com/knative/eventing/issues/5811)

**Persona**: Developer

When using the `delivery` spec to configure event delivery parameters, you can
use the `retryAfterMax` field to specify how
HTTP [Retry-After](https://datatracker.ietf.org/doc/html/rfc7231#section-7.1.3)
headers are handled when calculating backoff times for retrying **429** and
**503** responses. You can specify a `delivery` spec for Channels,
Subscriptions, Brokers, Triggers, and any other resource spec that accepts the
`delivery` field.

The `retryAfterMax` field only takes effect if you configure the `delivery` spec
to perform retries, and only pertains to retry attempts on **429** and **503**
response codes. The field provides an override to prevent large **Retry-After**
durations from impacting throughput, and must be specified using
the [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601#Times) format. The largest
of the normal backoff duration and the Retry-After header value will be used for
the subsequent retry attempt. Specifying a "zero" value of `PT0S` effectively
disables **Retry-After** support.

Prior to this experimental feature, Knative Eventing implementations have not
supported **Retry-After** headers, and this is an attempt to provide a path
for standardizing that support.  To begin, the feature is **opt-in**, but the
final state will be **opt-out** as follows:

| Feature Stage | Feature Flag | retryAfterMax Field Absent | retryAfterMax Field Present |
| --- | --- | --- | --- |
| Alpha / Beta | Disabled | Accepted by Webhook Validation & Retry-After headers NOT enforced | Rejected by WebHook Validation |
| Alpha / Beta | Enabled | Accepted  by Webhook Validation & Retry-After headers NOT enforced | Accepted by Webhook Validation & Retry-After headers enforced if max override > 0 |
| Stable / GA | n/a | Retry-After headers enforced without max override | Retry-After headers enforced if max override > 0 |

The following example shows a Subscription that retries sending an event three
times, and respects **Retry-After** headers while imposing a maximum backoff of
120 seconds:

```yaml
apiVersion: messaging.knative.dev/v1
kind: Subscription
metadata:
  name: example-subscription
  namespace: example-namespace
spec:
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: example-sink
  delivery:
    backoffDelay: PT2S
    backoffPolicy: linear
    retry: 3
    retryAfterMax: PT120S
```

!!! note
    While the experimental feature flag enforces all DeliverySpec usage of the
    `retryAfterMax` field through Webhook validation, it does not guarantee all
    implementations, such as Channels or Sources, actually implement support
    for the field.  The shared `HTTPMessageSender.SendWithRetries()` logic has
    been enhanced to support this feature, and all implementations using it to
    perform retries will automatically benefit.  Sandbox implementations not
    based on this shared library, for example RabbitMQ or Google Pub/Sub, would
    require additional development effort to respect the `retryAfterMax` field.
