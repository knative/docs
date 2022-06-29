# Getting started with Knative Eventing using Bitcoin transaction data

**Author: [Johana Saladas](https://twitter.com/developing4data), software engineer at IBM**

**Date: 2020-05-01**

I’ve been exploring [Knative Eventing](https://knative.dev/docs/eventing/), a system that enables a cloud native eventing ecosystem to be easily deployed through the use of **event producers** and **event consumers.** Most of the work on this demo has been done in version 0.11, and I have also run it in version 0.13, and now it also works on version 0.15.

This demo was presented at the first Knative Community Meetup, so you can also watch the video version here:
{{< youtube sGi_LuAaaT0 >}}

I put together a simple demo to explore some of the key advantages of event-driven architectures, such as:

- Push-based messaging.
- Decoupling of producers and consumers.
- Apply business logic while data is in motion.
- Real time event-streams for data science — millisecond decisions e.g fraud detection.

In this post, I’ll show you how to get an example eventing scenario up and running using some of the basic Knative eventing components; **Broker, Trigger, producer** and **consumer.** This demo shows streaming events in real-time, in-stream transformation, and push-based front-ends in action. You can use this as a basis and build out, exploring further with what is possible.

This scenario uses Bitcoin transaction events as an example of an event stream. The events will be displayed in real-time via and UI front-end and also classified into sizes by another service based on their total transaction value.

In the diagram below, you can see a plan of what we will deploy.

![Diagram of this example Knative Eventing scenario](/blog/images/knative-eventing-scenario.png)

There is a github repository to accompany this demo [here](https://github.com/josiemundi/knative-eventing-blockchain-demo). The source code for all of the individual services is available in the github repo. If you want to use the pre-built images from Docker hub then you will only need the files in the yaml directory.

## Step 1: Create the Namespace and create a Broker
```
kubectl apply -f 001-namespace.yaml
```

The first step is to deploy the 001-namespace.yaml, which creates a kubernetes namespace and automatically adds the label knative-eventing-injection=enabled. This creates a Knative Eventing **broker**.

The **Broker** is where events are sent to from an event-source or **producer.** It may be backed as a messaging channel, which by default is in-memory but can be something else (like a Kafka channel). From here they can be consumed by those services that are interested.

## Step 2: Deploy the Bitcoin event-source
```
kubectl apply -f 010-deployment.yaml
```
Our **event-source** is an application that takes (unconfirmed Bitcoin transaction) messages from the [blockchain.info websocket](https://www.blockchain.com/api/api_websocket) and then creates a new [CloudEvent.](https://cloudevents.io/) This is our producer of events and it *produces* events that other services *may or may not* be interested in subscribing to.

In our case we tell it where we want it to send the events, using the **sink** variable. The sink is passed in as an environmental variable in the deployment and, in this case, it is our Broker address. To get the Broker url, you can use the following command:
```
kubectl get broker -n knative-eventing-websocket-source
```
Once you have deployed the event-source, you can verify it is running by getting the logs:
```
kubectl —namespace knative-eventing-websocket-source logs -l app=wseventsource — tail=100 -f
```

## Step 3: Subscribe event-display to the Bitcoin events
```
kubectl apply -f 040-trigger.yaml
```

A **Trigger** provides a filter which selects events matching certain attributes to deliver to the specified service. There are three Triggers specified for this scenario. The subscribing service does not need to be deployed yet in order for you to set up a Trigger.

## Step 4: Deploy our Consuming Services

In our scenario we have *multiple* **consumers.** These are the services that are interested (or not) in the events. There are three consuming services that we have:

- **event-display** — Kubernetes deployment subscribed to events that are from “wss://ws.blockchain.info/inv”. This service takes these events and then displays them in real-time via a UI front-end. This service is a Kubernetes service.
```
kubectl apply -f 050-kubernetesdeploy.yaml
kubectl apply -f 060-kubernetesservice.yaml
```

Once you have deployed this service you can head to localhost:31234 with your web browser and you should see the bitcoin transaction events rendering in real-time in the UI:
![You should see this UI updating in real-time](/blog/images/knative-eventing-UI-real-time.png)

- **classifier** — subscribed to events that are from “wss://ws.blockchain.info/inv”. This service takes the events and then classifies each transaction value. In the application code, a new CloudEvent is created with a new **type** and **source.** These new events are emitted back out into the Knative eventing ecosystem.

![](/blog/images/knative-eventing-classifier.png)

The logic has been kept simple and there are only two size classes; *small* and *large.* It represents an example of an in-stream transformation or modelling application that could be happening as part of a data science or ML process. This type of architecture can be used for fraud detection, anomaly detection and other decisions where speed is critical.
```
kubectl apply -f 031-classifier-service.yaml
```

- **test-display** — Knative service subscribed to events that are from the **type** and **source** ‘classifier’.
```
kubectl apply -f 030-test-display-service.yaml
```

This service subscribes to the events that contain the size of the transaction so we can see these when we view the logs:
```
kubectl logs -l serving.knative.dev/service=test-display -c user-container — tail=100 -n knative-eventing-websocket-source -f
```
![Our test-display service consumes the size reply that is emitted by the classifier](/blog/images/knative-eventing-test-display.png)

## Further Reading
Give the demo a whirl and [let me know](https://twitter.com/developing4data) how you get on!

If you want to learn more, then you can check out some other examples in the [Knative docs](https://knative.dev/docs/samples/eventing). The [‘Knative Cookbook’](https://developers.redhat.com/books/knative-cookbook/?v=1) is another great resource for learning more about Knative Serving and Eventing.
