---
title: "Install on Minikube"
linkTitle: "Minikube"
weight: 10
type: "docs"
markup: "mmark"
---

This guide walks you through the installation of the latest version of
[Knative Serving](https://github.com/knative/serving) using pre-built images and
demonstrates creating and deploying an image of a sample "hello world" app onto
the newly created Knative cluster.

You can find [guides for other platforms here](./README.md).

## Before you begin

Knative requires a Kubernetes cluster v1.14 or newer.

### Install kubectl and Minikube

1. If you already have `kubectl` CLI, run `kubectl version` to check the
   version. You need v1.10 or newer. If your `kubectl` is older, follow the next
   step to install a newer version.

1. [Install the kubectl CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl).

1. [Install and configure minikube](https://github.com/kubernetes/minikube#installation)
   version v0.28.1 or later with a
   [VM driver](https://github.com/kubernetes/minikube#requirements), e.g. `kvm2`
   on Linux or `hyperkit` on macOS.

## Creating a Kubernetes cluster

After kubectl and Minikube are installed, create a cluster with version 1.12 or
greater and your chosen VM driver:

For Linux use:

```shell
minikube start --memory=8192 --cpus=6 \
  --kubernetes-version=v1.14.0 \
  --vm-driver=kvm2 \
  --disk-size=30g \
  --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"
```

For macOS use:

```shell
minikube start --memory=8192 --cpus=6 \
  --kubernetes-version=v1.14.0 \
  --vm-driver=hyperkit \
  --disk-size=30g \
  --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"
```

## Installing Istio

Knative depends on [Istio](https://istio.io/docs/concepts/what-is-istio/) for
traffic routing and ingress. You have the option of injecting Istio sidecars and
enabling the Istio service mesh, but it's not required for all Knative
components.

If your cloud platform offers a managed Istio installation, we recommend
installing Istio that way, unless you need the ability to customize your
installation.

If you prefer to install Istio manually, if your cloud provider doesn't offer a
managed Istio installation, or if you're installing Knative locally using
Minkube or similar, see the
[Installing Istio for Knative guide](./installing-istio.md).

> Note: [Ambassador](https://www.getambassador.io/) and
> [Gloo](https://gloo.solo.io/) are available as an alternative to Istio.
> [Click here](./Knative-with-Ambassador.md) to install Knative with Ambassador.
> [Click here](./Knative-with-Gloo.md) to install Knative with Gloo.

## Installing Knative

The following commands install all available Knative components as well as the
standard set of observability plugins. To customize your Knative installation,
see [Performing a Custom Knative Installation](./Knative-custom-install.md).

1. If you are upgrading from Knative 0.3.x: Update your domain and static IP
   address to be associated with the LoadBalancer `istio-ingressgateway` instead
   of `knative-ingressgateway`. Then run the following to clean up leftover
   resources:

   ```shell
   kubectl delete svc knative-ingressgateway -n istio-system
   kubectl delete deploy knative-ingressgateway -n istio-system
   ```

   If you have the Knative Eventing Sources component installed, you will also
   need to delete the following resource before upgrading:

   ```shell
   kubectl delete statefulset/controller-manager -n knative-sources
   ```

   While the deletion of this resource during the upgrade process will not
   prevent modifications to Eventing Source resources, those changes will not be
   completed until the upgrade process finishes.

1. To install Knative, first install the CRDs by running the `kubectl apply`
   command once with the `-l knative.dev/crd-install=true` flag. This prevents
   race conditions during the install, which cause intermittent errors:

   ```shell
   kubectl apply --selector knative.dev/crd-install=true \
   --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml \
   --filename https://github.com/knative/eventing/releases/download/{{< version >}}/release.yaml \
   --filename https://github.com/knative/serving/releases/download/{{< version >}}/monitoring.yaml
   ```

1. To complete the install of Knative and its dependencies, run the
   `kubectl apply` command again, this time without the `--selector` flag, to
   complete the install of Knative and its dependencies:

   ```shell
   kubectl apply --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml \
   --filename https://github.com/knative/eventing/releases/download/{{< version >}}/release.yaml \
   --filename https://github.com/knative/serving/releases/download/{{< version >}}/monitoring.yaml
   ```

1. Monitor the Knative components until all of the components show a `STATUS` of
   `Running`:

   ```shell
   kubectl get pods --namespace knative-serving
   kubectl get pods --namespace knative-eventing
   kubectl get pods --namespace knative-monitoring
   ```

## Deploying an app

Now that your cluster has Knative installed, you're ready to deploy an app.

If you'd like to follow a step-by-step guide for deploying your first app on
Knative, check out the
[Getting Started with Knative App Deployment](../serving/getting-started-knative-app.md)
guide.

If you'd like to view the available sample apps and deploy one of your choosing,
head to the [sample apps](../serving/samples/README.md) repo.

> Note: When looking up the IP address to use for accessing your app, you need
> to look up the NodePort for the `istio-ingressgateway` well as the IP address
> used for Minikube. You can use the following command to look up the value to
> use for the {IP_ADDRESS} placeholder used in the samples:

```shell
INGRESSGATEWAY=istio-ingressgateway

echo $(minikube ip):$(kubectl get svc $INGRESSGATEWAY --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
```

## Cleaning up

Delete the Kubernetes cluster along with Knative, Istio, and any deployed apps:

```shell
minikube delete
```
