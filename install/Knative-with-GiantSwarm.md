# Knative Install on Giant Swarm cluster

This guide walks you through the installation of the latest version of
Knative using pre-built images.

You can find [guides for other platforms here](README.md).

## Before you begin

Knative requires a Kubernetes cluster v1.10 or newer. `kubectl` v1.10 is also
required.  This guide walks you through creating a cluster with the correct
specifications for Knative on Giant Swarm managed cluster.

This guide assumes you are using bash in a Mac or Linux environment; some
commands will need to be adjusted for use in a Windows environment.

### Installing the Giant Swarm CLI

1. If you already have `gsctl` version `0.14.1` or later installed, you can skip to the next section and install `kubectl`

Install `gsctl` by following the instructions for your operating system.
See the [full installation instructions](https://docs.giantswarm.io/reference/gsctl/#install).

#### MacOS

```console
brew tap giantswarm/giantswarm
brew install gsctl
```

#### Linux 64-bit

```console
curl -O https://downloads.giantswarm.io/gsctl/0.14.1/gsctl-0.14.1-linux-amd64.tar.gz
tar xzf gsctl-0.14.1-linux-amd64.tar.gz
sudo cp gsctl-0.14.1-linux-amd64/gsctl /usr/local/bin/
```

### Installing kubectl

1.  If you already have `kubectl` CLI, run `kubectl version --short` to check
    the version. You need v1.10 or newer. If your `kubectl` is older, follow the
    next step to install a newer version.

2.  [Install the kubectl CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl).

## Cluster Setup

Now that we have all the tools, we need a Kubernetes cluster to install Knative.

### Configure your Giant Swarm installation

First let's identify your Giant Swarm installation and save it for use later.

1. Run `gsctl login <user@example.com> --endpoint <api.example.com>` replacing with your email account and your installation API endpoint.
1. Test your gsctl connection:
    ```bash
    gsctl ping
    ```

### Create a Kubernetes cluster using AKS

Next we will create a managed Kubernetes cluster in your Giant Swarm organisation. To make sure the cluster is large enough to host all the Knative and Istio components, the recommended configuration for a cluster is:

* Kubernetes version 1.10 or later
* Three or more nodes
* Standard_DS3_v2 nodes
* RBAC is enabled by default

1. Create the Giant Swarm cluster
    ```bash
    gsctl create cluster \
        --name 'Knative cluster' \
        --owner my-organisation \
        --azure-vm-size Standard_DS3_v2 \ 
        --num-workers 3
    ```

1. Get id of your created cluster
    ```bash
    gsctl list clusters

    ID     ORGANIZATION       NAME                                   RELEASE  CREATED
    2edvr  my-organisation    Knative cluster                        2.0.1    2018 Nov 15, 15:06 UTC
    ```

1. Configure kubectl to use the new cluster.
    ```bash
    gsctl create kubeconfig --cluster=2edvr --certificate-organizations='system:masters'
    ```

    > As RBAC is configured by default on the cluster, you have to be part of `system:masters` to be admin on the cluster.

1. Verify your cluster is up and running
    ```bash
    kubectl get nodes
    ```

## Installing Istio

Knative depends on Istio.

1. Install Istio:
    ```bash
    kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.2.1/third_party/istio-1.0.2/istio.yaml
    ```
1. Label the default namespace with `istio-injection=enabled`:
    ```bash
    kubectl label namespace default istio-injection=enabled
    ```

1. Monitor the Istio components until all of the components show a `STATUS` of
`Running` or `Completed`:
    ```bash
    kubectl get pods --namespace istio-system
    ```

It will take a few minutes for all the components to be up and running; you can
rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
  command to view the component's status updates in real time. Use CTRL + C to exit watch mode.

## Installing Knative components

You can install the Knative Serving and Build components together, or Build on its own.

### Installing Knative Serving and Build components

1. Run the `kubectl apply` command to install Knative and its dependencies:
    ```bash
    kubectl apply --filename https://github.com/knative/serving/releases/download/v0.2.1/release.yaml
    ```
1. Monitor the Knative components until all of the components show a
   `STATUS` of `Running`:
    ```bash
    kubectl get pods --namespace knative-serving
    kubectl get pods --namespace knative-build
    ```

### Installing Knative Build only

1. Run the `kubectl apply` command to install
   [Knative Build](https://github.com/knative/build) and its dependencies:
    ```bash
    kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.2.1/third_party/config/build/release.yaml
    ```
1. Monitor the Knative Build components until all of the components show a
   `STATUS` of `Running`:
    ```bash
    kubectl get pods --namespace knative-build

Just as with the Istio components, it will take a few seconds for the Knative
components to be up and running; you can rerun the `kubectl get` command to see
the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
  command to view the component's status updates in real time. Use CTRL + C to
  exit watch mode.

You are now ready to deploy an app or create a build in your new Knative
cluster.

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

You have two options for deploying your first app:

* You can follow the step-by-step
  [Getting Started with Knative App Deployment](getting-started-knative-app.md)
  guide.

* You can view the available [sample apps](../serving/samples/README.md) and
  deploy one of your choosing.

## Cleaning up

Running a cluster costs money, so you might want to delete the cluster when you're done if 
you're not using it. Deleting the cluster will also remove Knative, Istio, 
and any apps you've deployed.

To delete the cluster, enter the following command:
```bash
gsctl delete cluster -c 2edvr
```
