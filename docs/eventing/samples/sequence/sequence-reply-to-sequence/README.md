---
title: "Sequence Wired to another Sequence"
weight: 20
type: "docs"
---

# Using Sequences in series

## Prerequisites

For this example, we'll assume you have set up a `Broker` and an `InMemoryChannel`
as well as Knative Serving (for our functions). The examples use `newbroker`
namespace, again, if your broker lives in another Namespace, you will need to
modify the examples to reflect this.
If you want to use different type of `Channel`, you will have to modify the
`Sequence.Spec.ChannelTemplate` to create the appropriate Channel resources.

## Overview

We are going to create the following logical configuration. We create a CronJobSource,
feeding events to a `Sequence`, then taking the output of that `Sequence` and sending
it to a second `Sequence` and finally displaying the resulting output.

![Logical Configuration](./sequence-reply-to-sequence.png)


## Setup

### Create the Knative Services

Change `newbroker` below to create the steps in the Namespace where you have configured your
`Broker`

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: first
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:17f0bb4c6ee5b1e5580966aa705a51f1b54adc794356f14c9d441d91a26412a3
            env:
            - name: STEP
              value: "0"

---
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: second
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:17f0bb4c6ee5b1e5580966aa705a51f1b54adc794356f14c9d441d91a26412a3
            env:
            - name: STEP
              value: "1"
---
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: third
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:17f0bb4c6ee5b1e5580966aa705a51f1b54adc794356f14c9d441d91a26412a3
            env:
            - name: STEP
              value: "2"
---
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: fourth
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:17f0bb4c6ee5b1e5580966aa705a51f1b54adc794356f14c9d441d91a26412a3
            env:
            - name: STEP
              value: "3"

---
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: fifth
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:17f0bb4c6ee5b1e5580966aa705a51f1b54adc794356f14c9d441d91a26412a3
            env:
            - name: STEP
              value: "4"
---
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: sixth
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:17f0bb4c6ee5b1e5580966aa705a51f1b54adc794356f14c9d441d91a26412a3
            env:
            - name: STEP
              value: "5"
---
```


```shell
kubectl -n newbroker create -f ./steps.yaml
```

### Create the first Sequence

Here, if you are using different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel. Also, change the
spec.reply.name to point to your `Broker`

```yaml
apiVersion: messaging.knative.dev/v1alpha1
kind: Sequence
metadata:
  name: first-sequence
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1alpha1
    kind: InMemoryChannel
  steps:
  - ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: first
  - ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: second
  - ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: third
  reply:
    kind: Sequence
    apiVersion: messaging.knative.dev/v1alpha1
    name: second-sequence
```

Change `newbroker` below to create the `Sequence` in the Namespace where you have configured your
`Broker`. 
```shell
kubectl -n newbroker create -f ./sequence1.yaml
```


### Create the second Sequence

Here, again if you are using different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel. Also, change the
spec.reply.name to point to your `Broker`

```yaml
apiVersion: messaging.knative.dev/v1alpha1
kind: Sequence
metadata:
  name: second-sequence
spec:
  channelTemplate:
    apiVersion: messaging.knative.dev/v1alpha1
    kind: InMemoryChannel
  steps:
  - ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: fourth
  - ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: fifth
  - ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: sixth
  reply:
    kind: Service
    apiVersion: serving.knative.dev/v1alpha1
    name: event-display
```


### Create the Service displaying the events created by Sequence

**NOTE** This does not work yet because the events created by the Sequence in the last step
are filtered. [TODO: Fix this](https://github.com/knative/eventing/issues/1421)

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: event-display
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display
```

Change `newbroker` below to create the `Sequence` in the Namespace where you have configured your
`Broker`. 
```shell
kubectl -n newbroker create -f ./event-display.yaml
```

### Create the CronJobSource targeting the first Sequence

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: CronJobSource
metadata:
  name: cronjob-source
spec:
  schedule: "*/2 * * * *"
  data: '{"message": "Hello world!"}'
  sink:
    apiVersion: messaging.knative.dev/v1alpha1
    kind: Sequence
    name: first-sequence
```

Here, if you are using different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel. Also, change the
spec.reply.name to point to your `Broker`

```shell
kubectl -n newbroker create -f ./cron-source.yaml
```

### Inspecting the results

You can now see the final output by inspecting the logs of the event-display pods.
```shell
kubectl -n newbroker get pods
```

Then grab the pod name for the event-display (in my case: "event-display-hw7r6-deployment-5555cf68db-bx4m2")


```shell
vaikas@penguin:~/projects/go/src/github.com/knative/docs$ kubectl -n newbroker logs event-display-hw7r6-deployment-5555cf68db-bx4m2 user-container
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

And you can see that the initial Cron Source message ("Hello World!") has been appended to it by each
of the steps in the Sequence.
