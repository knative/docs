# Knative Install on Google Kubernetes Engine

This guide walks you through the installation of the latest version of
Knative using pre-built images.

You can find [guides for other platforms here](README.md).

## Before you begin

Knative requires a Kubernetes cluster v1.10 or newer. `kubectl` v1.10 is also
required.  This guide walks you through creating a cluster with the correct
specifications for Knative on Google Cloud Platform.

This guide assumes you are using bash in a Mac or Linux environment; some
commands will need to be adjusted for use in a Windows environment.

### Installing the Google Cloud SDK

1. If you already have `kubectl`, run `kubectl version` to check your client version.

1. If you already have `gcloud` installed with the `kubectl` component later than
   v1.10, you can skip these steps.

1. Download and install the `gcloud` command line tool:
   https://cloud.google.com/sdk/install

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

Set `CLUSTER_NAME` and `CLUSTER_ZONE` variables:

```bash
export CLUSTER_NAME=knative
export CLUSTER_ZONE=us-west1-c
```
The CLUSTER_NAME needs to be lowercase and unique among any other Kubernetes
clusters in your GCP project. The zone can be
[any compute zone available on GCP](https://cloud.google.com/compute/docs/regions-zones/#available).
These variables are used later to create a Kubernetes cluster.

### Setting up a Google Cloud Platform project

You need a GCP project to create a Google Kubernetes Engine cluster.

1. Create a new GCP project and set it as your `gcloud` default, or set an
   existing GCP project as your `gcloud` default:
    * If you don't already have a GCP project created, create a new project in `gcloud`:
      ```bash
      gcloud projects create my-knative-project --set-as-default
      ```
      Replace `my-knative-project` with the name you'd like to use for your GCP project.

      You also need to [enable billing](https://cloud.google.com/billing/docs/how-to/manage-billing-account)
      for your new project.

    * If you already have a GCP project, make sure your project is set as your
      `gcloud` default:
      ```bash
      gcloud config set project my-knative-project
      ```

      > Tip: Enter `gcloud config get-value project` to view the ID of your default GCP project.
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
      --enable-autorepair \
      --scopes=service-control,service-management,compute-rw,storage-ro,cloud-platform,logging-write,monitoring-write,pubsub,datastore \
      --num-nodes=3
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
    kubectl apply -f https://storage.googleapis.com/knative-releases/serving/latest/istio.yaml
    ```
1. Label the default namespace with `istio-injection=enabled`:
    ```bash
    kubectl label namespace default istio-injection=enabled
    ```
1. Monitor the Istio components until all of the components show a `STATUS` of
`Running` or `Completed`:
    ```bash
    kubectl get pods -n istio-system
    ```

It will take a few minutes for all the components to be up and running; you can
rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
  command to view the component's status updates in real time. Use CTRL + C to exit watch mode.

## Installing Knative components

You have the option to install and use only the Knative components that you
want. You can install only the component of Knative if you need that
functionality, for example Knative serving is not required to create and run
builds.

### Installing Knative Serving

1. Run the `kubectl apply` command to install
   [Knative Serving](https://github.com/knative/serving) and its dependencies:
    ```bash
    kubectl apply -f https://storage.googleapis.com/knative-releases/serving/latest/release.yaml
    ```
1. Monitor the Knative serving components until all of the components show a
   `STATUS` of `Running`:
    ```bash
    kubectl get pods -n knative-serving
    ```

### Installing Knative build

1. Run the `kubectl apply` command to install
   [Knative Build](https://github.com/knative/build) and its dependencies:
    ```bash
    kubectl apply -f https://storage.googleapis.com/knative-releases/build/latest/release.yaml
    ```
1. Monitor the Knative build components until all of the components show a
   `STATUS` of `Running`:
    ```bash
    kubectl get pods -n knative-build

Just as with the Istio components, it will take a few seconds for the Knative
components to be up and running; you can rerun the `kubectl get` command to see
the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
  command to view the component's status updates in real time. Use CTRL + C to
  exit watch mode.

You are now ready to deploy an app or create build in your new Knative cluster.

## Deploying apps or builds

Now that your cluster has Knative installed, you're ready to deploy an app or
create a build.

Depending on which Knative component you have installed, there are few options
for getting started:

* You can follow the step-by-step
  [Getting Started with Knative App Deployment](getting-started-knative-app.md)
  guide.

* You can view the available [sample apps](../serving/samples/README.md) and
  deploy one of your choosing.

* To get started by creating a build, see
  (Creating a simple Knative build)[../build/creating-builds.md]

## Cleaning up

Running a cluster in Kubernetes Engine costs money, so you might want to delete
the cluster when you're done if you're not using it. Deleting the cluster will
also remove Knative, Istio, and any apps you've deployed.

To delete the cluster, enter the following command:

```bash
gcloud container clusters delete $CLUSTER_NAME --zone $CLUSTER_ZONE
```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
