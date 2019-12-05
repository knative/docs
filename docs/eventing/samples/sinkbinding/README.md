---
title: "Sink Binding Example"
linkTitle: "Sink Binding"
weight: 10
type: "docs"
---

A SinkBinding is responsible for linking together "addressable" Kubernetes
resources that may receive events (aka the event "sink") with Kubernetes
resources that embed a PodSpec (as `spec.template.spec`) and want to produce
events.

The SinkBinding can be used to author new event sources using any of the
familiar compute abstractions that Kubernetes makes available (e.g. Deployment,
Job, DaemonSet, StatefulSet), or Knative abstractions (e.g. Service,
Configuration).


## Create a CronJob that uses SinkBinding

### Prerequisites

1. Setup [Knative Serving](../../../serving).
1. Setup [Knative Eventing and Sources](../../../eventing).

### Prepare the heartbeats image

Knative [event-contrib](https://github.com/knative/eventing-contrib) has a
sample of heartbeats event source. You could clone the source codes by

```
git clone -b "{{< branch >}}" https://github.com/knative/eventing-contrib.git
```

And then build a heartbeats image and publish to your image repo with

```
ko publish knative.dev/eventing-contrib/cmd/heartbeats
```

**Note**: `ko publish` requires:

- [`KO_DOCKER_REPO`](https://github.com/knative/serving/blob/master/DEVELOPMENT.md#environment-setup)
  to be set. (e.g. `gcr.io/[gcloud-project]` or `docker.io/<username>`)
- you to be authenticated with your `KO_DOCKER_REPO`

### Creating our event sink

In order to verify our `SinkBinding` is working, we will create an Event Display
Service that dumps incoming messages to its log.

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: event-display
spec:
  template:
    spec:
      containers:
        - image: gcr.io/knative-releases/github.com/knative/eventing-contrib/cmd/event_display
```

Use following command to create the service from `service.yaml`:

```shell
kubectl apply --filename service.yaml
```

The status of the created service can be seen using:

```shell
kubectl get ksvc

NAME            URL                                           LATESTCREATED         LATESTREADY           READY   REASON
event-display   http://event-display.default.1.2.3.4.xip.io   event-display-gqjbw   event-display-gqjbw   True
```

### Create our SinkBinding

In order to direct events to our Event Display, we will first create a
SinkBinding that will inject `$K_SINK` into select `Jobs`:

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: SinkBinding
metadata:
  name: bind-heartbeat
spec:
  subject:
    apiVersion: batch/v1
    kind: Job
    selector:
      matchLabels:
        app: heartbeat-cron

  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
```

In this case, we will bind any `Job` with the labels `app: heartbeat-cron`.

Use the following command to create the event source from `sinkbinding.yaml`:

```shell
kubectl apply --filename sinkbinding.yaml
```

### Create our CronJob

Now we will use the heartbeats container to send events to `$K_SINK` every time
the CronJob runs:

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: heartbeat-cron
spec:
spec:
  # Run every minute
  schedule: "* * * * *"
  jobTemplate:
    metadata:
      labels:
        app: heartbeat-cron
    spec:
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: single-heartbeat
              image: <FILL IN YOUR IMAGE HERE>
              args:
                - --period=1
              env:
                - name: ONE_SHOT
                  value: "true"
                - name: POD_NAME
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.name
                - name: POD_NAMESPACE
                  valueFrom:
                    fieldRef:
                      fieldPath: metadata.namespace
```

First, edit `heartbeats-source.yaml` to include the image name from the
`ko publish` command above, then run the following to apply it:

```shell
kubectl apply --filename heartbeats-source.yaml
```

### Verify

We will verify that the message was sent to the Knative eventing system by
looking at event-display service logs.

```shell
kubectl logs -l serving.knative.dev/service=event-display -c user-container --since=10m
```

You should see log lines showing the request headers and body of the event
message sent by the heartbeats source to the display function:

```
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.3
  type: dev.knative.eventing.samples.heartbeat
  source: https://knative.dev/eventing-contrib/cmd/heartbeats/#event-test/mypod
  id: 2b72d7bf-c38f-4a98-a433-608fbcdd2596
  time: 2019-10-18T15:23:20.809775386Z
  contenttype: application/json
Extensions,
  beats: true
  heart: yes
  the: 42
Data,
  {
    "id": 2,
    "label": ""
  }
```

## Using the SinkBinding with a Knative Service

SinkBinding is also compatible with our Knative Serving Cloud Events
[samples](../../../serving/samples/cloudevents); as a next step try using those
together.  For example, the [`cloudevents-go`
sample](../../../serving/samples/cloudevents/cloudevents-go) may be bound with:

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: SinkBinding
metadata:
  name: bind-heartbeat
spec:
  subject:
    apiVersion: serving.knative.dev/v1
    kind: Service
    name: cloudevents-go

  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
```

