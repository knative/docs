# Installing Knative

Follow this guide to install Knative components on a platform of your choice. 

## Choosing a Kubernetes cluster

To get started with Knative, you need a Kubernetes cluster. If you aren't
sure which Kubernetes platform is right for you, see
[Picking the Right Solution](https://kubernetes.io/docs/setup/pick-right-solution/).

We provide information for installing Knative on
[Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/), [IBM Cloud Kubernetes Service](https://www.ibm.com/cloud/container-service), [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/) and 
[Minikube](https://kubernetes.io/docs/setup/minikube/) clusters.

## Installing Knative

Follow these step-by-step guides for setting up Kubernetes and installing
Knative components on the following platforms:

* [Knative Install on Gardener](Knative-with-Gardener.md)
* [Knative Install on Google Kubernetes Engine](Knative-with-GKE.md)
* [Knative Install on IBM Cloud Kubernetes Service](Knative-with-IKS.md)
* [Knative Install on Azure Kubernetes Service](Knative-with-AKS.md)
* [Knative Install on Minikube](Knative-with-Minikube.md)

## Deploying an app

Now you're ready to deploy an app:

* Follow the step-by-step
  [Getting Started with Knative App Deployment](getting-started-knative-app.md)
  guide.

* View the available [sample apps](../serving/samples) and deploy one of your
  choosing.

## Configuring Knative Serving

After your Knative installation is running, you can set up a custom domain with
a static IP address to be able to use Knative for publicly available services
and set up an Istio IP range for outbound network access:

* [Assign a static IP address](../serving/gke-assigning-static-ip-address.md)
* [Configure a custom domain](../serving/using-a-custom-domain.md)
* [Configure outbound network access](../serving/outbound-network-access.md)
