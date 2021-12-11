# Getting Started with Knative
## Before you begin
!!! warning
    Knative Quickstart Environments are for experimentation use only. For production installation, see our [Installing Guide](../install/README.md)

Before you can get started with a Knative Quickstart deployment you must install kind, the Kubernetes CLI, and the Knative CLI.

### Prepare local Kubernetes cluster

You can use [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start){target=_blank} (Kubernetes in Docker) or [`minikube`](https://minikube.sigs.k8s.io/docs/start/){target=_blank} to run a local Kubernetes cluster with Docker container nodes.

### Install the Kubernetes CLI

The [Kubernetes CLI (`kubectl`)](https://kubernetes.io/docs/tasks/tools/install-kubectl){target=_blank}, allows you to run commands against Kubernetes clusters. You can use `kubectl` to deploy applications, inspect and manage cluster resources, and view logs.

### Install the Knative CLI

The Knative CLI (`kn`) provides a quick and easy interface for creating Knative resources, such as Knative Services and Event Sources, without the need to create or modify YAML files directly.

`kn` also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.

--8<-- "install-kn.md"

## Install the Knative "Quickstart" environment

You can get started with a local deployment of Knative by using the Knative `quickstart` plugin.

--8<-- "quickstart-install.md"
