# Knative Install on a Kubernetes Cluster

This guide walks you through the installation of the latest version of Knative
using pre-built images.

## Before you begin

Knative requires a Kubernetes cluster v1.10 or newer with the
[MutatingAdmissionWebhook admission controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#how-do-i-turn-on-an-admission-controller) enabled.
`kubectl` v1.10 is also required. This guide assumes that you've already created a
Kubernetes cluster which you're comfortable installing _alpha_ software on.

This guide assumes you are using bash in a Mac or Linux environment; some
commands will need to be adjusted for use in a Windows environment.

## Installing Istio

Knative depends on Istio. Istio workloads require privileged mode for Init
Containers.

1.  Install Istio:
    ```bash
    kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.2.2/third_party/istio-1.0.2/istio.yaml
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
> command to view the component's status updates in real time. Use CTRL + C to
> exit watch mode.

## Installing Knative components

You can install the Knative Serving and Build components together, or Build on its own.

### Installing Knative Serving and Build components

1. Run the `kubectl apply` command to install Knative and its dependencies:
   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/v0.2.2/release.yaml
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
   kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.2.2/third_party/config/build/release.yaml
   ```
1. Monitor the Knative Build components until all of the components show a
   `STATUS` of `Running`:
   ```bash
   kubectl get pods --namespace knative-build
   ```

Just as with the Istio components, it will take a few seconds for the Knative
components to be up and running; you can rerun the `kubectl get` command to see
the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> command to view the component's status updates in real time. Use CTRL + C to
> exit watch mode.

You are now ready to deploy an app or create a build in your new Knative
cluster.

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

You have two options for deploying your first app:

- You can follow the step-by-step
  [Getting Started with Knative App Deployment](getting-started-knative-app.md)
  guide.

- You can view the available [sample apps](../serving/samples/README.md) and
  deploy one of your choosing.
