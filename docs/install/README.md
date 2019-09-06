Follow this guide to install Knative components on a platform of your choice.

## Choosing a Kubernetes cluster

To get started with Knative, you need a Kubernetes cluster. If you aren't sure
which Kubernetes platform is right for you, see
[Picking the Right Solution](https://kubernetes.io/docs/setup/).

We provide information for installing Knative on
[Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/docs/),
[IBM Cloud Kubernetes Service](https://www.ibm.com/cloud/container-service),
[IBM Cloud Private](https://www.ibm.com/cloud/private),
[Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/),
[Minikube](https://kubernetes.io/docs/setup/minikube/),
[OpenShift](https://github.com/openshift/origin) and
[Pivotal Container Service](https://pivotal.io/platform/pivotal-container-service)
clusters.

## Installing Knative

Knative depends on an Ingress/Gateway which is capable of routing requests to
Knative Services.

Currently, three options exist which provide this functionality:
[Ambassador](https://www.getambassador.io/), an Envoy-based API Gateway,
[Gloo](https://gloo.solo.io), an Envoy-based API Gateway, and
[Istio](https://istio.io/), an Envoy-based Service Mesh.

## Installing Knative with Ambassador

[Installing with Ambassador](./Knative-with-Ambassador.md) gives us an
alternative to installing a service mesh for routing to applications with the
Knative Serving component. Note that Istio is required for the Knative Eventing
component.

## Installing Knative with Gloo

[Install with Gloo](./Knative-with-Gloo.md): Gloo functions as a lightweight
gateway for Knative. Choose this option if you don't require a service mesh in
your cluster and want a lightweight alternative to Istio. Gloo supports all
documented Knative features, as well as extensions to Serving such as Eventing
and Monitoring.

## Installing Knative with Istio

Istio is a popular service mesh that includes a Knative-compatible ingress.
Choose this option if you wish to use Istio service mesh features.

There are several options when installing Knative:

- **Comprehensive install** -- Comes with the default versions of all Knative
  components as well as a set of observability plugins. Quickest option for
  setup.

- **Limited install** -- Installs a subset of Knative components.

- **Custom install** -- Takes longer, but allows you to choose exactly which
  components and oberservability plugins to install.

For new users, we recommend the comprehensive install to get you up and running
quickly.

### Install guides

Follow these step-by-step guides for setting up Kubernetes and installing
Knative components.

**Comprehensive install guides**

The guides below show you how to create a Kubernetes cluster with the right
specs for Knative on your platform of choice, then walk through installing all
available Knative components and a set of observability plugins.

- [Knative Install on Azure Kubernetes Service](./Knative-with-AKS.md)
- [Knative Install on Gardener](./Knative-with-Gardener.md)
- [Knative Install on Google Kubernetes Engine](./Knative-with-GKE.md)
- [Knative Install on IBM Cloud Kubernetes Service](./Knative-with-IKS.md)
- [Knative Install on IBM Cloud Private](./Knative-with-ICP.md)
- [Knative Install on Minikube](./Knative-with-Minikube.md)
- [Knative Install on Pivotal Container Service](./Knative-with-PKS.md)

If you already have a Kubernetes cluster you're comfortable installing _alpha_
software on, use the following guide to install all Knative components:

- [Knative Install on any Kubernetes](./Knative-with-any-k8s.md)

**Limited install guides**

The guides below install some of the available Knative components, without all
available observability plugins, to minimize the disk space used for install.

- [Knative Install on Docker for Mac](./Knative-with-Docker-for-Mac.md)
- [Knative Install on OpenShift](./Knative-with-OpenShift.md)
- [Knative Install on OpenShift via Operator](https://github.com/openshift-knative/docs/blob/master/README.md)

**Custom install guide**

To choose which components and observability plugins to install, follow the
custom install guide:

- [Performing a Custom Knative Installation](./Knative-custom-install.md)

> **Note**: If need to set up a Kubernetes cluster with the correct
> specifications to run Knative, you can follow any of the install instructions
> through the creation of the cluster, then follow the
> [Performing a Custom Knative Installation](./knative-custom-install.md) guide.

**Observability install guide**

Follow this guide to install and set up the available observability plugins on a
Knative cluster.

- [Monitoring, Logging and Tracing Installation](../serving/installing-logging-metrics-traces.md)

## Deploying an app

Now you're ready to deploy an app:

- Follow the step-by-step
  [Getting Started with Knative App Deployment](../serving/getting-started-knative-app.md)
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

- [Checking the version of your Knative Serving installation](./check-install-version.md)
