---
title: "Getting started"
weight: 01
type: "docs"
showlandingtoc: "false"
---

<!-- TODO: make this a reusable snippet-->
There are two core Knative components that can be installed and used together or independently to provide different functions:

* [Knative Serving](./serving/): Easily manage stateless services on Kubernetes by reducing the developer effort required for autoscaling, networking, and rollouts.

* [Knative Eventing](./eventing/): Easily route events between on-cluster and off-cluster components by exposing event routing as configuration rather than embedded in code.

These components are delivered as Kubernetes custom resource definitions (CRDs), which can be configured by a cluster administrator to provide default settings for developer-created applications and event workflow components.

**Note**: Earlier versions of Knative included a build component.  That component has since evolved into the separate [Tekton Pipelines](https://tekton.dev/) project.
<!--/end-->
<!--
- [Installing Knative](./install/)
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
# Prerequisites

## Install `kind`

You can use `kind` (Kubernetes in Docker) to run a local Knative development cluster on a Docker container. See the [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start) documentation for installation options.

## Install `kubectl`

You can run commands against a Kubernetes cluster by using the Kubernetes CLI (`kubectl`). See the [Kubernetes](https://kubernetes.io/docs/tasks/tools/install-kubectl) documentation for installation options.

### Install `kn`

The Knative CLI (`kn`) provides a quick and easy interface for creating Knative resources such as Knative services and event sources, without the need to create or modify YAML files directly. `kn` also simplifies complex procedures such as autoscaling and traffic splitting.

See [Installing `kn`](../client/install-kn) for installation options.

## Installing Knative (sandbox)

The fastest way to get started with Knative locally** is to use _Knative on `kind`_ (`konk`).

!!! todo "Install Knative and Kubernetes on a local Docker Daemon using Konk"
    ```
    curl -sL install.konk.dev | bash
    ```

??? question "What does the KonK script actually do?"
    Knative on Kind (KonK) is a shell script which:

      1. Checks to see that you have Kind installed and creates a Cluster called "knative" via **[`01-kind.sh`](https://github.com/csantanapr/knative-kind/blob/master/01-kind.sh)**

      2. Installs **Knative Serving** with **Kourier** as the networking layer and **nip.io** as the DNS + some port-forwarding magic on the "knative" Cluster via **[`02-serving.sh`](https://github.com/csantanapr/knative-kind/blob/master/02-serving.sh)**

      3. Installs **Knative Eventing** with an In-Memory **Channels** and In-Memory **Broker** on the "knative" Cluster via **[`04-eventing.sh`](https://github.com/csantanapr/knative-kind/blob/master/04-eventing.sh)**
