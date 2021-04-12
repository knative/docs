# Installing Knative


## Installing Knative with KonK (Knative on Kind)
**The fastest way to get started with Knative locally** is to use the <a href= "https://konk.dev" target="blank_">Konk (Knative-on-kind) script.</a>

This script installs a local Knative deployment on your local machine's `Docker` daemon using [Kind](https://kind.sigs.k8s.io/).

### Prerequisites
- You will need to have [Docker installed.](https://docs.docker.com/get-docker/)
- You will need to have [Kind installed.](https://kind.sigs.k8s.io/docs/user/quick-start/)

!!! success "Install Knative and Kubernetes on a local Docker Daemon using Konk"
    ```
    curl -sL install.konk.dev | bash
    ```

!!! warning
    If you decide to use an installation method other than KonK, you will need DNS configured on Knative Serving and a broker installed for Knative Eventing to successfully complete the "Getting Started" tutorial.

## Other Installation Options
  - If you would like to customize the Knative installation or install it on a remote cluster, start by [Checking the Pre-Requisites](../install/prerequisites.md).
