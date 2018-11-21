# Installing Knative

Follow this guide to install Knative components on a platform of your choice.

## Choosing a Kubernetes cluster

To get started with Knative, you need a Kubernetes cluster. If you aren't sure
which Kubernetes platform is right for you, see
[Picking the Right Solution](https://kubernetes.io/docs/setup/pick-right-solution/).

We provide information for installing Knative on
[Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/),
[IBM Cloud Kubernetes Service](https://www.ibm.com/cloud/container-service),
[Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/),
[Minikube](https://kubernetes.io/docs/setup/minikube/),
[OpenShift](https://github.com/openshift/origin) and
[Pivotal Container Service](https://pivotal.io/platform/pivotal-container-service)
clusters.

## Installing Knative

There are several options when installing Knative:

* **Comprehensive install** -- Comes with the default versions of all Knative
  components. Quickest option for setup.

* **Limited install** -- Installs a subset of Knative components.

* **Custom install** -- Takes longer, but allows you to choose exactly which
  components to install.

For new users, we recommend the comprehensive install to get you up and running
quickly.

### Install guides

Follow these step-by-step guides for setting up Kubernetes and installing
Knative components.

**Comprehensive install guides**
The guides below show you how to create a Kubernetes cluster with the right
specs for Knative on your platform of choice, then walk through installing all
available Knative components.
* [Knative Install on Azure Kubernetes Service](Knative-with-AKS.md)
* [Knative Install on Gardener](Knative-with-Gardener.md)
* [Knative Install on Google Kubernetes Engine](Knative-with-GKE.md)
* [Knative Install on IBM Cloud Kubernetes Service](Knative-with-IKS.md)
* [Knative Install on Pivotal Container Service](Knative-with-PKS.md)

If you already have a Kubernetes cluster you're comfortable installing *alpha*
software on, use the following guide to install all Knative components:

- [Knative Install on any Kubernetes](Knative-with-any-k8s.md)

**Limited install guides**
The guides below install some of the available Knative components, sometimes
without all available observability plugins, to minimize disk use.
* [Knative Install on Minikube](Knative-with-Minikube.md)
* [Knative Install on Minishift](Knative-with-Minishift.md)
* [Knative Install on OpenShift](Knative-with-OpenShift.md)

**Custom install guide**
To choose which components and which versions of each component to install,
follow the custom install guide:

* [Perfoming a Custom Knative Installation](Knative-custom-install.md)

> **Note**: If need to set up a Kubernetes cluster with the correct
  specifications to run Knative, you can follow any of the install
  instructions through the creation of the cluster, then follow the
  [Perfoming a Custom Knative Installation](knative-custom-install.md) guide.

## Deploying an app

Now you're ready to deploy an app:

- Follow the step-by-step
  [Getting Started with Knative App Deployment](getting-started-knative-app.md)
  guide.

- View the available [sample apps](../serving/samples) and deploy one of your
  choosing.
  
- Walk through the Google codelab, 
  [Using Knative to deploy serverless applications to Kubernetes](https://codelabs.developers.google.com/codelabs/knative-intro/#0).

## Configuring Knative Serving

After your Knative installation is running, you can set up a custom domain with
a static IP address to be able to use Knative for publicly available services
and set up an Istio IP range for outbound network access:

- [Assign a static IP address](../serving/gke-assigning-static-ip-address.md)
- [Configure a custom domain](../serving/using-a-custom-domain.md)
- [Configure outbound network access](../serving/outbound-network-access.md)
- [Configuring HTTPS with a custom certificate](../serving/using-an-ssl-cert.md)

## Checking the version of your Knative Serving installation

- [Checking the version of your Knative Serving installation](check-install-version.md)

---

Except as otherwise noted, the content of this page is licensed under the
[Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/),
and code samples are licensed under the
[Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
