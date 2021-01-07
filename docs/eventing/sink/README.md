
A sink is an Addressable resource that acts as a link
between the Eventing mesh and an entity or system.

We can connect any source to a sink, such as `PingSource` and `KafkaSink` objects:

```yaml
apiVersion: sources.knative.dev/v1beta1
kind: PingSource
metadata:
  name: test-ping-source
spec:
  schedule: "*/1 * * * *"
  jsonData: '{"message": "Hello world!"}'
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: KafkaSink
      name: my-kafka-sink
```

We can connect a `Trigger` object to a sink, so that we can filter events, before sending them to a sink:

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
      apiVersion: eventing.knative.dev/v1alpha1
      kind: KafkaSink
      name: my-kafka-sink
```

## Knative Sinks

| Name | Maintainer | Description |
| -- | -- | -- |
| [KafkaSink](./kafka-sink.md)  | Knative  | Send events to a Kafka topic |
| [RedisSink](https://github.com/knative-sandbox/eventing-redis/tree/master/sink)  | Knative  | Send events to a Redis Stream |
