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
[MT Channel Based Broker](./mt-channel-based-broker.md). Simple example showing a `Broker`
where the configuration is specified in a `ConfigMap` config-br-default-channel,
which uses `InMemoryChannel`:

Example:

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
```

More complex example, showing the same `Broker` as above
but with failed events being delivered to Knative Service called `dlq-service`

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

### Creating a broker using defaults

Knative Eventing provides a `ConfigMap` which by default lives in
`knative-eventing` namespace and is called `default-br-config`. Out of the box
it comes configured to create
[MT Channel Based Brokers](./mt-channel-based-broker.md). If you are using a
different Broker implementation, you should modify the `ConfigMap`
accordingly. You can read more details on how to use
[default-br-config config map ](./defaults-br-config.md)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-br-defaults
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: v0.16.0
data:
  # Configuration for defaulting channels that do not specify CRD implementations.
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: config-br-default-channel
      namespace: knative-eventing
```

With this ConfigMap, any Broker created will be configured to use
MTChannelBasedBroker and the `Broker.Spec.Config` will be configured as
specified in the clusterDefault configuration. So, example below will create a
`Broker` called default in default namespace and uses MTChannelBasedBroker as
implementation.

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: default
  namespace: default
EOF
```

The defaults specified in the `defaults-br-config` will result in a following
Broker being created.

```yaml
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
```

To see the created `Broker`, you can get it like this:

```shell
kubectl get brokers default
```

```shell
kubectl get brokers default
NAME      READY   REASON   URL                                                                        AGE
default   True             http://broker-ingress.knative-eventing.svc.cluster.local/default/default   56m
```

Note the `URL` field where you can send `CloudEvent`s andthen use `Trigger`s to
route them to your functions.

To delete the `Broker`:

```shell
kubectl delete broker default
```

## Trigger

A Trigger represents a desire to subscribe to events from a specific Broker.

Simple example which will receive all the events from the given (`default`) broker and
deliver them to Knative Serving service `my-service`:

```shell
kubectl create -f - <<EOF
apiVersion: eventing.knative.dev/v1
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
EOF
```

### Trigger Filtering

Exact match filtering on any number of CloudEvents attributes as well as
extensions are supported. If your filter sets multiple attributes, an event must
have all of the attributes for the Trigger to filter it. Note that we only
support exact matching on string values. 

Example:

```shell
kubectl create -f - <<EOF
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
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: my-service
EOF
```

The example above filters events from the `default` Broker that are of type
`dev.knative.foo.bar` AND have the extension `myextension` with the value
`my-extension-value`. 

## Complete end-to-end example
<!-- TODO: review + clean this section up-->

### Broker setup

We assume that you have installed a Broker in namespace `default`. If you
haven't done that yet, [install it from here](./mt-channel-based-broker.md).

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
