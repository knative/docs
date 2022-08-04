# Strict Subscriber

**Flag name**: `strict-subscriber`

**Stage**: Beta, enabled by default

**Tracking issue**: [#5762](https://github.com/knative/eventing/pull/5762)

When defining a Subscription, if the `strict-subscriber` flag is enabled,
validation fails if the field `spec.subscriber` is not defined. This flag was
implemented to follow the latest version of
the [Knative Eventing spec](https://github.com/knative/specs/tree/main/specs/eventing)
.

For example, the following Subscription will fail validation if
the `strict-subscriber` flag is enabled:

```yaml
apiVersion: messaging.knative.dev/v1
kind: Subscription
metadata:
  name: example-subscription
  namespace: example-namespace
spec:
  reply:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: example-reply
```

With the flag disabled (default behavior) the Subscription can define either a
subscriber or a reply field, and validation will succeed. This is the default
behavior in Knative v0.26 and earlier.
