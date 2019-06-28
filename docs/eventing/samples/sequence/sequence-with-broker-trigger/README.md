
## Overview

We are going to create the following logical configuration. We create a
CronJobSource, feeding events into the Broker, then we create a `Filter` that
wires those events into a [`Sequence`](../../../sequence.md) consisting of 3
steps. Then we take the end of the Sequence and feed newly minted events back
into the Broker and create another Trigger which will then display those events.

**NOTE** [TODO: Fix this](https://github.com/knative/eventing/issues/1421) So,
currently as set up, the events emitted by the Sequence do not make it into the
Broker.

## Prerequisites

For this example, we'll assume you have set up a `Broker` and an
`InMemoryChannel` as well as Knative Serving (for our functions). The examples
use `default` namespace, again, if your broker lives in another Namespace, you
will need to modify the examples to reflect this.

If you want to use different type of `Channel`, you will have to modify the
`Sequence.Spec.ChannelTemplate` to create the appropriate Channel resources.

![Logical Configuration](./sequence-with-broker-trigger.png)

## Setup

### Create the Knative Services

Change `default` below to create the steps in the Namespace where you have
configured your `Broker`

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: first
spec:
  template:
    spec:
      containers:
      - image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:2656f39a7fcb6afd9fc79e7a4e215d14d651dc674f38020d1d18c6f04b220700
            env:
            - name: STEP
              value: "0"

---
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: second
spec:
  template:
    spec:
      containers:
      - image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:2656f39a7fcb6afd9fc79e7a4e215d14d651dc674f38020d1d18c6f04b220700
            env:
            - name: STEP
              value: "1"
---
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: third
spec:
  template:
    spec:
      containers:
      - image: us.gcr.io/probable-summer-223122/cmd-03315b715ae8f3e08e3a9378df706fbb@sha256:2656f39a7fcb6afd9fc79e7a4e215d14d651dc674f38020d1d18c6f04b220700
            env:
            - name: STEP
              value: "2"

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
    kind: Broker
    apiVersion: eventing.knative.dev/v1alpha1
    name: broker-test
```

Change `default` below to create the `Sequence` in the Namespace where you have
configured your `Broker`.

```shell
kubectl -n default create -f ./sequence.yaml
```

### Create the CronJobSource targeting the Broker

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
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Broker
    name: broker-test
```

Here, if you are using different type of Channel, you need to change the
spec.channelTemplate to point to your desired Channel. Also, change the
spec.reply.name to point to your `Broker`

Change `default` below to create the `Sequence` in the Namespace where you have
configured your `Broker`.

```shell
kubectl -n default create -f ./cron-source.yaml
```

### Create the Trigger targeting the Sequence

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: sequence-trigger
spec:
  filter:
    sourceAndType:
      type: dev.knative.cronjob.event
  subscriber:
    ref:
      apiVersion: messaging.knative.dev/v1alpha1
      kind: Sequence
      name: sequence
```

Change `default` below to create the `Sequence` in the Namespace where you have
configured your `Broker`.

```shell
kubectl -n default create -f ./trigger.yaml

```

### Create the Service and Trigger displaying the events created by Sequence

**NOTE** This does not work yet because the events created by the Sequence in
the last step are filtered.
[TODO: Fix this](https://github.com/knative/eventing/issues/1421)

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: sequence-display
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display
---
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: sequence-trigger
spec:
  filter:
    sourceAndType:
      type: samples.http.mod3
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: sequence-display
---

```

Change `default` below to create the `Sequence` in the Namespace where you have
configured your `Broker`.

```shell
kubectl -n default create -f ./display-trigger.yaml
```
