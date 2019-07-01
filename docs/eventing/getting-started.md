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

1. Create the Namespace.
2. Create some event consumers.
3. Create triggers.
4. Create event producers.


## Sending Events

Now that the components are created, you can creare a CloudEvent by sending an HTTP request to the Broker.

1. SSH into the Pod.
2. Make a curl request. 
	- To foo
	- To bar
	- To foo and bar
	- To neither foo nor bar
3. Exit SSH.

If everything has been done correctly, you should have sent four CloudEvents: two to foo and two to bar. You will verify this in the next section.

## Verifying Events

After sending events, verify that the events were received by the appropriate subscribers.

1. Look at the logs for the foo event consumer.
2. Look at the logs for the bar event consumer.

If you do not see these results, check the [Debugging Guide](TODO) for more information.

## Cleaning Up

1. Delete the namespace.

## What’s Next 

You've learned the basics of the Knative Eventing workflow. Here are some additional resources to help you continue to build with the Knative Eventing component.

- [Using event importer to consume events](TODO)
- [Configure Broker to Use a Different Channel](TODO)
- [Eventing Concepts](TODO) 


