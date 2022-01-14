# New Trigger Filters

**Flag name**: `new-trigger-filters`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#5204](https://github.com/knative/eventing/issues/5204)

## Table of contents

* [Overview](#overview)
* [About the filters field](#about-the-filters-field)
* [Supported filter dialects](#supported-filter-dialects)
    + [`exact`](#-exact-)
    + [`prefix`](#-prefix-)
    + [`suffix`](#-suffix-)
    + [`all`](#-all-)
    + [`any`](#-any-)
    + [`not`](#-not-)
    + [`sql`](#-sql-)
* [Conflict with the current `filter` field](#conflict-with-the-current--filter--field)
* [FAQ](#faq)
    + [Why are we adding yet another field? Why make the current `filter` field more robust?](#why-are-we-adding-yet-another-field--why-make-the-current--filter--field-more-robust-)
    + [Why `filters` and not another name that wouldn't be conflicting with the `filter` field?](#why--filters--and-not-another-name-that-wouldn-t-be-conflicting-with-the--filter--field-)

## Overview
This experimental features enables a new `filters` field in Triggers that conforms to the filters API field defined in the [`CloudEvents Subscriptions API`](https://github.com/cloudevents/spec/blob/master/subscriptions-api.md#323-filters) and allows users to specify a set of powerful filter expressions, where each expression evaluates to either true or false for each event.

The following example shows a Trigger using the new `filters` field
```yaml=
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  filters:
  - sql: "source LIKE '%commerce%' AND type IN ('order.created', 'order.updated', 'order.canceled')"
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

## About the filters field
* An array of filter expressions that evaluates to true or false. If any filter expression in the array evaluates to false, the event will not be sent to the `subscriber`.
* Each filter expression follows a "dialect" that defines the type of filter and the set of additional properties that are allowed within the filter expression.

## Supported filter dialects

The `filters` field supports the following dialects:

### `exact`

CloudEvent attribute String value must match exactly the specified String value.

```yaml=
filters:
  - exact:
      type: com.github.push
```
### `prefix`

CloudEvent attribute String value must start with the specified String value (case sensetive).

```yaml=
filters:
  - prefix:
      type: com.github.
```

### `suffix`

CloudEvent attribute String value must end with the specified String value (case sensitive).

```yaml=
filters:
  - suffix:
      type: .created
```

### `all`

All nested filter expessions must evaluate to true.

```yaml=
filters:
  - all:
      - exact:
          type: com.github.push
      - exact:
          subject: https://github.com/cloudevents/spec
```

### `any`

At least one nested filter expession must evaluate to true.

```yaml=
filters:
  - any:
      - exact:
          type: com.github.push
      - exact:
          subject: https://github.com/cloudevents/spec
```

### `not`

The nested expression evaluated must evaluate to false.

```yaml=
filters:
  - not:
      - exact:
          type: com.github.push       
```
### `sql`

The provided [CloudEvents SQL Expression](https://github.com/cloudevents/spec/blob/master/expression-language.md) must evaluate to true.

```yaml=
filters:
  - sql: "source LIKE '%commerce%' AND type IN ('order.created', 'order.updated', 'order.canceled')"
```

## Conflict with the current `filter` field

The current `filter` field will continue to be supported. However, when the feature is enabled and an object includes both `filter` and `filters`, the new `filters` field will override the `filter` field. This will allow you to try out the effect of the new `filters` field without compromising existing filters and you can introduce it to existing `Trigger` objects gradually.

```yaml=
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  # Current filter field. Will be ignored.
  filter:
    attributes:
      type: dev.knative.foo.bar
      myextension: my-extension-value
  # Enhanced filters field. This will override the old filter field. 
  filters:
    - sql: "type == 'dev.knative.foo.bar' AND myextension == 'my-extension-value'"
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```
## FAQ

### Why are we adding yet another field? Why make the current `filter` field more robust?

The reason there is twofold. First, at the time of developing `Trigger` APIs, there was no Subscriptions API in CloudEvents Project, so it makes sense to experiment with an API that makes us closer to Subscriptions API. Second, we still want to support users workload with the old `filter` field, and give them the possibility to transition to the new `filters` field.

### Why `filters` and not another name that wouldn't be conflicting with the `filter` field?

We've considered naming it `cefilters`, `subscriptionsAPIFilters` or `enhancedFilters` or something less conflicting. But we decided that introducing yet another different name than what's in the Subscriptions API is a step further from the alignment path we want to take towards the Subscriptions API. Instead, we decided it is a good opportunity to conform with the Subscriptions API at least starting from the field name level and leveraging the safety of this being an experimental feature.
