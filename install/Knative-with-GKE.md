# Easy Install on Google Kubernetes Engine

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) using pre-built images.

You can find [guides for other platforms here](README.md).

## Before you begin

Knative requires a Kubernetes cluster v1.10 or newer. If you don't have one,
you can create one on Google Cloud Platform. You can also use Minikube; see the
[Easy Install on Minikube](Knative-with-Minikube.md) guide for
instructions. This guide uses Google Kubernetes Engine to create a Kubernetes
cluster.

This guide assumes you are using bash in a Mac or Linux environment; some
commands will need to be adjusted for use in a Windows environment.

### Installing the Google Cloud SDK

> If you already have `gcloud` installed, you can skip these steps. 

1. Download and install the `gcloud` command line tool:
   https://cloud.google.com/sdk/
   
1. Authorize `gcloud`:
    ```
    gcloud auth login
    ```

### Setting environment variables

To simplify the command lines for this walkthrough, we need to define a few
environment variables.

1. Set a `PROJECT_ID` variable.
   * If you already have a default project set in `gcloud`, enter:
      ```bash
      export PROJECT_ID=$(gcloud config get-value project)
      ```
   * Or, if you don't have an existing GCP project you'd like to use, replace
    `my-knative-project` with your desired project ID. This variable will be
    used later to create your new GCP project. The project ID must be globally
    unique across all GCP projects.
      ```bash
      export PROJECT_ID=my-knative-project
      ```
1. Set `CLUSTER_NAME` and `CLUSTER_ZONE` variables as desired:
   ```bash
   export CLUSTER_NAME=knative
   export CLUSTER_ZONE=us-west1-c
   ```

### Setting up a Google Cloud Platform project

You need a Google Cloud Platform project to create a Kubernetes Engine cluster.

1. Create a new GCP project and set it as your `gcloud` default, or set an
   existing GCP as your `gcloud` default.
    * If you already have a GCP project, make sure your project is set as your
    `gcloud` default:
     ```bash
     gcloud config set project $PROJECT_ID
     ```
    * If you don't already have a GCP project configured, create a new project:
     ```bash
     gcloud projects create $PROJECT_ID --set-as-default
     ```
1. Enable the necessary APIs:
   ```
   gcloud services enable \
     cloudapis.googleapis.com \
     container.googleapis.com \
     containerregistry.googleapis.com
   ```

## Creating a Kubernetes cluster

To make sure the cluster is large enough to host all the Knative and
Istio components, the recommended configuration for a cluster is:

* Kubernetes version 1.10 or later
* 4 vCPU nodes (`n1-standard-4`)
* Node autoscaling, up to 10 nodes
* API scopes for `cloud-platform`, `logging-write`, `monitoring-write`, and
  `pubsub` (if those features will be used)

1. Create a Kubernetes cluster on GKE with the required specifications:
    ```
    gcloud container clusters create $CLUSTER_NAME \
      --zone=$CLUSTER_ZONE \
      --cluster-version=latest \
      --machine-type=n1-standard-4 \
      --enable-autoscaling --min-nodes=1 --max-nodes=10 \
      --scopes=cloud-platform,logging-write,monitoring-write,pubsub \
      --num-nodes=3 \
      --image-type=ubuntu
    ```  
1. Grant cluster-admin permissions to the current user: 
    ```bash
    kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)
    ```

Admin permissions are required to create the necessary
[RBAC rules for Istio](https://istio.io/docs/concepts/security/rbac/).

## Installing Istio

Knative depends on Istio.

1. Install Istio:
    ```bash
    kubectl apply -f https://storage.googleapis.com/knative-releases/latest/istio.yaml
    ```
1. Label the default namespace with `istio-injection=enabled`:
    ```bash
    kubectl label namespace default istio-injection=enabled
    ```
1. Monitor the Istio components, until all of the components show a `STATUS` of
`Running` or `Completed`:
    ```bash
    kubectl get pods -n istio-system --watch
    ```

CTRL+C when it's done.

## Installing Knative Serving

1. Next, we will install [Knative Serving](https://github.com/knative/serving)
and its dependencies:
    ```bash
    kubectl apply -f https://storage.googleapis.com/knative-releases/latest/release.yaml
    ```
1. Monitor the Knative components, until all of the components show a `STATUS` of
`Running`:
    ```bash
    kubectl get pods -n knative-serving --watch
    ```

CTRL+C when it's done.

You are now ready to deploy an app to your new Knative cluster.

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

You have two options for deploying your first app:

* You can follow the step-by-step
  [Getting Started with Knative App Deployment](getting-started-knative-app.md)
  guide.

* You can view the available [sample apps](../serving/samples/README.md) and
  deploy one of your choosing.

## Cleaning up

Running a cluster in Kubernetes Engine costs money, so you might want to delete
the cluster when you're done if you're not using it. Deleting the cluster will
also remove Knative, Istio, and any apps you've deployed.

To delete the cluster, enter the following command:

```bash
gcloud container clusters delete $CLUSTER_NAME --zone $CLUSTER_ZONE
```