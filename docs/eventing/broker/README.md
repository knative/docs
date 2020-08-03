Knative provides a multi-tenant, channel-based broker implementation that uses channels for event routing.

Before you can use the Knative Channel-based Broker, you must install a channel provider, such as InMemoryChannel, Kafka or Nats.

**NOTE:** InMemoryChannel channels are for development use only and must not be used in a production deployment.

For more information on which channels are available and how to install them,
see the list of [available channels](https://knative.dev/docs/eventing/channels/channels-crds/).

## How it works
<!--TODO: Add a diagram that shows this-->
When an Event is sent to the Broker, all request metadata other than the CloudEvent data and context attributes is stripped away.
Unless the information existed as a `CloudEvent` attribute, no information is retained about how this Event entered the Broker.

Once an Event has entered the Broker, it can be forwarded to event Channels by using subscrbers and Triggers.
This event delivery mechanism hides details of event routing from the event producer and event consumer.

Triggers register a subscriber's interest in a particular class of events, so that the subscriber's event sink will receive events that match the Trigger's filter.

## Default Broker configuration

Knative Eventing provides a `config-br-defaults` ConfigMap, which lives in the `knative-eventing` namespace, and provides default configuration settings to enable the creation of multi-tenant Brokers and InMemoryChannel type Channels.
<!-- TODO: Add link to Channel docs-->
**NOTE:** If you are using a different Broker or Channel implementation, you will need to modify the ConfigMap accordingly. For more information, see the [`config-br-defaults`](./config-br-defaults.md) ConfigMap documentation.

Create a Broker using the default settings:

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
  name: default
  namespace: default
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
EOF
```

## Next steps

After you have created a Broker, you can complete the following tasks to finish setting up event delivery.

### Subscriber

Create a function to receive events. This document uses a Knative Service, but
it could be anything that is
[Callable](https://github.com/knative/eventing/blob/master/docs/spec/interfaces.md).

```shell
kubectl create -f - <<EOF
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: my-service
  namespace: default
spec:
  template:
    spec:
      containers:
      -  # This corresponds to
         # https://github.com/knative/eventing-contrib/tree/master/cmd/event_display
         image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display
EOF
```

### Trigger

Create a `Trigger` that sends only events of a particular type to the subscriber
created above (`my-service`). For this example, we use Ping Source, and it
emits events types `dev.knative.sources.ping`.

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: my-service-trigger
  namespace: default
spec:
  broker: default
  filter:
    attributes:
      type: dev.knative.sources.ping
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
EOF
```

### Emitting Events using Ping Source

Knative Eventing comes with a [Ping Source](../samples/ping-source/README.md) which
emits an event on a configured schedule. For this we'll configure it to emit
events once a minute, saying, yes, you guessed it `Hello World!`.

```shell
kubectl create -f - <<EOF
apiVersion: sources.knative.dev/v1alpha2
kind: PingSource
metadata:
  name: test-ping-source
spec:
  schedule: "*/1 * * * *"
  jsonData: '{"message": "Hello world!"}'
  sink:
    ref:
      # Deliver events to Broker.
      apiVersion: eventing.knative.dev/v1
      kind: Broker
      name: default
EOF
```

The following example is more complex, and demonstrates the use of `deadLetterSink` configuration to send failed events to Knative Service called `dlq-service`:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  annotations:
    eventing.knative.dev/broker.class: MTChannelBasedBroker
  name: default
spec:
  # Configuration specific to this broker.
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
  # Where to deliver Events that failed to be processed.
  delivery:
    deadLetterSink:
      ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: dlq-service
```
