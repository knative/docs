---
audience: developer
components:
  - eventing
function: how-to
---

# Using Triggers

A trigger represents a desire to subscribe to events from a specific broker.

The `subscriber` value must be a [Destination](https://pkg.go.dev/knative.dev/pkg/apis/duck/v1#Destination).

## Example Triggers

The following trigger receives all the events from the `default` broker and
delivers them to the Knative Serving service `my-service`:

1. Create a YAML file using the following example:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
      name: my-service-trigger
    spec:
      broker: default
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: my-service
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.


The following trigger receives all the events from the `default` broker and
delivers them to the custom path `/my-custom-path` for the Kubernetes service `my-service`:

1. Create a YAML file using the following example:

    ```yaml
    apiVersion: eventing.knative.dev/v1
    kind: Trigger
    metadata:
      name: my-service-trigger
    spec:
      broker: default
      subscriber:
        ref:
          apiVersion: v1
          kind: Service
          name: my-service
        uri: /my-custom-path
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

## Trigger filtering

Various forms of filtering based on any number of CloudEvents attributes and extensions
are supported. If multiple `filters` are provided, all of them must evaluate to true
in order for the event to be passed to the subscriber of the trigger. Note that we
do not support filtering on the `data` field of CloudEvents.

!!! important
    The filters described in this section are currently only supported in the Apache Kafka Broker
    and the MTChannelBasedBroker. For other brokers, please refer to the [Legacy attribute filter](#legacy-attributes-filter).


### Example

This example filters events from the `default` broker that are of type
`dev.knative.foo.bar` and have the extension `myextension` which ends
with `-extensions.

1. Create a YAML file using the following example:

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
          suffix:
            myextension: -value
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: my-service
    ```

1. Apply the YAML file by running the command:

    ```bash
    kubectl apply -f <filename>.yaml
    ```
    Where `<filename>` is the name of the file you created in the previous step.

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
It's semantics and behaviour are the same as the `exact` filter dialect and wherever possible users should move to the
`exact` filter. However, for backwards compatability the attributes filter will continue to work for all users. The following
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

Whenver both the `filters` field and the `filter` field are both provided, the `filters` field will override the `filter` field. For example,
in the following trigger events with type `dev.knative.a` will be delivered, while events with type `dev.knative.b` will not.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  filters:
    exact:
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

- `eventing.knative.dev/injection`: if set to `enabled`, Eventing automatically creates a Broker for a Trigger if it doesn't exist. The Broker is created in the namespace where the Trigger is created. This annotation only works if you have the [Sugar Controller](../sugar/README.md) enabled, which is optional and not enabled by default.
- `knative.dev/dependency`: this annotation is used to mark the sources that the Trigger depends on. If one of the dependencies is not ready, the Trigger will not be ready.

The following YAML is an example of a Trigger with a dependency:
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
