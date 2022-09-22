# SinkBinding reference

![API version v1](https://img.shields.io/badge/API_Version-v1-green?style=flat-square)

This topic provides reference information about the configurable parameters for SinkBinding objects.

## Supported parameters

A `SinkBinding` resource supports the following parameters:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| [`apiVersion`][kubernetes-overview] | Specifies the API version, for example `sources.knative.dev/v1`. | Required |
| [`kind`][kubernetes-overview] | Identifies this resource object as a `SinkBinding` object. | Required |
| [`metadata`][kubernetes-overview] | Specifies metadata that uniquely identifies the `SinkBinding` object. For example, a `name`. | Required |
| [`spec`][kubernetes-overview] | Specifies the configuration information for this `SinkBinding` object. | Required |
| [`spec.sink`](../../sinks/README.md#sink-as-a-parameter) | A reference to an object that resolves to a URI to use as the sink. | Required |
| [`spec.subject`](#subject-parameter) | A reference to the resources for which the "runtime contract" is augmented by Binding implementations. | Required |
| [`spec.ceOverrides`](#cloudevent-overrides) | Defines overrides to control the output format and modifications to the event sent to the sink. | Optional |

### Subject parameter

The Subject parameter references the resources for which the "runtime contract"
is augmented by Binding implementations.

A `subject` definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| `apiVersion` | API version of the referent. | Required |
| [`kind`][kubernetes-kinds] | Kind of the referent. | Required |
| [`namespace`][kubernetes-namespaces] | Namespace of the referent. If omitted, this defaults to the object holding it. | Optional |
| [`name`][kubernetes-names] | Name of the referent. | Do not use if you configure `selector`. |
| `selector` | Selector of the referents. | Do not use if you configure `name`. |
| `selector.matchExpressions` | A list of label selector requirements. The requirements are ANDed. | Use one of `matchExpressions` or `matchLabels` |
| `selector.matchExpressions.key` | The label key that the selector applies to. | Required if using `matchExpressions` |
| `selector.matchExpressions.operator` | Represents a key's relationship to a set of values. Valid operators are `In`, `NotIn`, `Exists` and `DoesNotExist`. | Required if using `matchExpressions` |
| `selector.matchExpressions.values` | An array of string values. If `operator` is `In` or `NotIn`, the values array must be non-empty. If `operator` is `Exists` or `DoesNotExist`, the values array must be empty. This array is replaced during a strategic merge patch. | Required if using `matchExpressions` |
| `selector.matchLabels` | A map of key-value pairs. Each key-value pair in the `matchLabels` map is equivalent to an element of `matchExpressions`, where the key field is `matchLabels.<key>`, the `operator` is `In`, and the `values` array contains only "matchLabels.<value>". The requirements are ANDed. | Use one of `matchExpressions` or `matchLabels` |

#### Subject parameter examples

Given the following YAML, the `Deployment` named `mysubject` in the `default`
namespace is selected:

```yaml
apiVersion: sources.knative.dev/v1
kind: SinkBinding
metadata:
  name: bind-heartbeat
spec:
  subject:
    apiVersion: apps/v1
    kind: Deployment
    namespace: default
    name: mysubject
  ...
```

Given the following YAML, any `Job` with the label `working=example` in the
`default` namespace is selected:

```yaml
apiVersion: sources.knative.dev/v1
kind: SinkBinding
metadata:
  name: bind-heartbeat
spec:
  subject:
    apiVersion: batch/v1
    kind: Job
    namespace: default
    selector:
      matchLabels:
        working: example
  ...
```

Given the following YAML, any `Pod` with the label `working=example` OR
`working=sample` in the ` default` namespace is selected:

```yaml
apiVersion: sources.knative.dev/v1
kind: SinkBinding
metadata:
  name: bind-heartbeat
spec:
  subject:
    apiVersion: v1
    kind: Pod
    namespace: default
    selector:
      - matchExpression:
        key: working
        operator: In
        values:
          - example
          - sample
  ...
```

### CloudEvent Overrides

CloudEvent Overrides defines overrides to control the output format and
modifications of the event sent to the sink.

A `ceOverrides` definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| `extensions` | Specifies which attributes are added or overridden on the outbound event. Each `extensions` key-value pair is set independently on the event as an attribute extension. | Optional  |

!!! note
    Only valid [CloudEvent attribute names][cloudevents-attribute-naming] are
    allowed as extensions. You cannot set the spec defined attributes from
    the extensions override configuration. For example, you can not modify the
    `type` attribute.

#### CloudEvent Overrides example

```yaml
apiVersion: sources.knative.dev/v1
kind: SinkBinding
metadata:
  name: bind-heartbeat
spec:
  ...
  ceOverrides:
    extensions:
      extra: this is an extra attribute
      additional: 42
```

!!! contract
    This results in the `K_CE_OVERRIDES` environment variable being set on the
    `subject` as follows:
    ```{ .json .no-copy }
    { "extensions": { "extra": "this is an extra attribute", "additional": "42" } }
    ```

[kubernetes-overview]:
  https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/#required-fields
[kubernetes-kinds]:
  https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
[kubernetes-names]:
  https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
[kubernetes-namespaces]:
  https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
[cloudevents-attribute-naming]:
  https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#attribute-naming-convention
