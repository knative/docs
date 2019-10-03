---
title: "Install on Google Kubernetes Engine"
linkTitle: "Google Kubernetes Engine"
weight: 15
type: "docs"
---

This guide walks you through the installation of the latest version of all
Knative components using pre-built images.

You can find [guides for other platforms here](./README.md).

## Before you begin

> [Cloud Run on GKE](https://cloud.google.com/run/docs/gke/setup) is a hosted
> offering on top of GKE that builds around Istio and Knative Serving.

Knative requires a Kubernetes cluster v1.14 or newer, as well as a compatible
`kubectl`. This guide walks you through creating a cluster with the correct
specifications for Knative on Google Cloud Platform (GCP).

This guide assumes you are using `bash` in a Mac or Linux environment; some
commands will need to be adjusted for use in a Windows environment.

### Installing the Google Cloud SDK and `kubectl`

1. If you already have `gcloud` installed with `kubectl`, you can skip these
   steps.

   > Tip: To check which version of `kubectl` you have installed, enter:

   ```
   kubectl version
   ```

1. Download and install the `gcloud` command line tool:
   https://cloud.google.com/sdk/docs/quickstarts

1. Install the `kubectl` component:
   ```
   gcloud components install kubectl
   ```
1. Authorize `gcloud`:
   ```
   gcloud auth login
   ```

### Setting environment variables

To simplify the command lines for this walkthrough, we need to define a few
environment variables.

Set `CLUSTER_NAME` and `CLUSTER_ZONE` variables, you can replace `knative` and
`us-west1-c` with cluster name and zone of your choosing.

The `CLUSTER_NAME` needs to be lowercase and unique among any other Kubernetes
clusters in your GCP project. The zone can be
[any compute zone available on GCP](https://cloud.google.com/compute/docs/regions-zones/#available).
These variables are used later to create a Kubernetes cluster.

```bash
export CLUSTER_NAME=knative
export CLUSTER_ZONE=us-west1-c
```

### Setting up a Google Cloud Platform project

You need a Google Cloud Platform (GCP) project to create a Google Kubernetes
Engine cluster.

1. Set `PROJECT` environment variable, you can replace `my-knative-project` with
   the desired name of your GCP project. If you don't have one, we'll create one
   in the next step.

   ```bash
   export PROJECT=my-knative-project
   ```

1. If you don't have a GCP project, create and set it as your `gcloud` default:

   ```bash
   gcloud projects create $PROJECT --set-as-default
   ```

   You also need to
   [enable billing](https://cloud.google.com/billing/docs/how-to/manage-billing-account)
   for your new project.

1. If you already have a GCP project, make sure your project is set as your
   `gcloud` default:

   ```bash
   gcloud config set core/project $PROJECT
   ```

   > Tip: Enter `gcloud config get-value project` to view the ID of your default
   > GCP project.

1. Enable the necessary APIs:

   ```bash
   gcloud services enable \
     cloudapis.googleapis.com \
     container.googleapis.com \
     containerregistry.googleapis.com
   ```

## Creating a Kubernetes cluster

To make sure the cluster is large enough to host Knative and its dependencies,
the recommended configuration for a cluster is:

- Kubernetes version 1.14 or later
- 4 vCPU nodes (`n1-standard-4`)
- Node autoscaling, up to 10 nodes
- API scopes for `cloud-platform`

1. Create a Kubernetes cluster on GKE with the required specifications:

> Note: If this setup is for development, or a non-Istio networking layer (e.g.
> [Ambassador](./Knative-with-Ambassador.md) or [Gloo](./Knative-with-Gloo.md))
> will be used, then you can remove the `--addons` line below.

> Note: If you want to use [Auto TLS feature](../serving/using-auto-tls.md), you
> need to remove the `--addons` line below, and follow the
> [instructions](../installing-istio.md) to install Istio with Secret Discovery
> Service.

```bash
gcloud beta container clusters create $CLUSTER_NAME \
  --addons=HorizontalPodAutoscaling,HttpLoadBalancing,Istio \
  --machine-type=n1-standard-4 \
  --cluster-version=latest --zone=$CLUSTER_ZONE \
  --enable-stackdriver-kubernetes --enable-ip-alias \
  --enable-autoscaling --min-nodes=1 --max-nodes=10 \
  --enable-autorepair \
  --scopes cloud-platform
```

1. Grant cluster-admin permissions to the current user:

   ```bash
   kubectl create clusterrolebinding cluster-admin-binding \
     --clusterrole=cluster-admin \
     --user=$(gcloud config get-value core/account)
   ```

Admin permissions are required to create the necessary
[RBAC rules for Knative](https://istio.io/docs/concepts/security/rbac/).

## Installing Knative

The following commands install all available Knative components as well as the
standard set of observability plugins. To customize your Knative installation,
see [Performing a Custom Knative Installation](./Knative-custom-install.md).

1. To install Knative, first install the CRDs by running the `kubectl apply`
   command once with the `-l knative.dev/crd-install=true` flag. This prevents
   race conditions during the install, which cause intermittent errors:

   ```bash
   kubectl apply --selector knative.dev/crd-install=true \
   --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml \
   --filename https://github.com/knative/eventing/releases/download/{{< version >}}/release.yaml \
   --filename https://github.com/knative/serving/releases/download/{{< version >}}/monitoring.yaml
   ```

1. To complete the install of Knative and its dependencies, run the
   `kubectl apply` command again, this time without the `--selector` flag, to
   complete the install of Knative and its dependencies:

   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml \
   --filename https://github.com/knative/eventing/releases/download/{{< version >}}/release.yaml \
   --filename https://github.com/knative/serving/releases/download/{{< version >}}/monitoring.yaml
   ```

1. Monitor the Knative components until all of the components show a `STATUS` of
   `Running`:

   ```bash
   kubectl get pods --namespace knative-serving
   kubectl get pods --namespace knative-eventing
   kubectl get pods --namespace knative-monitoring
   ```

## What's next

Now that your cluster has Knative installed, you can see what Knative has to
offer.

To deploy your first app with the
[Getting Started with Knative App Deployment](../serving/getting-started-knative-app.md)
guide.

Get started with Knative Eventing by walking through one of the
[Eventing Samples](../eventing/samples/).

[Install Cert-Manager](../serving/installing-cert-manager.md) if you want to use
the [automatic TLS cert provisioning feature](../serving/using-auto-tls.md).

## Cleaning up

Running a cluster in Kubernetes Engine costs money, so you might want to delete
the cluster when you're done if you're not using it. Deleting the cluster will
also remove Knative, Istio, and any apps you've deployed.

To delete the cluster, enter the following command:

```bash
gcloud container clusters delete $CLUSTER_NAME --zone $CLUSTER_ZONE
```
