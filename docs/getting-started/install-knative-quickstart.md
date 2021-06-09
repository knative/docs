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
 
## Install Knative on Minikube

As an alternative to Kind, you can also install Knative on Minikube:

[`knative-on-minikube.sh`](https://raw.githubusercontent.com/psschwei/knative-on-minikube/main/knative-on-minikube.sh) is a shell script that completes the following fuctions:

1. Creates a cluster called `minikube`.
1. Installs Knative Serving with Kourier as the default networking layer, and sslip.io as the DNS.
1. Installs Knative Eventing and creates a default broker and channel implementation.

Prerequisites:

* [Minikube](https://minikube.sigs.k8s.io/docs/start/) is installed on your machine
* The appropriate [driver](https://minikube.sigs.k8s.io/docs/drivers/) is configured for your machine. The script defaults to using `kvm2`, an alternative driver can be used by setting `VM_DRIVER` variable, i.e. `VM_DRIVER=docker ./knative-on-minikube.sh`

## Install the Knative CLI

The Knative CLI (`kn`) provides a quick and easy interface for creating Knative resources such as Knative services and event sources, without the need to create or modify YAML files directly. `kn` also simplifies completion of otherwise complex procedures such as autoscaling and traffic splitting.

--8<-- "install-kn.md"
