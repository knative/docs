# ContainerSource reference

![API version v1](https://img.shields.io/badge/API_Version-v1-green?style=flat-square)

This topic provides reference information about the configurable fields for the
ContainerSource object.


## ContainerSource

A ContainerSource definition supports the following fields:

| Field | Description | Required or optional |
|-------|-------------|----------------------|
| [`apiVersion`][kubernetes-overview] | Specifies the API version, for example `sources.knative.dev/v1`. | Required |
| [`kind`][kubernetes-overview] | Identifies this resource object as a ContainerSource object. | Required |
| [`metadata`][kubernetes-overview] | Specifies metadata that uniquely identifies the ContainerSource object. For example, a `name`. | Required |
| [`spec`][kubernetes-overview] | Specifies the configuration information for this ContainerSource object. | Required |
| [`spec.sink`](../../sinks/README.md#sink-as-a-parameter) | A reference to an object that resolves to a URI to use as the sink. | Required |
| [`spec.template`](#template-parameter) | A `template` in the shape of `Deployment.spec.template` to be used for this ContainerSource. | Required |
| [`spec.ceOverrides`](#cloudevent-overrides) | Defines overrides to control the output format and modifications to the event sent to the sink. | Optional |


### Template parameter

This is a `template` in the shape of `Deployment.spec.template` to use for the ContainerSource.
For more information, see the [Kubernetes Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

<!-- not sure what the required and optional fields are for this. -->

#### Example: template parameter

```yaml
apiVersion: sources.knative.dev/v1
kind: ContainerSource
metadata:
  name: test-heartbeats
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-nightly/knative.dev/eventing/cmd/heartbeats
          name: heartbeats
          args:
            - --period=1
          env:
            - name: POD_NAME
              value: "mypod"
            - name: POD_NAMESPACE
              value: "event-test"
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
    Only valid [CloudEvent attribute names][cloudevents-attribute-naming]
    are allowed as extensions. You cannot set the spec defined attributes from
    the extensions override configuration. For example, you can not modify the
    `type` attribute.

#### Example: CloudEvent Overrides

```yaml
apiVersion: sources.knative.dev/v1
kind: ContainerSource
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
[cloudevents-attribute-naming]:
  https://github.com/cloudevents/spec/blob/v1.0.2/cloudevents/spec.md#attribute-naming-convention
