# Orchestrating CloudEvents with Knative and Zeebe

**Author: [Mauricio Salatino (Salaboy)](https://twitter.com/salaboy), Principal Software Engineer @ [Camunda](http://camunda.com) and [LearnK8s](http://learnk8s.io) Instructor**

**Date: 2020-10-10**

A couple of weeks ago, I presented at the **Knative Meetup** ([Video](https://www.youtube.com/watch?v=msDDdqmyEFA&list=PLQjzPfIiEQLIEpoCPxBYAVrjqy6LxLtQ8), [Slides](https://www.slideshare.net/salaboy/orchestrating-cloud-events-knative-meetup-2020)) about how you can leverage the Cloud Native workflow engine [Zeebe](http://zeebe.io) to understand, enhance and orchestrate your applications that are already using [CloudEvents](https://cloudevents.io).

I wanted to expand a bit on how these tools can help you gain a deeper understanding of how your distributed applications are working.

You can find the Demo application, installation instructions, and some videos of the application and the tools in action on [GitHub](https://github.com/salaboy/orchestrating-cloud-events/).

The application that I built consists of four microservices that use [CloudEvents](https://cloudevents.io/) to communicate and perform the typical (happy path) flow of the application: **“Buy Concert Tickets”**. Each service runs as Knative Service using Knative Eventing for exchanging messages with other services.

![Knative Application](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-service-knative.png?raw=true)

The application heavily relies on Knative Eventing as all the services emit events to the broker and register [Knative Triggers (Subscriptions)](https://github.com/salaboy/customer-waiting-room-app/blob/master/charts/customer-waiting-room-app/templates/ktriggers.yaml#L1) to the events that they are interested in.

The following events are being emitted by the application for every single user who wants to buy tickets on our website:

![Application Events](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-events.png?raw=true)

> Note that this Cloud Native application uses [WebSockets](https://en.wikipedia.org/wiki/WebSocket#:~:text=WebSocket%20is%20a%20computer%20communications,being%20standardized%20by%20the%20W3C.), which adds an extra layer of complexity when you think about scaling it.

Even if you have tracing (with something like [OpenTracing](https://opentracing.io) and a centralized logging system, understanding what is going on inside your event-driven applications is quite tricky. Think about it like this -- lets say we have only 10 customers trying to buy tickets at once, understanding where each customer is in the process, or where potential bottlenecks are appearing is challenging.

Until this point, this is just a normal Knative application and, because you are using Knative Eventing which natively supports CloudEvents, you can integrate more tools to the ecosystem as you will see in the next section.

## Visualize / Understand

Without changing anything inside the application code or setup, you can tap into the event stream and map the events that are meaningful for your customer journey and visualize them using [Zeebe](http://zeebe.io) and [Camunda Operate](https://camunda.com/products/cloud/):

![Knative and Zeebe](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-service-knative-zeebe.png?raw=true)

You can start simply by creating a workflow model that consumes the events emitted by the application to report status, as the following model shows:

![Workflow model v1](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-v1.png?raw=true)

This simple workflow model waits for the application events and moves the flow forward when each event arrives. And yes, you guessed it, it works with **CloudEvents** :).

For each customer that joins the queue to buy tickets, a new workflow instance is created to keep track of them. Having these instances allows you to track individual customers and quickly understand where everyone is at a given point in time.

![workflow model instances](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-v1-operate-1.png?raw=true)

Zeebe comes with Camunda Operate, which allows you to see all this information in almost real-time and have a detailed audit trail about the workflow execution and the data associated with it.

![Operate UI](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-v1-operate-2.png?raw=true)

## Decorate / Enhance

Now that you have the power of a workflow engine, you can leverage some of its features to decorate or enhance your applications. An ehnchanced version of the workflow model could look like this:

![Workflow model v2](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-v2.png?raw=true)

Now when the customer reaches the **Payment Sent** state, meaning that they have already made a reservation, the model waits for the **Payment Sent** CloudEvent to arrive.

![timers](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-v2-timers.png?raw=true)

As you can see above, two timer boundary events have been associated with the **Payment Sent** state. The bottom one, with dashed lines, is a non-interrupting event, meaning that it will not disrupt the actual flow, it will be just triggered in a fire-and-forget fashion. This results in the Payment Reminder being sent and, because it can be configured as a recurring timer, it will trigger every X amount of time (for the presentation this was set to 10 seconds).

![Websockets push notification](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-push-notification-websocket.png?raw=true)

The above image shows the notification on the frontend, which was generated by the workflow engine, routed to the website backend and forwarded using WebSockets to the website frontend in the customer browser.

The top one, with solid lines, is an interrupting event, meaning that it will cause the normal flow of the model to be discarded and continue only to the steps defined from the timer (in this case, **Reservation Time Out**). For this scenario, the interrupting timer is set to be triggered after X amount of time after the tickets' reservation was made (for the presentation, this was set to 2 minutes). After the reservation times out, the website redirects the customer back to the beginning.

For both timers, you get full traceability (e.g. when and how often they were triggered). You can see these details graphically in **Operate**:

![Workflow model v2 in Operate](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-v2-timers-operate.png?raw=true)

You can see that the non-interrupting timer was triggered several times, generating payment reminders in the frontend. Even if we don’t implement the frontend notifications, you can use these timers to measure and classify how much time it actually takes your customer to make the payment. This can be really useful to classify different categories; for example, how much time it takes, on average, for people to provide payment details.

A big difference between these timers and [Cronjobs (for example in Kubernetes)](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) is that these timers are contextual to the state that they are associated with, meaning that as soon as the **Payment Sent** CloudEvent is received, both timers are automatically cancelled and garbage collected. For this particular scenario, you want notifications about the payment to be sent but also make sure the reservation doesn’t time out if the payment was sent. The workflow engine deals with these very common requirements in a transparent way for the user who is interested in registering time-based events as part of their applications.

## Orchestrate

The **Payment Reminder** and **Reservation Time Out** status, shown in the model above, represent when we cross the line from simply listening to events to actually emitting CloudEvents from a workflow model. Now the workflow model is not only helping you to visualize and understand what your Cloud Native applications are doing but driving and interacting with your services.

While using a workflow engine to orchestrate CloudEvents, you have a bunch of new tools at your fingertips to deal with more complex scenarios.

Version 3 of the Workflow Model shows a more complex diagram, where a subprocess can be used to group a set of states together. By doing so, you can quickly identify stages inside your workflows, as well as register events for these stages such as timers or message events.

![Workflow Model V3](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-v3.png?raw=true)

The worfklow can react on the CloudEvent **Customer Abandoned Queue** at any given time inside the **Customer Buying Tickets** stage. This will trigger the Customer **Clean Up** event to garbage collect all the data related with the Customer Session from all the services caching data.

In the following screenshot, inside Camunda Operate, you can quickly visualize how many instances of the workflows are at a given stage as well as how many workflows have finished, and in which state they finished:

![Workflow Model V3 in Operate](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-v3-operate-stage.png?raw=true)

Another advantage of using a workflow engine is flow control. By using flow control elements such as Exclusive Gateways, you can delegate some high-level decisions (usually encoding business logic) to the workflow engine:

![Workfloe Model V4](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-v4.png?raw=true)

As you can see in the above model, the exclusive gateway is being used to choose between two different paths based on a condition. In this case, the condition is evaluating how many tickets are being reserved by the customer and, based on that, the model is choosing between a normal credit card payment or a more complex money transfer.

## Architecture & Next Steps

From an architectural perspective, the integration between the Workflow Engine and Knative is quite simple. It relies on **CloudEvents** and a component that is in charge to route the events to the right workflows, and the other way around.

The [Zeebe CloudEvents Router](https://github.com/zeebe-io/zeebe-cloud-events-router) is in charge of exposing an endpoint where events can be forwarded and, at the same time, understand where to push events from workflow models.

![Knative and Zeebe Detailed](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-service-knative-zeebe-detailed.png?raw=true)

As you can see in the above diagram, the **Zeebe CloudEvents Router** is not alone. The [Zeebe Operator](https://github.com/zeebe-io/zeebe-operator), in charge of provisioning or connecting to remote Workflow Engines, has the capacity to deploy and manage workflow definitions. This means that it can parse and understand if a workflow model emits or consume cloud events, information that can be used to dynamically provision [Knative Channels](https://knative.dev/docs/eventing/channels/) and create [Knative Triggers](https://knative.dev/docs/eventing/triggers/) for each model, as it is being done in [Knative Flow (Sequence and Parallel)](https://knative.dev/docs/eventing/flows/).

For example, for version 1 of our workflow model:

![Workflow Model V1](https://github.com/salaboy/orchestrating-cloud-events/blob/master/imgs/tickets-v1.png?raw=true)

The following Knative Triggers are created:

```
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: router-queue-join-trigger
  namespace: default
spec:
  broker: default
  filter:
    attributes:
      type: Queue.CustomerJoined
  subscriber:
    uri: http://zeebe-cloud-events-router.default.svc.cluster.local/message

---
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: router-queue-exit-trigger
  namespace: default
spec:
  broker: default
  filter:
    attributes:
      type: Queue.CustomerExited
  subscriber:
    uri: http://zeebe-cloud-events-router.default.svc.cluster.local/message

---
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: router-tickets-reserved-trigger
  namespace: default
spec:
  broker: default
  filter:
    attributes:
      type: Tickets.Reserved
  subscriber:
    uri: http://zeebe-cloud-events-router.default.svc.cluster.local/message

---
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: router-tickets-payment-sent-trigger
  namespace: default
spec:
  broker: default
  filter:
    attributes:
      type: Tickets.PaymentSent
  subscriber:
    uri: http://zeebe-cloud-events-router.default.svc.cluster.local/message

---
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: router-tickets-payment-authorized-trigger
  namespace: default
spec:
  broker: default
  filter:
    attributes:
      type: Tickets.PaymentsAuthorized
  subscriber:
    uri: http://zeebe-cloud-events-router.default.svc.cluster.local/message
```
As mentioned before, further integrations should deal with more advanced topologies at the messaging layer. For example, being able to logically group workflow models to use a dedicated [Knative Channel](https://knative.dev/docs/eventing/channels/) and [Zeebe CloudEvents Router](https://github.com/zeebe-io/zeebe-cloud-events-router). In future releases, the Zeebe Operator will be aware of the CloudEvents Router to provision and manage the Knative and CloudEvents integration.

## Sum up

In this blog post, I’ve spent some time describing the wonders of what you can do with a Workflow Engine like Zeebe on top of Knative Applications. I’ve personally had a lot of fun while working with Knative, as the abstractions provided helped me to build a very robust application that I can move to different cloud providers easily, without changing any of my services.
Watch this demo live here:
{{< youtube msDDdqmyEFA >}}
The projects and the integration shown in this blog post are in active development, so if you are interested or want to get involved please reach out via twitter: [@salaboy](http://twitter.com/salaboy) or join our slack channel: [zeebe-io.slack.com](http://zeebe-io.slack.com)

If you want to run this demo in your own Kubernetes Cluster you can find the instructions here: [https://github.com/salaboy/orchestrating-cloud-events/](https://github.com/salaboy/orchestrating-cloud-events/) and if you feel like giving the repository a star we will appreciate it :)
