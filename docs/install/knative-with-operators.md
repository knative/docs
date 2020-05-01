---
title: "Installing Knative components using Operators"
weight: 10
type: "docs"
---

Knative provides operators as tools to install, configure and manage Knative. This guide explains how to install and
uninstall Knative using Knative operators.

New in 0.14, Knative offers a [combined operator for managing both Serving and Eventing](https://github.com/knative-sandbox/operator). For release 0.14,
you may **alternatively** choose to install the [Serving operator](https://github.com/knative/serving-operator) and [Eventing operator](https://github.com/knative/eventing-operator) instead of the combined operator.

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

## Limitations of Knative Operators:

Knative Operators are still in Alpha phase. They have not been tested in a production environment, and should be used
for development or test purposes only.

## Option 1: Install Knative with combined operator

Knative has released a combined operator to install both Serving and Eventing components. You can find the information
about the releases on the [Releases page](https://github.com/knative-sandbox/operator/releases).

### Installing the combined Knative Operator

__From releases__:

Run the following command to install the combined Knative Operator:

```
kubectl apply -f https://github.com/knative-sandbox/operator/releases/download/v0.14.1/operator.yaml
```

__From source code__:

You can also install Knative Operators from source using `ko`.

1. Install the [ko](https://github.com/google/ko) build tool.
1. Download the source code using the following command:

```
git clone https://github.com/knative-sandbox/operator.git
```

1. Install the operator in the root directory of the source using the following command:

```
ko apply -f config/
```

The combined operator installs both Serving and Eventing operators. Go through the following sections to verify your operator:

- [Verify Knative Serving Operator](#verify-the-operator-installation)
- [Verify Knative Eventing Operator](#verify-the-operator-installation-1)

Install Knative Serving and Eventing with Operator CRs:

- [Install Knative Serving](#installing-the-knative-serving-component)
- [Install Knative Eventing](#installing-the-knative-eventing-component)

## Option 2: Install Knative with separate operators

Alternatively, if you would like to install Knative Serving and Knative Eventing Operators separately, go through the
following sections:

- [Install Knative Serving using Operator](#installing-the-knative-serving-operator)
- [Install Knative Eventing using Operator](#installing-the-knative-serving-operator)

## Install Knative Serving with Operator:

Information about Knative Serving Operator releases can be found on the [Releases page](https://github.com/knative/serving-operator/releases).

### Installing the Knative Serving Operator

__From releases__:

Run the following command to install Knative Serving Operator:

```
kubectl apply -f https://github.com/knative/serving-operator/releases/download/v0.14.0/serving-operator.yaml
```

__From source code__:

You can also install Knative Operators from source using `ko`.

1. Install the [ko](https://github.com/google/ko) build tool.
1. Download the source code using the following command:

```
git clone https://github.com/knative/serving-operator.git
```

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

### Installing the Knative Eventing Operator

__From releases__:

Run the following command to install Knative Eventing Operator:

```
kubectl apply -f https://github.com/knative/eventing-operator/releases/download/v0.14.1/eventing-operator.yaml
```

__From source code__:

You can also install Knative Operators from source using `ko`.

1. Install the [ko](https://github.com/google/ko) build tool.
1. Download the source code using the following command:

```
git clone https://github.com/knative/eventing-operator.git
```

1. Install the operator in the root directory of the source using the following command:

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

Follow the following sections to remove Knative components:

- [Remove Knative Serving](#removing-the-knative-serving-component)
- [Remove Knative Eventing](#removing-the-knative-eventing-component)

If you install the combined Knative Operator, go to the following section to uninstall it:

- [Remove combined Knative Operator](#removing-the-combined-knative-operator)

If you install the separate Knative Operators, follow the following sections to uninstall them:

- [Remove Knative Serving Operator](#removing-the-knative-serving-operator)
- [Remove Knative Eventing Operator](#removing-the-knative-eventing-operator)

### Removing the Knative Serving component

Remove the Knative Serving CR:

```
kubectl delete KnativeServing knative-serving -n knative-serving
```

Knative Serving operator prevents unsafe removal of Knative serving resources. Even if the operator CR is successfully
removed, all the CRDs in Knative Serving are still kept in the cluster. All your resources relying on Knative CRDs
can still work.

### Removing the Knative Eventing component

Remove the Knative Eventing CR:

```
kubectl delete KnativeEventing knative-eventing -n knative-eventing
```

Knative Eventing operator also prevents unsafe removal of Knative Eventing resources by keeping the Knative Eventing CRDs.

### Removing the combined Knative Operator:

If you have installed the combined Knative Operator using the Release page, remove the operator using the following command:

```
kubectl delete -f https://github.com/knative-sandbox/operator/releases/download/v0.14.1/operator.yaml
```

If you have installed it from the source, uninstall it using the following command while in the root directory
for the source:

```
ko delete -f config/
```

### Removing the Knative Serving Operator:

If you have installed Knative Serving Operator using the Release page, remove the operator using the following command:

```
kubectl delete -f https://github.com/knative/serving-operator/releases/download/v0.14.0/serving-operator.yaml
```

If you have installed Knative Serving Operator from source, uninstall it using the following command while in the root directory
for the source:

```
ko delete -f config/
```

### Removing the Knative Eventing Operator:

If you have installed Knative Eventing Operator using the Release page, remove the operator using the following command:

```
kubectl delete -f https://github.com/knative/eventing-operator/releases/download/v0.14.1/eventing-operator.yaml
```

If you have installed Knative Eventing Operator from source, uninstall it using the following command while in the root directory
for the source:

```
ko delete -f config/
```

## What's next

- [Configure Knative Serving using Operator](./operator/configuring-serving-cr.md)
- [Configure Knative Eventing using Operator](./operator/configuring-eventing-cr.md)
