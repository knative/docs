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
- All Knative Eventing components installed. Information on how to do this is [here](https://knative.dev/docs/install/knative-custom-install/). 

## Creating Components

Before you start to send Knative events, you need to create the components needed to move the events. In this example, you'll be creating components individually, but you can also create components by deploying a [single YAML file](https://raw.githubusercontent.com/akashrv/docs/qs/docs/eventing/samples/hello-world/quick-start.yaml).

### Namespace
First, create the Namespace. In this guide, you will be using a Namespace called "kn-eventing-step-by-step-sample".

1. (Optional) Create a shell variable called `K_NAMESPACE` using the following command:

```sh
K_NAMESPACE=kn-eventing-step-by-step-sample
```

This step prevents you from having to type the same long name multiple times.

2. Create the namespace using this command:

```sh
kubectl create namespace $K_NAMESPACE
```

3. Setup up the namespace for Knative Eventing. To do this, add a label to your namespace with this command:

```sh
kubectl label namespace $K_NAMESPACE knative-eventing-injection=enabled
```

This label triggers Knative to add `Service Accounts`, `Role Bindings`, and a ``Broker`` to your namespace. You'll learn more about `Brokers` in the next section.

### Broker

The `Broker` ensures that every event sent to the `Broker` by event producers is sent to all interested event consumers. While you created the `Broker` when you labeled your Namespace as ready for eventing, it is important to verify that your `Broker` is working.

1. Use the following command to verify that the `Broker` is in a healthy state:

```sh
kubectl -n $K_NAMESPACE get Broker default
```

This should return the following:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-Broker.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

2. If the READY column reads False, wait 2 minutes and repeat Step 1. If the READY column still reads False, see the [Debugging Guide](TODO) to trouble shoot the issue.

Now your `Broker` is ready to manage your events.

### Event Consumers

These components receive the events sent by event producers (you'll create those a little later). You'll create two event consumers, `foo` and `bar`.

*Note: These steps may change, as the current steps in the Hello Word Eventing Solution don't seem to work. Will ask for engineer input here. This is a workaround for now*


To create the `foo` component:

1. Create a YAML file called `foo.yaml`.
2. Copy the following code into `foo.yaml`:
```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-Broker.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```
3. Apply `foo.yaml` to the Namespace.

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-Broker.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

To create the bar component:

1. Create a YAML file called `bar.yaml`.
2. Copy the following code into `bar.yaml`:
```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-Broker.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```
3. Apply `bar.yaml` to the Namespace.

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

Just like the `Broker`, verify that the event consumers are working with the following command:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

This should return:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

### Triggers

`Triggers` allow events to register interest with a `Broker`. A `Trigger` is split into two parts: the Filter, which tracks interested events, and the Subscriber, which determines where the event should be sent. 

*Note: These steps may change, as the current steps in the Hello Word Eventing Solution don't seem to work. Will ask for engineer input here. This is a workaround for now*


For example, to create a `Trigger` to send events to `foo`:

1. Create a YAML file called `trigger.yaml`.
2. Copy the following code into `trigger.yaml`:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

Before you apply the YAML, take notice to the value of the Filter. Every valid CloudEvent has attributes named Type and Source. Triggers allow you to specify interest in specific CloudEvents by matching the CloudEvent's Type and Source. Your YAML is searching for all CloudEvents of type `foo`, regardless of their Source.

Add another trigger to your YAML file for all of the CloudEvents that come from `bar`:

1. Copy the following code into `trigger.yaml`:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

2. Apply `trigger.yaml` to the Namespace.

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

3. Verify that the `Triggers` are running correctly with the following command:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

You should expect to see something like:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

Now, you made a namespace with a `Broker` inside it. Then, you created a pair of event consumers and registered their interest in a certain events by creating `Triggers`.



### Event Producers

Since this tutorial uses manual curl requests to send events, the final component you will need to make is a `Pod`. The `Broker` is only exposed from within the Kubernetes cluster, so we will run the curl request from there.

1. Create a YAML file called `pod.yaml`.
2. Copy the following code into `pod.yaml`:
```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```
3. Apply `pod.yaml` to the Namespace.

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

## Sending Events

Now that the components are created, you can creare a CloudEvent by sending an HTTP request to the `Broker`.

1. SSH into the `Pod` with the following command:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

Now, you can make a curl request. To show the various types of events you can send, you will make four curl requests.

1. To make a request to `foo`, paste the following in the SSH terminal:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

You should receive a `202 Accepted` response.

2. To make a request to `bar`, paste the following in the SSH terminal:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

You should receive a `202 Accepted` response.

3. To make a request to `foo` and `bar`, paste the following in the SSH terminal:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

You should receive a `202 Accepted` response.

4. To make a request to neither `foo` nor `bar`, paste the following in the SSH terminal:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```
You should receive a `202 Accepted` response.

5. Exit SSH with the following command:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

If everything has been done correctly, you should have sent four CloudEvents: two to `foo` and two to `bar`. You will verify this in the next section.

## Verifying Events

After sending events, verify that the events were received by the appropriate subscribers.

1. Look at the logs for the `foo` event consumer with the following command:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

This should return: 

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

2. Look at the logs for the `bar` event consumer with the following command:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

This should return: 

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

If you do not see these results, check the [Debugging Guide](TODO) for more information.

## Cleaning Up

Delete the namespace to conserve resources:

```sh
NAME      READY   REASON   HOSTNAME                                                           AGE
default   True             default-`Broker`.kn-eventing-step-by-step-sample.svc.cluster.local   1m
```

## What’s Next 

You've learned the basics of the Knative Eventing workflow. Here are some additional resources to help you continue to build with the Knative Eventing component.

- [Using event importer to consume events](TODO)
- [Configure `Broker` to Use a Different Channel](TODO)
- [Eventing Concepts](TODO) 


