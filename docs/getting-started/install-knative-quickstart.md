# Getting Started with the Knative "Quickstart" Environment

!!! warning
    Knative Quickstart Environments are for experimentation only. For production installation, see our [Administrator's Guide](../admin)

## Install Knative using the konk script

You can get started with a local deployment of Knative by using _Knative on Kind_ (`konk`):

`konk` is a shell script that completes the following functions:

1. Checks if you have `kind` installed, and creates a cluster called `knative`.
1. Installs Knative Serving with Kourier as the default networking layer, and nip.io as the DNS.
1. Installs Knative Eventing and creates a default broker and channel implementation.

!!! todo "Install Knative and Kubernetes on a local Docker Daemon using `konk`"
    ```
    curl -sL install.konk.dev | bash
    ```

## Install the Knative CLI

The Knative CLI (`kn`) provides a quick and easy interface for creating Knative resources such as Knative services and event sources, without the need to create or modify YAML files directly. `kn` also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.

--8<-- "docs/snippets/install-kn.md"
