# Experimental features

In Knative we want to keep the innovation alive, experimenting and delivering new features without affecting the stability of the project.

In order to achieve that goal in Knative Eventing, we have a process to include new features.
This allows users like you to try out new features and provide feedback back to the project.

This document explains how to enable experimental features and which ones are available today.

For more details about the process, the feature phases, quality requirements and guarantees, check out the [Experimental features process documentation](https://github.com/knative/eventing/blob/main/docs/experimental-features.md).

!!! warning
    Depending on the feature stage, an experimental feature might be unstable and break your Knative setup or even your cluster setup, use them with caution.
    For more details about quality guarantees, check out the [Feature stage definition](https://github.com/knative/eventing/blob/main/docs/experimental-features.md#stage-definition).

## Before you begin

You must have a Knative cluster running with the Eventing component installed. [Learn more](../admin/install/README.md)

## Experimental features configuration

When installing Eventing, the `config-features` ConfigMap is added to your cluster in the `knative-eventing` namespace.
In order to enable a feature, you just need to add it to the config map and set its value to `enabled`.
For example, to enable `new-cool-feature`:

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

When using the `KReference` type to refer to another Knative resource, you can just specify the API `group` of the resource, instead of the full `APIVersion`.

For example, in order to refer to an `InMemoryChannel`, instead of the following spec:

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

With this feature you can allow Knative to resolve the full `APIVersion` and further upgrades, deprecations and removals of the referred CRD without affecting existing resources.

!!! note
    At the moment this feature is implemented only for `Subscription.Spec.Subscriber.Ref` and `Subscription.Spec.Channel`.

### DeliverySpec.Timeout field

**Flag name**: `delivery-timeout`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#5148](https://github.com/knative/eventing/issues/5148)

When using the `delivery` spec to configure event delivery parameters, you can use `timeout` field to specify the timeout for each sent HTTP request. The duration of the `timeout` parameter is specified using the [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601#Times) format.

The following example shows a Subscription that retries sending an event 3 times, and on each retry the request timeout is going to be 5 seconds:

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

You can specify a `delivery` spec for Channels, Subscriptions, Brokers, Triggers, and any other resource spec that accepts the `delivery` field.
