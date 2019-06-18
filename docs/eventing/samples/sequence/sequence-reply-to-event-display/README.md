---
title: "Sequence Wired to event-display"
weight: 20
type: "docs"
---

# Using Sequences in series

## Prerequisites

For this example, we'll assume you have set up an `InMemoryChannel`
as well as Knative Serving (for our functions). The examples use `newbroker`
namespace, again, if you want to deploy to another Namespace, you will need
to modify the examples to reflect this.
If you want to use different type of `Channel`, you will have to modify the
`Sequence.Spec.ChannelTemplate` to create the appropriate Channel resources.

## Overview

We are going to create the following logical configuration. We create a CronJobSource,
feeding events to a `Sequence`, then taking the output of that `Sequence` and
displaying the resulting output.

![Logical Configuration](./sequence-reply-to-event-display.png)


## Setup

### Create the Knative Services

Change `newbroker` below to create the steps in the Namespace where you want resources
created.

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
```


```shell
kubectl -n newbroker create -f ./steps.yaml
```

### Create the Sequence

Here, if you are using different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel.

```yaml
apiVersion: messaging.knative.dev/v1alpha1
kind: Sequence
metadata:
  name: sequence
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
    kind: Service
    apiVersion: serving.knative.dev/v1alpha1
    name: event-display
```

Change `newbroker` below to create the `Sequence` in the Namespace where you want the
resources to be created.
```shell
kubectl -n newbroker create -f ./sequence.yaml
```


### Create the Service displaying the events created by Sequence

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

Change `newbroker` below to create the `Sequence` in the Namespace where you want your resources
to be created.
```shell
kubectl -n newbroker create -f ./event-display.yaml
```

### Create the CronJobSource targeting the Sequence

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
    name: sequence
```

Here, if you are using different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel. 

```shell
kubectl -n newbroker create -f ./cron-source.yaml
```

### Inspecting the results

You can now see the final output by inspecting the logs of the event-display pods.
```shell
kubectl -n newbroker get pods
```

Then grab the pod name for the event-display (in my case: "event-display-sldk5-deployment-79b69bb4c9-djwj4")


```shell
vaikas@penguin:~/projects/go/src/github.com/knative/docs$ kubectl -n newbroker3 logs event-display-sldk5-deployment-79b69bb4c9-djwj4 user-container
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  cloudEventsVersion: 0.1
  eventType: samples.http.mod3
  source: /transformer/2
  eventID: df52b47e-02fd-45b2-8180-dabb572573f5
  eventTime: 2019-06-18T14:18:42.478140635Z
  contentType: application/json
Data,
  {
    "id": 0,
    "message": "Hello world! - Handled by 0 - Handled by 1 - Handled by 2"
  }
```

And you can see that the initial Cron Source message ("Hello World!") has been appended to it by each
of the steps in the Sequence.
