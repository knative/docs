---
title: "Install on IBM Cloud Kubernetes Service (IKS)"
linkTitle: "IBM Cloud Kubernetes Service"
weight: 10
type: "docs"
---

This guide walks you through the installation of the latest version of Knative
on an IBM Cloud Kubernetes Service (IKS) cluster.

You can find [guides for other platforms here](./README.md).

## Before you begin

Knative requires a Kubernetes cluster v1.11 or newer. This guide walks you
through creating a cluster with the correct specifications for Knative on IBM
Cloud Kubernetes Service.

This guide assumes you are using bash in a Mac or Linux environment; some
commands need to be adjusted for use in a Windows environment.

### Installing the IBM Cloud developer tools

> If you already have `ibmcloud` installed with the `ibmcloud cs` plugin, you
> can skip these steps.

1.  Download and install the `ibmcloud` command line tool:
    https://console.bluemix.net/docs/cli/index.html#overview

1.  Install the `cs` (container-service) plugin:
    ```bash
    ibmcloud plugin install container-service -r Bluemix
    ```
1.  Authorize `ibmcloud`:
    ```bash
    ibmcloud login
    ```

### Setting environment variables

To simplify the command lines for this walkthrough, you need to define a few
environment variables.

1.  Set `CLUSTER_NAME`, `CLUSTER_REGION`, and `CLUSTER_ZONE` variables:

    ```bash
    export CLUSTER_NAME=knative
    export CLUSTER_REGION=us-south
    export CLUSTER_ZONE=dal13
    ```

    - `CLUSTER_NAME` must be lowercase and unique among any other Kubernetes
      clusters in this IBM Cloud region.
    - `CLUSTER_REGION` can be any region where IKS is available. You can get a
      list of all available regions via the
      [IBM Cloud documentation](https://console.bluemix.net/docs/containers/cs_regions.html#regions-and-zones)
      or via `ibmcloud cs regions`.
    - `CLUSTER_ZONE` can be any zone that is available in the specified region
      above. You can get a list of all avaible locations from the
      [IBM Cloud documentation](https://console.bluemix.net/docs/containers/cs_regions.html#zones)
      or by using `ibmcloud cs zones` after you set the region by using
      `ibmcloud cs region-set $CLUSTER_REGION`.

### Creating a Kubernetes cluster

To make sure the cluster is large enough to host all the Knative and Istio
components, the recommended configuration for a cluster is:

- Kubernetes version 1.11 or later
- 4 vCPU nodes with 16GB memory (`b2c.4x16`)

1.  Set `ibmcloud` to the appropriate region:

    ```bash
    ibmcloud cs region-set $CLUSTER_REGION
    ```

1.  Create a Kubernetes cluster on IKS with the required specifications:

    ```bash
    ibmcloud cs cluster-create --name=$CLUSTER_NAME \
      --zone=$CLUSTER_ZONE \
      --machine-type=b2c.4x16 \
      --workers=3
    ```

    If you're starting in a fresh account with no public and private VLANs, they
    are created automatically for you. If you already have VLANs configured in
    your account, get them via `ibmcloud cs vlans --zone $CLUSTER_ZONE` and
    include the public/private VLAN in the `cluster-create` command:

    ```bash
    ibmcloud cs cluster-create --name=$CLUSTER_NAME \
      --zone=$CLUSTER_ZONE \
      --machine-type=b2c.4x16 \
      --workers=3 \
      --private-vlan $PRIVATE_VLAN_ID \
      --public-vlan $PUBLIC_VLAN_ID
    ```

1.  Wait until your Kubernetes cluster is deployed:

    ```bash
    ibmcloud cs clusters | grep $CLUSTER_NAME
    ```

    It can take a while for your cluster to be deployed. Repeat the above
    command until the state of your cluster is "normal".

1.  Point `kubectl` to the cluster:

    ```bash
    ibmcloud cs cluster-config $CLUSTER_NAME
    ```

    Follow the instructions on the screen to `EXPORT` the correct `KUBECONFIG`
    value to point to the created cluster.

1.  Make sure all nodes are up:

    ```
    kubectl get nodes
    ```

    Make sure all the nodes are in `Ready` state. You are now ready to install
    Istio into your cluster.

With a Kuberntes cluster ready, you now have two choices on how to install
Knative: via a one-click "add-on" or manually.

## Installing Knative using an IKS managed add-on

The easiest way to install it is using the Managed Knative add-on facility. This
one-click install process will install Knative, and Istio if not already
installed, and provide automatic updates and lifecycle management of your
Knative control plane.

You can get the add-on via the "Add-ons" tab of your Kubernetes cluster's
console page, or via the command line:

```bash
ibmcloud ks cluster-addon-enable knative -y $CLUSTER_NAME
```

For more information about the add-on see
[here](https://cloud.ibm.com/docs/containers?topic=containers-knative_tutorial#knative_tutorial).

## Manually installing Knative on IKS

However, if you'd like to install Knative manually, see the instructions below.
Kind in mind that if you do not use the add-on mechanism then you will need to
manually manage the upgrade of your Istio and Knative installs yourself going
forward.

### Installing Istio

Knative depends on Istio. If your cloud platform offers a managed Istio
installation, we recommend installing Istio that way, unless you need the
ability to customize your installation.

If you prefer to install Istio manually, if your cloud provider doesn't offer a
managed Istio installation, or if you're installing Knative locally using
Minkube or similar, see the
[Installing Istio for Knative guide](./installing-istio.md).

You must install Istio on your Kubernetes cluster before continuing with these
instructions to install Knative.

### Installing Knative

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
   --filename https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml \
   --filename https://github.com/knative/build/releases/download/v0.6.0/build.yaml \
   --filename https://github.com/knative/eventing/releases/download/v0.7.0/release.yaml \
   --filename https://github.com/knative/eventing-contrib/releases/download/v0.7.0/eventing-sources.yaml \
   --filename https://github.com/knative/serving/releases/download/v0.7.0/monitoring.yaml \
   --filename https://raw.githubusercontent.com/knative/serving/v0.6.0/third_party/config/build/clusterrole.yaml
   ```

1. To complete the install of Knative and its dependencies, run the
   `kubectl apply` command again, this time without the `--selector` flag, to
   complete the install of Knative and its dependencies:

   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.7.0/serving.yaml --selector networking.knative.dev/certificate-provider!=cert-manager \
   --filename https://github.com/knative/build/releases/download/v0.6.0/build.yaml \
   --filename https://github.com/knative/eventing/releases/download/v0.7.0/release.yaml \
   --filename https://github.com/knative/eventing-contrib/releases/download/v0.7.0/eventing-sources.yaml \
   --filename https://github.com/knative/serving/releases/download/v0.7.0/monitoring.yaml \
   --filename https://raw.githubusercontent.com/knative/serving/v0.6.0/third_party/config/build/clusterrole.yaml
   ```

   > **Notes**:
   >
   > - By default, the Knative Serving component installation (`serving.yaml`)
   >   includes a controller for
   >   [enabling automatic TLS certificate provisioning](../serving/using-auto-tls.md).
   >   If you do intend on immediately enabling auto certificates in Knative,
   >   you can remove the
   >   `--selector networking.knative.dev/certificate-provider!=cert-manager`
   >   statement to install the controller. Otherwise, you can choose to install
   >   the auto certificates feature and controller at a later time.
   >
   > - For the v0.4.0 release and newer, the `clusterrole.yaml` file is required
   >   to enable the Build and Serving components to interact with each other.

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

Running a cluster in IKS costs money, so if you're not using it, you might want
to delete the cluster when you're done. Deleting the cluster also removes
Knative, Istio, and any apps you've deployed.

To delete the cluster, enter the following command:

```bash
ibmcloud cs cluster-rm $CLUSTER_NAME
```

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
