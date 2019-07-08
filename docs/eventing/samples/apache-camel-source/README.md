These samples show how to configure a Camel Source. It is an Event Source that
can leverage one of the[250+ Apache Camel components](https://github.com/apache/camel/tree/master/components)
for generating events.

## Prerequisites

1. [Install Knative Serving and Eventing](../../../install).

1. Install the [Apache Camel K](https://github.com/apache/camel-k) Operator in
   any namespace where you want to run Camel sources.

   The preferred version that is compatible with Camel sources is
   [Camel K v0.3.3](https://github.com/apache/camel-k/releases/tag/0.3.3).

   Installation instruction are provided on the
   [Apache Camel K Github repository](https://github.com/apache/camel-k#installation).
   Documentation includes specific instructions for common Kubernetes
   environments, including development clusters.

1. Download Kail binaries for Linux or OSX, which can be found on the [latest release](https://github.com/boz/kail/releases/latest) page. You can use `kail` instead of `kubectl logs` to tail the logs of the subscriber.

1. Install the Camel Source from the `camel.yaml` in the [Eventing Sources release page](https://github.com/knative/eventing-contrib/releases):

   ```shell
   kubectl apply --filename camel.yaml
   ```
   

### Create a Channel and a Subscriber

To verify that the `CamelSource` is working, we will create:

- a simple Knative event display service that prints incoming events to its log
- an in-memory channel named `camel-test` that will buffer events created by the event source
- a subscription to direct events from the test channel to the event display service

Deploy the [`display_resources.yaml`](./display_resources.yaml):

```shell
kubectl apply --filename display_resources.yaml
```

### Run a CamelSource using the Timer component

The samples directory contains some sample sources that can be used to generate
events.

The simplest one, that does not require additional configuration is the "timer"
source.

If you want, you can customize the source behavior using options available in
the Apache Camel documentation for the
[timer component](https://github.com/apache/camel/blob/master/camel-core/src/main/docs/timer-component.adoc).
All Camel components are documented in the
[Apache Camel github repository](https://github.com/apache/camel/tree/master/components).

Install the [timer CamelSource](source_timer.yaml) from source:

```shell
kubectl apply -f source_timer.yaml
```

We will verify that the published message was sent to the Knative eventing
system by looking at the downstream of the `CamelSource`.
 
```shell
kubectl logs --selector serving.knative.dev/service=camel-event-display -c user-container
```
or 

You can also use [`kail`](https://github.com/boz/kail) to tail the logs of the subscriber.

```shell
kail -d camel-event-display --since=10m
```

If you have deployed the timer source, you should see log lines appearing every 3
seconds.


### Run a CamelSource using the Telegram component

Another useful component available with Camel is the Telegram component. It can
be used to forward messages of a [Telegram](https://telegram.org/) chat into
Knative channels as events.

Before using the provided Telegram CamelSource example, you need to follow the
instructions on the Telegram website for creating a
[Telegram Bot](https://core.telegram.org/bots). The quickest way to create a bot
is to contact the [Bot Father](https://telegram.me/botfather), another Telegram
Bot, using your preferred Telegram client (mobile or web). After you create the
bot, you'll receive an **authorization token** that is needed for the source to
work.

First, edit the [telegram CamelSource](source_telegram.yaml) and put the
authorization token, replacing the `<put-your-token-here>` placeholder.

To reduce noise in the event display, you can remove the previously created
timer CamelSource from the namespace:

```shell
kubectl delete camelsource camel-timer-source
```

Install the [telegram CamelSource](source_telegram.yaml) from source:

```shell
kunbectl apply -f source_telegram.yaml
```

Start `kail` again and keep it open on the event display:

```shell
kail -d camel-event-display --since=10m
```

Now, you can contact your bot with any Telegram client. Each message you send
to the bot will be printed by the event display as a cloudevent.


### Run a Camel K Source

For complex use cases that require multiple steps to be executed before event data is ready to be published, you can use Camel K sources.
Camel K lets you use Camel DSL to design one or more routes that can define arbitrarily complex workflows before sending events to the target sink.

If you have previously deployed other CamelSources, to reduce noise in the event display, you can remove them all from the namespace:

```shell
kubectl delete camelsource --all
```

Install the [Camel K Source](source_camel_k.yaml) from source:

```shell
kubectl apply -f source_camel_k.yaml
```

Start `kail` again and keep it open on the event display:

```shell
kail -d camel-event-display --since=10m
```

The event display will show some JSON data periodically pulled from an external REST API.
The API in the example is static, but you can use your own dynamic API by replacing the endpoint.
