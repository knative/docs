# Eventing experimental features

To keep Knative innovative, the maintainers of this project have developed an
[experimental features process](https://github.com/knative/eventing/blob/main/docs/experimental-features.md)
that allows new, experimental features to be delivered and tested by users
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

To enable a feature, you must add it to the `config-features` ConfigMap
under the `data` spec, and set the value for the feature to `enabled`. For
example, to enable a feature called `new-cool-feature`, you would add the
following ConfigMap entry:

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

To disable it, you can either remove the flag or set it to `disabled`:

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

## Available experimental features

The following table gives an overview of the available experimental features in
Knative Eventing:

| Feature | Flag | Description | Maturity |
| ------- | ---- | ----------- | -------- |
| [DeliverySpec.RetryAfterMax field](delivery-retryafter.md)  | `delivery-retryafter` | Specify a maximum retry duration that overrides HTTP [Retry-After](https://datatracker.ietf.org/doc/html/rfc7231#section-7.1.3) headers when calculating backoff times for retrying **429** and **503** responses. | Alpha, disabled by default |
| [DeliverySpec.Timeout field](delivery-timeout.md) | `delivery-timeout` | When using the `delivery` spec to configure event delivery parameters, you can use  the`timeout` field to specify the timeout for each sent HTTP request. | Alpha, disabled by default |
| [KReference.Group field](kreference-group.md) | `kreference-group` | Specify the API `group` of `KReference` resources without the API version. | Alpha, disabled by default |
| [Knative reference mapping](kreference-mapping.md) | `kreference-mapping` | Provide mappings from a [Knative reference](https://github.com/knative/specs/blob/main/specs/eventing/overview.md#destination) to a templated URI. | Alpha, disabled by default |
| [New trigger filters](new-trigger-filters.md) | `new-trigger-filters` | Enables a new Trigger `filters` field that supports a set of powerful filter expressions. | Alpha, disabled by default |
