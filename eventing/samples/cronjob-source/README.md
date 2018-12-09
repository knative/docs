# Cron Job Source example

Cron Job Source example shows how to configure Cron Job as event source for functions.

## Deployment Steps

### Prerequisites

1. Setup [Knative Serving](https://github.com/knative/docs/tree/master/serving).
1. Setup
   [Knative Eventing](https://github.com/knative/docs/tree/master/eventing).

### Channel

1. Create a `Channel`. You can use your own `Channel` or use the provided sample, which creates a channel called `cronjob-test`. If you use your own `Channel` with a different name, then you will need to alter other commands later.

```shell
kubectl -n default apply -f channel.yaml
```

### Create Cron Job Event Source

1. In order to receive events, you need to create a concrete Event Source for a specific namespace. If you want to consume events from a differenet namespace or using a different `Service Account`, you need to modify the yaml accordingly.

```shell
kubectl -n default apply -f cronjob-source.yaml
```

### Subscriber

In order to check the `CronJobSource` is fully working, we will create a simple Knative Service that dumps incoming messages to its log and create a `Subscription` from the `Channel` to that Knative Service.

1. If the deployed `CronJobSource` is pointing at a `Channel` other than `cronjob-test`, modify `subscriber.yaml` by replacing `cronjob-test` with that `Channel`'s name.
1. Deploy `subscriber.yaml`.

```shell
kubectl -n default apply -f subscriber.yaml
```

### Verify

We will verify that the message was sent to the Knative eventing system by looking at message dumper logs.

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
