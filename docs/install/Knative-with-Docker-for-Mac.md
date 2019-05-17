---
title: "Install on Docker for Mac OS"
linkTitle: "Docker - Mac OS"
weight: 15
type: "docs"
---

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) using pre-built images and
demonstrates creating and deploying an image of a sample "hello world" app onto
the newly created Knative cluster.

You can find [guides for other platforms here](./README.md).

## Before you begin

Knative requires a Kubernetes cluster v1.11 or newer. If you don't have one, you
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

Knative depends on Istio. Run the following to install Istio. (This changes
`LoadBalancer` to `NodePort` for the `istio-ingress` service).

```shell
curl -L https://raw.githubusercontent.com/knative/serving/v0.5.2/third_party/istio-1.0.7/istio.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --filename -

# Label the default namespace with istio-injection=enabled.
kubectl label namespace default istio-injection=enabled
```

Monitor the Istio components until all of the components show a `STATUS` of
`Running` or `Completed`:

```shell
kubectl get pods --namespace istio-system
```

It will take a few minutes for all the components to be up and running; you can
rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> command to view the component's status updates in real time. Use CTRL+C to
> exit watch mode.

## Installing Knative Serving

Next, install [Knative Serving](https://github.com/knative/serving).

Because you have limited resources available, use the
`https://github.com/knative/serving/releases/download/v0.5.2/serving.yaml` file,
which installs only Knative Serving:

```shell
curl -L https://github.com/knative/serving/releases/download/v0.6.0/serving.yaml \
  | sed 's/LoadBalancer/NodePort/' \
  | kubectl apply --selector networking.knative.dev/certificate-provider!=cert-manager --filename -
```

  **Notes**: 
  > - By default, the Knative Serving component installation (`serving.yaml`) includes a controller
  >   for [enabling automatic TLS certificate provisioning](../serving/using-auto-tls.md). If you do
  >   intend on immediately enabling auto certificates in Knative, you can remove the 
  >   `--selector networking.knative.dev/certificate-provider!=cert-manager` statement to install the
  >   controller. 

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
[Getting Started with Knative App Deployment](./getting-started-knative-app.md)
guide.

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../serving/samples/README.md) repo.

> Note: You can replace the {IP_ADDRESS} placeholder used in the samples with
> `localhost` as mentioned above.

## Cleaning up

Docker for Mac supports several levels of resetting its state and thus cleaning
up.

To reset only the Kubernetes cluster to a fresh one, click "Reset Kubernetes
cluster" in the
[_Reset_ preferences](https://docs.docker.com/docker-for-mac/#reset).

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
