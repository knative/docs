---
title: "Cron job source example"
linkTitle: "Cron job source"
weight: 10
type: "docs"
---

Cron Job Source example shows how to configure Cron Job as event source for
functions.

## Deployment Steps

### Prerequisites

1. Setup [Knative Serving](../../../serving).
1. Setup [Knative Eventing](../../../eventing).

### Create a Knative Service

In order to verify `CronJobSource` is working, we will create a simple Knative
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
        - image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display
```

Use following command to create the service from `service.yaml`:

```shell
kubectl apply --filename service.yaml
```

### Create Cron Job Event Source

For each set of cron events you want to request, you need to create an Event
Source in the same namespace as the destination. If you need a different
ServiceAccount to create the Deployment, modify the entry accordingly in the
yaml.

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: CronJobSource
metadata:
  name: test-cronjob-source
spec:
  schedule: "*/2 * * * *"
  data: '{"message": "Hello world!"}'
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: event-display
```

Use following command to create the event source from `cronjob-source.yaml`:

```shell
kubectl apply --filename cronjob-source.yaml
```

### Verify

We will verify that the message was sent to the Knative eventing system by
looking at message dumper logs.

```shell
kubectl logs -l serving.knative.dev/service=event-display -c user-container --since=10m
```

You should see log lines showing the request headers and body from the source:

```
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 1.0
  type: dev.knative.cronjob.event
  source: /apis/v1/namespaces/default/cronjobsources/test-cronjob-source
  id: d8e761eb-30c7-49a3-a421-cd5895239f2d
  time: 2019-12-04T14:24:00.000702251Z
  datacontenttype: application/json
Data,
  {
    "message": "Hello world!"
  }
```

You can also use [`kail`](https://github.com/boz/kail) instead of `kubectl logs`
to tail the logs of the subscriber.

```shell
kail -l serving.knative.dev/service=event-display -c user-container --since=10m
```

### Cleanup

You can remove the Cron Event Source via:

```shell
kubectl delete --filename cronjob-source.yaml
```

Similarly, you can remove the Service via:

```shell
kubectl delete --filename service.yaml
```
