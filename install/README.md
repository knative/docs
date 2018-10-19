# Installing Knative

Follow this guide to install Knative components on a platform of your choice. 

## Choosing a Kubernetes cluster

To get started with Knative, you need a Kubernetes cluster. If you aren't
sure which Kubernetes platform is right for you, see
[Picking the Right Solution](https://kubernetes.io/docs/setup/pick-right-solution/).

We provide information for installing Knative on
[Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/), [IBM Cloud Kubernetes Service](https://www.ibm.com/cloud/container-service), [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/), [Minikube](https://kubernetes.io/docs/setup/minikube/), [OpenShift](https://github.com/openshift/origin) and [Pivotal Container Service](https://pivotal.io/platform/pivotal-container-service) clusters.

## Installing Knative

Follow these step-by-step guides for setting up Kubernetes and installing
Knative components on the following platforms:

* [Knative Install on Azure Kubernetes Service](Knative-with-AKS.md)
* [Knative Install on Gardener](Knative-with-Gardener.md)
* [Knative Install on Google Kubernetes Engine](Knative-with-GKE.md)
* [Knative Install on IBM Cloud Kubernetes Service](Knative-with-IKS.md)
* [Knative Install on Minikube](Knative-with-Minikube.md)
* [Knative Install on OpenShift](Knative-with-OpenShift.md)
* [Knative Install on Minishift](Knative-with-Minishift.md)
* [Knative Install on Pivotal Container Service](Knative-with-PKS.md)

If you already have a Kubernetes cluster you're comfortable installing
*alpha* software on, use the following instructions:

* [Knative Install on any Kubernetes](Knative-with-any-k8s.md)

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

## Checking the version of your Knative Serving installation

* [Checking the version of your Knative Serving installation](check-install-version.md)

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
