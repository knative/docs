# Cron Job Source example

Cron Job Source example shows how to configure Cron Job as event source for
functions.

## Deployment Steps

### Prerequisites

1. Setup [Knative Serving](https://github.com/knative/docs/tree/master/serving).
1. Setup
   [Knative Eventing](https://github.com/knative/docs/tree/master/eventing).

### Create a Knative Service

In order to verify `CronJobSource` is working, we will create a simple Knative
Service that dumps incoming messages to its log.

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: message-dumper
spec:
  runLatest:
    configuration:
      revisionTemplate:
        spec:
          container:
            image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/message_dumper
```

Use following command to create the service from `service.yaml`:

```shell
kubectl apply --filename service.yaml
```

### Create Cron Job Event Source

For each set of cron events you want to request, you need to create an Event
Source in the same namespace as the destiantion. If you need a different
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
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    name: message-dumper
```

Use following command to create the event source from `cronjob-source.yaml`:

```shell
kubectl apply --filename cronjob-source.yaml
```

### Verify

We will verify that the message was sent to the Knative eventing system by
looking at message dumper logs.

```shell
kubectl logs -l serving.knative.dev/service=message-dumper -c user-container --since=10m
```

You should see log lines showing the request headers and body from the source:

```
2019/03/14 14:28:06 Message Dumper received a message: POST / HTTP/1.1
Host: message-dumper.default.svc.cluster.local
Transfer-Encoding: chunked
Accept-Encoding: gzip
Ce-Cloudeventsversion: 0.1
Ce-Eventid: 9790bf44-914a-4e66-af59-b43c06ccb73b
Ce-Eventtime: 2019-03-14T14:28:00.005163309Z
Ce-Eventtype: dev.knative.cronjob.event
Ce-Source: CronJob
...

{"message":"Hello world!"}
```

You can also use [`kail`](https://github.com/boz/kail) instead of `kubectl logs`
to tail the logs of the subscriber.

```shell
kail -l serving.knative.dev/service=message-dumper -c user-container --since=10m
```

### Cleanup

You can remove the Cron Event Source via:
```shell
kubectl delete --filename cronjob-source.yaml
```

Similarily, you can remove the Service via:

```shell
kubectl delete --filename service.yaml
```
