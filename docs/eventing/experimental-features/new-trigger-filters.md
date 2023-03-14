# New trigger filters

**Flag name**: `new-trigger-filters`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#5204](https://github.com/knative/eventing/issues/5204)
## Overview
This experimental feature enables a new `filters` field in Triggers that conforms to the filters API field defined in the [`CloudEvents Subscriptions API`](https://github.com/cloudevents/spec/blob/main/subscriptions/spec.md#324-filters). It allows users to specify a set of powerful filter expressions, where each expression evaluates to either true or false for each event.

The following example shows a Trigger using the new `filters` field:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  filters:
    - cesql: "source LIKE '%commerce%' AND type IN ('order.created', 'order.updated', 'order.canceled')"
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

## About the filters field
* An array of filter expressions that evaluates to true or false. If any filter expression in the array evaluates to false, the event will not be sent to the `subscriber`.
* Each filter expression follows a dialect that defines the type of filter and the set of additional properties that are allowed within the filter expression.

## Supported filter dialects

The `filters` field supports the following dialects:

### `exact`

CloudEvent attribute String value must exactly match the specified String value. Matching is case-sensitive.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  ...
spec:
  ...
  filters:
    - exact:
        type: com.github.push
```

### `prefix`

CloudEvent attribute String value must start with the specified String value. Matching is case-sensitive.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  ...
spec:
  ...
  filters:
    - prefix:
        type: com.github.
```

### `suffix`

CloudEvent attribute String value must end with the specified String value. Matching is case-sensitive.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  ...
spec:
  ...
  filters:
    - suffix:
        type: .created
```

### `all`

All nested filter expressions must evaluate to true.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  ...
spec:
  ...
  filters:
    - all:
        - exact:
            type: com.github.push
        - exact:
            subject: https://github.com/cloudevents/spec
```

### `any`

At least one nested filter expression must evaluate to true.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  ...
spec:
  ...
  filters:
    - any:
        - exact:
            type: com.github.push
        - exact:
            subject: https://github.com/cloudevents/spec
```

### `not`

The nested expression evaluated must evaluate to false.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  ...
spec:
  ...
  filters:
      - not:
          exact:
              type: com.github.push
```
### `cesql`

The provided [CloudEvents SQL Expression](https://github.com/cloudevents/spec/blob/main/cesql/spec.md) must evaluate to true.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  ...
spec:
  ...
  filters:
    - cesql: "source LIKE '%commerce%' AND type IN ('order.created', 'order.updated', 'order.canceled')"
```

## Conflict with the current `filter` field

The current `filter` field will continue to be supported. However, if you enable this feature and an object includes both `filter` and `filters`, the new `filters` field overrides the `filter` field. This allows you to try the new `filters` field without compromising existing filters, and you can introduce it to existing `Trigger` objects gradually.

```yaml
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
    - cesql: "type = 'dev.knative.foo.bar' AND myextension = 'my-extension-value'"
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

## FAQ

### Why add yet another field? Why not make the current `filter` field more robust?

The reason is twofold. First, at the time of developing `Trigger` APIs, there was no Subscriptions API in CloudEvents Project, so it makes sense to experiment with an API that is closer to the Subscriptions API. Second, we still want to support users workload with the old `filter` field, and give them the possibility to transition to the new `filters` field.

### Why `filters` and not another name that wouldn't conflict with the `filter` field?

We considered other names, such as `cefilters`, `subscriptionsAPIFilters`, or `enhancedFilters`, but we decided that this would be a step further from aligning with the Subscriptions API. Instead, we decided it is a good opportunity to conform with the Subscriptions API, at least at the field name level, and to leverage the safety of this being an experimental feature.
