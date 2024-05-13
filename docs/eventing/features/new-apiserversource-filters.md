# New trigger filters

**Flag name**: `new-apiserversource-filters`

**Stage**: Alpha, disabled by default

**Tracking issue**: [#7791](https://github.com/knative/eventing/issues/7791)
## Overview
This feature enables a new `filters` field in APIServerSource that conforms to the filters API field defined in the [`CloudEvents Subscriptions API`](https://github.com/cloudevents/spec/blob/main/subscriptions/spec.md#324-filters). It allows users to specify a set of powerful filter expressions, where each expression evaluates to either true or false for each event.

The following example shows a APIServerSource using the new `filters` field:

```yaml
---
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
 name: my-apiserversource
 namespace: default
spec:
  filters:
  - any:
    - exact:
        type: dev.knative.apiserver.ref.add

  serviceAccountName: apiserversource
  mode: Reference
  resources: ...
  sink: ...

```

## About the filters field
* An array of filter expressions that evaluates to true or false. If any filter expression in the array evaluates to false, the event will not be sent to the `sink`.
* Each filter expression follows a dialect that defines the type of filter and the set of additional properties that are allowed within the filter expression.

## Supported filter dialects

The `filters` field supports the following dialects:

### `exact`

CloudEvent attribute String value must exactly match the specified String value. Matching is case-sensitive.

```yaml
apiVersion: sources.knative.dev/v1
kind: APIServerSource
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
apiVersion: sources.knative.dev/v1
kind: APIServerSource
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
apiVersion: sources.knative.dev/v1
kind: APIServerSource
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
apiVersion: sources.knative.dev/v1
kind: APIServerSource
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
apiVersion: sources.knative.dev/v1
kind: APIServerSource
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
apiVersion: sources.knative.dev/v1
kind: APIServerSource
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
apiVersion: sources.knative.dev/v1
kind: APIServerSource
metadata:
  ...
spec:
  ...
  filters:
    - cesql: "source LIKE '%commerce%' AND type IN ('order.created', 'order.updated', 'order.canceled')"
```

## FAQ

## Which are the event types APIServerSource provide?

* `dev.knative.apiserver.resource.add`
* `dev.knative.apiserver.resource.update`
* `dev.knative.apiserver.resource.delete`
* `dev.knative.apiserver.ref.add`
* `dev.knative.apiserver.ref.update`
* `dev.knative.apiserver.ref.delete`
