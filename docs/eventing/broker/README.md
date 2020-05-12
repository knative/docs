Broker and Trigger are CRDs providing an event delivery mechanism that hides the
details of event routing from the event producer and event consumer.

## Broker

A Broker represents an 'event mesh'. Events are sent to the Broker's ingress and
are then sent to any subscribers that are interested in that event. Once inside
a Broker, all metadata other than the CloudEvent is stripped away (e.g. unless
set as a CloudEvent attribute, there is no concept of how this event entered the
Broker).

There can be different classes of Brokers providing different kinds
of semantics around durability of events, performance, etc. The Broker that is
part of the Knative Eventing repo is used for these examples, it uses Knative
[Channels](../channels/) for delivering events. You can read more details about
[Channel Based Broker](./channel-based-broker.md). Simple example showing a `Broker`
where the configuration is specified in a `ConfigMap` config-br-default-channel,
which uses `InMemoryChannel`:

Example:

```yaml
apiVersion: eventing.knative.dev/v1beta1
kind: Broker
metadata:
  name: default
spec:
  # Configuration specific to this broker.
  config:
    apiVersion: v1
    kind: ConfigMap
    name: config-br-default-channel
    namespace: knative-eventing
```

More complex example, showing the same `Broker` as above
but with failed events being delivered to Knative Service called `dlq-service`

```yaml
apiVersion: eventing.knative.dev/v1beta1
kind: Broker
metadata:
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

## Trigger

A Trigger represents a desire to subscribe to events from a specific Broker.

Simple example which will receive all the events from the given (`default`) broker and
deliver them to Knative Serving service `my-service`:

```yaml
apiVersion: eventing.knative.dev/v1beta1
kind: Trigger
metadata:
  name: my-service-trigger
spec:
  broker: default
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

### Trigger Filtering

Exact match filtering on any number of CloudEvents attributes as well as extensions are
supported. If your filter sets multiple attributes, an event must have all of the attributes for the Trigger to filter it.
Note that we only support exact matching on string values.

Example:

```yaml
apiVersion: eventing.knative.dev/v1beta1
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
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

The example above filters events from the `default` Broker that are of type `dev.knative.foo.bar` AND
have the extension `myextension` with the value `my-extension-value`.

## Complete end-to-end example

### Broker setup

We assume that you have installed a Broker in namespace `default`. If you haven't done that
yet, [install it from here](./channel-based-broker.md).

### Subscriber

Create a function to receive events. This document uses a Knative Service, but
it could be anything that is [Callable](https://github.com/knative/eventing/blob/master/docs/spec/interfaces.md).

```yaml
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
         image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display@sha256:a214514d6ba674d7393ec8448dd272472b2956207acb3f83152d3071f0ab1911
```

### Trigger

Create a `Trigger` that sends only events of a particular type to the subscriber
created above (`my-service`). For this example, we use Ping Source, and it
emits events types `dev.knative.sources.ping`.

```yaml
apiVersion: eventing.knative.dev/v1beta1
kind: Trigger
metadata:
  name: my-service-trigger
  namespace: default
spec:
  filter:
    attributes:
      type: dev.knative.sources.ping
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

#### Defaulting

The Webhook will default the `spec.broker` field to `default`, if left
unspecified.

The Webhook will default the YAML above to:

```yaml
apiVersion: eventing.knative.dev/v1beta1
kind: Trigger
metadata:
  name: my-service-trigger
  namespace: default
spec:
  broker: default # Defaulted by the Webhook.
  filter:
    attributes:
      type: dev.knative.sources.ping
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
```

You can make multiple `Trigger`s on the same `Broker` corresponding to different
types, sources (or any other CloudEvents attribute), and subscribers.

### Emitting Events using Ping Source

Knative Eventing comes with a [Ping Source](../samples/ping-source/README.md) which
emits an event on a configured schedule. For this we'll configure it to emit
events once a minute, saying, yes, you guessed it `Hello World!`.

```yaml
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
      apiVersion: eventing.knative.dev/v1alpha1
      kind: Broker
      name: default
```
