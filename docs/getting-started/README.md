# Welcome to the Knative Quickstart tutorial

Following this Quickstart tutorial provides you with a simplified, local Knative installation by using the Knative `quickstart` plugin.

You can use this simple Knative deployment to try out commonly used features of **Knative Serving** and **Knative Eventing**.

!!! warning
    Knative `quickstart` environments are for experimentation use only.
    For a production ready installation, see the [YAML-based installation](/docs/install/yaml-install/)
    or the [Knative Operator installation](/docs/install/operator/knative-with-operators/).

We recommend that you complete the topics in this tutorial in order.

## Before you begin

Before you can get started with a Knative `quickstart` deployment you must install:

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start){target=_blank} (Kubernetes in Docker)
or [minikube](https://minikube.sigs.k8s.io/docs/start/){target=_blank} to enable
you to run a local Kubernetes cluster with Docker container nodes.

- The [Kubernetes CLI (`kubectl`)](https://kubernetes.io/docs/tasks/tools/install-kubectl){target=_blank} to run commands against Kubernetes clusters. You can use `kubectl` to deploy applications, inspect and manage cluster resources, and view logs.

- The Knative CLI (`kn`). For instructions, see the next section.

- You need to have a minimum of 3&nbsp;CPUs and 3&nbsp;GB of RAM available for the cluster to be created.

!!! tip
    Hit ++"."++ (period) on your keyboard to move forward in the tutorial. Use ++","++ (comma) to go back at any time.

<!--TODO: This tip only applies for users using a keyboard, i.e. not great for responsive design, since it doesn't work for users on mobile devices. Should we remove it or have it only appear on certain devices? Is responsive design really possible using mkdocs?-->
