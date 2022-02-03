# Install Knative using Quickstart

This topic describes how to install Knative Serving and Eventing using
the Knative Quickstart plugin.
The plugin installs a preconfigured Knative deployment on a local Kubernetes cluster.

!!! warning
    Knative Quickstart Environments are for experimentation use only. For a production ready installation, see [Installing Knative](../install/README.md).

## Before you begin

Before you can get started with a Knative Quickstart deployment you must install kind or minikube, the Kubernetes CLI, and the Knative CLI.

### Prepare a local Kubernetes cluster

You can use [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start){target=_blank} (Kubernetes in Docker) or [`minikube`](https://minikube.sigs.k8s.io/docs/start/){target=_blank} to run a local Kubernetes cluster with Docker container nodes.

### Install the Kubernetes CLI

The [Kubernetes CLI (`kubectl`)](https://kubernetes.io/docs/tasks/tools/install-kubectl){target=_blank}, allows you to run commands against Kubernetes clusters. You can use `kubectl` to deploy applications, inspect and manage cluster resources, and view logs.

### Install the Knative CLI

The Knative CLI (`kn`) provides a quick and easy interface for creating Knative resources, such as Knative Services and Event Sources, without the need to create or modify YAML files directly.

`kn` also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.

--8<-- "install-kn.md"

## Install the Knative "Quickstart" environment

You can get started with a local deployment of Knative by using the Knative `quickstart` plugin.

!!! todo "Installing the `quickstart` plugin"
    === "Using Homebrew"
        For macOS, you can install the `quickstart` plugin by using [Homebrew](https://brew.sh){target=_blank}.
            ```
            brew install knative-sandbox/kn-plugins/quickstart
            ```

    === "Using a binary"
         You can install the `quickstart` plugin by downloading the executable binary for your system and placing it on your `PATH` (for example, in `/usr/local/bin`).

         A link to the latest stable binary release is available on the [`quickstart` release page](https://github.com/knative-sandbox/kn-plugin-quickstart/releases){target=_blank}.

    === "Using Go"
        1. Check out the `kn-plugin-quickstart` repository:

              ```
              git clone https://github.com/knative-sandbox/kn-plugin-quickstart.git
              cd kn-plugin-quickstart/
              ```

        1. Build an executable binary:

              ```
              hack/build.sh
              ```

        1. Move the executable binary file to a directory on your `PATH`:

             ```
             mv kn-quickstart /usr/local/bin
             ```

         1. Verify that the plugin is working, for example:

             ```
             kn quickstart --help
             ```

The `quickstart` plugin completes the following functions:

1. **Checks if you have the selected Kubernetes instance installed,** and creates a cluster called `knative`.
2. **Installs Knative Serving with Kourier** as the default networking layer, and sslip.io as the DNS.
3. **Installs Knative Eventing** and creates an in-memory Broker and Channel implementation.


!!! todo "Install Knative and Kubernetes locally"
    === "Using kind"

        Install Knative and Kubernetes on a local Docker daemon by running:
        ```bash
        kn quickstart kind
        ```

        After the plugin is finished, verify you have a cluster called `knative`:
        ```bash
        kind get clusters
        ```

    === "Using minikube"

        Install Knative and Kubernetes in a minikube instance by running:
        ```bash
        kn quickstart minikube
        ```

        After the plugin is finished, verify you have a cluster called `knative`:
        ```bash
        minikube profile list
        ```

## Next steps

Now you've installed Knative, learn how to deploy your first Service in the
next topic in this tutorial.
