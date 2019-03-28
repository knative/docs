These samples show how to configure a Camel source. It is a event source that
can leverage one of the [250+ Apache Camel components](https://github.com/apache/camel/tree/master/components)
for generating events.

## Prerequisites

1. Setup [Knative Serving](../../../serving).

1. Setup [Knative Eventing](../../../eventing).

1. Install the [Apache Camel K](https://github.com/apache/camel-k) Operator in any namespace where you want to run Camel sources.

   The preferred version that is compatible with Camel sources is [Camel K v0.2.0](https://github.com/apache/camel-k/releases/tag/0.2.0).

   Installation instruction are provided on the [Apache Camel K Github repository](https://github.com/apache/camel-k#installation).
   Documentation includes specific instructions for common Kubernetes environments, including development clusters.

1. Install the Camel Source from the `camel.yaml` in the [Eventing Sources release page](https://github.com/knative/eventing-sources/releases):

   ```shell
   kubectl apply --filename camel.yaml
   ```

## Create a Channel and a Subscriber

In order to check if a `CamelSource` is fully working, we will create:

- a simple Knative Service that dumps incoming messages to its log
- a in-memory channel named `camel-test` that will buffer messages created by the event source
- a subscription to direct messages on the test channel to the dumper service

Deploy the [`dumper_resources.yaml`](./dumper_resources.yaml):

```shell
kubectl apply --filename dumper_resources.yaml
```

## Run a CamelSource using the Timer component

The simplest example of CamelSource, that does not require additional configuration, is the "timer" source.

If you want, you can customize the source behavior using options available in the Apache Camel documentation for the
[timer component](https://github.com/apache/camel/blob/master/components/camel-timer/src/main/docs/timer-component.adoc).
All Camel components are documented in the [Apache Camel github repository](https://github.com/apache/camel/tree/master/components).

Install the [`source_timer.yaml`](source_timer.yaml) resource:

```shell
kubectl apply --filename source_timer.yaml
```

We will verify that the published messages were sent into the Knative eventing
system by looking at what is downstream of the `CamelSource`.

```shell
kubectl logs --selector serving.knative.dev/service=camel-message-dumper -c user-container
```

If you've deployed the timer source, you should see log lines appearing every 3 seconds.

## Run a CamelSource using the Telegram component

Another useful component available with Camel is the Telegram component. It can be used to forward messages of
a [Telegram](https://telegram.org/) chat into Knative channels as events.

Before using the provided Telegram CamelSource example, you need to follow the instructions on the Telegram website for
creating a [Telegram Bot](https://core.telegram.org/bots).
The quickest way to create a bot is to contact the [Bot Father](https://telegram.me/botfather), another Telegram Bot,
using your preferred Telegram client (mobile or web).
After you create the bot, you'll receive an **authorization token** that is needed for the source to work.

First, download and edit the [`source_telegram.yaml`](source_telegram.yaml) file and put the authorization token, replacing the `<put-your-token-here>` placeholder.

To reduce noise in the message dumper, you can remove the previously created timer CamelSource from the namespace:

```shell
kubectl delete camelsource camel-timer-source
```

Install the [`source_telegram.yaml`](source_telegram.yaml) resource:

```shell
kubectl apply -f source_telegram.yaml
```

Now, you can **send messages to your bot** with any Telegram client.

Check again the logs on the message dumper:

```shell
kubectl logs --selector serving.knative.dev/service=camel-message-dumper -c user-container
```

Each message you'll send to the bot will be printed by the message dumper as cloudevent.
