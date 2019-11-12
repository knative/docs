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
        - image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display
```

Change `default` below to create the `Sequence` in the Namespace where you want
your resources to be created.

```shell
kubectl -n default create -f ./event-display.yaml
```

### Create the Parallel

The `parallel.yaml` file contains the specifications for creating the Parallel.

```yaml
apiVersion: flows.knative.dev/v1alpha1
kind: Parallel
metadata:
  name: odd-even-parallel
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1alpha1
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

### Create the CronJobSource targeting the Parallel

This will create a CronJobSource which will send a CloudEvent with {"message":
"Even or odd?"} as the data payload every minute.

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: CronJobSource
metadata:
  name: cronjob-source
spec:
  schedule: "*/1 * * * *"
  data: '{"message": "Even or odd?"}'
  sink:
    ref:
      apiVersion: flows.knative.dev/v1alpha1
      kind: Parallel
      name: odd-even-parallel
```

```shell
kubectl create -f ./cron-source.yaml
```

### Inspecting the results

You can now see the final output by inspecting the logs of the event-display
pods. Note that since we set the `CronJobSource` to emit every minute, it might
take some time for the events to show up in the logs.

Let's look at the `event-display` log:

```shell
kubectl logs -l serving.knative.dev/service=event-display --tail=30 -c user-container

☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.3
  type: dev.knative.cronjob.event
  source: /apis/v1/namespaces/default/cronjobsources/cronjob-source
  id: 2884f4a3-53f2-4926-a32c-e696a6fb3697
  time: 2019-07-31T18:10:00.000309586Z
  datacontenttype: application/json; charset=utf-8
Extensions,
  knativehistory: odd-even-parallel-kn-parallel-0-kn-channel.default.svc.cluster.local, odd-even-parallel-kn-parallel-kn-channel.default.svc.cluster.local
Data,
  {
    "message": "we are even!"
  }
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.3
  type: dev.knative.cronjob.event
  source: /apis/v1/namespaces/default/cronjobsources/cronjob-source
  id: 2e519f11-3b6f-401c-b196-73f8b235de58
  time: 2019-07-31T18:11:00.002649881Z
  datacontenttype: application/json; charset=utf-8
Extensions,
  knativehistory: odd-even-parallel-kn-parallel-1-kn-channel.default.svc.cluster.local, odd-even-parallel-kn-parallel-kn-channel.default.svc.cluster.local
Data,
  {
    "message": "this is odd!"
  }
```
