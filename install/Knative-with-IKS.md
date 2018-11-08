# Knative Install on IBM Cloud Kubernetes Service (IKS)

This guide walks you through the installation of the latest version of Knative
using pre-built images.  

You may also have it all installed for you by clicking the button below:  
[![Deploy to IBM Cloud](https://bluemix.net/deploy/button_x2.png)](https://console.bluemix.net/devops/setup/deploy?repository=https://git.ng.bluemix.net/start-with-knative/toolchain.git)  

More [instructions on the deploy button here](https://git.ng.bluemix.net/start-with-knative/toolchain/blob/master/README.md).

You can find [guides for other platforms here](README.md).

## Before you begin

Knative requires a Kubernetes cluster v1.10 or newer. This guide walks you
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

## Creating a Kubernetes cluster

To make sure the cluster is large enough to host all the Knative and Istio
components, the recommended configuration for a cluster is:

- Kubernetes version 1.10 or later
- 4 vCPU nodes with 16GB memory (`b2c.4x16`)

1.  Set `ibmcloud` to the appropriate region:
    ```bash
    ibmcloud cs region-set $CLUSTER_REGION
    ```
1.  Create a Kubernetes cluster on IKS with the required specifications:

    ```bash
    ibmcloud cs cluster-create --name=$CLUSTER_NAME \
      --zone=$CLUSTER_ZONE \
      --kube-version=1.10.3 \
      --machine-type=b2c.4x16 \
      --workers=3
    ```

    If you're starting in a fresh account with no public and private VLANs, they
    are created automatically for you. If you already have VLANs configured
    in your account, get them via `ibmcloud cs vlans --zone $CLUSTER_ZONE` and
    include the public/private VLAN in the `cluster-create` command:

    ```bash
    ibmcloud cs cluster-create --name=$CLUSTER_NAME \
      --zone=$CLUSTER_ZONE \
      --kube-version=1.10.3 \
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

    Follow the instructions on the screen to `EXPORT` the correct `KUBECONFIG` value
    to point to the created cluster.

1.  Make sure all nodes are up:

    ```
    kubectl get nodes
    ```

    Make sure all the nodes are in `Ready` state. You are now ready to install Istio
    into your cluster.

## Installing Istio

Knative depends on Istio.

1.  Install Istio:
    ```bash
    kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.2.0/third_party/istio-1.0.2/istio.yaml
    ```
1.  Label the default namespace with `istio-injection=enabled`:
    ```bash
    kubectl label namespace default istio-injection=enabled
    ```
1.  Monitor the Istio components until all of the components show a `STATUS` of
    `Running` or `Completed`:
    ```bash
    kubectl get pods --namespace istio-system
    ```

It will take a few minutes for all the components to be up and running; you can
rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> command to view the component's status updates in real time. Use CTRL+C to
> exit watch mode.

## Installing Knative components

You can install the Knative Serving and Build components together, or Build on its own.

### Installing Knative Serving and Build components

1. Run the `kubectl apply` command to install Knative and its dependencies:
    ```bash
    kubectl apply --filename https://github.com/knative/serving/releases/download/v0.2.0/release.yaml
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
    kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.2.0/third_party/config/build/release.yaml
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

- Follow the step-by-step
  [Getting Started with Knative App Deployment](getting-started-knative-app.md)
  guide.

- View the available [sample apps](../serving/samples) and deploy one of your
  choosing.

## Cleaning up

Running a cluster in IKS costs money, so if you're not using it, you might
want to delete the cluster when you're done. Deleting the cluster also removes
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
