---
title: "Install on Azure Kubernetes Service (AKS)"
linkTitle: "Azure Kubernetes Service"
weight: 15
type: "docs"
---

This guide walks you through the installation of the latest version of Knative
using pre-built images.

You can find [guides for other platforms here](./README.md).

## Before you begin

Knative requires a Kubernetes cluster v1.11 or newer. `kubectl` v1.10 is also
required. This guide walks you through creating a cluster with the correct
specifications for Knative on Azure Kubernetes Service (AKS).

This guide assumes you are using bash in a Mac or Linux environment; some
commands will need to be adjusted for use in a Windows environment.

### Installing the Azure CLI

1. If you already have `azure cli` version `2.0.41` or later installed, you can
   skip to the next section and install `kubectl`

Install `az` by following the instructions for your operating system. See the
[full installation instructions](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
if yours isn't listed below. You will need az cli version 2.0.37 or greater.

#### MacOS

```console
brew install azure-cli
```

#### Ubuntu 64-bit

1. Add the azure-cli repo to your sources:
   ```console
   echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
        sudo tee /etc/apt/sources.list.d/azure-cli.list
   ```
1. Run the following commands to install the Azure CLI and its dependencies:
   ```console
   sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
   sudo apt-get install apt-transport-https
   sudo apt-get update && sudo apt-get install azure-cli
   ```

### Installing kubectl

1. If you already have `kubectl`, run `kubectl version` to check your client
   version. If you have `kubectl` v1.10 installed, you can skip to the next
   section and create an AKS cluster

```bash
az aks install-cli
```

## Cluster Setup

Now that we have all the tools, we need a Kubernetes cluster to install Knative.

### Configure your Azure account

First let's identify your Azure subscription and save it for use later.

1. Run `az login` and follow the instructions in the command output to authorize
   `az` to use your account
1. List your Azure subscriptions:
   ```bash
   az account list -o table
   ```

### Create a Resource Group for AKS

To simplify the command lines for this walkthrough, we need to define a few
environment variables. First determine which region you'd like to run AKS in,
along with the resource group you'd like to use.

1. Set `RESOURCE_GROUP` and `LOCATION` variables:

   ```bash
   export LOCATION=eastus
   export RESOURCE_GROUP=knative-group
   export CLUSTER_NAME=knative-cluster
   ```

2. Create a resource group with the az cli using the following command if you
   are using a new resource group.
   ```bash
   az group create --name $RESOURCE_GROUP --location $LOCATION
   ```

### Create a Kubernetes cluster using AKS

Next we will create a managed Kubernetes cluster using AKS. To make sure the
cluster is large enough to host all the Knative and Istio components, the
recommended configuration for a cluster is:

- Kubernetes version 1.11 or later
- Three or more nodes
- Standard_DS3_v2 nodes
- RBAC enabled

1. Enable AKS in your subscription, use the following command with the az cli:
   `bash az provider register -n Microsoft.ContainerService` You should also
   ensure that the `Microsoft.Compute` and `Microsoft.Network` providers are
   registered in your subscription. If you need to enable them:
   `bash az provider register -n Microsoft.Compute az provider register -n Microsoft.Network`
1. Create the AKS cluster!

   ```bash
   az aks create --resource-group $RESOURCE_GROUP \
   --name $CLUSTER_NAME \
   --generate-ssh-keys \
   --kubernetes-version 1.11.5 \
   --enable-rbac \
   --node-vm-size Standard_DS3_v2
   ```

1. Configure kubectl to use the new cluster.

   ```bash
   az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --admin
   ```

1. Verify your cluster is up and running
   ```bash
   kubectl get nodes
   ```

## Installing Istio

> Note: [Gloo](https://gloo.solo.io/) is available as an alternative to Istio.
> Gloo is not currently compatible with the Knative Eventing component.
> [Click here](./Knative-with-Gloo.md) to install Knative with Gloo.

Knative depends on Istio.

1. Install Istio:

   ```bash
   kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.5.2/third_party/istio-1.0.7/istio-crds.yaml && \
   kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.5.2/third_party/istio-1.0.7/istio.yaml
   ```

   Note: the resources (CRDs) defined in the `istio-crds.yaml`file are also
   included in the `istio.yaml` file, but they are pulled out so that the CRD
   definitions are created first. If you see an error when creating resources
   about an unknown type, run the second `kubectl apply` command again.

1. Label the default namespace with `istio-injection=enabled`:

   ```bash
   kubectl label namespace default istio-injection=enabled
   ```

1. Monitor the Istio components until all of the components show a `STATUS` of
   `Running` or `Completed`: `bash kubectl get pods --namespace istio-system`

It will take a few minutes for all the components to be up and running; you can
rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> command to view the component's status updates in real time. Use CTRL + C to
> exit watch mode.

## Installing Knative

The following commands install all available Knative components. To customize
your Knative installation, see
[Performing a Custom Knative Installation](./Knative-custom-install.md).

1. If you are upgrading from Knative 0.3.x: Update your domain and static IP
   address to be associated with the LoadBalancer `istio-ingressgateway` instead
   of `knative-ingressgateway`. Then run the following to clean up leftover
   resources:

   ```
   kubectl delete svc knative-ingressgateway -n istio-system
   kubectl delete deploy knative-ingressgateway -n istio-system
   ```

   If you have the Knative Eventing Sources component installed, you will also
   need to delete the following resource before upgrading:

   ```
   kubectl delete statefulset/controller-manager -n knative-sources
   ```

   While the deletion of this resource during the upgrade process will not
   prevent modifications to Eventing Source resources, those changes will not be
   completed until the upgrade process finishes.

1. To install Knative, first install the CRDs by running the `kubectl apply`
   command once with the `-l knative.dev/crd-install=true` flag. This prevents
   race conditions during the install, which cause intermittent errors:

   ```bash
   kubectl apply --selector knative.dev/crd-install=true \
   --filename https://github.com/knative/serving/releases/download/v0.5.2/serving.yaml \
   --filename https://github.com/knative/build/releases/download/v0.5.0/build.yaml \
   --filename https://github.com/knative/eventing/releases/download/v0.5.0/release.yaml \
   --filename https://github.com/knative/eventing-sources/releases/download/v0.5.0/eventing-sources.yaml \
   --filename https://github.com/knative/serving/releases/download/v0.5.2/monitoring.yaml \
   --filename https://raw.githubusercontent.com/knative/serving/v0.5.2/third_party/config/build/clusterrole.yaml
   ```

1. To complete the install of Knative and its dependencies, run the
   `kubectl apply` command again, this time without the `--selector`
   flag, to complete the install of Knative and its dependencies:

   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.5.2/serving.yaml \
   --filename https://github.com/knative/build/releases/download/v0.5.0/build.yaml \
   --filename https://github.com/knative/eventing/releases/download/v0.5.0/release.yaml \
   --filename https://github.com/knative/eventing-sources/releases/download/v0.5.0/eventing-sources.yaml \
   --filename https://github.com/knative/serving/releases/download/v0.5.2/monitoring.yaml \
   --filename https://raw.githubusercontent.com/knative/serving/v0.5.2/third_party/config/build/clusterrole.yaml
   ```

   > **Note**: For the v0.4.0 release and newer, the `clusterrole.yaml` file is
   > required to enable the Build and Serving components to interact with each
   > other.

1. Monitor the Knative components until all of the components show a `STATUS` of
   `Running`:
   ```bash
   kubectl get pods --namespace knative-serving
   kubectl get pods --namespace knative-build
   kubectl get pods --namespace knative-eventing
   kubectl get pods --namespace knative-sources
   kubectl get pods --namespace knative-monitoring
   ```

## What's next

Now that your cluster has Knative installed, you can see what Knative has to
offer.

To deploy your first app with Knative, follow the step-by-step
[Getting Started with Knative App Deployment](./getting-started-knative-app.md)
guide.

To get started with Knative Eventing, pick one of the
[Eventing Samples](../eventing/samples/) to walk through.

To get started with Knative Build, read the [Build README](../build/README.md),
then choose a sample to walk through.

## Cleaning up

Running a cluster costs money, so you might want to delete the cluster when
you're done if you're not using it. Deleting the cluster will also remove
Knative, Istio, and any apps you've deployed.

To delete the cluster, enter the following command:

```bash
az aks delete --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --yes --no-wait
```
