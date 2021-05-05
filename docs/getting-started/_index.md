---
title: "Getting started"
weight: 01
type: "docs"
showlandingtoc: "false"
---

## Installing Knative

To get started with a development Knative installation, you can install Knative components and Kubernetes on a local Docker Daemon by using _Knative on [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start)_ (`konk`).

## Prerequisites

- Install [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start) before you use `konk`.

## About `konk`

`konk` is a shell script that:
<!--does konk install kind? Confirm-->
1. Runs a script called [`01-kind.sh`](https://github.com/csantanapr/knative-kind/blob/master/01-kind.sh), that checks if `kind` is installed. If `kind` is installed, the script creates a Kubernetes cluster on `kind` called `knative`.
1. Runs a script called [`02-serving.sh`](https://github.com/csantanapr/knative-kind/blob/master/02-serving.sh), that:
    - Installs Knative Serving with Kourier as the default networking layer.
    - Installs nip.io as the DNS, and provides a default port-forwarding configuration for the `knative` cluster.
1. Runs a script called [`04-eventing.sh`](https://github.com/csantanapr/knative-kind/blob/master/04-eventing.sh), that installs Knative Eventing, and creates a default InMemoryChannel resource and channel-based broker on the `knative` cluster.
<!-- TODO: Add links for serving and kourier/networking docs sections-->
<!--TODO: Add links for channel and broker resources and Knative Eventing docs-->

## Installing Knative using `konk`

To install `konk`, enter the following command:

```
curl -sL install.konk.dev | bash
```

## Install CLI tools

You can interact with your Knative on your cluster by using the `kubectl` and `kn` CLI tools.

- `kubectl` is used primarily to complete Kubernetes cluster administrator tasks.
<!-- TODO: Add link to admin guide-->
- `kn` is used primarily by developers to create Knative components and set up workflows.

For more information, see the [CLI tools](../client) documentation.
<!--
- [Getting started with app deployment](./serving/getting-started-knative-app/)
- [Getting started with serving](./serving/)
- [Getting started with eventing](./eventing/)

### Samples and demos

- [Autoscaling](./serving/autoscaling/autoscale-go/)
- [Binding running services to eventing ecosystems](./eventing/samples/kubernetes-event-source/)
- [REST API sample](./serving/samples/rest-api-go/)
- [All samples for serving](./serving/samples/)
- [All samples for eventing](./eventing/samples/)

### Debugging

- [Debugging application issues](./serving/debugging-application-issues/)
-->

## Create an app

Applications in Knative are represented as Knative services (`ksvc`). Services are `Service` Kubernetes custom resources. See [Creating Knative services](../developer/services/creating-services/).

<!-- TODO: check if we can combine these two-->
## Deploy an app

After you have created an app, you can deploy it as a Knative service. See [Getting Started with App Deployment](../getting-started-knative-app/).
