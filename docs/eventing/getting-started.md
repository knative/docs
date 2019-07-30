---
title: "Getting Started with Eventing"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 9
type: "docs"
---

This getting started guide will walk you through all the steps involved in a typical Knative use case. You will learn how to create, send, and verify events in Knative.

## Before you begin

You need:

- A Kubernetes cluster with [Knative Eventing installed](../install/README.md). 

## Setting up Eventing subcomponents

Before you start to send events, you need to create the components needed to transport the events. This guide walks you through creating each Eventing subcomponent.

### Configuring namespace for eventing

In most Knative tutorials, you will operate inside of a namespace. A namespace groups together subcomponents so that you can easily organize them.

1. Create the namespace. This command creates a namespace called **event-example**:

```sh
kubectl create namespace event-example
```

2. Set up the namespace for Knative Eventing. To set up the namespace, add a label to your namespace with this command:

```sh
kubectl label namespace event-example knative-eventing-injection=enabled
```

The `knative-eventing-injection` label triggers Knative to add Knative Eventing subcomponents such as the `Broker` in your namespace.

In the next section, you'll learn more about the `Broker`.

### Validating that the `Broker` is running

The `Broker` ensures that every event sent by event producers is sent to the correct event consumers. While you created the `Broker` when you labeled your namespace as ready for eventing, it is important to verify that your `Broker` is working correctly. In this guide, you will use the default broker.

1. Use the following command to verify that the `Broker` is in a healthy state:

```sh
kubectl -n event-example get Broker default
```

This should return the following:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-Broker.event-example.svc.cluster.local   1m
```

When the `Broker` is **READY**, it can begin to manage the events it receives.

2. If the **READY** column reads **False**, wait 2 minutes and repeat Step 1. If the **READY** column still reads **False**, see the [Debugging Guide](./debugging/README.md) to troubleshoot the issue.

Now your `Broker` is ready to manage events.

### Creating event consumers

These subcomponents receive the events sent by event producers (you'll create those a little later). You'll create two event consumers, `hello-display` and `goodbye-display`, so that you can see how to selectively deliver events to different consumers later.


1. To create the `hello-display` subcomponent, enter the following command:

```sh
kubectl -n event-example apply -f - << END
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
          # Source code: https://github.com/knative/eventing-contrib/blob/release-0.6/cmd/event_display/main.go
          image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display@sha256:37ace92b63fc516ad4c8331b6b3b2d84e4ab2d8ba898e387c0b6f68f0e3081c4

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

2. To create the `goodbye-display` subcomponent, enter the following command:

```sh
kubectl -n event-example apply -f - << END
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
          # Source code: https://github.com/knative/eventing-contrib/blob/release-0.6/cmd/event_display/main.go
          image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display@sha256:37ace92b63fc516ad4c8331b6b3b2d84e4ab2d8ba898e387c0b6f68f0e3081c4

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

3. Just like you did with the `Broker`, verify that the event consumers are working with the following command:

```sh
kubectl -n event-example get deployments hello-display goodbye-display
```

This commmand shows all of the deployments that have been created in `hello-display` and `goodbye-display`. You should have one replica in each event consumer:

```sh
NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-display    1         1         1            1           26s
NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
goodbye-display    1         1         1            1           16s
```

The number of replicas in the **DESIRED** column should match the number of replicas in the **AVAILABLE** column. This may take a few minutes. If after two minutes the numbers still do not match the example, then see the [Debugging Guide](./debugging/README.md).

### Creating `Triggers`

A `Trigger` expresses an event consumer's interest in events it wants to receive. A `Trigger` is split into two parts: the `filter`, which specifies interesting events, and the `subscriber`, which determines where the event should be sent. `Triggers` can match various types of events:

1. To create the first `Trigger` enter the following command:

```sh
kubectl -n event-example apply -f - << END
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: hello-display
spec:
  filter:
    sourceAndType:
      type: greeting
  subscriber:
    ref:
     apiVersion: v1
     kind: Service
     name: hello-display
END
```

Take notice of the attributes of the Filter.  All Knative events use a specification for describing event data called [CloudEvents](https://cloudevents.io/). Every valid CloudEvent has attributes named `type` and `source`. Triggers allow you to specify interest in specific CloudEvents by matching its `type` and `source`. 

In this case, the `Trigger` you created matches all `CloudEvents` of `type` `greeting` and sends them to the event consumer `hello-display`.

2. To add the second `Trigger`, enter the following command:

```sh
kubectl -n event-example apply -f - << END
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: goodbye-display
spec:
  filter:
    sourceAndType:
      source: sendoff
  subscriber:
    ref:
     apiVersion: v1
     kind: Service
     name: goodbye-display
END
```

Here, the command creates a `Trigger` that matches all `CloudEvents` of `source` `sendoff` and sends them to the event consumer `goodbye-display`.

3. Verify that the `Triggers` are running correctly with the following command:

```sh
kubectl -n event-example get triggers
```

This command displays the **NAME**, **Broker**, **SUBSCRIBER_URI**, **AGE** and readiness of the `Triggers` in your namespace. You should see something like this:


```sh
NAME                 READY   REASON   BROKER    SUBSCRIBER_URI                                                                 AGE
goodbye-display          True             default   http://goodbye-display.event-example.svc.cluster.local/   9s
hello-display          True             default   http://hello-display.event-example.svc.cluster.local/    16s
```

Both `Triggers` should be ready and pointing to the correct **Broker**  and **SUBSCRIBER_URI**. If this is not the case, see the [Debugging Guide](./debugging/README.md).

You have now created all of the subcomponents needed to recieve and manage events. In the next section, you will make the subcomponent that will be used to create your events.



### Creating event producers

Since this guide uses manual curl requests to send events, the final subcomponent you will need to make is an event producer called a `Pod`. The `Broker` is only exposed from within the Kubernetes cluster, so you will run the curl request from the `Pod`.

1. To create the `Pod`, enter the following command:

```sh
kubectl -n event-example apply -f - << END
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

You will use this `Pod` to send events in the next section.

## Sending CloudEvents to the `Broker`

Now that the `Pod` is created, you can create a `CloudEvent` by sending an HTTP request to the `Broker`. 

1. SSH into the `Pod` with the following command:

```sh
kubectl -n default attach curl -it
```

Now, you can make a HTTP request. To show the various types of events you can send, you will make three requests.

1. To make the first request, enter the following in the SSH terminal:

```sh
curl -v "default-broker.event-example.svc.cluster.local" \
  -X POST \
  -H "Ce-Id: say-hello" \
  -H "Ce-Specversion: 0.2" \
  -H "Ce-Type: greeting" \
  -H "Ce-Source: not-sendoff" \
  -H "Content-Type: application/json" \
  -d '{"msg":"Hello Knative!"}'
```

This creates a `CloudEvent` that has the `type` `greeting`. When an event is sent to the `Broker`, the `Trigger` `hello-display` will activate and send it to the event consumer of the same name.

If the event has been received, you will receive a `202 Accepted` response.


2. To make the second request, enter the following in the SSH terminal:

```sh
 curl -v "default-broker.event-example.svc.cluster.local" \
  -X POST \
  -H "Ce-Id: say-goodbye" \
  -H "Ce-Specversion: 0.2" \
  -H "Ce-Type: not-greeting" \
  -H "Ce-Source: sendoff" \
  -H "Content-Type: application/json" \
  -d '{"msg":"Goodbye Knative!"}'
```

This creates a `CloudEvent` that has the `source` `sendoff`. When the event is sent to the `Broker`, the `Trigger` `goodbye-display` will activate and send it to the event consumer of the same name.

If the event has been received, you will receive a `202 Accepted` response.


3. To make the third request, paste the following in the SSH terminal:

```sh
 curl -v "default-broker.event-example.svc.cluster.local" \
  -X POST \
  -H "Ce-Id: say-hello-goodbye" \
  -H "Ce-Specversion: 0.2" \
  -H "Ce-Type: greeting" \
  -H "Ce-Source: sendoff" \
  -H "Content-Type: application/json" \
  -d '{"msg":"Hello Knative! Goodbye Knative!"}'
```

This creates a `CloudEvent` that has the `type` `greeting` and the`source` `sendoff`. When the event is sent to the `Broker`, the `Triggers` `hello-display` and `goodbye-display` will activate and send it to the event consumer of the same name.

If the event has been received, you should receive a `202 Accepted` response.

4. Exit SSH.

If everything has been done correctly, you should have sent 2 `CloudEvents` to the `hello-display` event consumer and 2 `CloudEvents` to the `goodbye-display` event consumer (note that `say-hello-goodbye` is sent to *both* `hello-display` and `goodbye-display`). You will verify that these events were received correctly in the next section.

## Verifying events were received 

After sending events, verify that the events were received by the appropriate `Subscribers`.

1. Look at the logs for the `hello-display` event consumer with the following command:

```sh
kubectl -n event-example logs -l app=hello-display
```


The command shows the `Attributes` and `Data` of the events you sent to `hello-display`:

```sh
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.2
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
  specversion: 0.2
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

2. Look at the logs for the `goodbye-display` event consumer with the following command:

```sh
kubectl -n event-example logs -l app=goodbye-display
```

The command shows the `Attributes` and `Data` of the events you sent to `goodbye-display`:


```sh
☁️  cloudevents.Event
 Validation: valid
 Context Attributes,
   specversion: 0.2
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
   specversion: 0.2
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

These results should match up with the events you created in **Sending CloudEvents to the Broker**. If they do not, see the [Debugging Guide](./debugging/README.md) for more information.

## Cleaning up

Delete the namespace to conserve resources:

```sh
kubectl delete namespace event-example
```

## What’s next 

You've learned the basics of the Knative Eventing workflow. Here are some additional resources to help you continue to build with the Knative Eventing component.

- [Knative Eventing Overview](./README.md)
- [Broker and Trigger](./broker-trigger.md)
- [Eventing with a Github source](./samples/github-source.md) 


