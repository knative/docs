# Install Knative using quickstart

This topic describes how to install a local deployment of Knative Serving and
Eventing using the Knative `quickstart` plugin.

The plugin installs a preconfigured Knative deployment on a local Kubernetes cluster.

!!! warning
    Knative `quickstart` environments are for experimentation use only.
    For a production ready installation, see the [YAML-based installation](/docs/install/yaml-install/)
    or the [Knative Operator installation](/docs/install/operator/knative-with-operators/).

## Before you begin

Before you can get started with a Knative `quickstart` deployment you must install:

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start){target=_blank} (Kubernetes in Docker)
or [minikube](https://minikube.sigs.k8s.io/docs/start/){target=_blank} to enable
you to run a local Kubernetes cluster with Docker container nodes.
- The [Kubernetes CLI (`kubectl`)](https://kubernetes.io/docs/tasks/tools/install-kubectl){target=_blank}
to run commands against Kubernetes clusters.
You can use `kubectl` to deploy applications, inspect and manage cluster resources, and view logs.
- The Knative CLI (`kn`) v0.25 or later. For instructions, see the next section.

### Install the Knative CLI

--8<-- "install-kn.md"

## Install the Knative quickstart plugin

To get started, install the Knative `quickstart` plugin:

=== "Using Homebrew"

    Do one of the following:

    - To install the `quickstart` plugin by using [Homebrew](https://brew.sh){target=_blank}, run the command:

        ```bash
        brew install knative-sandbox/kn-plugins/quickstart
        ```

    - To upgrade an existing `quickstart` install to the latest version, run the command:

        ```bash
        brew upgrade knative-sandbox/kn-plugins/quickstart
        ```
=== "Using a binary"
    1. Download the executable binary for your system from the [`quickstart` release page](https://github.com/knative-sandbox/kn-plugin-quickstart/releases){target=_blank}.

    1. Move the executable binary file to a directory on your `PATH`, for example, in `/usr/local/bin`.

    1. Verify that the plugin is working, for example:

        ```bash
        kn quickstart --help
        ```

=== "Using Go"
    1. Check out the `kn-plugin-quickstart` repository:

          ```bash
          git clone https://github.com/knative-sandbox/kn-plugin-quickstart.git
          cd kn-plugin-quickstart/
          ```

    1. Build an executable binary:

          ```bash
          hack/build.sh
          ```

    1. Move the executable binary file to a directory on your `PATH`:

          ```bash
          mv kn-quickstart /usr/local/bin
          ```

     1. Verify that the plugin is working, for example:

          ```bash
          kn quickstart --help
          ```

## Run the Knative quickstart plugin

The `quickstart` plugin completes the following functions:

1. **Checks if you have the selected Kubernetes instance installed**
1. **Creates a cluster called `knative`**
1. **Installs Knative Serving** with Kourier as the default networking layer, and sslip.io as the DNS
1. **Installs Knative Eventing** and creates an in-memory Broker and Channel implementation


To get a local deployment of Knative, run the `quickstart` plugin:

=== "Using kind"

    1. Install Knative and Kubernetes on a local Docker daemon by running:

        ```bash
        kn quickstart kind
        ```

    1. After the plugin is finished, verify you have a cluster called `knative`:

        ```bash
        kind get clusters
        ```

=== "Using minikube"

    1. Install Knative and Kubernetes in a minikube instance by running:

        ```bash
        kn quickstart minikube
        ```

    1. After the plugin is finished, verify you have a cluster called `knative`:

        ```bash
        minikube profile list
        ```
    1. To finish setting up networking for minikube, run the following command in a separate terminal window:
        ```bash
        minikube tunnel --profile knative
        ```
        The tunnel must continue to run in a terminal window while you are using your Knative `quickstart` environment.

        !!! note
            To terminate the process and clean up network routes, enter `Ctrl-C`.
            For more information about the `minikube tunnel` command, see the [minikube documentation](https://minikube.sigs.k8s.io/docs/handbook/accessing/#using-minikube-tunnel).
