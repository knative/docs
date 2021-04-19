# Installing Knative with KonK (Knative on Kind)

## Before you begin
- You will need to have <a href= "https://kind.sigs.k8s.io/docs/user/quick-start/" target="blank_">Kind installed</a>.

??? todo "Installing Kind"

    === "Using Homebrew"
        ```bash
        brew install kind
        ```

    === "Upgrade Kind using Homebrew"
        ```bash
        brew upgrade kind
        ```

    === "From the Kind website"
        See <a href= "https://kind.sigs.k8s.io/docs/user/quick-start/" target="blank_">Kind website</a> for other installation options.
- You will need to have `kubectl` installed.

??? todo "Installing the `kubectl` CLI"

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
