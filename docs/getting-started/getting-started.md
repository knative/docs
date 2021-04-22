# Installing Knative with KonK (Knative on Kind)

## Before you begin


### Install <a href= "https://kind.sigs.k8s.io/docs/user/quick-start/" target="blank_">Kind</a>.

???+ todo "Installing Kind"

    === "macOS"
        Use Homebrew
        ```bash
        brew install kind
        ```
        Or
        ```bash
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-darwin-amd64
        ```

    === "Linux"
        ```bash
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.10.0/kind-linux-amd64
        chmod +x ./kind
        mv ./kind /some-dir-in-your-PATH/kind
        ```

    === "Windows"
        ```terminal
        curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.10.0/kind-windows-amd64
        Move-Item .\kind-windows-amd64.exe c:\some-dir-in-your-PATH\kind.exe
        ```
        Use [Chocolatey](https://chocolatey.org/packages/kind)

See <a href= "https://kind.sigs.k8s.io/docs/user/quick-start/" target="blank_">Kind website</a> for other installation options.

??? question "Need to upgrade Kind?"
    === "Upgrade Kind using Homebrew"
        ```bash
        brew upgrade kind
        ```
    === "Other Upgrade Options"
        See <a href= "https://kind.sigs.k8s.io/docs/user/quick-start/" target="blank_">Kind website</a> for other upgrade options.

### Install `kubectl`

???+ todo "Installing the `kubectl` CLI"

    === "Using Homebrew"
        If you are on macOS and using [Homebrew](http://brew.sh) package manager, you can install kubectl with Homebrew.
        ``` bash
        brew install kubectl
        ```
    === "From the Kubernetes website"
        See <a href="https://kubernetes.io/docs/tasks/tools/install-kubectl/" target="_blank">the Kubernetes docs</a> for other installation options.

## Installing Knative on Kind (KonK)
==**The fastest way to get started with Knative locally** is to use the <a href= "https://konk.dev" target="blank_">Konk (Knative-on-kind) script.</a>==

!!! todo "Install Knative and Kubernetes on a local Docker Daemon using Konk"
    ```
    curl -sL install.konk.dev | bash
    ```

??? question "What does the KonK script actually do?"
    Knative on Kind (KonK) is a shell script which:

      1. Checks to see that you have Kind installed and creates a Cluster called "knative" via **[`01-kind.sh`](https://github.com/csantanapr/knative-kind/blob/master/01-kind.sh)**

      2. Installs **Knative Serving** with **Kourier** as the networking layer and **nip.io** as the DNS + some port-forwarding magic on the "knative" Cluster via **[`02-serving.sh`](https://github.com/csantanapr/knative-kind/blob/master/02-serving.sh)**

      3. Installs **Knative Eventing** with an In-Memory **Channels** and In-Memory **Broker** on the "knative" Cluster via **[`04-eventing.sh`](https://github.com/csantanapr/knative-kind/blob/master/04-eventing.sh)**
