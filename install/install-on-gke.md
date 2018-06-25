# Knative the easy way

This guide walks you through the installation of the latest version of [Knative](https://github.com/knative/serving) using pre-built images and demonstrates deployment of a sample app onto the newly created Knative cluster.

## Prerequisites

Knative requires a Kubernetes cluster (v1.10 or newer). If you don't have one, you can create one on Google Cloud Platform.
You can also use Minikube; see the [Knative the easy way with Minikube](Knative-with-Minikube.md) guide for instructions.

First, define a few environment variables. If you already have a default project set in `gcloud`, enter:

```shell
export PROJECT_ID=$(gcloud config get-value project)
```

Or, if you don't have an existing GCP project you'd like to use, replace `my-knative-project` with your desired project ID. This variable will be used later to create your new GCP project. The project ID must be globally unique across all GCP projects.

```shell
export PROJECT_ID=my-knative-project
```

Set the following two variables as desired:

```shell
export CLUSTER_NAME=knative
export CLUSTER_ZONE=us-west1-c
```

## Setup

### gcloud CLI

> If you already have `gcloud` installed, you can skip this section. 

Download and install the `gcloud` command line tool:

   https://cloud.google.com/sdk/

Authorize `gcloud`:

```
gcloud auth login
```

### Google Cloud Platform Project

If you already have a GCP project configured, make sure your project is set as your `gcloud` default:

```
gcloud config set project $PROJECT_ID
```

If you don't already have a GCP project configured, create a new project:

```
gcloud projects create $PROJECT_ID --set-as-default
```

Enable the necessary APIs:

```
gcloud services enable \
  cloudapis.googleapis.com \
  container.googleapis.com \
  containerregistry.googleapis.com
```

## Kubernetes

Create a Kubernetes cluster on GKE (large enough to host all the Knative and Istio components):

```
gcloud container clusters create $CLUSTER_NAME \
  --zone=$CLUSTER_ZONE \
  --cluster-version 1.10.2-gke.3 \
  --machine-type n1-standard-4 \
  --enable-autoscaling --min-nodes=1 --max-nodes=10 \
  --scopes=cloud-platform,logging-write,monitoring-write,pubsub \
  --num-nodes 3 \
  --image-type ubuntu
```  

Grant cluster-admin permissions to the current user: 

```bash
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user=$(gcloud config get-value core/account)
```

Admin permissions are required to create the necessary [RBAC rules for Istio](https://istio.io/docs/concepts/security/rbac/).

## Istio

Knative depends on Istio. Install Istio:

```bash
kubectl apply -f https://storage.googleapis.com/knative-releases/latest/istio.yaml

# Label the default namespace with istio-injection=enabled.
kubectl label namespace default istio-injection=enabled
```

Wait until each Istio component is ready (STATUS column shows 'Running' or 'Completed'):

```bash
kubectl get pods -n istio-system --watch
```
CTRL+C when it's done.

## Knative

Next, we will install [Knative](https://github.com/knative/serving):

```bash
kubectl apply -f https://storage.googleapis.com/knative-releases/latest/release.yaml
```

Wait until each Knative component is running (STATUS column shows 'Running'):

```bash
kubectl get pods -n knative-serving-system --watch
```
CTRL+C when it's done.
 
Now you can deploy your app or function to your newly created Knative cluster.

## Test App 

The following instructions will deploy the `Primer` sample app onto your new Knative cluster.

> Note, you will be deploying using a pre-built image so no need to clone the Primer repo or install anything locally. If you want to run the `Primer` app locally, see the [Primer Readme](https://github.com/mchmarny/primer) for instructions. 


```bash
kubectl apply -f https://storage.googleapis.com/knative-samples/primer.yaml
```

Wait for the ingress to obtain a public IP. This may take a few seconds. You can check by running:

```bash
kubectl get ing --watch
```
CTRL+C when it's done.

Capture the IP and host name in environment variables by running these commands:

```bash
export SERVICE_IP=$(kubectl get ing primer-ingress \
  -o jsonpath="{.status.loadBalancer.ingress[0]['ip']}")
  
export SERVICE_HOST=$(kubectl get ing primer-ingress \
  -o jsonpath="{.spec.rules[0]['host']}")
``` 

> Alternatively, you can create an entry in your DNS server to point your subdomain to the IP.

Run the Primer app:

```bash
curl -H "Host: ${SERVICE_HOST}" http://$SERVICE_IP/5000000
```

The higher the number, the longer it will run.

## Cleanup

Delete the Kubernetes cluster, which deletes Knative, Istio, and the Primer sample app:

```
gcloud container clusters delete $CLUSTER_NAME --zone $CLUSTER_ZONE
```
