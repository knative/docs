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

Knative depends on Istio. Istio workloads require privileged mode for Init
Containers

1. Install Istio:

   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.5.0/istio-crds.yaml && \
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.5.0/istio.yaml
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

1. Run the `kubectl apply` command to install Knative and its dependencies:

   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.5.0/serving.yaml \
   --filename https://github.com/knative/build/releases/download/v0.5.0/build.yaml \
   --filename https://github.com/knative/eventing/releases/download/v0.5.0/release.yaml \
   --filename https://github.com/knative/eventing-sources/releases/download/v0.5.0/eventing-sources.yaml \
   --filename https://github.com/knative/serving/releases/download/v0.5.0/monitoring.yaml \
   --filename https://raw.githubusercontent.com/knative/serving/v0.5.0/third_party/config/build/clusterrole.yaml
   ```

   > **Note**: If your install fails on the first attempt, try rerunning the
   > commands. They will likely succeed on the second attempt. For background
   > info and to track the upcoming solution to this problem, see issues
   > [#968](https://github.com/knative/docs/issues/968) and
   > [#1036](https://github.com/knative/docs/issues/1036).

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

To delete the cluster, follow the documentation at
https://docs.pivotal.io/runtimes/pks/1-1/delete-cluster.html.
