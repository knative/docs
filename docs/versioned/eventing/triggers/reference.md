---
audience: developer
components:
  - eventing
function: reference
---

# Trigger filtering reference

Use this page to look up filter dialects, compatibility, and Trigger annotations.
To create a route and verify matching events, use [Using Triggers](README.md).
For the routing model, see [Brokers](../brokers/README.md).

The `subscriber` value must be a [Destination](https://pkg.go.dev/knative.dev/pkg/apis/duck/v1#Destination).

## Trigger filtering

Various forms of filtering based on any number of CloudEvents attributes and extensions
are supported. If multiple `filters` are provided, all of them must evaluate to true
in order for the event to be passed to the subscriber of the trigger. Note that we
do not support filtering on the `data` field of CloudEvents.

`spec.filters` is a list of expressions. Each expression can set only one
nonempty dialect; combine different predicates as separate list entries or
nest them under `all`. These constraints were rechecked in the v1.24
[`TriggerSpec` type](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/apis/eventing/v1/trigger_types.go)
and [`ValidateOneOf` validation](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/apis/eventing/v1/trigger_validation.go).
The list shape, top-level subscriber, and validation of nested dialects are
unchanged from the historical v1.23 check; that earlier check alone is not
v1.24 validation.
The abbreviated dialect snippets below illustrate fields, not complete manifests.

!!! important "Implementation support: retained claim, release scope unverified"
    The original Trigger filtering page at the experiment baseline `c250e7f7`
    listed support for `spec.filters` only in the Apache Kafka Broker and
    MTChannelBasedBroker. It did not record the implementation versions for
    that claim. The v1.24 API citations above validate expression shape and
    validation rules, **not** a Broker capability matrix; the historical support
    claim has not been revalidated across v1.24 Broker/extension implementations. Identify your installed
    [Broker implementation](../brokers/broker-types/README.md) and release, and
    ask its platform owner for release-specific dialect support evidence before
    changing filters. API acceptance alone does not prove implementation support.
    Keep a working [legacy attributes filter](#legacy-attributes-filter) rather
    than migrating to a dialect whose support has not been established.

### Example

This example filters events from the `default` broker that are of type
`dev.knative.foo.bar` and have an extension `myextension` whose value ends with
`-value`. Both predicates must match.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  filters:
    - exact:
        type: dev.knative.foo.bar
    - suffix:
        myextension: -value
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

### Supported filter dialects

#### `exact`

CloudEvent attribute String value must exactly match the specified String value. Matching is case-sensitive.
If the attribute is not a String, the filter will compare a String representation of the attribute to the
specified String value.

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

#### `prefix`

CloudEvent attribute String value must start with the specified String value. Matching is case-sensitive.
If the attribute is not a String, the filter will compare a String representation of the attribute to the
specified String value.

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

#### `suffix`

CloudEvent attribute String value must end with the specified String value. Matching is case-sensitive.
If the attribute is not a String, the filter will compare a String representation of the attribute to the
specified String value.

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

#### `all`

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

#### `any`

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

#### `not`

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

#### `cesql`

The provided [CloudEvents SQL Expression](https://github.com/cloudevents/spec/blob/cesql/v1.0.0/cesql/spec.md) must evaluate to true.

!!! important
    Knative 1.15+ only supports the CloudEvents SQL v1.0 specification. Any CESQL expressions written prior to Knative v1.15 should
    be verified, as there were some changes in the CESQL specification.

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

### Legacy attributes filter

The legacy attributes filter provides exact match filtering on any number of CloudEvents attributes as well as extensions.
Its semantics and behaviour are the same as the `exact` filter dialect. Consider
moving to `exact` only when your installed Broker implementation and release
support `spec.filters`; check the [dialect support restriction](#trigger-filtering)
first. Do not migrate a working legacy filter to an unsupported dialect.
For backwards compatibility the attributes filter continues to be supported. The following
example filters events from the `default` broker that are of type `dev.knative.foo.bar` and have the extension `myextension`
with the value `my-extension-value`.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  filter:
    attributes:
      type: dev.knative.foo.bar
      myextension: my-extension-value
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

Whenever both the `filters` field and the `filter` field are provided, the `filters` field will override the `filter` field. For example,
in the following Trigger, events with type `dev.knative.a` match the effective
filter, while events with type `dev.knative.b` do not. Matching selects events
for delivery; it does not guarantee subscriber receipt.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  filters:
    - exact:
        type: dev.knative.a
  filter:
    attributes:
      type: dev.knative.b
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

## Trigger annotations

You can modify a Trigger's behavior by setting the following two annotations:

- `eventing.knative.dev/injection`: the rechecked v1.24 [annotation validator](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/apis/eventing/v1/trigger_validation.go) accepts only `enabled` or `disabled`, and only when `spec.broker` is `default`. Do not treat this annotation alone as an automatic Broker-creation switch: the v1.24 [Sugar Trigger reconciler](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/reconciler/sugar/trigger/trigger.go) selects Triggers using `config-sugar`'s `trigger-selector` labels, not this annotation. The optional [Sugar Controller](../sugar/README.md) must be installed and [configured](../configuration/sugar-configuration.md); it is not enabled by default. For selected Triggers it can create a missing Broker in the Trigger's namespace. An annotation value of `disabled` does not override that label selection in v1.24. These validator/reconciler behaviors are unchanged from the historical v1.23 source.
- `knative.dev/dependency`: this annotation is used to mark the sources that the Trigger depends on. If one of the dependencies is not ready, the Trigger will not be ready.

The following YAML is an example of a Trigger with a dependency. `subscriber`
is required directly under `spec`, as defined by
[`TriggerSpec`](https://github.com/knative/eventing/blob/knative-v1.24.0/pkg/apis/eventing/v1/trigger_types.go),
not nested under `filter`. The referenced PingSource and subscriber must exist
for this example to become Ready.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
  annotations:
    knative.dev/dependency: '{"kind":"PingSource","name":"test-ping-source","apiVersion":"sources.knative.dev/v1"}'
spec:
  broker: default
  filter:
    attributes:
      type: dev.knative.foo.bar
      myextension: my-extension-value
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

## Related reference

- [Eventing API reference](../reference/eventing-api.md) for the release-specific resource schema.
- [Event delivery reference](../reference/event-delivery.md) for delivery fields and implementation support.
- [Events do not reach a subscriber](../troubleshooting/events-not-delivered.md) to investigate an existing route.
