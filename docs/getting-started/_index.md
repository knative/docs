---
title: "Getting started"
weight: 01
type: "docs"
showlandingtoc: "false"
---

## About Knative
<!-- TODO: make reusable snippets-->
There are two core Knative components that can be installed and used together or independently to provide different functions:

* [Knative Serving](./serving/): Easily manage stateless services on Kubernetes by reducing the developer effort required for autoscaling, networking, and rollouts.

* [Knative Eventing](./eventing/): Easily route events between on-cluster and off-cluster components by exposing event routing as configuration rather than embedded in code.

To get started with a development Knative installation, you can install Knative components and Kubernetes on a local Docker Daemon by using _Knative on _[`kind`](https://kind.sigs.k8s.io/docs/user/quick-start)_ (`konk`).

`konk` is a shell script that:

1. Runs a script called [`01-kind.sh`](https://github.com/csantanapr/knative-kind/blob/master/01-kind.sh), that checks if `kind` is installed, installs it if not, and then creates a Kubernetes cluster on `kind` called `knative`.
<!--does konk install kind? Confirm-->

1. Runs a script called [`02-serving.sh`](https://github.com/csantanapr/knative-kind/blob/master/02-serving.sh), that:

    1. Installs Knative Serving with Kourier as the default networking layer.
<!-- TODO: Add links for serving and kourier/networking docs sections-->

    1. Installs nip.io as the DNS, and provides a default port-forwarding configuration for the `knative` cluster.

1. Runs a script called [`04-eventing.sh`](https://github.com/csantanapr/knative-kind/blob/master/04-eventing.sh), that installs Knative Eventing, and creates a default InMemoryChannel resource and channel-based broker on the `knative` cluster.
<!--TODO: Add links for channel and broker resources and Knative Eventing docs-->

# Installing Knative using `konk`

To install `konk`, enter the following command:

```
curl -sL install.konk.dev | bash
```

# Install CLI tools

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
