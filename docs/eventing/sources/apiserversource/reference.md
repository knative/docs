# ApiServerSource reference

![version](https://img.shields.io/badge/API_Version-v1-red?style=flat-square)

This topic provides reference information about the configurable fields for the
ApiServerSource object.


## ApiServerSource

An ApiServerSource definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| [`apiVersion`][kubernetes-overview] | Specifies the API version, for example `sources.knative.dev/v1`. | Required |
| [`kind`][kubernetes-overview] | Identifies this resource object as an ApiServerSource object. | Required |
| [`metadata`][kubernetes-overview] | Specifies metadata that uniquely identifies the ApiServerSource object. For example, a `name`. | Required |
| [`spec`][kubernetes-overview] | Specifies the configuration information for this ApiServerSource object. | Required |
| `spec.mode` | EventMode controls the format of the event. Set to `Reference` to send a `dataref` event type for the resource being watched. In this case, only a reference to the resource will be included in the event payload. Set to `Resource` to have the full resource lifecycle event in the payload. Defaults to `Reference`. | Optional |
| [`spec.owner`](#owner-parameter) | ResourceOwner is an additional filter to only track resources that are owned by a specific resource type. If ResourceOwner matches Resources[n] then Resources[n] is allowed to pass the ResourceOwner filter. | Optional |
| [`spec.resources`](#resources-parameter) | The resources that the source tracks so it can send related lifecycle events from the Kubernetes ApiServer. Includes an optional label selector to help filter. | Required |
| `spec.serviceAccountName` | The name of the ServiceAccount to use to run this source. Defaults to `default` if not set. | Optional |
| [`spec.sink`](#sink-parameter) | A reference to an object that resolves to a URI to use as the sink. | Required |
| [`spec.ceOverrides`](#cloudevent-overrides) | Defines overrides to control the output format and modifications to the event sent to the sink. | Optional |


### Owner parameter

ResourceOwner is an additional filter to only track resources that are owned by
a specific resource type. If ResourceOwner matches Resources[n] then Resources[n]
is allowed to pass the ResourceOwner filter.

An `owner` definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| `apiVersion` | API version of the resource to watch. | Required |
| [`kind`][kubernetes-kinds] | Kind of the resource to watch More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds. | Required |

#### Example: Owner parameter

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
 name: <apiserversource>
 namespace: <namespace>
spec:
  ...
  owner:
    apiVersion: apps/v1
    kind: Deployment
  ...
```


### Resources parameter

The `resources` parameter specifies the resources that the source tracks so that
it can send related lifecycle events from the Kubernetes ApiServer.
The parameter includes an optional label selector to help filter.

A `resources` definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| `apiVersion` | API version of the resource to watch. | Required |
| [`kind`][kubernetes-kinds] | Kind of the resource to watch. | Required |
| [`selector`] | LabelSelector Filters this source to objects to those resources pass the label selector. More info: http://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors | Optional |
| `selector.matchExpressions` | A list of label selector requirements. The requirements are ANDed. | Use one of `matchExpressions` or `matchLabels` |
| `selector.matchExpressions.key` | The label key that the selector applies to. | Required if using `matchExpressions` |
| `selector.matchExpressions.operator` | Represents a key's relationship to a set of values. Valid operators are `In`, `NotIn`, `Exists` and `DoesNotExist`. | Required if using `matchExpressions` |
| `selector.matchExpressions.values` | An array of string values. If `operator` is `In` or `NotIn`, the values array must be non-empty. If `operator` is `Exists` or `DoesNotExist`, the values array must be empty. This array is replaced during a strategic merge patch. | Required if using `matchExpressions` |
| `selector.matchLabels` | A map of key-value pairs. Each key-value pair in the `matchLabels` map is equivalent to an element of `matchExpressions`, where the key field is `matchLabels.<key>`, the `operator` is `In`, and the `values` array contains only "matchLabels.<value>". The requirements are ANDed. | Use one of `matchExpressions` or `matchLabels` |

#### Example: Resources parameter

Given the following YAML, the ... is selected:

```yaml
# add example here
```

#### Example: Resources parameter using matchExpressions

Given the following YAML, the ... is selected:

```yaml
# add example here
```
#### Example: Resources parameter using matchLabels

Given the following YAML, the ... is selected:

```yaml
# add example here
```


### Sink parameter

Sink is a reference to an object that resolves to a URI to use as the sink.

A `sink` definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| `ref` | This points to an Addressable. | Required if _not_ using `uri`  |
| `ref.apiVersion` | API version of the referent. | Required if using `ref` |
| [`ref.kind`][kubernetes-kinds] | Kind of the referent. | Required if using `ref` |
| [`ref.namespace`][kubernetes-namespaces] | Namespace of the referent. If omitted this defaults to the object holding it. | Optional |
| [`ref.name`][kubernetes-names] | Name of the referent. | Required if using `ref` |
| `uri` | This can be an absolute URL with a non-empty scheme and non-empty host that points to the target or a relative URI. Relative URIs are resolved using the base URI retrieved from Ref. | Required if _not_ using `ref` |

!!! note
    At least one of `ref` or `uri` is required. If both are specified, `uri` is
    resolved into the URL from the Addressable `ref` result.

#### Example: Sink parameter

Given the following YAML, if `ref` resolves into
`"http://mysink.default.svc.cluster.local"`, then `uri` is added to this
resulting in `"http://mysink.default.svc.cluster.local/extra/path"`.

<!-- TODO we should have a page to point to describing the ref+uri destinations and the rules we use to resolve those and reuse the page. -->

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
 name: <apiserversource>
 namespace: <namespace>
spec:
  ...
  sink:
    ref:
      apiVersion: v1
      kind: Service
      namespace: default
      name: mysink
    uri: /extra/path
```

!!! contract
    This results in the `K_SINK` environment variable being set on the `subject`
    as `"http://mysink.default.svc.cluster.local/extra/path"`.


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

#### Example: CloudEvent Overrides

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
 name: <apiserversource>
 namespace: <namespace>
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

```json
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
  https://github.com/cloudevents/spec/blob/v1.0.1/spec.md#attribute-naming-convention
