---
title: "Getting Started with Eventing"
#linkTitle: "OPTIONAL_ALTERNATE_NAV_TITLE"
weight: 9
type: "docs"
---

This getting started guide will walk you through all the steps involved in a typical Knative workflow. You will learn how to create, send, and verify Knative events.

## Before You Begin

You need:

- A Kubernetes cluster with [Knative installed](https://knative.dev/docs/install/index.html).
- All Knative Eventing components installed. Information on how to install the Eventing components is [here](https://knative.dev/docs/install/knative-custom-install/). 

## Set Up Components

Before you start to send Knative events, you need to create the components needed to move the events. In this guide, you will be creating components individually, but you can also create components by deploying a [single YAML file](https://raw.githubusercontent.com/akashrv/docs/qs/docs/eventing/samples/hello-world/quick-start.yaml).

### Configure Namespace For Eventing

First, create the `namespace`. In this guide, you will be using the default `namespace`.

1. Create the `namespace` using this command:

```sh
kubectl create namespace default
```

2. Set up up the `namespace` for Knative Eventing. To set up the `namespace`, add a label to your `namespace` with this command:

```sh
kubectl label namespace default knative-eventing-injection=enabled
```

This label triggers Knative to add `Service Accounts`, `Role Bindings`, and a `Broker` to your `namespace`. You'll learn more about `Brokers` in the next section.

### Examine Broker For Issues

The `Broker` ensures that every event sent to the `Broker` by event producers is sent to all interested `event consumers`. While you created the `Broker` when you labeled your `namespace` as ready for eventing, it is important to verify that your `Broker` is working correctly.

1. Use the following command to verify that the `Broker` is in a healthy state:

```sh
kubectl -n default get Broker default
```

This should return the following:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-Broker.default.svc.cluster.local   1m
```

2. If the **READY** column reads **False**, wait 2 minutes and repeat Step 1. If the **READY** column still reads **False**, see the [Debugging Guide](./debugging/README.md) to troubleshoot the issue.

Now your `Broker` is ready to manage your events.

### Create Event Consumers

These components receive the events sent by event producers (you'll create those a little later). You'll create two event consumers, `foo` and `bar`, so that you can see how to selectively send events to distinct event consumers later.



To create the `foo` component:

1. Copy the following code:

```sh
kubectl -n default apply -f - << END
apiVersion: apps/v1
kind: Deployment
metadata:
  name: foo-display
spec:
  replicas: 1
  selector:
    matchLabels: &labels
      app: foo-display
  template:
    metadata:
      labels: *labels
    spec:
      containers:
        - name: event-display
          # Source code: https://github.com/knative/eventing-sources/blob/release-0.6/cmd/event_display/main.go
          image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display@sha256:37ace92b63fc516ad4c8331b6b3b2d84e4ab2d8ba898e387c0b6f68f0e3081c4

---

# Service pointing at the previous Deployment. This will be the target for event
# consumption.
kind: Service
apiVersion: v1
metadata:
  name: foo-display
spec:
  selector:
    app: foo-display
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
END
```

2. Paste into your terminal window.


To create the `bar` component:

1. Copy the following code:

```sh
kubectl -n default apply -f - << END
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bar-display
spec:
  replicas: 1
  selector:
    matchLabels: &labels
      app: bar-display
  template:
    metadata:
      labels: *labels
    spec:
      containers:
        - name: event-display
          # Source code: https://github.com/knative/eventing-sources/blob/release-0.6/cmd/event_display/main.go
          image: gcr.io/knative-releases/github.com/knative/eventing-sources/cmd/event_display@sha256:37ace92b63fc516ad4c8331b6b3b2d84e4ab2d8ba898e387c0b6f68f0e3081c4

---

# Service pointing at the previous Deployment. This will be the target for event
# consumption.
kind: Service
apiVersion: v1
metadata:
  name: bar-display
spec:
  selector:
    app: bar-display
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
END
```

2. Paste into your terminal window.

Just like the `Broker`, verify that the event consumers are working with the following command:

```sh
kubectl -n default get deployments foo-display bar-display
```

This should return:

```sh
NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
foo-display    1         1         1            1           16m
NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
bar-display    1         1         1            1           16m
```

The number in the **DESIRED** column should match the number in the **AVAILABLE** column. This may take a few minutes. If after two minutes the numbers still do not match the example, then see the [Debugging Guide](./debugging/README.md).

### Create Triggers

`Triggers` allow events to register interest with a `Broker`. A `Trigger` is split into two parts: the `Filter`, which tracks interested events, and the `Subscriber`, which determines where the event should be sent. 

For example, to create a `Trigger` to send events to `foo`:

1. Copy the following code:

```sh
kubectl -n default apply -f - << END
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: foo-display
spec:
  filter:
    sourceAndType:
      type: foo
  subscriber:
    ref:
     apiVersion: v1
     kind: Service
     name: foo-display
END
```

2. Paste into your terminal window.

Take notice of the attributes of the `Filter`. Every valid `CloudEvent` has attributes named `Type` and `Source`. Triggers allow you to specify interest in specific `CloudEvents` by matching the `CloudEvent's` `Type` and `Source`. Here, the command searches for all `CloudEvents` of type `foo`, regardless of their `Source`.

Add another `Trigger` to send events to `bar`:

1. Copy the following code:

```sh
kubectl -n default apply -f - << END
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: bar-display
spec:
  filter:
    sourceAndType:
      source: bar
  subscriber:
    ref:
     apiVersion: v1
     kind: Service
     name: bar-display
END
```

2. Paste into your terminal window.


3. Verify that the `Triggers` are running correctly with the following command:

```sh
kubectl -n default get triggers
```

You should expect to see something like:

```sh
NAME                 READY   REASON   BROKER    SUBSCRIBER_URI                                                                 AGE
bar-display          True             default   http://bar-display.default.svc.cluster.local/   9s
foo-display          True             default   http://foo-display.default.svc.cluster.local/    16s
```

You now have a `namespace` with a `Broker` inside it. You also have a pair of event consumers with their interest registered in certain kinds of events by creating `Triggers`.



### Create Event Producers

Since this guide uses manual curl requests to send events, the final component you will need to make is an event producer called a `Pod`. The `Broker` is only exposed from within the Kubernetes cluster, so you will run the curl request from there.

1. Copy the following code:

```sh
kubectl -n default apply -f - << END
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

2. Paste into your terminal window.

## Send CloudEvents to the Broker

Now that the Pod is created, you can create a CloudEvent by sending an HTTP request to the `Broker`.

1. SSH into the `Pod` with the following command:

```sh
kubectl -n default attach curl -it
```

Now, you can make a curl request. To show the various types of events you can send, you will make three curl requests.

1. To make a request to `foo`, paste the following in the SSH terminal:

```sh
curl -v "default-broker.default.svc.cluster.local" \
  -X POST \
  -H "Ce-Id: should-be-seen-by-foo" \
  -H "Ce-Specversion: 0.2" \
  -H "Ce-Type: foo" \
  -H "Ce-Source: anything-but-bar" \
  -H "Content-Type: application/json" \
  -d '{"msg":"Hello World event from Knative - Foo"}'
```

You should receive a `202 Accepted` response.

2. To make a request to `bar`, paste the following in the SSH terminal:

```sh
 curl -v "default-broker.default.svc.cluster.local" \
  -X POST \
  -H "Ce-Id: should-be-seen-by-test" \
  -H "Ce-Specversion: 0.2" \
  -H "Ce-Type: anything-but-foo" \
  -H "Ce-Source: bar" \
  -H "Content-Type: application/json" \
  -d '{"msg":"Hello World event from Knative - Bar"}'
```

You should receive a `202 Accepted` response.

3. To make a request to `foo` and `bar`, paste the following in the SSH terminal:

```sh
 curl -v "default-broker.default.svc.cluster.local" \
  -X POST \
  -H "Ce-Id: should-be-seen-by-test" \
  -H "Ce-Specversion: 0.2" \
  -H "Ce-Type: foo" \
  -H "Ce-Source: bar" \
  -H "Content-Type: application/json" \
  -d '{"msg":"Hello World event from Knative - Both"}'
```

You should receive a `202 Accepted` response.


4. Exit SSH.

If everything has been done correctly, you should have sent 3 `CloudEvents`. You will verify that the events were received correctly in the next section.

## Verify Events Were Received 

After sending events, verify that the events were received by the appropriate `Subscribers`.

1. Look at the logs for the `foo` event consumer with the following command:

```sh
kubectl -n default logs -l app=foo-display
```

This should return: 

```sh
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.2
  type: foo
  source: anything-but-bar
  id: should-be-seen-by-foo
  time: 2019-05-20T17:59:43.81718488Z
  contenttype: application/json
Extensions,
  knativehistory: default-broker-srk54-channel-24gls.default.svc.cluster.local
Data,
  {
    "msg": "Hello World event from Knative - Foo"
  }
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.2
  type: foo
  source: bar
  id: should-be-seen-by-test
  time: 2019-05-20T17:59:54.211866425Z
  contenttype: application/json
Extensions,
  knativehistory: default-broker-srk54-channel-24gls.default.svc.cluster.local
Data,
  {
    "msg": "Hello World event from Knative - Both"
  }
```

2. Look at the logs for the `bar` event consumer with the following command:

```sh
kubectl -n default logs -l app=bar-display
```

This should return: 

```sh
☁️  cloudevents.Event
 Validation: valid
 Context Attributes,
   specversion: 0.2
   type: anything-but-foo
   source: bar
   id: should-be-seen-by-test
   time: 2019-05-20T17:59:49.044926148Z
   contenttype: application/json
 Extensions,
   knativehistory: default-broker-srk54-channel-24gls.default.svc.cluster.local
 Data,
   {
     "msg": "Hello World event from Knative - Bar"
   }
 ☁️  cloudevents.Event
 Validation: valid
 Context Attributes,
   specversion: 0.2
   type: foo
   source: bar
   id: should-be-seen-by-test
   time: 2019-05-20T17:59:54.211866425Z
   contenttype: application/json
 Extensions,
   knativehistory: default-broker-srk54-channel-24gls.default.svc.cluster.local
 Data,
   {
     "msg": "Hello World event from Knative - Both"
   } 
```

If you do not see these results, see the [Debugging Guide](./debugging/README.md) for more information.

## Clean Up

Delete the namespace to conserve resources:

```sh
kubectl delete namespace default
```

## What’s Next 

You've learned the basics of the Knative Eventing workflow. Here are some additional resources to help you continue to build with the Knative Eventing component.

- [Using event importer to consume events](TODO)
- [Configure `Broker` to Use a Different Channel](https://github.com/Harwayne/knative-eventing/blob/sample-3/configure-broker-to-use-a-different-channel.md)
- [Eventing Concepts](TODO) 


