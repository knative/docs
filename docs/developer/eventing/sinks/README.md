# Event sinks

When you create an event source, you can specify a _sink_ where events are sent to from the source. A sink is an Addressable resource that can receive incoming events from other Knative Eventing resources. Knative Services, Channels, and Brokers are all examples of sinks.

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
    You can configure which resources can be used with the `--sink` flag for `kn` CLI commands by [Customizing kn](../../../../client/configure-kn/#customizing-kn).

## Supported third-party sink types

| Name | Maintainer | Description |
| -- | -- | -- |
| [KafkaSink](./kafka-sink.md)  | Knative  | Send events to a Kafka topic |
| [RedisSink](https://github.com/knative-sandbox/eventing-redis/tree/main/sink)  | Knative  | Send events to a Redis Stream |
