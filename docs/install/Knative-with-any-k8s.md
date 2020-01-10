---
title: "Install on a Kubernetes cluster"
linkTitle: "On existing cluster"
weight: 15
type: "docs"
---

This guide walks you through the installation of the latest version of Knative
using pre-built images.

## Before you begin

Knative requires a Kubernetes cluster v1.15 or newer, as well as a compatible
`kubectl`. This guide assumes that you've already created a Kubernetes cluster
which you're comfortable installing _alpha_ software on.

This guide assumes you are using bash in a Mac or Linux environment; some
commands will need to be adjusted for use in a Windows environment.

## Installing Istio

Knative depends on Istio. If your cloud platform offers a managed Istio
installation, we recommend installing Istio that way, unless you need the
ability to customize your installation. For example, the
[GKE Install Guide](./Knative-with-GKE.md) includes the instructions for
installing Istio on your cluster using `gcloud`.

If you prefer to install Istio manually, if your cloud provider doesn't offer a
managed Istio installation, or if you're installing Knative locally using
Minkube or similar, see the
[Installing Istio for Knative guide](./installing-istio.md).

You must install Istio on your Kubernetes cluster before continuing with these
instructions to install Knative.

## Installing `cluster-local-gateway` for serving cluster-internal traffic

If you installed Istio, you can install a `cluster-local-gateway` within your Knative cluster so that you can serve cluster-internal traffic. If you want to configure your revisions to use routes that are visible only within your cluster, [install and use the `cluster-local-gateway`](./installing-istio.md#updating-your-install-to-use-cluster-local-gateway).

## Installing Knative

The following commands install all available Knative components. To customize
your Knative installation, see
[Performing a Custom Knative Installation](./Knative-custom-install.md).

1. To install Knative, first install the CRDs by running the `kubectl apply`
   command once with the `-l knative.dev/crd-install=true` flag. This prevents
   race conditions during the install, which cause intermittent errors:

   ```bash
   kubectl apply --selector knative.dev/crd-install=true \
   --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml \
   --filename https://github.com/knative/eventing/releases/download/{{< version >}}/release.yaml \
   --filename https://github.com/knative/serving/releases/download/{{< version >}}/monitoring.yaml
   ```

1. To complete the install of Knative and its dependencies, run the
   `kubectl apply` command again, this time without the `--selector` flag, to
   complete the install of Knative and its dependencies:

   ```bash
   kubectl apply --filename https://github.com/knative/serving/releases/download/{{< version >}}/serving.yaml \
   --filename https://github.com/knative/eventing/releases/download/{{< version >}}/release.yaml \
   --filename https://github.com/knative/serving/releases/download/{{< version >}}/monitoring.yaml
   ```

1. Monitor the Knative components until all of the components show a `STATUS` of
   `Running`:

   ```bash
   kubectl get pods --namespace knative-serving
   kubectl get pods --namespace knative-eventing
   kubectl get pods --namespace knative-monitoring
   ```

## What's next

Now that your cluster has Knative installed, you can see what Knative has to
offer.

To deploy your first app with the
[Getting Started with Knative App Deployment](../serving/getting-started-knative-app.md)
guide.

Get started with Knative Eventing by walking through one of the
[Eventing Samples](../eventing/samples/).

[Install Cert-Manager](../serving/installing-cert-manager.md) if you want to use the
[automatic TLS cert provisioning feature](../serving/using-auto-tls.md).
