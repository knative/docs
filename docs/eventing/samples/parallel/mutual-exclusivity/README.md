In this example, we are going to see how we can create a Parallel with mutually
exclusive branches.

This example is the same as the
[multiple branches example](../multiple-branches/README.md) except that we are now
going to rely on the Knative
[switch](https://github.com/lionelvillard/knative-functions#switch) function
to provide a soft mutual exclusivity guarantee.

NOTE: this example must be deployed in the default namespace.

## Prerequisites

Please refer to the sample overview for the [prerequisites](../README.md).

### Create the Knative Services

Let's first create the switcher and transformer services that we will use in our
Parallel.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: me-even-odd-switcher
spec:
  template:
    spec:
      containers:
      - image: villardl/switcher-nodejs:0.1
        env:
        - name: EXPRESSION
          value: Math.round(Date.parse(event.time) / 60000) % 2
        - name: CASES
          value: '[0, 1]'
---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: even-transformer
spec:
  template:
    spec:
      containers:
      - image: villardl/transformer-nodejs:0.1
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
kubectl create -f ./switcher.yaml -f ./transformers.yaml
```

### Create the Service displaying the events created by Parallel

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

```shell
kubectl -n default create -f ./event-display.yaml
```

### Create the Parallel object

The `parallel.yaml` file contains the specifications for creating the Parallel object.

```yaml
apiVersion: flows.knative.dev/v1beta1
kind: Parallel
metadata:
  name: me-odd-even-parallel
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1beta1
    kind: InMemoryChannel
  branches:
    - filter:
        uri: "http://me-even-odd-switcher.default.svc.cluster.local/0"
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: me-even-transformer
    - filter:
        uri: "http://me-even-odd-switcher.default.svc.cluster.local/1"
      subscriber:
        ref:
          apiVersion: serving.knative.dev/v1
          kind: Service
          name: me-odd-transformer
  reply:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: me-event-display
```

```shell
kubectl create -f ./parallel.yaml
```

### Create the PingSource targeting the Parallel object

This will create a PingSource which will send a CloudEvent with `{"message":
"Even or odd?"}` as the data payload every minute.

```yaml
apiVersion: sources.knative.dev/v1alpha2
kind: PingSource
metadata:
  name: me-ping-source
spec:
  schedule: "*/1 * * * *"
  jsonData: '{"message": "Even or odd?"}'
  sink:
    ref:
      apiVersion: flows.knative.dev/v1beta1
      kind: Parallel
      name: me-odd-even-parallel
```

```shell
kubectl create -f ./ping-source.yaml
```

### Inspecting the results

You can now see the final output by inspecting the logs of the
`me-event-display` pods. Note that since we set the `PingSource` to emit
every minute, it might take some time for the events to show up in the logs.

Let's look at the `me-event-display` log:

```shell
kubectl logs -l serving.knative.dev/service=me-event-display --tail=50 -c user-container

☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/default/pingsources/me-ping-source
  id: 0b0db15c-9b36-4388-8eaa-8c23a9dc2707
  time: 2020-03-03T21:30:00.0007292Z
  datacontenttype: application/json; charset=utf-8
Extensions,
  knativehistory: me-odd-even-parallel-kn-parallel-kn-channel.default.svc.cluster.local; me-odd-even-parallel-kn-parallel-0-kn-channel.default.svc.cluster.local
  traceparent: 00-e8b17109cd21d4fa66a86633b5a614c7-ba96d220fe13211c-00
Data,
  {
    "message": "we are even!"
  }
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.sources.ping
  source: /apis/v1/namespaces/default/pingsources/me-ping-source
  id: 321170d1-dea7-4b18-9290-28adb1de089b
  time: 2020-03-03T21:31:00.0007847Z
  datacontenttype: application/json; charset=utf-8
Extensions,
  knativehistory: me-odd-even-parallel-kn-parallel-kn-channel.default.svc.cluster.local; me-odd-even-parallel-kn-parallel-1-kn-channel.default.svc.cluster.local
  traceparent: 00-78d8b044d23c85789f0a13fd3679ac24-1d69ddde56d620c7-00
Data,
  {
    "message": "this is odd!"
  }
```
