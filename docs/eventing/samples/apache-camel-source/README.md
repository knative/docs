These samples show how to configure Camel Sources. These event sources are highly dynamic and allow you to
generate events from a variety of systems (cloud platforms, social networks, datastores, message brokers, legacy systems, etc.), 
leveraging all the [300+ components provided by Apache Camel](https://camel.apache.org/components/latest/).

All Camel Sources use [Apache Camel K](https://github.com/apache/camel-k) as the runtime engine.

## Prerequisites

1. [Install Knative Serving and Eventing](../../../install).

1. Install the [Apache Camel K](https://github.com/apache/camel-k) Operator in
   any namespace where you want to run Camel sources.

   The preferred version that is compatible with Camel sources is
   [Camel K v1.0.0-M4](https://github.com/apache/camel-k/releases).

   Installation instructions are provided in the
   [Apache Camel K Manual](https://camel.apache.org/camel-k/latest/installation/installation.html).
   Documentation includes specific instructions for common Kubernetes
   environments, including development clusters.

1. Install the Camel Source from the `camel.yaml` in the
   [Eventing Sources release page](https://github.com/knative/eventing-contrib/releases):

   ```shell
   kubectl apply --filename camel.yaml
   ```

### Create Test Resources

All the `CamelSource` examples use some test resources for the purpose of displaying the generated events.
The following resources need to be created:

- a simple Knative event display service that prints incoming events to its log
- an in-memory channel named `camel-test` that buffers events created by the
  event source
- a subscription to direct events from the test channel to the event display
  service

Deploy the [`display_resources.yaml`](./display_resources.yaml):

```shell
kubectl apply --filename display_resources.yaml
```

### Run a Timer CamelSource

The samples directory contains some sample sources that can be used to generate
events.

The simplest example of `CamelSource`, that does not require additional
configuration, is the timer source.

The timer source periodically generates "Hello world!" events and forwards them to the provided destination. 

If you want, you can customize the source behavior using options available in
the Apache Camel documentation for the
[timer component](https://camel.apache.org/components/latest/timer-component.html).
All Camel components are documented in the
[Apache Camel Website](https://camel.apache.org/components/latest/).

Install the [timer CamelSource](source_timer.yaml) from source:

```shell
kubectl apply -f source_timer.yaml
```

Verify that the published events were sent into the Knative eventing system by
looking at what is downstream of the `CamelSource`.

```shell
kubectl logs --selector serving.knative.dev/service=camel-event-display -c user-container
```

If you have deployed the timer source, you should see new log lines appearing every
3 seconds.

### Run a MQTT CamelSource

One of the 300+ Camel components that you can leverage is [Camel-Paho](https://camel.apache.org/components/latest/paho-component.html), 
based on the [Eclipse Paho](https://www.eclipse.org/paho/) open source project.

A source based on Paho (like the provided [MQTT CamelSource](source_mqtt.yaml)) allows to bridge any MQTT broker to a Knative resource,
automatically converting IoT messages to Cloudevents.

To use the MQTT source, you need a MQTT broker running and reachable from your cluster.
For example, it's possible to run a [Mosquitto MQTT Broker](https://mosquitto.org/) for testing purposes.  

First, edit the [MQTT CamelSource](source_mqtt.yaml) and put the
correct address of the MQTT broker in the `brokerUrl` field.
You also need to provide the name of the topic that you want to subscribe to: just change `paho:mytopic` to match
the topic that you want to use.

You can also scale this source out, in order to obtain more throughput, by changing the value of the `replicas` field.
By default it creates *2* replicas for demonstration purposes.

To reduce noise in the event display, you can remove all previously created
CamelSources from the namespace:

```shell
kubectl delete camelsource --all
```

Install the [mqtt CamelSource](source_mqtt.yaml):

```shell
kubectl apply -f source_mqtt.yaml
```

You can now send MQTT messages to your broker using your favourite client (you can even use Camel K for sending test events).

Each message you send to the MQTT broker will be printed by the event display as a Cloudevent.

You can verify that your messages reach the event display by checking its logs:

```shell
kubectl logs --selector serving.knative.dev/service=camel-event-display -c user-container
```


### Run a Telegram CamelSource

Another useful component available with Camel is the Telegram component. It can
be used to forward messages of a [Telegram](https://telegram.org/) chat into
Knative channels as events.

Before using the provided Telegram `CamelSource` example, you need to follow the
instructions on the Telegram website for creating a
[Telegram Bot](https://core.telegram.org/bots). The quickest way to create a bot
is to contact the [Bot Father](https://telegram.me/botfather), another Telegram
Bot, using your preferred Telegram client (mobile or web). After you create the
bot, you will receive an **authorization token** that is needed for the source
to work.

First, edit the [telegram CamelSource](source_telegram.yaml) and put the
authorization token, replacing the `<put-your-token-here>` placeholder.

To reduce noise in the event display, you can remove all previously created
CamelSources from the namespace:

```shell
kubectl delete camelsource --all
```

Install the [telegram CamelSource](source_telegram.yaml):

```shell
kubectl apply -f source_telegram.yaml
```

Now, you can contact your bot with any Telegram client. Each message you send to
the bot will be printed by the event display as a Cloudevent.

You can verify that your messages reach the event display by checking its logs:

```shell
kubectl logs --selector serving.knative.dev/service=camel-event-display -c user-container
```


### Run an HTTP Poller CamelSource

CamelSources are not limited to using a single Camel component. For example, 
you can combine the [Camel Timer component](https://camel.apache.org/components/latest/timer-component.html)
with the [Camel HTTP component](https://camel.apache.org/components/latest/http-component.html)
to periodically fetch an external API, transform the result into a Cloudevent and forward it to a 
given destination.

The example will retrieve a static JSON file from a remote URL, but you can edit the
[HTTP poller CamelSource](source_http_poller.yaml) to add your own API.

If you have previously deployed other CamelSources, to reduce noise in the event
display, you can remove them all from the namespace:

```shell
kubectl delete camelsource --all
```

Install the [HTTP poller CamelSource](source_http_poller.yaml):

```shell
kubectl apply -f source_http_poller.yaml
```

The event display will show some JSON data periodically pulled from the external
REST API. To check the logs:

```shell
kubectl logs --selector serving.knative.dev/service=camel-event-display -c user-container
```
