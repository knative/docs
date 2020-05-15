We are going to create the following logical configuration. We create a
PingSource, feeding events into the Broker, then we create a `Filter` that
wires those events into a [`Sequence`](../../../flows/sequence.md) consisting of 3
steps. Then we take the end of the Sequence and feed newly minted events back
into the Broker and create another Trigger which will then display those events.

## Prerequisites

For this example, we'll assume you have set up an `InMemoryChannel` as well as Knative Serving (for our functions). The examples
use `default` namespace, again, if your broker lives in another Namespace, you
will need to modify the examples to reflect this.

If you want to use different type of `Channel`, you will have to modify the
`Sequence.Spec.ChannelTemplate` to create the appropriate Channel resources.

![Logical Configuration](./sequence-with-broker-trigger.png)

The functions used in these examples live in
[https://github.com/knative/eventing-contrib/blob/master/cmd/appender/main.go](https://github.com/knative/eventing-contrib/blob/master/cmd/appender/main.go).

## Setup

### Creating the Broker

The easiest way to create a Broker is to annotate your namespace:

```shell
kubectl label namespace default knative-eventing-injection=enabled
```

### Create the Knative Services

Change `default` below to create the steps in the Namespace where you have
configured your `Broker`

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: first
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/appender
          env:
            - name: MESSAGE
              value: " - Handled by 0"

---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: second
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/appender
          env:
            - name: MESSAGE
              value: " - Handled by 1"
---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: third
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/appender
          env:
            - name: MESSAGE
              value: " - Handled by 2"

---

```

```shell
kubectl -n default create -f ./steps.yaml
```

### Create the Sequence

The `sequence.yaml` file contains the specifications for creating the Sequence.
If you are using a different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel.

Also, change the spec.reply.name to point to your `Broker`

```yaml
apiVersion: flows.knative.dev/v1beta1
kind: Sequence
metadata:
  name: sequence
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1beta1
    kind: InMemoryChannel
  steps:
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: first
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: second
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: third
  reply:
    ref:
      kind: Broker
      apiVersion: eventing.knative.dev/v1beta1
      name: default
```

Change `default` below to create the `Sequence` in the Namespace where you have
configured your `Broker`.

```shell
kubectl -n default create -f ./sequence.yaml
```

### Create the PingSource targeting the Broker

This will create a PingSource which will send a CloudEvent with {"message":
"Hello world!"} as the data payload every 2 minutes.

```yaml
apiVersion: sources.knative.dev/v1alpha2
kind: PingSource
metadata:
  name: ping-source
spec:
  schedule: "*/2 * * * *"
  jsonData: '{"message": "Hello world!"}'
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1beta1
      kind: Broker
      name: default
```

Here, if you are using different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel. Also, change the
spec.reply.name to point to your `Broker`

Change `default` below to create the `Sequence` in the Namespace where you have
configured your `Broker`.

```shell
kubectl -n default create -f ./ping-source.yaml
```

### Create the Trigger targeting the Sequence

```yaml
apiVersion: eventing.knative.dev/v1beta1
kind: Trigger
metadata:
  name: sequence-trigger
spec:
  filter:
    attributes:
      type: dev.knative.sources.ping
  subscriber:
    ref:
      apiVersion: flows.knative.dev/v1beta1
      kind: Sequence
      name: sequence
```

Change `default` below to create the `Sequence` in the Namespace where you have
configured your `Broker`.

```shell
kubectl -n default create -f ./trigger.yaml

```

### Create the Service and Trigger displaying the events created by Sequence

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: sequence-display
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/appender
---
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: display-trigger
spec:
  filter:
    attributes:
      type: samples.http.mod3
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: sequence-display
---

```

Change `default` below to create the `Service` and `Trigger` in the Namespace
where you have configured your `Broker`.

```shell
kubectl -n default create -f ./display-trigger.yaml
```

### Inspecting the results

You can now see the final output by inspecting the logs of the event-display
pods.

```shell
kubectl -n default get pods
```

Then look at the logs for the event-display pod:

```shell
kubectl -n default logs -l serving.knative.dev/service=sequence-display -c user-container --tail=-1
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: samples.http.mod3
  source: /apis/v1/namespaces/default/pingsources/ping-source
  id: 159bba01-054a-4ae7-b7be-d4e7c5f773d2
  time: 2020-03-03T14:56:00.000652027Z
  datacontenttype: application/json
Extensions,
  knativearrivaltime: 2020-03-03T14:56:00.018390608Z
  knativehistory: default-kne-trigger-kn-channel.default.svc.cluster.local; sequence-kn-sequence-0-kn-channel.default.svc.cluster.local; sequence-kn-sequence-1-kn-channel.default.svc.cluster.local; sequence-kn-sequence-2-kn-channel.default.svc.cluster.local; default-kne-trigger-kn-channel.default.svc.cluster.local
  traceparent: 00-e893412106ff417a90a5695e53ffd9cc-5829ae45a14ed462-00
Data,
  {
    "id": 0,
    "message": "Hello world! - Handled by 0 - Handled by 1 - Handled by 2"
  }
```

And you can see that the initial PingSource message `{"Hello World!"}` has been
appended to it by each of the steps in the Sequence.
