---
title: "Installing Knative components using Operators"
weight: 10
type: "docs"
---

# Knative installations with Knative Operators

Knative provides operators as tools to install, configure and manage Knative. This guide explains how to install and
uninstall Knative using Knative operators.

Each component in Knative has a separate operator for installation and configuration. This means that there is a [Serving operator](https://github.com/knative/serving-operator)
and an [Eventing operator](https://github.com/knative/eventing-operator), and you can choose to install one or both independently.

## Before you begin

Knative installation using Operators requires the following:

- A Kubernetes cluster v1.15 or newer, as well as a compatible kubectl. This guide assumes that you've already created
a Kubernetes cluster. If you have only one node for your cluster, set CPUs to at least 6, Memory to at least 6.0 GB,
Disk storage to at least 30 GB. If you have multiple nodes for your cluster, set CPUs to at least 2, Memory to at least
4.0 GB, Disk storage to at least 20 GB for each node.
- The Kubernetes cluster must be able to access the internet, since Knative operators download images online.
- Istio:
    - [Download and install Istio](https://knative.dev/development/install/installing-istio/#downloading-istio-and-installing-crds). Go through all the 4 sub-steps.
    - [Update your Istio to use cluster local gateway](https://knative.dev/development/install/installing-istio/#updating-your-install-to-use-cluster-local-gateway).

Knative operators are still in Alpha phase. They focus on installation on a generic Kubernetes platform, such as
Docker Desktop, Minikube, or kubeadm clusters, and the operators do not perform any platform specific customization.
If you are not sure the customization of the Knative operators for vendor-specific platforms, use the generic Kubernetes
platform.

## Limitations of Knative Operators:

Knative Operators use custom resources (CRs) to configure your Knative deployment.

 - Currently, the CRs included with Knative Operators do not provide high availability (HA) capabilities.
 - Knative Operators have not been tested in a production environment, and should be used for development or test purposes only.

## Install Knative Serving with Operator:

Information about Knative Serving Operator releases can be found on the [Releases page](https://github.com/knative/serving-operator/releases).

### Installling the Knative Serving Operator

__From releases__:

Replace \<version\> with the latest version or the version you would like to install, and run the following command to
install Knative Serving Operator:

```
kubectl apply -f https://github.com/knative/serving-operator/releases/download/<version>/serving-operator.yaml
```

__From source code__:

You can also install Knative Operators from source using `ko`.

1. Install the [ko]((https://github.com/google/ko)) build tool.
1. Install the operator in the root directory of the source using the following command:

```
ko apply -f config/
```

### Verify the operator installation

Verify the installation of Knative Serving Operator using the command:

```
kubectl get deployment knative-serving-operator
```

If the operator is installed correctly, the deployment should show a `Ready` status. Here is a sample output:

```
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
knative-serving-operator   1/1     1            1           19h
```

### Track the log

Use the following command to track the log of the operator:

```
kubectl logs -f $(kubectl get pods -l name=knative-serving-operator -o name)
```

### Installing the Knative Serving component

1. Create and apply the Knative Serving CR:

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

2. Verify the Knative Serving deployment:

```
kubectl get deployment -n knative-serving
```

If Knative Serving has been successfully deployed, all deployments of the Knative Serving will show `READY` status. Here
is a sample output:

```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
activator          1/1     1            1           19h
autoscaler         1/1     1            1           19h
autoscaler-hpa     1/1     1            1           19h
controller         1/1     1            1           19h
networking-istio   1/1     1            1           19h
webhook            1/1     1            1           19h
```

## Install Knative Eventing with Operator:

Information about Knative Eventing Operator releases can be found on the [Releases page](https://github.com/knative/eventing-operator/releases).

### Installling the Knative Eventing Operator

__From releases__:

Replace \<version\> with the latest version or the version you would like to install, and run the following command to
install Knative Eventing Operator:

```
kubectl apply -f https://github.com/knative/eventing-operator/releases/download/<version>/eventing-operator.yaml
```

__From source code__:

You can also install Knative Operators from source using `ko`.

- Install the [ko]((https://github.com/google/ko)) build tool.
- Install the operator in the root directory of the source using the following command:

```
ko apply -f config/
```

### Verify the operator installation

Verify the installation of Knative Eventing Operator using the command:

```
kubectl get deployment knative-eventing-operator
```

If the operator is installed correctly, the deployment should show a `Ready` status. Here is a sample output:

```
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
knative-eventing-operator   1/1     1            1           19h
```

### Track the log

Use the following command to track the log of the operator:

```
kubectl logs -f $(kubectl get pods -l name=knative-eventing-operator -o name)
```

### Installing the Knative Eventing component

1. Create and apply the Knative eventing CR:

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

2. Verify the Knative Eventing deployment:

```
kubectl get deployment -n knative-eventing
```

If Knative Eventing has been successfully deployed, all deployments of the Knative Eventing will show `READY` status. Here
is a sample output:

```
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
broker-controller     1/1     1            1           42h
eventing-controller   1/1     1            1           42h
eventing-webhook      1/1     1            1           42h
imc-controller        1/1     1            1           42h
imc-dispatcher        1/1     1            1           42h
```

## Uninstall Knative

### Removing the Knative Serving component

Remove the Knative Serving CR:

```
kubectl delete KnativeServing knative-serving -n knative-serving
```

Knative Serving operator prevents unsafe removal of Knative serving resources. Even if the operator CR is successfully
removed, all the CRDs in Knative Serving are still kept in the cluster. All your resources relying on Knative CRDs
can still work.

### Removing the Knative Serving Operator:

If you have installed Knative Serving using the Release page, remove the operator using the following command:

```
kubectl delete -f https://github.com/knative/serving-operator/releases/download/<version>/serving-operator.yaml
```

Replace <version> with the version number of Knative Serving you have installed.

If you have installed Knative Serving from source, uninstall it using the following command while in the root directory
for the source:

```
ko delete -f config/
```

### Removing Knative Eventing component

Remove the Knative Eventing CR:

```
kubectl delete KnativeEventing knative-eventing -n knative-eventing
```

Knative Eventing operator also prevents unsafe removal of Knative Eventing resources by keeping the Knative Eventing CRDs.

### Removing Knative Eventing Operator:

If you have installed Knative Eventing using the Release page, remove the operator using the following command:

```
kubectl delete -f https://github.com/knative/eventing-operator/releases/download/<version>/eventing-operator.yaml
```

Replace <version> with the version number of Knative Eventing you have installed.

If you have installed Knative Eventing from source, uninstall it using the following command while in the root directory
for the source:

```
ko delete -f config/
```
