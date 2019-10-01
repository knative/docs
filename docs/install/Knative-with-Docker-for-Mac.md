---
title: "Install on Docker for Mac OS"
linkTitle: "Docker - Mac OS"
weight: 15
type: "docs"
markup: "mmark"
---

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) using pre-built images and
demonstrates creating and deploying an image of a sample "hello world" app onto
the newly created Knative cluster.

You can find [guides for other platforms here](./README.md).

## Before you begin

Knative requires a Kubernetes cluster v1.14 or newer. If you don't have one, you
can create one using [Docker for Mac](https://docs.docker.com/docker-for-mac/).
If you haven't already,
[install Docker for Mac](https://docs.docker.com/docker-for-mac/install/) before
continuing.

## Creating a Kubernetes cluster

1. After Docker for Mac is installed, configure it with sufficient resources.
   You can do that via the
   [_Advanced_ menu](https://docs.docker.com/docker-for-mac/#advanced) in Docker
   for Mac's preferences. Set **CPUs** to at least **6** and **Memory** to at
   least **8.0 GiB**.
1. Now enable Docker for Mac's
   [Kubernetes capabilities](https://docs.docker.com/docker-for-mac/#kubernetes)
   and wait for the cluster to start up.

## Installing Istio

Knative depends on [Istio](https://istio.io/docs/concepts/what-is-istio/) for
traffic routing and ingress. You have the option of injecting Istio sidecars and
enabling the Istio service mesh, but it's not required for all Knative
components.

If your cloud platform offers a managed Istio installation, we recommend
installing Istio that way, unless you need the ability to customize your
installation.

If you prefer to install Istio manually, if your cloud provider doesn't offer a
managed Istio installation, or if you're installing Knative locally using
Minkube or similar, see the
[Installing Istio for Knative guide](./installing-istio.md).

## Installing Knative Serving

Next, install [Knative Serving](https://github.com/knative/serving).

Because you have limited resources available, use the
`https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml` file,
which installs only Knative Serving:

```shell
curl -L https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --filename -
```

> Note: Unlike minikube, we're not changing the LoadBalancer to a NodePort here.
> Docker for Mac will assign `localhost` as the host for that LoadBalancer,
> making the applications available easily.

Monitor the Knative components until all of the components show a `STATUS` of
`Running`:

```shell
kubectl get pods --namespace knative-serving
```

Just as with the Istio components, it will take a few seconds for the Knative
components to be up and running; you can rerun the command to see the current
status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> command to view the component's status updates in real time. Use CTRL+C to
> exit watch mode.

Now you can deploy an app to your newly created Knative cluster.

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

If you'd like to follow a step-by-step guide for deploying your first app on
Knative, check out the
[Getting Started with Knative App Deployment](../serving/getting-started-knative-app.md)
guide.

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../serving/samples/README.md) repo.

> Note: You can replace the {IP_ADDRESS} placeholder used in the samples with
> `localhost` as mentioned above.

Get started with Knative Eventing by walking through one of the
[Eventing Samples](../eventing/samples/).

[Install Cert-Manager](../serving/installing-cert-manager.md) if you want to use the
[automatic TLS cert provisioning feature](../serving/using-auto-tls.md).

## Cleaning up

Docker for Mac supports several levels of resetting its state and thus cleaning
up.

To reset only the Kubernetes cluster to a fresh one, click "Reset Kubernetes
cluster" in the
[_Reset_ preferences](https://docs.docker.com/docker-for-mac/#reset).


