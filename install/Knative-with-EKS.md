# Knative Install on Elastic Container Service for Kubernetes (Amazon EKS)

This guide walks you through the installation of the latest version of Knative
using pre-built images.

## Before you begin

Knative requires a Kubernetes cluster v1.11 or newer. This guide walks you
through creating a cluster with the correct specifications for Knative on Elastic Container Service for Kubernetes (Amazon EKS).


## Creating a Kubernetes cluster

Follow the instruction on: https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html

## Installing Istio

Knative depends on Istio.

1.  Install Istio:

    ```bash
    kubectl apply --filename https://github.com/knative/serving/releases/download/v0.4.0/istio-crds.yaml && \
    kubectl apply --filename https://github.com/knative/serving/releases/download/v0.4.0/istio.yaml
    ```

    Note: the resources (CRDs) defined in the `istio-crds.yaml`file are also
    included in the `istio.yaml` file, but they are pulled out so that the CRD
    definitions are created first. If you see an error when creating resources
    about an unknown type, run the second `kubectl apply` command again.

1.  Label the default namespace with `istio-injection=enabled`:
    ```bash
    kubectl label namespace default istio-injection=enabled
    ```
1.  Monitor the Istio components until all of the components show a `STATUS` of
    `Running` or `Completed`:
    ```bash
    kubectl get pods --namespace istio-system
    ```

It will take ca. 2 minutes for all the components to be up and running; you can
rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> command to view the component's status updates in real time. Use CTRL+C to
> exit watch mode.

## Installing Knative

The following commands install all available Knative components as well as the
standard set of observability plugins. To customize your Knative installation,
see [Performing a Custom Knative Installation](Knative-custom-install.md).

1. If you are upgrading from Knative 0.3.x: Update your domain and static IP
   address to be associated with the LoadBalancer `istio-ingressgateway` instead
   of `knative-ingressgateway`.  Then run the following to clean up leftover
   resources:
   ```
   kubectl delete svc knative-ingressgateway -n istio-system
   kubectl delete deploy knative-ingressgateway -n istio-system
   ```

1. Run the `kubectl apply` command to install Knative and its dependencies:
   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.4.0/serving.yaml \
   --filename https://github.com/knative/build/releases/download/v0.4.0/build.yaml \
   --filename https://github.com/knative/eventing/releases/download/v0.4.0/release.yaml \
   --filename https://github.com/knative/eventing-sources/releases/download/v0.4.0/release.yaml \
   --filename https://github.com/knative/serving/releases/download/v0.4.0/monitoring.yaml \
   --filename https://raw.githubusercontent.com/knative/serving/v0.4.0/third_party/config/build/clusterrole.yaml
   ```
   > **Note**: For the v0.4.0 release and newer, the `clusterrole.yaml` file is
   > required to enable the Build and Serving components to interact with each other.
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
[Getting Started with Knative App Deployment](getting-started-knative-app.md)
guide.

To get started with Knative Eventing, pick one of the
[Eventing Samples](../eventing/samples/) to walk through.

To get started with Knative Build, read the [Build README](../build/README.md),
then choose a sample to walk through.

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
