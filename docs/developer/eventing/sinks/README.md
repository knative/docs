# About sinks

When you create an event source, you can specify a _sink_ where events are sent to from the source. A sink is an Addressable resource that can receive incoming events from other resources. Knative Services, Channels, and Brokers are all examples of sinks.

You can also connect a Trigger to a sink, so that events are filtered before they are sent to the sink. A sink that is connected to a Trigger is configured as a `subscriber` in the Trigger resource spec.

For example:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: <trigger-name>
spec:
...
  subscriber:
    ref:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: KafkaSink
      name: <kafka-sink-name>
```

Where;

- `<trigger-name>` is the name of the Trigger being connected to the sink.
- `<kafka-sink-name>` is the name of a KafkaSink object.

## Sink as a parameter

Sink is used as a reference to an object that resolves to a URI to use as the sink.

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

### Sink parameter example

Given the following YAML, if `ref` resolves into
`"http://mysink.default.svc.cluster.local"`, then `uri` is added to this
resulting in `"http://mysink.default.svc.cluster.local/extra/path"`.

<!-- TODO we should have a page to point to describing the ref+uri destinations and the rules we use to resolve those and reuse the page. -->

```yaml
apiVersion: sources.knative.dev/v1
kind: SinkBinding
metadata:
  name: bind-heartbeat
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

## Using custom resources as sinks

To use a Kubernetes custom resource (CR) as a sink for events, you must:

1. Make the CR Addressable. You must ensure that the CR contains a `status.address.url`. For more information, see the spec for [Addressable resources](https://github.com/knative/specs/blob/main/specs/eventing/interfaces.md#addressable).

1. Create an Addressable-resolver ClusterRole to obtain the necessary RBAC rules for the sink to receive events.

    For example, you can create a `kafkasinks-addressable-resolver` ClusterRole to allow `get`, `list`, and `watch` access to KafkaSink objects and statuses:

    ```yaml
    kind: ClusterRole
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: kafkasinks-addressable-resolver
      labels:
        kafka.eventing.knative.dev/release: devel
        duck.knative.dev/addressable: "true"
    # Do not use this role directly. These rules will be added to the "addressable-resolver" role.
    rules:
      - apiGroups:
          - eventing.knative.dev
        resources:
          - kafkasinks
          - kafkasinks/status
        verbs:
          - get
          - list
          - watch
    ```

## Specifying sinks using the kn CLI --sink flag

When you create an event-producing CR by using the Knative (`kn`) CLI, you can specify a sink where events are sent to from that resource, by using the `--sink` flag.

The following example creates a SinkBinding that uses a Service, `http://event-display.svc.cluster.local`, as the sink:

```bash
kn source binding create bind-heartbeat \
  --namespace sinkbinding-example \
  --subject "Job:batch/v1:app=heartbeat-cron" \
  --sink http://event-display.svc.cluster.local \
  --ce-override "sink=bound"
```

The `svc` in `http://event-display.svc.cluster.local` determines that the sink is a Knative Service. Other default sink prefixes include Channel and Broker.

!!! tip
    You can configure which resources can be used with the `--sink` flag for `kn` CLI commands by [Customizing kn](../../../../client/configure-kn/#example-configuration-file).

## Supported third-party sink types

| Name | Maintainer | Description |
| -- | -- | -- |
| [KafkaSink](./kafka-sink.md)  | Knative  | Send events to a Kafka topic |
| [RedisSink](https://github.com/knative-sandbox/eventing-redis/tree/main/sink)  | Knative  | Send events to a Redis Stream |
