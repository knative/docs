---
title: "Sink binding"
weight: 01
type: "docs"
aliases:
  - /docs/eventing/samples/sinkbinding/index
  - /docs/eventing/samples/sinkbinding/README
  - /docs/eventing/sources/sinkbinding.md
---

![API version v1](https://img.shields.io/badge/API_Version-v1-red?style=flat-square)

The `SinkBinding` custom object supports decoupling event production from
delivery addressing.

You can use a SinkBinding to direct an subject to an event sink. The _Subject_
is a Kubernetes resource that embeds a `PodSpec` template and produces events.
The _Event sink_ is an addressable Kubernetes object that can receive events.

To create new subjects you can use any of the compute objects that Kubernetes
makes available such as:

- `Deployment`
- `Job`
- `DaemonSet`
- `StatefulSet`

You can also create new subjects that use Knative abstractions, such as
`Service` or `Configuration` objects.

The SinkBinding injects environment variables into the `PodTemplateSpec` of the
event sink. Because of this, the application code does not need to interact
directly with the Kubernetes API to locate the event destination.

These environment variables as as follows:

- `K_SINK` - The url of the resolved event consumer.
- `K_CE_OVERRIDES` - A json object that specifies overrides to the outbound
  event.

## Configuring a `SinkBinding`

A `SinkBinding` definition supports the following fields:

- Required:
  - [`apiVersion`][kubernetes-overview] - Specifies the API version, for example
    `sources.knative.dev/v1`.
  - [`kind`][kubernetes-overview] - Identifies this resource object as a
    `SinkBinding` object.
  - [`metadata`][kubernetes-overview] - Specifies metadata that uniquely
    identifies the `SinkBinding` object. For example, a `name`.
  - [`spec`][kubernetes-overview] - Specifies the configuration information for
    this `SinkBinding` object. This must include:
    - [`sink`](#using-the-sink-parameter) - A reference to an object that will
      resolve to a uri to use as the sink.
    - [`subject`](#using-the-subject-parameter) - A reference to the resource(s)
      whose "runtime contract" should be augmented by Binding implementations.
- Optional:
  - `spec`
    - [`ceOverrides`](#using-cloudevent-overrides) - defines overrides to
      control the output format and modifications of the event sent to the sink.

### Using the Sink parameter

Sink is a reference to an object that will resolve to a uri to use as the sink.

A `sink` definition supports the following fields:

- `ref` - Ref points to an Addressable.
  - `apiVersion` API version of the referent.
  - [`kind`][kubernetes-kinds] - Kind of the referent.
  - [`namespace`][kubernetes-namespaces] - Namespace of the referent. This is
    optional field, it gets defaulted to the object holding it if leftout.
  - [`name`][kubernetes-names] - Name of the referent.
- `uri` - URI can be an absolute URL(non-empty scheme and non-empty host)
  pointing to the target or a relative URI. Relative URIs will be resolved using
  the base URI retrieved from Ref.

At least one [`ref`, `uri`] is required, and if both are specified, `uri` will
be resolved into the url from the Addressable `ref` result.

Example, given:

```yaml
sink:
  ref:
    apiVersion: v1
    kind: Service
    namespace: default
    name: mysink
  uri: /extra/path
```

If `ref` resolves into `"http://mysink.default.svc.cluster.local"`, then `uri`
is added to this resulting in
`"http://mysink.default.svc.cluster.local/extra/path"`.

This will result in the `K_SINK` environment variable to be set on the `subject`
as `"http://mysink.default.svc.cluster.local/extra/path"`.

<!-- TODO we should have a page to point to describing the ref+uri destinations and the rules we use to resolve those and reuse the page. -->

### Using the Subject parameter

Subject references the resource(s) whose "runtime contract" should be augmented
by Binding implementations.

A `subject` definition supports the following fields:

- `apiVersion` API version of the referent.
- [`kind`][kubernetes-kinds] - Kind of the referent.
- [`namespace`][kubernetes-namespaces] - Namespace of the referent. This is
  optional field, it gets defaulted to the object holding it if leftout.
- [`name`][kubernetes-names] - Name of the referent.
- `selector` - Selector of the referents. Mutually exclusive with Name.
  - `matchExpressions` - A list of label selector requirements. The requirements
    are ANDed.
    - `key` - The label key that the selector applies to.
    - `operator` - Represents a key's relationship to a set of values. Valid
      operators are In, NotIn, Exists and DoesNotExist.
    - `values` - An array of string values. If the operator is In or NotIn, the
      values array must be non-empty. If the operator is Exists or DoesNotExist,
      the values array must be empty. This array is replaced during a strategic
      merge patch.
  - `matchLabels` - A map of `{key,value}` pairs. A single `{key,value}` in the
    matchLabels map is equivalent to an element of matchExpressions, whose key
    field is "key", the operator is "In", and the values array contains only
    "value". The requirements are ANDed.

Examples,

- The `Deployment` named `mysubject` in `default` namespace will be selected:

  ```yaml
  subject:
    apiVersion: apps/v1
    kind: Deployment
    namespace: default
    name: mysubject
  ```

- Any `Job` with the label `working=example` in the` default` namespace will be
  selected:

  ```yaml
  subject:
    apiVersion: batch/v1beta1
    kind: Job
    namespace: default
    selector:
      matchLabels:
        working: example
  ```

- Any `Pod` with the label `working=example` OR `working=sample` in
  the` default` namespace will be selected.:

  ```yaml
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
  ```

### Using CloudEvent Overrides

CloudEvent Overrides defines overrides to control the output format and
modifications of the event sent to the sink.

A `ceOverrides` definition supports the following fields:

- `extensions` - Specify what attribute are added or overridden on the outbound
  event. Each `Extensions` key-value pair are set on the event as an attribute
  extension independently.

**Note:** Only valid [CloudEvent attribute names][cloudevents-attribute-naming]
are allowed as extensions, and the spec defined attributes are not settable from
the extensions override configuration, an example: one can not modify the `type`
attribute.

```yaml
ceOverrides:
  extensions:
    extra: this is an extra attribute
    additional: 42
```

This will result in the `K_CE_OVERRIDES` environment variable to be set on the
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
