# Event Sourcing with Apache Camel K and Knative Eventing

**Author: Matthias Weßendorf, Senior Principal Software Engineer @ Red Hat**

## Why Apache Camel K?

The [Apache Camel](https://camel.apache.org/){:target="_blank"} is a popular Open Source integration framework that empowers you to quickly and easily integrate various systems consuming or producing data. With [Apache Camel K](https://camel.apache.org/camel-k/latest){:target="_blank"} the project provides a lightweight integration framework built from Apache Camel that runs natively on Kubernetes and is specifically designed for serverless and microservice architectures.

The Camel K framework also supports Knative, allowing developers to [bind](https://camel.apache.org/camel-k/latest/kamelets/kamelets-user.html#kamelets-usage-binding){:target="_blank"} any Kamelet to a Knative component. A Kamelet can act as "source" of data or alternatively as "sink". There are several Kamelets available for integrating and connecting to 3rd party services or products, such as Amazon Web Services (AWS), Google Cloud or even tradition message systems like AMQP 1.0 or JMS brokers like Apache Artemis. The full list of Kamelets can be found in the [documentation](https://camel.apache.org/camel-kamelets/latest/index.html){:target="_blank"}.

## Installation

The [Installation](https://camel.apache.org/camel-k/next/installation/installation.html) from Apache Camel K offers a few choices, such as CLI, Kustomize, OLM or Helm. Example of Helm installation:

```
$ helm repo add camel-k https://apache.github.io/camel-k/charts/
$ helm install my-camel-k camel-k/camel-k
```

Besides Camel K we also need to have Knative Eventing installed, as described in the [documentation](https://knative.dev/docs/install/yaml-install/eventing/install-eventing-with-yaml/){:target="_blank"}.

## Creating a Knative Broker instance

We are using a Knative Broker as the heart of our system, acting as an [Event Mesh](https://knative.dev/docs/eventing/event-mesh/){:target="_blank"} for both event producers and event consumers:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  namespace: default
  name: demo-broker
```

Now event producers can send events to it and event consumers can receive events.

## Using Kamelets as Event Sources

In order to bind a Kamelet to a Knative component, like the above broker, we are using the `Pipe` API. A Pipe allows to declaratively move data from a system described by a Kamelet _towards_ a Knative destination **or** _from_ a Knative destination to another (external) system described by a Kamelet.

Below is a `Pipe` that uses a ready-to-use `Kamelet`, a `timer-source`

```yaml
apiVersion: camel.apache.org/v1
kind: Pipe
metadata:
  name: timer-source-pipe
spec:
  source:
    ref:
      kind: Kamelet
      apiVersion: camel.apache.org/v1
      name: timer-source
    properties:
      message: Hello Knative Eventing!
  sink:
    properties:
      cloudEventsType: com.corp.my.timer.source
    ref:
      kind: Broker
      apiVersion: eventing.knative.dev/v1
      name: demo-broker
```

The `timer-source` Kamelet is referenced as the `source` of the `Pipe` and sends periodically (default is `1000ms`) the value of its `message` property to the outbound `sink`. Here we use the Knative Broker, which accepts CloudEvents. The conversion of the message payload to CloudEvents format is done by Apache Camel for us. On the `sink` we can also define the `type` of the CloudEvent to be send.

## Using Kamelets as Event Consumers

In order to consume messages from the Knative broker, using Apache Camel K, we need a different `Pipe` where the above Broker acts as the source of events and a Kamelet is used as sink to receive the CloudEvents: 

```yaml
apiVersion: camel.apache.org/v1
kind: Pipe
metadata:
  name: log-sink-pipe
spec:
  source:
    ref:
      kind: Broker
      apiVersion: eventing.knative.dev/v1
      name: demo-broker
    properties:
      type: com.corp.my.timer.source
  sink:
    ref:
      kind: Kamelet
      apiVersion: camel.apache.org/v1
      name: log-sink
```

The `demo-broker` is referenced as the `source` of the `Pipe` and within the `properties` we define which CloudEvent `type` we are interested in. On a matching CloudEvent, the event is routed to the referenced `sink`. In this example we are using a simple `log-sink` Kamelet, which will just print the received data on its standard out log.


!!! note

    In order for the above to work, the Apache Camel K operator will indeed create a Knative `Trigger` from the `Pipe` data, where the `spec.broker` will match our `demo-broker` and the `spec.filter.attributes.types` field will be set to `com.corp.my.timer.source` to ensure only matching CloudEvent types are being forwarded.

## Conclusion

With Apache Camel K the Knative Eventing ecosystem benefits from a huge number of predefined Kamelets for integration with a lot of services and products. Sending events from Google Cloud to AWS is possible. Knative Eventing acts as the heart of the routing, with the Knative Broker and Trigger APIs as the Event Mesh for your Kubernetes cluster!
