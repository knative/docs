---
title: "Creating an event source by using the sample event source"
linkTitle: "Using the sample event source"
weight: 60
type: "docs"
showlandingtoc: "false"
aliases:
  - /docs/eventing/samples/writing-event-source
---

# Creating an event source by using the sample event source

This guide explains how to create your own event source for Knative
Eventing by using a [sample repository](https://github.com/knative-sandbox/sample-source), and explains the key concepts behind each required component. Documentation for the default [Knative event sources](../../sources/) can be used as an additional reference.

After completing the provided tutorial, you will have created a basic event source controller and a receive adapter. Events can be viewed by using the `event_display` Knative service.
<!--TODO: Provide links to docs about what the event source controller and receiver adapter are-->

<!-- Is Go required? Is this for all Knative development or just event source creation?-->

## Prerequisites

- You are familiar with Kubernetes and Go development.
- You have installed Git.
- You have installed Go.
- Clone the [sample source](https://github.com/knative-sandbox/sample-source). <!--optional?-->
<!-- add links, versions if required-->
<!---TODO: decide...Maybe don't list these if they're optional, unless they're called out in a procedure-->

Optional:

- Install the [ko](https://github.com/google/ko/) CLI tool.
- Install the [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) CLI tool.
- Set up [minikube](https://github.com/kubernetes/minikube).

## Steps

1. [Separation of Concerns](./01-theory)
2. [API Definition](./02-lifecycle-and-types)
3. [Controller](./03-controller)
4. [Reconciler](./04-reconciler)
5. [Receive Adapter](./05-receive-adapter)
6. [Example YAML](./06-yaml)
7. [Moving the event source to the `knative-sandbox` organization](./07-knative-sandbox)
