# Knative the easy way (on Google Kubernetes Engine)

This guide walks you through the installation of the latest version of
[Knative serving](https://github.com/knative/serving) using pre-built images on
a Google Kubernetes Engine cluster.

You can find [guides for other platforms here](README.md).

## Prerequisites

### Install gcloud SDK

> If you already have `gcloud` installed, you can skip this section.

1. [Install the Google Cloud SDK](https://cloud.google.com/sdk/).
1. Authorize `gcloud` to use your Google account:

```shell
gcloud auth login
```

### Define environment variables

To simply the command lines for this walkthrough, we need to define a few
environment variables.

If you already have a default project set in `gcloud`, enter:

```shell
export PROJECT_ID=$(gcloud config get-value project)
```

Or, if you don't have an existing GCP project you'd like to use,
replace `my-knative-project` with your desired project ID. This variable will
be used later to create your new GCP project. The project ID must be globally
unique across all GCP projects.

```shell
export PROJECT_ID=my-knative-project
```

Set the following two variables as desired:

```shell
export CLUSTER_NAME=knative
export CLUSTER_ZONE=us-west1-c
```

### Register a Google Cloud Platform Project

If you already have a GCP project configured, make sure your project is set
as your `gcloud` default:

```shell
gcloud config set project $PROJECT_ID
```

If you don't already have a GCP project configured, create a new project:

```shell
gcloud projects create $PROJECT_ID --set-as-default
```

Enable the necessary APIs in this project:

```shell
gcloud services enable \
  cloudapis.googleapis.com \
  container.googleapis.com \
  containerregistry.googleapis.com
```

## Step 1: Create a Kubernetes Cluster

Create a Kubernetes cluster on GKE (large enough to host all the Knative
components). The recommended configuration for a cluster is:

* Kubernetes version 1.10 or later
* 4 vCPU nodes (`n1-standard-4`)
* Node autoscaling, up to 10 nodes
* API scopes for `cloud-platform`, `logging-write`, `monitoring-write`, and
  `pubsub` (if those features will be used)

To create a cluster matching these requriements:

```shell
gcloud container clusters create $CLUSTER_NAME \
  --zone=$CLUSTER_ZONE \
  --cluster-version latest \
  --machine-type n1-standard-4 \
  --enable-autoscaling --min-nodes=1 --max-nodes=10 \
  --scopes=cloud-platform,logging-write,monitoring-write,pubsub \
  --num-nodes 3
```  

After the cluster is created, grant `cluster-admin` permissions to the current
user. These permissions are required to create the necessary
[RBAC rules for Istio](https://istio.io/docs/concepts/security/rbac/).

```shell
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$(gcloud config get-value core/account)
```

## Step 2: Install Istio

Knative depends on Istio, which must be installed first:

```shell
# Install from pre-compiled images
kubectl apply -f https://storage.googleapis.com/knative-releases/latest/istio.yaml

# Label the default namespace with istio-injection=enabled.
kubectl label namespace default istio-injection=enabled
```

Monitor the Istio components, until all of the components report `Running` or
`Completed`:

```shell
kubectl get pods -n istio-system --watch
```

CTRL+C when it's done.

## Step 3: Install Knative Serving

Next, we will install [Knative Serving](https://github.com/knative/serving) and
its dependencies:

```shell
kubectl apply -f https://storage.googleapis.com/knative-releases/latest/release.yaml
```

Monitor the Knative components, until all of the components report `Running`:

```shell
kubectl get pods -n knative-serving --watch
```

CTRL+C when it's done.

You are now ready to deploy apps Now you can deploy your app or function to your
newly created Knative cluster.

## Step 4: Run Hello World

Now that your cluster is running the Knative components, follow the insturctions
for one of the [sample apps](../serving/samples/README.md) to deploy your first
app.

## Cleanup (optional)

Running a cluster in Kubernetes Engine will cost you money, so if you aren't
using it you may wish to delete the cluster when you're done. Deleting the
cluster will also remove Knative, Istio, and any apps you've deployed.

```shell
gcloud container clusters delete $CLUSTER_NAME --zone $CLUSTER_ZONE
```
