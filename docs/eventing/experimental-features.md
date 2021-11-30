# Experimental features

In order to keep Knative innovative, the maintainers of this project have
developed an
[experimental features process](https://github.com/knative/eventing/blob/main/docs/experimental-features.md),
that allows new, experimental features to be delivered and tested by users,
without affecting the stability of the core project.

<!--TODO: Add note about HOW / where users can provide feedback, otherwise there's not much point mentioning that-->

!!! warning
    Experimental features are unstable and may cause issues in your Knative setup or even your cluster setup.
    These features should be used with caution, and should never be tested on a production environment. For more
    information about quality guarantees for features at different stages of
    development, see the
    [Feature stage definition](https://github.com/knative/eventing/blob/main/docs/experimental-features.md#stage-definition)
    documentation.

This document explains how to enable experimental features and which ones are
available today.

## Before you begin

You must have a Knative cluster running with Knative Eventing installed.

## Experimental features configuration

When you install Knative Eventing, the `config-features` ConfigMap is added to
your cluster in the `knative-eventing` namespace.

In order to enable a feature, you must add it to the `config-features` ConfigMap
under the `data` spec, and set the value for the feature to `enabled`. For example,
to enable a feature called `new-cool-feature`, you would add the following ConfigMap
entry:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-features
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
    knative.dev/config-propagation: original
    knative.dev/config-category: eventing
data:
  new-cool-feature: enabled
```

In order to disable it, you can either remove the flag or set it to `disabled`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-features
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
    knative.dev/config-propagation: original
    knative.dev/config-category: eventing
data:
  new-cool-feature: disabled
```

## Features list

### KReference.Group field

**Flag name**: `kreference-group`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#5086](https://github.com/knative/eventing/issues/5086)

**Persona**: Developer

When using the `KReference` type to refer to another Knative resource, you can
just specify the API `group` of the resource, instead of the full `APIVersion`.

For example, in order to refer to an `InMemoryChannel`, instead of the following
spec:

```yaml
apiVersion: messaging.knative.dev/v1
kind: InMemoryChannel
name: my-channel
```

You can use the following:

```yaml
group: messaging.knative.dev
kind: InMemoryChannel
name: my-channel
```

With this feature you can allow Knative to resolve the full `APIVersion` and
further upgrades, deprecations and removals of the referred CRD without
affecting existing resources.

!!! note
    At the moment this feature is implemented only for
    `Subscription.Spec.Subscriber.Ref` and `Subscription.Spec.Channel`.

### DeliverySpec.RetryAfterMax field

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

### DeliverySpec.Timeout field

**Flag name**: `delivery-timeout`

**Stage**: Alpha, disabled by default

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

### Knative reference mapping

**Flag name**: `kreference-mapping`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#5148](https://github.com/knative/eventing/issues/5593)

**Persona**: Administrator, Developer

When enabled, this feature allows you to provide mappings from a [Knative reference](https://github.com/knative/specs/blob/main/specs/eventing/overview.md#destination) to a templated URI.


!!! note
    Currently only PingSource supports this experimental feature.

For example, you can directly reference non-addressable resources anywhere that Knative Eventing accepts a reference, such as for a PingSource sink, or a Trigger subscriber.

Mappings are defined by a cluster administrator in the `config-reference-mapping` ConfigMap.
The following example maps `JobDefinition` to a Job runner service:

{% raw %}

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-kreference-mapping
  namespace: knative-eventing
data:
  JobDefinition.v1.mygroup: "https://jobrunner.{{ .SystemNamespace }}.svc.cluster.local/{{ .Name }}"
```

{% endraw %}

The key must be of the form `<Kind>.<version>.<group>`. The value must resolved
to a valid URI. Currently, the following template data are supported:

- Name: The name of the referenced object
- Namespace: The namespace of the referenced object
- UID: The UID of the referenced object
- SystemNamespace: The namespace of where Knative Eventing is installed

Given the above mapping, the following example shows how you can directly reference
`JobDefinition` objects in a PingSource:

```yaml
apiVersion: sources.knative.dev/v1
kind: PingSource
metadata:
  name: trigger-job-every-minute
spec:
  schedule: "*/1 * * * *"
  sink:
    ref:
      apiVersion: mygroup/v1
      kind: JobDefinition
      name: ajob
```

### Strict Subscriber

**Flag name**: `strict-subscriber`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#5762](https://github.com/knative/eventing/pull/5762)

When defining a Subscription, if the `strict-subscriber` flag is enabled, validation fails if the field `spec.subscriber` is not defined. This flag was implemented to follow the latest version of the [Knative Eventing spec](https://github.com/knative/specs/tree/main/specs/eventing).

For example, the following Subscription will fail validation if the `strict-subscriber` flag is enabled:
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

With the flag disabled (default behavior) the Subscription can define either a subscriber or a reply field, and validation will succeed. This is the default behavior in Knative v0.26 and earlier.
