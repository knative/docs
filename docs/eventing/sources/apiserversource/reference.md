# ApiServerSource reference

![version](https://img.shields.io/badge/API_Version-v1-green?style=flat-square)

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
| [`spec.resources`](#resources-parameter) | The resources that the source tracks so it can send related lifecycle events from the Kubernetes ApiServer. Includes an optional label selector to help filter. | Required |
| `spec.mode` | EventMode controls the format of the event. Set to `Reference` to send a `dataref` event type for the resource being watched. Only a reference to the resource is included in the event payload. Set to `Resource` to have the full resource lifecycle event in the payload. Defaults to `Reference`. | Optional |
| [`spec.owner`](#owner-parameter) | ResourceOwner is an additional filter to only track resources that are owned by a specific resource type. If ResourceOwner matches Resources[n] then Resources[n] is allowed to pass the ResourceOwner filter. | Optional |
| [`spec.serviceAccountName`](#serviceaccountname-parameter) | The name of the ServiceAccount to use to run this source. Defaults to `default` if not set. | Optional |
| [`spec.sink`](../../sinks/README.md#sink-as-a-parameter) | A reference to an object that resolves to a URI to use as the sink. | Required |
| [`spec.ceOverrides`](#cloudevent-overrides) | Defines overrides to control the output format and modifications to the event sent to the sink. | Optional |
| [`spec.namespaceSelector`](#namespaceselector-parameter) | Specifies a label selector to track multiple namespaces. If unspecified, the namespace of the ApiServerSource will be tracked. | Optional |

### Resources parameter

The `resources` parameter specifies the resources that the source tracks so that
it can send related lifecycle events from the Kubernetes ApiServer.
The parameter includes an optional label selector to help filter.

A `resources` definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| `apiVersion` | API version of the resource to watch. | Required |
| [`kind`][kubernetes-kinds] | Kind of the resource to watch. | Required |
| [`selector`][label-selectors] | LabelSelector filters this source to objects to those resources pass the label selector. <!-- unsure what this means --> | Optional |
| `selector.matchExpressions` | A list of label selector requirements. The requirements are ANDed. | Use one of `matchExpressions` or `matchLabels` |
| `selector.matchExpressions.key` | The label key that the selector applies to. | Required if using `matchExpressions` |
| `selector.matchExpressions.operator` | Represents a key's relationship to a set of values. Valid operators are `In`, `NotIn`, `Exists` and `DoesNotExist`. | Required if using `matchExpressions` |
| `selector.matchExpressions.values` | An array of string values. If `operator` is `In` or `NotIn`, the values array must be non-empty. If `operator` is `Exists` or `DoesNotExist`, the values array must be empty. This array is replaced during a strategic merge patch. | Required if using `matchExpressions` |
| `selector.matchLabels` | A map of key-value pairs. Each key-value pair in the `matchLabels` map is equivalent to an element of `matchExpressions`, where the key field is `matchLabels.<key>`, the `operator` is `In`, and the `values` array contains only "matchLabels.<value>". The requirements are ANDed. | Use one of `matchExpressions` or `matchLabels` |

#### Example: Resources parameter

Given the following YAML, the ApiServerSource object receives events for all Pods
and Deployments in the namespace:

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
  name: <apiserversource>
  namespace: <namespace>
spec:
  # ...
  resources:
    - apiVersion: v1
      kind: Pod
    - apiVersion: apps/v1
      kind: Deployment
```

#### Example: Resources parameter using matchExpressions

Given the following YAML, ApiServerSource object receives events for all Pods in
the namespace that have a label `app=myapp` or `app=yourapp`:

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
  name: <apiserversource>
  namespace: <namespace>
spec:
  # ...
  resources:
    - apiVersion: v1
      kind: Pod
      selector:
        matchExpressions:
          - key: app
            operator: In
            values:
              - myapp
              - yourapp
```

#### Example: Resources parameter using matchLabels

Given the following YAML, the ApiServerSource object receives events for all Pods
in the namespace that have a label `app=myapp`:

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
  name: <apiserversource>
  namespace: <namespace>
spec:
  # ...
  resources:
    - apiVersion: v1
      kind: Pod
      selector:
        matchLabels:
          app: myapp
```

### ServiceAccountName parameter

ServiceAccountName is a reference to a Kubernetes service account.

To track the lifecycle events of the specified [`resources`](#resources-parameter),
you must assign the proper permissions to the ApiServerSource object.

#### Example: tracking Pods

The following YAML files create a ServiceAccount, Role and RoleBinding
and grant the permission to get, list and watch Pod resources in the namespace
`apiserversource-example` for the ApiServerSource.

Example ServiceAccount:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: test-service-account
  namespace: apiserversource-example
```

Example Role with permission to get, list and watch Pod resources:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: test-role
rules:
  - apiGroups:
    - ""
    resources:
    - pods
    verbs:
    - get
    - list
    - watch
```

Example RoleBinding:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: test-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: test-role
subjects:
  - kind: ServiceAccount
    name: test-service-account
    namespace: apiserversource-example
```

Example ApiServerSource using `test-service-account`:

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
 name: test-apiserversource
 namespace: apiserversource-example
spec:
  # ...
  serviceAccountName: test-service-account
  ...
```

### Owner parameter

ResourceOwner is an additional filter to only track resources that are owned by
a specific resource type. If ResourceOwner matches Resources[n] then Resources[n]
is allowed to pass the ResourceOwner filter.

An `owner` definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| `apiVersion` | API version of the resource to watch. | Required |
| [`kind`][kubernetes-kinds] | Kind of the resource to watch. | Required |

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

### NamespaceSelector parameter

The NamespaceSelector is an optional label selector that can be utilized to target more than one namespace. If the selector is unset, the namespace of the ApiServerSource will be tracked.

A `namespaceSelector` supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| `matchExpressions` | A list of label selector requirements. The requirements are ANDed. | Use one of `matchExpressions` or `matchLabels` |
| `matchExpressions.key` | The label key that the selector applies to. | Required if using `matchExpressions` |
| `matchExpressions.operator` | Represents a key's relationship to a set of values. Valid operators are `In`, `NotIn`, `Exists` and `DoesNotExist`. | Required if using `matchExpressions` |
| `matchExpressions.values` | An array of string values. If `operator` is `In` or `NotIn`, the values array must be non-empty. If `operator` is `Exists` or `DoesNotExist`, the values array must be empty. This array is replaced during a strategic merge patch. | Required if using `matchExpressions` |
| `matchLabels` | A map of key-value pairs. Each key-value pair in the `matchLabels` map is equivalent to an element of `matchExpressions`, where the key field is `matchLabels.<key>`, the `operator` is `In`, and the `values` array contains only "matchLabels.<value>". The requirements are ANDed. | Use one of `matchExpressions` or `matchLabels` |

#### Example: Target multiple namespaces with matchExpressions

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
 name: <apiserversource>
 namespace: <namespace>
spec:
  ...
  namespaceSelector:
    matchExpressions:
      - key: environment
        operator: In
        values:
          - production
          - development
  ...
```

#### Example: Target multiple namespaces with matchLabels

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
 name: <apiserversource>
 namespace: <namespace>
spec:
  ...
  namespaceSelector:
    matchLabels:
      environment: production
  ...
```

#### Example: Target all namespaces with an empty selector

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
 name: <apiserversource>
 namespace: <namespace>
spec:
  ...
  namespaceSelector: {}
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
    sink container as follows:

```json
{ "extensions": { "extra": "this is an extra attribute", "additional": "42" } }
```

[kubernetes-overview]:
  https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/#required-fields
[kubernetes-kinds]:
  https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
[label-selectors]:
  http://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
[cloudevents-attribute-naming]:
  https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#attribute-naming-convention
