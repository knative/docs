---
title: "CLI tools"
weight: 03
type: "docs"
showlandingtoc: "false"
aliases:
  - /docs/reference/resources
  - /docs/client/connecting-kn-to-your-cluster
---

The following CLI tools are supported for use with Knative.

## kubectl

You can use `kubectl` to apply the YAML files required to install Knative components, and also to create Knative resources, such as services and event sources using YAML.

See <a href="https://kubernetes.io/docs/tasks/tools/install-kubectl/" target="_blank">Install and Set Up `kubectl`</a>.

## kn

`kn` provides a quick and easy interface for creating Knative resources such as services and event sources, without the need to create or modify YAML files directly. `kn` also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.

**NOTE:** `kn` cannot be used to install Knative components such as Serving or Eventing.

See [Installing `kn`](./install-kn/).

## Connecting CLI tools to your cluster

After you have installed `kubectl` or `kn`, these tools will search for the `kubeconfig` file of your cluster in the default location of `$HOME/.kube/config`, and will use this file to connect to the cluster.

A `kubeconfig` file is usually automatically created when you create a Kubernetes cluster.

For more information about `kubeconfig` files, see <a href="https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/" target="_blank">Organizing Cluster Access Using kubeconfig Files</a>.

### Using kubeconfig files with your platform

Instructions for using `kubeconfig` files are available for the following platforms:

- <a href="https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html" target="_blank">Amazon EKS</a>
- <a href="https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl" target="_blank">Google GKE</a>
- <a href="https://cloud.ibm.com/docs/containers?topic=containers-getting-started" target="_blank">IBM IKS</a>
- <a href="https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/administrator-cli-commands.html#create-kubeconfig" target="_blank">Red Hat OpenShift Cloud Platform</a>
- Starting <a href="https://minikube.sigs.k8s.io/docs/start/" target="_blank">minikube</a> writes this file automatically, or provides an appropriate context in an existing configuration file.
