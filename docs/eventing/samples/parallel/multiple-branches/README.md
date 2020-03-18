We are going to create a Parallel with two branches:

- the first branch accepts events with a time that is is even
- the second branch accepts events with a time that is is odd

The events produced by each branch are then sent to the `event-display` service.

## Prerequisites

Please refer to the sample overview for the [prerequisites](../README.md).

### Create the Knative Services

Let's first create the filter and transformer services that we will use in our
Parallel.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: even-filter
spec:
  template:
    spec:
      containers:
      - image: villardl/filter-nodejs:0.1
        env:
        - name: FILTER
          value: |
            Math.round(Date.parse(event.time) / 60000) % 2 === 0
---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: odd-filter
spec:
  template:
    spec:
      containers:
      - image: villardl/filter-nodejs:0.1
        env:
        - name: FILTER
          value: |
            Math.round(Date.parse(event.time) / 60000) % 2 !== 0
---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: even-transformer
spec:
  template:
    spec:
      containers:
      - image: villardl/transformer-nodejs
        env:
        - name: TRANSFORMER
          value: |
            ({"message": "we are even!"})

---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: odd-transformer
spec:
  template:
    spec:
      containers:
      - image: villardl/transformer-nodejs:0.1
        env:
        - name: TRANSFORMER
          value: |
            ({"message": "this is odd!"})
.
```

```shell
kubectl create -f ./filters.yaml -f ./transformers.yaml
```

### Create the Service displaying the events created by Sequence

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: event-display
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display
```

Change `default` below to create the `Sequence` in the Namespace where you want
your resources to be created.

```shell
kubectl -n default create -f ./event-display.yaml
```

### Create the Parallel

The `parallel.yaml` file contains the specifications for creating the Parallel.

```yaml
apiVersion: flows.knative.dev/v1beta1
kind: Parallel
metadata:
  name: odd-even-parallel
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1beta1
    kind: InMemoryChannel
  branches:
    - filter:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: even-filter
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: even-transformer
    - filter:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: odd-filter
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: odd-transformer
  reply:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
```

```shell
kubectl create -f ./parallel.yaml
```

### Create the PingSource targeting the Parallel

This will create a PingSource which will send a CloudEvent with `{"message":
"Even or odd?"}` as the data payload every minute.

```yaml
apiVersion: sources.knative.dev/v1alpha2
kind: PingSource
metadata:
  name: ping-source
spec:
  schedule: "*/1 * * * *"
  data: '{"message": "Even or odd?"}'
  sink:
    ref:
      apiVersion: flows.knative.dev/v1alpha2
      kind: Parallel
      name: odd-even-parallel
```

```shell
kubectl create -f ./ping-source.yaml
```

### Inspecting the results

You can now see the final output by inspecting the logs of the event-display
pods. Note that since we set the `PingSource` to emit every minute, it might
take some time for the events to show up in the logs.

Let's look at the `event-display` log:

```shell
kubectl logs -l serving.knative.dev/service=event-display --tail=30 -c user-container

☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/default/pingsources/ping-source
  id: 015a4cf4-8a43-44a9-8702-3d4171d27ba5
  time: 2020-03-03T21:24:00.0007254Z
  datacontenttype: application/json; charset=utf-8
Extensions,
  knativehistory: odd-even-parallel-kn-parallel-kn-channel.default.svc.cluster.local; odd-even-parallel-kn-parallel-0-kn-channel.default.svc.cluster.local
  traceparent: 00-41a139bf073f3cfcba7bb7ce7f1488fc-68a891ace985221a-00
Data,
  {
    "message": "we are even!"
  }
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/default/pingsources/ping-source
  id: 52e6b097-f914-4b5a-8539-165650e85bcd
  time: 2020-03-03T21:23:00.0004662Z
  datacontenttype: application/json; charset=utf-8
Extensions,
  knativehistory: odd-even-parallel-kn-parallel-kn-channel.default.svc.cluster.local; odd-even-parallel-kn-parallel-1-kn-channel.default.svc.cluster.local
  traceparent: 00-58d371410d7daf2033be226860b4ee5d-05d686ee90c3226f-00
Data,
  {
    "message": "this is odd!"
  }
```
