---
title: "Install on Pivotal Container Service"
linkTitle: "Pivotal Container Service"
weight: 10
type: "docs"
---

This guide walks you through the installation of the latest version of Knative
using pre-built images.

You can find [guides for other platforms here](./README.md).

## Before you begin

Knative requires a Kubernetes cluster v1.11 or newer. `kubectl` v1.10 is also
required. This guide walks you through creating a cluster with the correct
specifications for Knative on Pivotal Container Service.

This guide assumes you are using bash in a Mac or Linux environment; some
commands will need to be adjusted for use in a Windows environment.

### Installing Pivotal Container Service

To install Pivotal Container Service (PKS), follow the documentation at
https://docs.pivotal.io/runtimes/pks/1-1/installing-pks.html.

## Creating a Kubernetes cluster

> NOTE: Knative uses Istio sidecar injection and requires privileged mode for
> your init containers.

To enable privileged mode and create a cluster:

1. Enable privileged mode:
   1. Open the Pivotal Container Service tile in PCF Ops Manager.
   1. In the plan configuration that you want to use, enable both of the
      following:
      - Enable Privileged Containers - Use with caution
      - Disable DenyEscalatingExec
   1. Save your changes.
   1. In the PCF Ops Manager, review and then apply your changes.
1. [Create a cluster](https://docs.pivotal.io/runtimes/pks/1-1/create-cluster.html).

## Access the cluster

To retrieve your cluster credentials, follow the documentation at
https://docs.pivotal.io/runtimes/pks/1-1/cluster-credentials.html.

## Installing Istio

Knative depends on Istio. If your cloud platform offers a managed Istio
installation, we recommend installing Istio that way, unless you need the
ability to customize your installation. For example, the
[GKE Install Guide](./knative-with-gke.md) includes the instructions for
installing Istio on your cluster using `gcloud`.

If you prefer to install Istio manually, if your cloud provider doesn't offer
a managed Istio installation, or if you're installing Knative locally using
Minkube or similar, see the
[Installing Istio for Knative guide](./installing-istio.md).

You must install Istio on your Kubernetes cluster before continuing with these
instructions to install Knative.

## Installing Cert-Manager

Follow the [instructions](../serving/installing-cert-manager.md) to install Cert-Manager if you want to use use [Auto TLS feature](../serving/using-auto-tls.md).

## Installing Knative

The following commands install all available Knative components as well as the
standard set of observability plugins. To customize your Knative installation,
see [Performing a Custom Knative Installation](./Knative-custom-install.md).

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
   --filename https://github.com/knative/serving/releases/download/v0.6.0/serving.yaml \
   --filename https://github.com/knative/build/releases/download/v0.5.0/build.yaml \
   --filename https://github.com/knative/eventing/releases/download/v0.5.0/release.yaml \
   --filename https://github.com/knative/eventing-sources/releases/download/v0.5.0/eventing-sources.yaml \
   --filename https://github.com/knative/serving/releases/download/v0.6.0/monitoring.yaml \
   --filename https://raw.githubusercontent.com/knative/serving/v0.6.0/third_party/config/build/clusterrole.yaml
   ```

1. To complete the install of Knative and its dependencies, run the
   `kubectl apply` command again, this time without the `--selector` flag, to
   complete the install of Knative and its dependencies:

   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.6.0/serving.yaml --selector networking.knative.dev/certificate-provider!=cert-manager \
   --filename https://github.com/knative/build/releases/download/v0.5.0/build.yaml \
   --filename https://github.com/knative/eventing/releases/download/v0.5.0/release.yaml \
   --filename https://github.com/knative/eventing-sources/releases/download/v0.5.0/eventing-sources.yaml \
   --filename https://github.com/knative/serving/releases/download/v0.6.0/monitoring.yaml \
   --filename https://raw.githubusercontent.com/knative/serving/v0.6.0/third_party/config/build/clusterrole.yaml
   ```

   > **Notes**: 
   > - By default, the Knative Serving component installation (`serving.yaml`) includes a controller
   >   for [enabling automatic TLS certificate provisioning](../serving/using-auto-tls.md). If you do
   >   intend on immediately enabling auto certificates in Knative, you can remove the 
   >   `--selector networking.knative.dev/certificate-provider!=cert-manager` statement to install the
   >   controller. 
   >   Otherwise, you can choose to install the auto certificates feature and controller at a later time.
   >   
   > - For the v0.4.0 release and newer, the `clusterrole.yaml` file is
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

To delete the cluster, follow the documentation at
https://docs.pivotal.io/runtimes/pks/1-1/delete-cluster.html.
