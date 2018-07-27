# Installing Knative

Follow this guide to install Knative components on a platform of your choice. 

## Choosing a Kubernetes cluster

To get started with Knative, you need a Kubernetes cluster. If you aren't
sure which Kubernetes platform is right for you, see
[Picking the Right Solution](https://kubernetes.io/docs/setup/pick-right-solution/).

You'll find documentation for installing Knative on multiple cloud platforms
as well as [Minikube](https://kubernetes.io/docs/setup/minikube/).

## Installing Knative

To install Knative, you'll need a Kubernetes cluster that meets the specifications
for Knative on your platform of choice.

To install Knative, complete these two steps:

  1. Create a Kubernetes cluster on your chosen platform:
     * [Knative on Azure Kubernetes Service](Knative-with-AKS.md)
     * [Knative on Gardener](Knative-with-Gardener.md)
     * [Knative on Google Kubernetes Engine](Knative-with-GKE.md)
     * [Knative on IBM Cloud Kubernetes Service](Knative-with-IKS.md)
     * [Knative on Minikube](Knative-with-Minikube.md)
     * [Knative on Pivotal Container Service](Knative-with-PKS.md)

  2. Install Knative onto your Kubernetes cluster:
     * [Install Knative](Knative-with-any-k8s.md)

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
* [Configuring HTTPS with a custom certificate](../serving/using-an-ssl-cert.md)

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
