---
title: "Sequence wired to another Sequence"
linkTitle: "Using Sequences in series"
weight: 20
type: "docs"
---

We are going to create the following logical configuration. We create a
CronJobSource, feeding events to a [`Sequence`](../../../sequence.md), then
taking the output of that `Sequence` and sending it to a second `Sequence` and
finally displaying the resulting output.

![Logical Configuration](./sequence-reply-to-sequence.png)

## Prerequisites

For this example, we'll assume you have set up a an `InMemoryChannel` as well as
Knative Serving (for our functions). The examples use `default` namespace,
again, if you want to deploy to another Namespace, you will need to modify the
examples to reflect this.

If you want to use different type of `Channel`, you will have to modify the
`Sequence.Spec.ChannelTemplate` to create the appropriate Channel resources.

## Setup

### Create the Knative Services

Change `default` below to create the steps in the Namespace where you want
resources created.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: first
spec:
  template:
    spec:
      containers:
        - image: gcr.io/vaikas-knative/cmd-736bbd9d5a42b6282732cf4569e3c0ff@sha256:f069e4e58d6b420d66304d3bbde019160eb12ca17bb98fc3b88e0de5ad2cacd1
          env:
            - name: STEP
              value: "0"

---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: second
spec:
  template:
    spec:
      containers:
        - image: gcr.io/vaikas-knative/cmd-736bbd9d5a42b6282732cf4569e3c0ff@sha256:f069e4e58d6b420d66304d3bbde019160eb12ca17bb98fc3b88e0de5ad2cacd1
          env:
            - name: STEP
              value: "1"
---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: third
spec:
  template:
    spec:
      containers:
        - image: gcr.io/vaikas-knative/cmd-736bbd9d5a42b6282732cf4569e3c0ff@sha256:f069e4e58d6b420d66304d3bbde019160eb12ca17bb98fc3b88e0de5ad2cacd1
          env:
            - name: STEP
              value: "2"
---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: fourth
spec:
  template:
    spec:
      containers:
        - image: gcr.io/vaikas-knative/cmd-736bbd9d5a42b6282732cf4569e3c0ff@sha256:f069e4e58d6b420d66304d3bbde019160eb12ca17bb98fc3b88e0de5ad2cacd1
          env:
            - name: STEP
              value: "3"

---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: fifth
spec:
  template:
    spec:
      containers:
        - image: gcr.io/vaikas-knative/cmd-736bbd9d5a42b6282732cf4569e3c0ff@sha256:f069e4e58d6b420d66304d3bbde019160eb12ca17bb98fc3b88e0de5ad2cacd1
          env:
            - name: STEP
              value: "4"
---
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: sixth
spec:
  template:
    spec:
      containers:
        - image: gcr.io/vaikas-knative/cmd-736bbd9d5a42b6282732cf4569e3c0ff@sha256:f069e4e58d6b420d66304d3bbde019160eb12ca17bb98fc3b88e0de5ad2cacd1
          env:
            - name: STEP
              value: "5"
---

```

```shell
kubectl -n default create -f ./steps.yaml
```

### Create the first Sequence

The `sequence1.yaml` file contains the specifications for creating the Sequence.
If you are using a different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel.

```yaml
apiVersion: flows.knative.dev/v1alpha1
kind: Sequence
metadata:
  name: first-sequence
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1alpha1
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
      kind: Sequence
      apiVersion: flows.knative.dev/v1alpha1
      name: second-sequence
```

Change `default` below to create the `Sequence` in the Namespace where you want
your resources created.

```shell
kubectl -n default create -f ./sequence1.yaml
```

### Create the second Sequence

The `sequence2.yaml` file contains the specifications for creating the Sequence.
If you are using a different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel.

```yaml
apiVersion: flows.knative.dev/v1alpha1
kind: Sequence
metadata:
  name: second-sequence
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1alpha1
    kind: InMemoryChannel
  steps:
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: fourth
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: fifth
    - ref:
        apiVersion: serving.knative.dev/v1
        kind: Service
        name: sixth
  reply:
    ref:
      kind: Service
      apiVersion: serving.knative.dev/v1
      name: event-display
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
      containerers:
        - image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display
```

Change `default` below to create the `Sequence` in the Namespace where you want
your resources created.

```shell
kubectl -n default create -f ./event-display.yaml
```

### Create the CronJobSource targeting the first Sequence

This will create a CronJobSource which will send a CloudEvent with {"message":
"Hello world!"} as the data payload every 2 minutes.

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: CronJobSource
metadata:
  name: cronjob-source
spec:
  schedule: "*/2 * * * *"
  data: '{"message": "Hello world!"}'
  sink:
    ref:
      apiVersion: flows.knative.dev/v1alpha1
      kind: Sequence
      name: first-sequence
```

```shell
kubectl -n default create -f ./cron-source.yaml
```

### Inspecting the results

You can now see the final output by inspecting the logs of the event-display
pods.

```shell
kubectl -n default get pods
```

Then look at the logs for the event-display pod:

```shell
kubectl -n default logs -l serving.knative.dev/service=event-display -c user-container
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  cloudEventsVersion: 0.1
  eventType: samples.http.mod3
  source: /transformer/5
  eventID: 7628a147-ec74-43d5-a888-8384a1b6b005
  eventTime: 2019-06-18T13:57:20.279354375Z
  contentType: application/json
Data,
  {
    "id": 0,
    "message": "Hello world! - Handled by 0 - Handled by 1 - Handled by 2 - Handled by 3 - Handled by 4 - Handled by 5"
  }
```

And you can see that the initial Cron Source message ("Hello World!") has been
appended to it by each of the steps in the Sequence.
