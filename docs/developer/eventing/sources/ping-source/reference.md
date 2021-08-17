# PingSource reference

This topic provides reference information about the configurable fields for the
PingSource object.


## PingSource

A PingSource definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| [`apiVersion`][kubernetes-overview] | Specifies the API version, for example `sources.knative.dev/v1`. | Required |
| [`kind`][kubernetes-overview] | Identifies this resource object as a PingSource object. | Required |
| [`metadata`][kubernetes-overview] | Specifies metadata that uniquely identifies the PingSource object. For example, a `name`. | Required |
| [`spec`][kubernetes-overview] | Specifies the configuration information for this PingSource object. | Required |
| `spec.contentType`| The media type of `data` or `dataBase64`. Default is empty. | Optional |
| `spec.data` | The data used as the body of the event posted to the sink. Default is empty. Mutually exclusive with `dataBase64`. | Required if not sending base64 encoded data |
| `spec.dataBase64` | A base64-encoded string of the actual event's body posted to the sink. Default is empty. Mutually exclusive with `data`. | Required if sending base64 encoded data |
| `spec.schedule` | Specifies the cron schedule. Defaults to `* * * * *`. | Optional |
| [`spec.sink`](#sink-parameter) | A reference to an object that resolves to a URI to use as the sink. | Required |
| `spec.timezone` | Modifies the actual time relative to the specified timezone. Defaults to the system time zone. <br><br> See the [list of valid tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) on Wikipedia. For general information about time zones, see the [IANA](https://www.iana.org/time-zones) website.  | Optional |
| [`spec.ceOverrides`](#cloudevent-overrides) | Defines overrides to control the output format and modifications to the event sent to the sink. | Optional |


### Sink parameter

The `sink` parameter is a reference to an object that resolves to a URI to use as the sink.

A `sink` definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| `ref` | This points to an Addressable. | Required if _not_ using `uri`  |
| `ref.apiVersion` | API version of the referent. | Required if using `ref` |
| [`ref.kind`][kubernetes-kinds] | Kind of the referent. | Required if using `ref` |
| [`ref.name`][kubernetes-names] | Name of the referent. | Required if using `ref` |
| [`ref.namespace`][kubernetes-namespaces] | Namespace of the referent. If omitted this defaults to the object holding it. | Optional |
| `uri` | This can be an absolute URL with a non-empty scheme and non-empty host that points to the target or a relative URI. Relative URIs are resolved using the base URI retrieved from Ref. | Required if _not_ using `ref` |

!!! note
    At least one of `ref` or `uri` is required. If both are specified, `uri` is
    resolved into the URL from the Addressable `ref` result.

#### Example: sink parameter

Given the following YAML, if `ref` resolves into
`"http://mysink.default.svc.cluster.local"`, then `uri` is added to this
resulting in `"http://mysink.default.svc.cluster.local/extra/path"`.

<!-- TODO we should have a page to point to describing the ref+uri destinations and the rules we use to resolve those and reuse the page. -->

```yaml
apiVersion: sources.knative.dev/v1
kind: PingSource
metadata:
  name: test-heartbeats
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
    This results in the `K_SINK` environment variable being set as
    `"http://mysink.default.svc.cluster.local/extra/path"`.  <!-- unsure about this -->


### CloudEvent Overrides

CloudEvent Overrides defines overrides to control the output format and
modifications of the event sent to the sink.

A `ceOverrides` definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| `extensions` | Specifies which attributes are added or overridden on the outbound event. Each `extensions` key-value pair is set independently on the event as an attribute extension. | Optional  |

!!! note
    Only valid [CloudEvent attribute names][cloudevents-attribute-naming]
    are allowed as extensions. You cannot set the spec defined attributes from
    the extensions override configuration. For example, you can not modify the
    `type` attribute.

#### Example: CloudEvent Overrides

```yaml
apiVersion: sources.knative.dev/v1
kind: PingSource
metadata:
  name: test-heartbeats
spec:
  ...
  ceOverrides:
    extensions:
      extra: this is an extra attribute
      additional: 42
```

!!! contract
    This results in the `K_CE_OVERRIDES` environment variable being set on the
    `subject` as follows: <!-- unsure about this -->
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
  https://github.com/cloudevents/spec/blob/v1.0.1/spec.md#attribute-naming-convention
