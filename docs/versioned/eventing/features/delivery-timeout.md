# DeliverySpec.Timeout field

**Flag name**: `delivery-timeout`

**Stage**: Beta, enabled by default

**Tracking issue**: [#5148](https://github.com/knative/eventing/issues/5148)

**Persona**: Developer

When using the `delivery` spec to configure event delivery parameters, you can
use `timeout` field to specify the timeout for each sent HTTP request. The
duration of the `timeout` parameter is specified using the
[ISO 8601](https://en.wikipedia.org/wiki/ISO_8601#Times) format.

The following example shows a Subscription that retries sending an event 3
times, and on each retry the request timeout is 5 seconds:

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
    timeout: PT5S
```

You can specify a `delivery` spec for Channels, Subscriptions, Brokers,
Triggers, and any other resource spec that accepts the `delivery` field.
