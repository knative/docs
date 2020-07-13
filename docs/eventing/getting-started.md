---
title: "Getting Started with Knative Eventing"
linkTitle: "Getting started"
weight: 9
type: "docs"
---

After you install Knative Eventing, you can create, send, and verify events.

This guide shows how you can use a basic workflow for managing events in Knative:

1. [Creating and configuring Knative Eventing Resources](#setting-up-knative-eventing-resources)
1. [Sending events with HTTP requests](#sending-events-to-the-broker)
1. [Verifying events were sent correctly](#verifying-events-were-received)

## Setting up Knative Eventing resources

Before you start to manage events, you must create the objects needed to
transport the events.

### Creating a Knative Eventing namespace

You use namespaces to group together and organize your Knative
resources.
<!--TODO: Add documentation about namespaces to core docs?-->

1. Create a namespace called `event-example` by entering the following command:

  ```sh
  kubectl create namespace event-example
  ```
This creates an empty namespace called `event-example`.

### Add a broker to the namespace

The [`broker`](./broker/README.md#broker) allows you to route events to different event sinks or consumers.

1. Add a broker named `default` to your namespace by entering the following command:

  ```sh
  kubectl create -f - <<EOF
  apiVersion: eventing.knative.dev/v1
  kind: Broker
  metadata:
   name: default
   namespace: event-example
  EOF
  ```

1. Verify that the broker is working correctly, by entering the following command:

```sh
kubectl --namespace event-example get Broker default
```
This shows information about your broker. If the broker is working correctly, it shows a `READY` status of `True`:
```sh
NAME      READY   REASON   URL                                                        AGE
default   True             http://default-broker.event-example.svc.cluster.local      1m
```

If `READY` is `False`, wait 2 minutes and re-run the command.
If you continue to receive the `False` status, see the [Debugging Guide](./debugging/README.md) to troubleshoot the issue.

### Creating event consumers

Your event consumers receive the events sent by event producers. In this step,
you will create two event consumers, `hello-display` and `goodbye-display`, to
demonstrate how you can configure your event producers to selectively target a
specific consumer.

1. To deploy the `hello-display` consumer to your cluster, run the following
   command:

   ```sh
   kubectl --namespace event-example apply --filename - << END
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: hello-display
   spec:
     replicas: 1
     selector:
       matchLabels: &labels
         app: hello-display
     template:
       metadata:
         labels: *labels
       spec:
         containers:
           - name: event-display
             # Source code: https://github.com/knative/eventing-contrib/tree/master/cmd/event_display
             image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display

   ---

   # Service pointing at the previous Deployment. This will be the target for event
   # consumption.
     kind: Service
     apiVersion: v1
     metadata:
       name: hello-display
     spec:
       selector:
         app: hello-display
       ports:
       - protocol: TCP
         port: 80
         targetPort: 8080
   END
   ```

1. To deploy the `goodbye-display` consumer to your cluster, run the following
   command:

   ```sh
   kubectl --namespace event-example apply --filename - << END
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: goodbye-display
   spec:
     replicas: 1
     selector:
       matchLabels: &labels
         app: goodbye-display
     template:
       metadata:
         labels: *labels
       spec:
         containers:
           - name: event-display
             # Source code: https://github.com/knative/eventing-contrib/tree/master/cmd/event_display
             image: gcr.io/knative-releases/knative.dev/eventing-contrib/cmd/event_display

   ---

   # Service pointing at the previous Deployment. This will be the target for event
   # consumption.
   kind: Service
   apiVersion: v1
   metadata:
     name: goodbye-display
   spec:
     selector:
       app: goodbye-display
     ports:
     - protocol: TCP
       port: 80
       targetPort: 8080
   END
   ```

1. Just like you did with the `Broker`, verify that your event consumers are
   working by running the following command:

   ```sh
   kubectl --namespace event-example get deployments hello-display goodbye-display
   ```

   This lists the `hello-display` and `goodbye-display` consumers that you
   deployed:

   ```sh
   NAME              READY   UP-TO-DATE   AVAILABLE   AGE
   hello-display     1/1     1            1           26s
   goodbye-display   1/1     1            1           16s
   ```

   The number of replicas in your **READY** column should match the number of
   replicas in your **AVAILABLE** column, which might take a few minutes. If
   after two minutes the numbers do not match, then see the
   [Debugging Guide](./debugging/README.md) to help troubleshoot the issue.

### Creating `Triggers`

A [Trigger](./broker/README.md#trigger) defines the events that you want each of
your event consumers to receive. Your `Broker` uses triggers to forward events
to the right consumers. Each trigger can specify a filter to select relevant
events based on the Cloud Event context attributes.

1. To create the first `Trigger`, run the following command:

   ```sh
   kubectl --namespace event-example apply --filename - << END
   apiVersion: eventing.knative.dev/v1
   kind: Trigger
   metadata:
     name: hello-display
   spec:
     broker: default
     filter:
       attributes:
         type: greeting
     subscriber:
       ref:
        apiVersion: v1
        kind: Service
        name: hello-display
   END
   ```

   The command creates a trigger that sends all events of type `greeting` to
   your event consumer named `hello-display`.

1. To add the second `Trigger`, run the following command:

   ```sh
   kubectl --namespace event-example apply --filename - << END
   apiVersion: eventing.knative.dev/v1
   kind: Trigger
   metadata:
     name: goodbye-display
   spec:
     broker: default
     filter:
       attributes:
         source: sendoff
     subscriber:
       ref:
        apiVersion: v1
        kind: Service
        name: goodbye-display
   END
   ```

   The command creates a trigger that sends all events of source `sendoff` to
   your event consumer named `goodbye-display`.

1. Verify that the triggers are working correctly by running the following
   command:

   ```sh
   kubectl --namespace event-example get triggers
   ```

   This returns the `hello-display` and `goodbye-display` triggers that you
   created:

   ```sh
   NAME                   READY   REASON   BROKER    SUBSCRIBER_URI                                                                 AGE
   goodbye-display        True             default   http://goodbye-display.event-example.svc.cluster.local/                        9s
   hello-display          True             default   http://hello-display.event-example.svc.cluster.local/                          16s
   ```

   If the triggers are correctly configured, they will be ready and pointing to
   the correct **Broker** (the default broker) and **SUBSCRIBER_URI** has a
   value similar to (triggerName.namespaceName.svc.cluster.local) _exact value
   dependent on Broker implementation_. If this is not the case, see the
   [Debugging Guide](./debugging/README.md) to help troubleshoot the issue.

You have now created all of the resources needed to receive and manage events.
You created the `Broker`, which manages the events sent to event consumers with
the help of triggers. In the next section, you will make the event producer that
will be used to create your events.

### Creating event producers

In this section you will create an event producer that you can use to interact
with the Knative Eventing subcomponents you created earlier. Most events are
created systematically, but this guide uses `curl` to manually send individual
events and demonstrate how these events are received by the correct event
consumer. Because you can only access the `Broker` from within your Eventing
cluster, you must create a `Pod` within that cluster to act as your event
producer.

In the following step, you will create a `Pod` that executes your `curl`
commands to send events to the `Broker` in your Eventing cluster.

To create the `Pod`, run the following command:

```sh
kubectl --namespace event-example apply --filename - << END
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: curl
  name: curl
spec:
  containers:
    # This could be any image that we can SSH into and has curl.
  - image: radial/busyboxplus:curl
    imagePullPolicy: IfNotPresent
    name: curl
    resources: {}
    stdin: true
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    tty: true
END
```

Now that you've set up your Eventing cluster to send and consume events, you
will use HTTP requests to manually send separate events and demonstrate how each
of those events can target your individual event consumers in the next section.

## Sending Events to the `Broker`

Now that you've created the Pod, you can create an event by sending an HTTP
request to the `Broker`. SSH into the `Pod` by running the following command:

```sh
  kubectl --namespace event-example attach curl -it
```

You have sshed into the Pod, and can now make an HTTP request. A prompt similar
to the one below will appear:

```sh
    Defaulting container name to curl.
    Use 'kubectl describe pod/ -n event-example' to see all of the containers in this pod.
    If you don't see a command prompt, try pressing enter.
    [ root@curl:/ ]$
```

To show the various types of events you can send, you will make three requests:

1. To make the first request, which creates an event that has the `type`
   `greeting`, run the following in the SSH terminal:

   ```sh
   curl -v "http://default-broker.event-example.svc.cluster.local" \
     -X POST \
     -H "Ce-Id: say-hello" \
     -H "Ce-Specversion: 1.0" \
     -H "Ce-Type: greeting" \
     -H "Ce-Source: not-sendoff" \
     -H "Content-Type: application/json" \
     -d '{"msg":"Hello Knative!"}'
   ```

   When the `Broker` receives your event, `hello-display` will activate and send
   it to the event consumer of the same name.

   If the event has been received, you will receive a `202 Accepted` response
   similar to the one below:

   ```sh
   < HTTP/1.1 202 Accepted
   < Content-Length: 0
   < Date: Mon, 12 Aug 2019 19:48:18 GMT
   ```

1) To make the second request, which creates an event that has the `source`
   `sendoff`, run the following in the SSH terminal:

   ```sh
   curl -v "http://default-broker.event-example.svc.cluster.local" \
     -X POST \
     -H "Ce-Id: say-goodbye" \
     -H "Ce-Specversion: 1.0" \
     -H "Ce-Type: not-greeting" \
     -H "Ce-Source: sendoff" \
     -H "Content-Type: application/json" \
     -d '{"msg":"Goodbye Knative!"}'
   ```

   When the `Broker` receives your event, `goodbye-display` will activate and
   send the event to the event consumer of the same name.

   If the event has been received, you will receive a `202 Accepted` response
   similar to the one below:

   ```sh
   < HTTP/1.1 202 Accepted
   < Content-Length: 0
   < Date: Mon, 12 Aug 2019 19:48:18 GMT
   ```

1) To make the third request, which creates an event that has the `type`
   `greeting` and the`source` `sendoff`, run the following in the SSH terminal:

   ```sh
   curl -v "http://default-broker.event-example.svc.cluster.local" \
     -X POST \
     -H "Ce-Id: say-hello-goodbye" \
     -H "Ce-Specversion: 1.0" \
     -H "Ce-Type: greeting" \
     -H "Ce-Source: sendoff" \
     -H "Content-Type: application/json" \
     -d '{"msg":"Hello Knative! Goodbye Knative!"}'
   ```

   When the `Broker` receives your event, `hello-display` and `goodbye-display`
   will activate and send the event to the event consumer of the same name.

   If the event has been received, you will receive a `202 Accepted` response
   similar to the one below:

   ```sh
   < HTTP/1.1 202 Accepted
   < Content-Length: 0
   < Date: Mon, 12 Aug 2019 19:48:18 GMT
   ```

1) Exit SSH by typing `exit` into the command prompt.

You have sent two events to the `hello-display` event consumer and two events to
the `goodbye-display` event consumer (note that `say-hello-goodbye` activates
the trigger conditions for _both_ `hello-display` and `goodbye-display`). You
will verify that these events were received correctly in the next section.

## Verifying events were received

After sending events, verify that your events were received by the appropriate
`Subscribers`.

1. Look at the logs for the `hello-display` event consumer by running the
   following command:

   ```sh
   kubectl --namespace event-example logs -l app=hello-display --tail=100
   ```

   This returns the `Attributes` and `Data` of the events you sent to
   `hello-display`:

   ```sh
   ☁️  cloudevents.Event
   Validation: valid
   Context Attributes,
     specversion: 1.0
     type: greeting
     source: not-sendoff
     id: say-hello
     time: 2019-05-20T17:59:43.81718488Z
     contenttype: application/json
   Extensions,
     knativehistory: default-broker-srk54-channel-24gls.event-example.svc.cluster.local
   Data,
     {
       "msg": "Hello Knative!"
     }
   ☁️  cloudevents.Event
   Validation: valid
   Context Attributes,
     specversion: 1.0
     type: greeting
     source: sendoff
     id: say-hello-goodbye
     time: 2019-05-20T17:59:54.211866425Z
     contenttype: application/json
   Extensions,
     knativehistory: default-broker-srk54-channel-24gls.event-example.svc.cluster.local
   Data,
    {
      "msg": "Hello Knative! Goodbye Knative!"
    }
   ```

1. Look at the logs for the `goodbye-display` event consumer by running the
   following command:

   ```sh
   kubectl --namespace event-example logs -l app=goodbye-display --tail=100
   ```

   This returns the `Attributes` and `Data` of the events you sent to
   `goodbye-display`:

   ```sh
   ☁️  cloudevents.Event
   Validation: valid
   Context Attributes,
      specversion: 1.0
      type: not-greeting
      source: sendoff
      id: say-goodbye
      time: 2019-05-20T17:59:49.044926148Z
      contenttype: application/json
    Extensions,
      knativehistory: default-broker-srk54-channel-24gls.event-example.svc.cluster.local
   Data,
      {
        "msg": "Goodbye Knative!"
      }
    ☁️  cloudevents.Event
    Validation: valid
    Context Attributes,
      specversion: 1.0
      type: greeting
      source: sendoff
      id: say-hello-goodbye
      time: 2019-05-20T17:59:54.211866425Z
      contenttype: application/json
    Extensions,
      knativehistory: default-broker-srk54-channel-24gls.event-example.svc.cluster.local
    Data,
     {
       "msg": "Hello Knative! Goodbye Knative!"
     }
   ```

## Cleaning up

After you finish this guide, delete your namespace to conserve resources if you
do not plan to use them.

Note: If you plan to continue learning about Knative Eventing with one of our
[code samples](./samples/), check the requirements of the sample and make sure
you do not need a namespace before you delete `event-example`. You can always
reuse your namespaces.

Run the following command to delete `event-example`:

```sh
kubectl delete namespace event-example
```

This removes the namespace and all of its resources from your cluster.
