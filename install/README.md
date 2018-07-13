# Installing Knative

Follow this guide to install Knative components on a platform of your choice. 

## Choosing a Kubernetes cluster

To get started with Knative, you need a Kubernetes cluster. If you aren't
sure what Kubernetes platform is right for you, see
[Picking the Right Solution](https://kubernetes.io/docs/setup/pick-right-solution/).

We provide information for installing Knative on
[Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/) and
[Minikube](https://kubernetes.io/docs/setup/minikube/) clusters.

## Installing Knative

Follow these step-by-step guides for setting up Kubernetes and installing
Knative components on the following platforms:

* [Easy Install on Google Kubernetes Engine](Knative-with-GKE.md)
* [Easy Install on Minikube](Knative-with-Minikube.md)

## Configuring Knative Serving

After your Knative installation is running, you can set up a custom domain with 
a static IP address to be able to use Knative for publicly available services:

- [Assign a static IP address](../serving/gke-assigning-static-ip-address.md)
- [Configure a custom domain](../serving/using-a-custom-domain.md)

Knative Serving blocks all outbound traffic by default. To enable outbound access (when you want 
to connect to Cloud Storage API, for example), you need to change the proxy scope by [configuring outbound network access](../serving/outbound-network-access.md).

## Deploying an app

Now you're ready to deploy an app:

* You can follow the step-by-step
  [Getting Started with Knative App Deployment](getting-started-knative-app.md)
  guide.

* You can view the available [sample apps](../serving/samples/README.md) and
  deploy one of your choosing.
