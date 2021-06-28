

`konk` is a shell script that completes the following functions:

1. **Checks if you have [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start){target=_blank} installed,** and creates a cluster called `knative`.
1. **Installs Knative Serving with Kourier** as the default networking layer, and nip.io as the DNS.
1. **Installs Knative Eventing** and creates an in-memory Broker and Channel implementation.

!!! todo "Install Knative and Kubernetes on a local Docker Daemon using `konk`"
    ```bash
    curl -sL install.konk.dev | bash
    ```

??? bug "Having issues with Kind?"
    We've found that some users (specifically Linux) may have trouble with Docker and, subsequently, Kind. Though this tutorial assumes you have KonK installed, you can easily follow along with a different installation.

    We have provide an alternative Quickstart on `minikube` here: [https://github.com/csantanapr/knative-minikube](https://github.com/csantanapr/knative-minikube){_target="_blank"}

Installing `konk` may take a few minutes. After the script is finished, check to make sure you have a Cluster called `knative`
!!! success "Verify Installation"
    ```bash
    kind get clusters
    ```
