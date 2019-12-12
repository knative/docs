---
title: "Connecting the `kn` Client to your cluster"
linkTitle: "Connecting to your cluster"
weight: 10
type: "docs"
---

The `kn` Client uses your `kubectl` client configuration, the kubeconfig file, to connect to your cluster. This file is usually automatically created when you create a Kubernetes cluster. `kn` looks for your kubeconfig file in the default location of `$HOME/.kube/config`.

For more information about kubeconfig files, see [Organizing Cluster Access Using kubeconfig Files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/).

## Using kubeconfig files with your platform
Instructions for using kubeconfig files are available for the following platforms:
- [Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)
- [Google GKE](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
- [IBM IKS](https://cloud.ibm.com/docs/containers?topic=containers-getting-started)
- [Red Hat OpenShift Cloud Platform](https://docs.openshift.com/container-platform/4.1/cli_reference/administrator-cli-commands.html#create-kubeconfig)
- Starting [minikube](https://github.com/kubernetes/minikube) writes this file (or gives you an appropriate context in an existing configuration file).
