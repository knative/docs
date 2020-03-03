---
title: "Installing Knative with Knative Operators"
weight: 10
type: "docs"
---

# Knative installations with Knative Operators

Knative provides operators as tools to install, configure and manage Knative. This guide explains how to install and
uninstall Knative using Knative operators.

Each component in Knative has a separate operator for installation and configuration. This means that there is a [Serving operator](https://github.com/knative/serving-operator)
and an [Eventing operator](https://github.com/knative/eventing-operator), and you can choose to install one or both independently.

## Prerequisites:

### Set up a Kubernetes cluster

Knative operators are still in Alpha phase. They focus on installation on a generic Kubernetes platform, such as
Docker Desktop, Minikube, or kubeadm clusters, and the operators do not perform any platform specific customization.
If you are not sure the customization of the Knative operators for vendor-specific platforms, use the generic Kubernetes
platform.

If you have only one node for your cluster, set CPUs to at least 6, Memory to at least 6.0 GB, Disk storage to at
least 30 GB. If you have multiple nodes for your cluster, set CPUs to at least 2, Memory to at least 4.0 GB, Disk storage
to at least 20 GB for each node.

You need to make sure that your Kubernetes cluster is able to access the internet, since Knative operators download
images online.

Vendor-specific Kubernetes services, such as Google Kubernetes Engine, IBM Kubernetes Service, or OpenShift, may need
some additional configurations, after the Knative is installed using the operators. In this tutorial, we do not introduce
the customization or additional configurations, that may vary from platform to platform.

### Install Istio

Knative Serving needs an ingress or gateway to route inbound network traffic to the services. Knative Operators only support
Istio in this release. Since we talk about the installation on generic Kubernetes service, Istio can be installed with
the following steps:

1. [Download and install Istio](https://knative.dev/development/install/installing-istio/#downloading-istio-and-installing-crds). Go through all the 4 sub-steps.
2. [Update your Istio to use cluster local gateway](https://knative.dev/development/install/installing-istio/#updating-your-install-to-use-cluster-local-gateway).

## Limitations of Knative Operators:

Knative operators use custom resources as the sources of truth to configure your Knative. The current custom resources
still have limited capabilities, which can not configure everything to meet Knative needs, but Knative operators are
making progress in extending their capabilities. One of the major missing points is that Knative operators do not currently
provide HA capabilities.

The open source versions of Knative operators have not been tested on any existing production environment, so use
them for development or test purpose. However, we encourage you to experiment Knative operators on top of the Kubernetes
cluster for your production environment, helping us find out what we can potentially improve in Knative operators by
reporting your issues.

## Install Knative Serving with Operator:

All the releases for Knative Serving Operator can be found on [this page](https://github.com/knative/serving-operator/releases).

### From releases:

Replace \<version\> with the latest version or the version you would like to install, and run the following command to
install Knative Serving Operator:

```
kubectl apply -f https://github.com/knative/serving-operator/releases/download/<version>/serving-operator.yaml
```

### From source code:

The source code is available on this page. You need to install the building tool [ko](https://github.com/google/ko) first. After downloading the
source code, you can install the operator in the root directory of the source code with the following command:

```
ko apply -f config/
```

Verify the installation of Knative Serving Operator with the command:

```
kubectl get deployment knative-serving-operator
```

You should see the deployment is ready, if the operator is installed.

Use the following command to track the log of the operator:

```
kubectl logs -f $(kubectl get pods -l name=knative-serving-operator -o name)
```

If everything goes fine, it is time to install Knative Serving by installing the custom resource of Knative Serving
operator. Operator supports to install Knative Serving under any namespace, which needs to be created as well. Then,
we can create a custom resource with empty spec section. Technically, you can use any namespace, but we recommend you
to use `knative-serving`. In the rest of this tutorial, we keep on using `knative-serving` as the namespace to create the
Serving operator CR and all the other namespaced Serving resources. To create the CR, you can run the following command:

```
cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
 name: knative-serving
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
EOF
```

Wait some time for Knative Serving is to become ready. Check the Knative Serving deployment with the following command:

```
kubectl get deployment -n knative-serving
```

You will receive the status of Knative serving deployments. If Knative Serving has been successfully deployed, you will
see all the deployments of the Knative Serving have reached READY status.

## Install Knative Eventing with Operator:

All the releases for Knative Eventing Operator can be found on [this page](https://github.com/knative/eventing-operator/releases).

### From releases:

Replace \<version\> with the latest version or the version you would like to install, and run the following command to
install Knative Eventing Operator:

```
kubectl apply -f https://github.com/knative/serving-operator/releases/download/<version>/eventing-operator.yaml
```

### From source code:

The source code is available on this page. You need to install the building tool [ko](https://github.com/google/ko) first. After downloading the source
code, you can install the operator in the root directory of the source code with the following command:

```
ko apply -f config/
```

Verify the installation of Knative Eventing Operator with the command:

```
kubectl get deployment knative-eventing-operator
```

You should see the deployment is ready, if the operator is installed. Use the following command to track the log of
the operator:

```
kubectl logs -f $(kubectl get pods -l name=knative-eventing-operator -o name)
```

If deployment of Knative Eventing operator is ready, it is time to install Knative Evenintg by installing the custom
resource of Knative Eventing operator. The same to Knative Serving operator, you can use any namespace, but we recommend
you to use `knative-eventing` for Knative eventing. In the rest of this tutorial, we keep on using `knative-eventing` as the
namespace to create the Eventing operator CR and all the other namespaced Eventing resources. Run the following command:

```
cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
 name: knative-eventing
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
EOF
```

Wait some time for Knative Eventing to become ready. Check the Knative Eventing deployments with the following command:

```
kubectl get deployment -n knative-eventing
```

We should see a list of Knative Eventing deployments up and running. If Knative Eventing has been successfully deployed,
you should see all the deployments of Knative Eventing are up and running.

## Uninstall Knative Serving with Operator:

### To remove Knative Serving component:

All the resources of Knative Serving are owned by the Knative Serving operator custom resource. To uninstall your Knative
Serving, you only need to remove the operator CR with the command:

```
kubectl delete KnativeServing knative-serving -n knative-serving
```

Knative Serving operator prevents unsafe removal of Knative serving resources. Even if the operator CR is successfully
removed, all the CRDs in Knative Serving are still kept in the cluster. All your resources relying on Knative CRDs
can still work.

### To remove Knative Serving Operator:

If you install from releases, run the following command:

```
kubectl delete -f https://github.com/knative/serving-operator/releases/download/<version>/serving-operator.yaml
```

Replace <version> with the version number of Knative Serving, you have installed.

If you install from source code, run the following command in the root directory of your source code:

```
ko delete -f config/
```

## Uninstall Knative Eventing with Operator:

### To remove Knative Eventing component:

All the resources of Knative Eventing are owned by the Knative Eventing operator custom resource. You can uninstall your
Knative Eventing, by removing the operator CR with the command:

```
kubectl delete KnativeEventing knative-eventing -n knative-eventing
```

Knative Eventing operator also prevents unsafe removal of Knative Eventing resources by keeping the Knative Eventing CRDs.

### To remove Knative Eventing Operator:

If you install from releases, run the following command:

```
kubectl delete -f https://github.com/knative/eventing-operator/releases/download/<version>/serving-operator.yaml
```

Replace <version> with the version number of Knative Eventing, you have installed.

If you install from source code, run the following command in the root directory of your source code:

```
ko delete -f config/
```
