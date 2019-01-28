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
            image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/message_dumper@sha256:73a95b05b5b937544af7c514c3116479fa5b6acf7771604b313cfc1587bf0940
```

Use following command to create the service from `service.yaml`:

```shell
kubectl apply -f service.yaml
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
kubectl apply -f cronjob-source.yaml
```

### Verify

We will verify that the message was sent to the Knative eventing system by
looking at message dumper logs.

1. Use [`kail`](https://github.com/boz/kail) to tail the logs of the subscriber.

   ```shell
   kail -d message-dumper -c user-container --since=10m
   ```

You should see log lines similar to:

```json
{
  "ID": "1543616460000180552-203",
  "EventTime": "2018-11-30T22:21:00.000186721Z",
  "Body": "{\"message\": \"Hello world!\"}"
}
```
